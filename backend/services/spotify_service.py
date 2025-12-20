"""
Spotify Web API integration service for Astro.FM.

Handles OAuth authentication and playlist creation.

S2: Documentation Rule - All functions include clear docstrings.
C3: Least Privilege - API keys loaded via environment variables.
"""
import os
from typing import Optional, Dict, List, Any
from dataclasses import dataclass
from urllib.parse import urlencode
import base64
import hashlib
import secrets
import httpx

# Spotify API endpoints
SPOTIFY_AUTH_URL = "https://accounts.spotify.com/authorize"
SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token"
SPOTIFY_API_BASE = "https://api.spotify.com/v1"

# Required scopes for playlist creation and library access
SPOTIFY_SCOPES = [
    "playlist-modify-public",
    "playlist-modify-private",
    "user-read-private",
    "user-read-email",
    "user-library-read",  # Access user's saved tracks
]


@dataclass
class SpotifyTokens:
    """Container for Spotify OAuth tokens."""
    access_token: str
    refresh_token: str
    expires_in: int
    token_type: str = "Bearer"


@dataclass
class SpotifyUser:
    """Spotify user profile information."""
    id: str
    display_name: Optional[str]
    email: Optional[str]
    product: Optional[str]  # "premium", "free", etc.


@dataclass
class SpotifyTrack:
    """Spotify track information."""
    id: str
    name: str
    artists: List[str]
    uri: str
    external_url: str
    preview_url: Optional[str]
    duration_ms: int
    # Audio features (optional, added when fetched)
    energy: Optional[float] = None
    valence: Optional[float] = None  # happiness/positivity
    tempo: Optional[float] = None
    danceability: Optional[float] = None


