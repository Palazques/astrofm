"""
App Spotify Service - Manages Astro.FM's own Spotify account.

This service handles authentication and API calls using the app's
dedicated Spotify account (astrofm.official@gmail.com), allowing
playlist creation without requiring users to connect their own Spotify.

S2: Documentation Rule - Clear docstrings for all methods.
"""
import os
import time
import base64
import hashlib
import secrets
from typing import Optional, List, Dict, Any
import httpx

# Spotify API endpoints
SPOTIFY_AUTH_URL = "https://accounts.spotify.com/authorize"
SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token"
SPOTIFY_API_BASE = "https://api.spotify.com/v1"

# Required scopes for playlist creation
SPOTIFY_SCOPES = [
    "playlist-modify-public",
    "playlist-modify-private",
    "user-read-private",
]


class AppSpotifyService:
    """
    Manages Astro.FM's own Spotify account for playlist creation.
    
    Uses OAuth refresh token for persistent authentication.
    No user interaction required after initial setup.
    """
    
    _instance: Optional["AppSpotifyService"] = None
    
    def __init__(self):
        self.client_id = os.getenv("SPOTIFY_CLIENT_ID", "")
        self.client_secret = os.getenv("SPOTIFY_CLIENT_SECRET", "")
        self.refresh_token = os.getenv("ASTROFM_SPOTIFY_REFRESH_TOKEN", "")
        self.redirect_uri = "http://127.0.0.1:8000/api/cosmic/app-callback"
        
        self._access_token: Optional[str] = None
        self._token_expires: float = 0
        self._user_id: Optional[str] = None
        
        # State for OAuth flow
        self._pending_states: Dict[str, float] = {}
    
    @property
    def is_configured(self) -> bool:
        """Check if Spotify credentials are configured."""
        return bool(self.client_id and self.client_secret)
    
    @property
    def is_ready(self) -> bool:
        """Check if app account is ready (has refresh token)."""
        return bool(self.refresh_token)
    
    # =========================================================================
    # OAuth Flow (One-time setup)
    # =========================================================================
    
    def get_auth_url(self) -> Dict[str, str]:
        """
        Generate OAuth URL for one-time app account authorization.
        
        Returns:
            Dict with 'url' and 'state' for CSRF protection
        """
        state = secrets.token_urlsafe(32)
        self._pending_states[state] = time.time()
        
        # Clean up old states (older than 10 minutes)
        current = time.time()
        self._pending_states = {
            s: t for s, t in self._pending_states.items()
            if current - t < 600
        }
        
        params = {
            "client_id": self.client_id,
            "response_type": "code",
            "redirect_uri": self.redirect_uri,
            "state": state,
            "scope": " ".join(SPOTIFY_SCOPES),
            "show_dialog": "true",
        }
        
        query = "&".join(f"{k}={v}" for k, v in params.items())
        url = f"{SPOTIFY_AUTH_URL}?{query}"
        
        return {"url": url, "state": state}
    
    def validate_state(self, state: str) -> bool:
        """Validate OAuth state parameter."""
        if state in self._pending_states:
            del self._pending_states[state]
            return True
        return False
    
    async def exchange_code_for_tokens(self, code: str) -> Dict[str, str]:
        """
        Exchange authorization code for access and refresh tokens.
        
        Args:
            code: Authorization code from Spotify callback
            
        Returns:
            Dict with 'access_token' and 'refresh_token'
        """
        auth_header = base64.b64encode(
            f"{self.client_id}:{self.client_secret}".encode()
        ).decode()
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                SPOTIFY_TOKEN_URL,
                headers={
                    "Authorization": f"Basic {auth_header}",
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                data={
                    "grant_type": "authorization_code",
                    "code": code,
                    "redirect_uri": self.redirect_uri,
                },
            )
            
            if response.status_code != 200:
                raise ValueError(f"Token exchange failed: {response.text}")
            
            data = response.json()
            
            # Store tokens
            self._access_token = data["access_token"]
            self._token_expires = time.time() + data.get("expires_in", 3600)
            
            return {
                "access_token": data["access_token"],
                "refresh_token": data["refresh_token"],
            }
    
    # =========================================================================
    # Token Management
    # =========================================================================
    
    async def get_access_token(self) -> str:
        """
        Get valid access token, refreshing if expired.
        
        Returns:
            Valid Spotify access token
            
        Raises:
            ValueError: If no refresh token is configured
        """
        if not self.refresh_token:
            raise ValueError(
                "No refresh token configured. Run one-time OAuth setup first."
            )
        
        # Return cached token if still valid (with 60s buffer)
        if self._access_token and time.time() < self._token_expires - 60:
            return self._access_token
        
        # Refresh the token
        auth_header = base64.b64encode(
            f"{self.client_id}:{self.client_secret}".encode()
        ).decode()
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                SPOTIFY_TOKEN_URL,
                headers={
                    "Authorization": f"Basic {auth_header}",
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                data={
                    "grant_type": "refresh_token",
                    "refresh_token": self.refresh_token,
                },
            )
            
            if response.status_code != 200:
                raise ValueError(f"Token refresh failed: {response.text}")
            
            data = response.json()
            self._access_token = data["access_token"]
            self._token_expires = time.time() + data.get("expires_in", 3600)
            
            return self._access_token
    
    # =========================================================================
    # Spotify API Methods
    # =========================================================================
    
    async def get_user_id(self) -> str:
        """Get the app account's Spotify user ID."""
        if self._user_id:
            return self._user_id
        
        token = await self.get_access_token()
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(
                f"{SPOTIFY_API_BASE}/me",
                headers={"Authorization": f"Bearer {token}"},
            )
            
            if response.status_code != 200:
                raise ValueError(f"Failed to get user info: {response.text}")
            
            self._user_id = response.json()["id"]
            return self._user_id
    
    async def search_track(
        self, 
        query: str, 
        limit: int = 1
    ) -> Optional[Dict[str, Any]]:
        """
        Search for a track on Spotify.
        
        Args:
            query: Search query (e.g., 'track:"Bohemian Rhapsody" artist:"Queen"')
            limit: Maximum results to return
            
        Returns:
            First matching track or None
        """
        token = await self.get_access_token()
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(
                f"{SPOTIFY_API_BASE}/search",
                headers={"Authorization": f"Bearer {token}"},
                params={
                    "q": query,
                    "type": "track",
                    "limit": limit,
                    "market": "US",
                },
            )
            
            if response.status_code != 200:
                return None
            
            items = response.json().get("tracks", {}).get("items", [])
            return items[0] if items else None
    
    async def create_playlist(
        self,
        name: str,
        description: str,
        track_uris: List[str],
        public: bool = True,
    ) -> Dict[str, str]:
        """
        Create a playlist on the app's Spotify account.
        
        Args:
            name: Playlist name
            description: Playlist description
            track_uris: List of Spotify track URIs
            public: Whether playlist is public
            
        Returns:
            Dict with 'id', 'url', and 'uri'
        """
        token = await self.get_access_token()
        user_id = await self.get_user_id()
        
        print(f"[AppSpotify] Creating playlist: {name}")
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Create empty playlist
            response = await client.post(
                f"{SPOTIFY_API_BASE}/users/{user_id}/playlists",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json",
                },
                json={
                    "name": name,
                    "description": description,
                    "public": public,
                },
            )
            
            if response.status_code not in (200, 201):
                raise ValueError(f"Failed to create playlist: {response.text}")
            
            playlist = response.json()
            playlist_id = playlist["id"]
            
            # Add tracks (max 100 per request)
            for i in range(0, len(track_uris), 100):
                batch = track_uris[i:i + 100]
                await client.post(
                    f"{SPOTIFY_API_BASE}/playlists/{playlist_id}/tracks",
                    headers={
                        "Authorization": f"Bearer {token}",
                        "Content-Type": "application/json",
                    },
                    json={"uris": batch},
                )
            
            return {
                "id": playlist_id,
                "url": playlist["external_urls"]["spotify"],
                "uri": playlist["uri"],
            }


# Singleton instance
_app_spotify_instance: Optional[AppSpotifyService] = None


def get_app_spotify_service() -> AppSpotifyService:
    """Get singleton instance of AppSpotifyService."""
    global _app_spotify_instance
    if _app_spotify_instance is None:
        _app_spotify_instance = AppSpotifyService()
    return _app_spotify_instance