class SpotifyService:
    """
    Service for interacting with Spotify Web API.
    
    Handles OAuth 2.0 Authorization Code Flow with PKCE and
    playlist operations.
    """
    
    def __init__(self):
        """Initialize with credentials from environment variables."""
        self.client_id = os.getenv("SPOTIFY_CLIENT_ID")
        self.client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")
        self.redirect_uri = os.getenv(
            "SPOTIFY_REDIRECT_URI", 
            "http://127.0.0.1:8000/api/spotify/callback"
        )
        
        # In-memory token storage (replace with database in production)
        # Key: state, Value: (tokens, user_id)
        self._token_store: Dict[str, SpotifyTokens] = {}
        self._user_store: Dict[str, SpotifyUser] = {}
        
        # PKCE verifier storage (temporary, during auth flow)
        self._verifier_store: Dict[str, str] = {}
    
    @property
    def is_configured(self) -> bool:
        """Check if Spotify credentials are configured."""
        return bool(self.client_id and self.client_secret)
    
    def _generate_pkce_pair(self) -> tuple[str, str]:
        """
        Generate PKCE code verifier and challenge.
        
        Returns:
            Tuple of (code_verifier, code_challenge)
        """
        # Generate random verifier (43-128 characters)
        code_verifier = secrets.token_urlsafe(64)
        
        # Create SHA256 hash and base64url encode
        digest = hashlib.sha256(code_verifier.encode()).digest()
        code_challenge = base64.urlsafe_b64encode(digest).decode().rstrip("=")
        
        return code_verifier, code_challenge
    
    def get_auth_url(self, state: Optional[str] = None) -> Dict[str, str]:
        """
        Generate Spotify OAuth authorization URL.
        
        Args:
            state: Optional state parameter for CSRF protection
            
        Returns:
            Dict with 'url' and 'state' keys
        """
        if not self.is_configured:
            raise ValueError("Spotify credentials not configured")
        
        # Generate state if not provided
        if not state:
            state = secrets.token_urlsafe(32)
        
        # Generate PKCE pair
        code_verifier, code_challenge = self._generate_pkce_pair()
        
        # Store verifier for later token exchange
        self._verifier_store[state] = code_verifier
        
        params = {
            "client_id": self.client_id,
            "response_type": "code",
            "redirect_uri": self.redirect_uri,
            "state": state,
            "scope": " ".join(SPOTIFY_SCOPES),
            "code_challenge_method": "S256",
            "code_challenge": code_challenge,
        }
        
        auth_url = f"{SPOTIFY_AUTH_URL}?{urlencode(params)}"
        
        return {"url": auth_url, "state": state}
    
    async def exchange_code_for_tokens(
        self, 
        code: str, 
        state: str
    ) -> SpotifyTokens:
        """
        Exchange authorization code for access tokens.
        
        Args:
            code: Authorization code from Spotify callback
            state: State parameter to retrieve PKCE verifier
            
        Returns:
            SpotifyTokens with access and refresh tokens
        """
        # Retrieve PKCE verifier
        code_verifier = self._verifier_store.pop(state, None)
        if not code_verifier:
            raise ValueError("Invalid state - PKCE verifier not found")
        
        data = {
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": self.redirect_uri,
            "client_id": self.client_id,
            "code_verifier": code_verifier,
        }
        
        # Add client secret for confidential clients
        auth_header = base64.b64encode(
            f"{self.client_id}:{self.client_secret}".encode()
        ).decode()
        
        headers = {
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/x-www-form-urlencoded",
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                SPOTIFY_TOKEN_URL, 
                data=data, 
                headers=headers
            )
            response.raise_for_status()
            token_data = response.json()
        
        tokens = SpotifyTokens(
            access_token=token_data["access_token"],
            refresh_token=token_data["refresh_token"],
            expires_in=token_data["expires_in"],
            token_type=token_data.get("token_type", "Bearer"),
        )
        
        # Store tokens (keyed by state for now - replace with user session)
        self._token_store[state] = tokens
        
        # Fetch and store user info
        user = await self.get_current_user(tokens.access_token)
        self._user_store[state] = user
        
        return tokens
    
    async def refresh_access_token(self, refresh_token: str) -> SpotifyTokens:
        """
        Refresh an expired access token.
        
        Args:
            refresh_token: The refresh token from initial auth
            
        Returns:
            New SpotifyTokens with fresh access token
        """
        auth_header = base64.b64encode(
            f"{self.client_id}:{self.client_secret}".encode()
        ).decode()
        
        data = {
            "grant_type": "refresh_token",
            "refresh_token": refresh_token,
        }
        
        headers = {
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/x-www-form-urlencoded",
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                SPOTIFY_TOKEN_URL, 
                data=data, 
                headers=headers
            )
            response.raise_for_status()
            token_data = response.json()
        
        return SpotifyTokens(
            access_token=token_data["access_token"],
            refresh_token=token_data.get("refresh_token", refresh_token),
            expires_in=token_data["expires_in"],
            token_type=token_data.get("token_type", "Bearer"),
        )
    
    async def get_current_user(self, access_token: str) -> SpotifyUser:
        """
        Get the current user's Spotify profile.
        
        Args:
            access_token: Valid Spotify access token
            
        Returns:
            SpotifyUser with profile information
        """
        headers = {"Authorization": f"Bearer {access_token}"}
        
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{SPOTIFY_API_BASE}/me", 
                headers=headers
            )
            response.raise_for_status()
            data = response.json()
        
        return SpotifyUser(
            id=data["id"],
            display_name=data.get("display_name"),
            email=data.get("email"),
            product=data.get("product"),
        )
    
    async def search_track(
        self, 
        access_token: str,
        query: str,
        artist: Optional[str] = None,
        limit: int = 1
    ) -> List[SpotifyTrack]:
        """
        Search for tracks on Spotify.
        
        Args:
            access_token: Valid Spotify access token
            query: Track name to search for
            artist: Optional artist name to refine search
            limit: Number of results to return
            
        Returns:
            List of matching SpotifyTrack objects
        """
        search_query = query
        if artist:
            search_query = f"track:{query} artist:{artist}"
        
        params = {
            "q": search_query,
            "type": "track",
            "limit": limit,
        }
        
        headers = {"Authorization": f"Bearer {access_token}"}
        
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{SPOTIFY_API_BASE}/search",
                params=params,
                headers=headers
            )
            response.raise_for_status()
            data = response.json()
        
        tracks = []
        for item in data.get("tracks", {}).get("items", []):
            tracks.append(SpotifyTrack(
                id=item["id"],
                name=item["name"],
                artists=[a["name"] for a in item["artists"]],
                uri=item["uri"],
                external_url=item["external_urls"]["spotify"],
                preview_url=item.get("preview_url"),
                duration_ms=item["duration_ms"],
            ))
        
        return tracks
    
    async def create_playlist(
        self,
        access_token: str,
        user_id: str,
        name: str,
        description: str = "",
        public: bool = True,
        track_uris: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Create a new Spotify playlist and optionally add tracks.
        
        Args:
            access_token: Valid Spotify access token
            user_id: Spotify user ID to create playlist for
            name: Playlist name
            description: Optional playlist description
            public: Whether playlist should be public
            track_uris: Optional list of Spotify track URIs to add
            
        Returns:
            Dict with playlist 'id', 'url', and 'uri'
        """
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
        }
        
        # Create playlist
        create_data = {
            "name": name,
            "description": description,
            "public": public,
        }
        
        async with httpx.AsyncClient() as client:
            # Create the playlist
            response = await client.post(
                f"{SPOTIFY_API_BASE}/users/{user_id}/playlists",
                json=create_data,
                headers=headers
            )
            response.raise_for_status()
            playlist_data = response.json()
            
            playlist_id = playlist_data["id"]
            
            # Add tracks if provided
            if track_uris:
                # Spotify allows max 100 tracks per request
                for i in range(0, len(track_uris), 100):
                    batch = track_uris[i:i+100]
                    await client.post(
                        f"{SPOTIFY_API_BASE}/playlists/{playlist_id}/tracks",
                        json={"uris": batch},
                        headers=headers
                    )
        
        return {
            "id": playlist_id,
            "url": playlist_data["external_urls"]["spotify"],
            "uri": playlist_data["uri"],
            "name": playlist_data["name"],
        }
    
    async def get_user_saved_tracks(
        self,
        access_token: str,
        limit: int = 50,
        offset: int = 0,
        max_tracks: int = 500
    ) -> List[SpotifyTrack]:
        """
        Fetch user's saved tracks from their library.
        
        Args:
            access_token: Valid Spotify access token
            limit: Tracks per request (max 50)
            offset: Starting offset
            max_tracks: Maximum total tracks to fetch
            
        Returns:
            List of SpotifyTrack from user's library
        """
        headers = {"Authorization": f"Bearer {access_token}"}
        all_tracks = []
        
        async with httpx.AsyncClient() as client:
            while len(all_tracks) < max_tracks:
                params = {"limit": min(limit, 50), "offset": offset}
                response = await client.get(
                    f"{SPOTIFY_API_BASE}/me/tracks",
                    params=params,
                    headers=headers
                )
                response.raise_for_status()
                data = response.json()
                
                items = data.get("items", [])
                if not items:
                    break
                
                for item in items:
                    track = item.get("track")
                    if track:
                        all_tracks.append(SpotifyTrack(
                            id=track["id"],
                            name=track["name"],
                            artists=[a["name"] for a in track["artists"]],
                            uri=track["uri"],
                            external_url=track["external_urls"]["spotify"],
                            preview_url=track.get("preview_url"),
                            duration_ms=track["duration_ms"],
                        ))
                
                offset += len(items)
                if not data.get("next"):
                    break
        
        return all_tracks[:max_tracks]
    
    async def get_audio_features(
        self,
        access_token: str,
        track_ids: List[str],
        track_info: Optional[List[Dict[str, str]]] = None
    ) -> Dict[str, Dict[str, float]]:
        """
        Get audio features for multiple tracks using RapidAPI.
        
        NOTE: The original Spotify /audio-features endpoint is no longer
        available for new applications. This method now uses RapidAPI's
        Track Analysis service with aggressive caching.
        
        Args:
            access_token: Valid Spotify access token (kept for API compatibility)
            track_ids: List of Spotify track IDs
            track_info: Optional list of {name, artist} dicts for fallback queries
            
        Returns:
            Dict mapping track_id to audio features
        """
        from services.audio_features_service import get_audio_features_service
        from models.audio_features import TrackInfo
        
        audio_service = get_audio_features_service()
        features_map = {}
        
        if not audio_service.is_configured:
            # Return defaults for all tracks if RapidAPI not configured
            print("SpotifyService: RapidAPI not configured, using defaults")
            for track_id in track_ids:
                features_map[track_id] = {
                    "energy": 0.5,
                    "valence": 0.5,
                    "tempo": 120.0,
                    "danceability": 0.5,
                }
            return features_map
        
        # Build TrackInfo list if we have track info
        tracks_to_fetch = []
        for i, track_id in enumerate(track_ids):
            if track_info and i < len(track_info):
                info = track_info[i]
                tracks_to_fetch.append(TrackInfo(
                    track_id=track_id,
                    name=info.get("name", ""),
                    artist=info.get("artist", "")
                ))
            else:
                # No name/artist info, will use Spotify ID endpoint only
                tracks_to_fetch.append(TrackInfo(
                    track_id=track_id,
                    name="",
                    artist=""
                ))
        
        # Fetch features (uses caching internally)
        results = await audio_service.get_batch_features(tracks_to_fetch)
        
        # Convert to legacy format for backward compatibility
        for track_id, features in results.items():
            features_map[track_id] = {
                "energy": features.energy,
                "valence": features.valence,
                "tempo": features.tempo,
                "danceability": features.danceability,
            }
        
        return features_map
    
    async def get_saved_tracks_with_features(
        self,
        access_token: str,
        max_tracks: int = 200
    ) -> List[SpotifyTrack]:
        """
        Fetch user's saved tracks with their audio features.
        
        Args:
            access_token: Valid Spotify access token
            max_tracks: Maximum tracks to fetch
            
        Returns:
            List of SpotifyTrack with audio features populated
        """
        # Get saved tracks
        tracks = await self.get_user_saved_tracks(
            access_token, max_tracks=max_tracks
        )
        
        if not tracks:
            return []
        
        # Get audio features for all tracks
        track_ids = [t.id for t in tracks]
        features = await self.get_audio_features(access_token, track_ids)
        
        # Add features to tracks
        for track in tracks:
            if track.id in features:
                f = features[track.id]
                track.energy = f["energy"]
                track.valence = f["valence"]
                track.tempo = f["tempo"]
                track.danceability = f["danceability"]
        
        return tracks
    
    def get_stored_tokens(self, state: str) -> Optional[SpotifyTokens]:
        """Get stored tokens for a state/session."""
        return self._token_store.get(state)
    
    def get_stored_user(self, state: str) -> Optional[SpotifyUser]:
        """Get stored user for a state/session."""
        return self._user_store.get(state)
    
    def store_tokens(self, session_id: str, tokens: SpotifyTokens) -> None:
        """Store tokens for a session."""
        self._token_store[session_id] = tokens
    
    def store_user(self, session_id: str, user: SpotifyUser) -> None:
        """Store user for a session."""
        self._user_store[session_id] = user


# Singleton instance
_spotify_service: Optional[SpotifyService] = None


def get_spotify_service() -> SpotifyService:
    """Get or create the Spotify service singleton."""
    global _spotify_service
    if _spotify_service is None:
        _spotify_service = SpotifyService()
    return _spotify_service
