"""
Spotify API routes for Astro.FM.

Handles OAuth callbacks, playlist creation, and connection status.

S2: Documentation Rule - All endpoints include clear docstrings.
"""
from typing import Optional, List
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import RedirectResponse, HTMLResponse
from pydantic import BaseModel

from services.spotify_service import get_spotify_service, SpotifyTokens


router = APIRouter(prefix="/api/spotify", tags=["spotify"])


# =============================================================================
# Request/Response Models
# =============================================================================

class AuthUrlResponse(BaseModel):
    """Response for auth URL endpoint."""
    url: str
    state: str


class ConnectionStatus(BaseModel):
    """Spotify connection status."""
    connected: bool
    user_id: Optional[str] = None
    display_name: Optional[str] = None
    product: Optional[str] = None


class CreatePlaylistRequest(BaseModel):
    """Request to create a Spotify playlist."""
    session_id: str
    name: str
    description: Optional[str] = "Created by Astro.FM 🌟"
    songs: List[dict]  # List of {title, artist} dicts from our playlist


class PlaylistCreatedResponse(BaseModel):
    """Response after creating a playlist."""
    success: bool
    playlist_id: Optional[str] = None
    playlist_url: Optional[str] = None
    playlist_uri: Optional[str] = None
    tracks_added: int = 0
    tracks_not_found: List[str] = []


class GenerateFromLibraryRequest(BaseModel):
    """Request to generate playlist from user's library."""
    session_id: str
    name: str
    description: Optional[str] = "Cosmic playlist from your library by Astro.FM 🌟"
    energy_target: float = 0.5  # 0-1 scale
    mood_target: float = 0.5    # 0-1 (valence: sad to happy)
    tempo_min: int = 80
    tempo_max: int = 160
    playlist_size: int = 20


class LibraryTrack(BaseModel):
    """Track from user's library with audio features."""
    id: str
    name: str
    artists: List[str]
    uri: str
    url: str
    energy: Optional[float] = None
    valence: Optional[float] = None
    tempo: Optional[float] = None


class LibraryPlaylistResponse(BaseModel):
    """Response for generate-from-library with track details."""
    success: bool
    playlist_id: Optional[str] = None
    playlist_url: Optional[str] = None
    playlist_uri: Optional[str] = None
    tracks_added: int = 0
    tracks_not_found: List[str] = []
    # Include track details for display
    tracks: List[LibraryTrack] = []
    avg_energy: Optional[float] = None
    avg_valence: Optional[float] = None

# =============================================================================
# OAuth Endpoints
# =============================================================================

@router.get("/auth-url", response_model=AuthUrlResponse)
async def get_auth_url():
    """
    Get Spotify OAuth authorization URL.
    
    Returns:
        AuthUrlResponse with URL to redirect user to and state for session tracking
    """
    spotify = get_spotify_service()
    
    if not spotify.is_configured:
        raise HTTPException(
            status_code=503,
            detail="Spotify integration is not configured. Please add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET to .env"
        )
    
    try:
        auth_data = spotify.get_auth_url()
        return AuthUrlResponse(url=auth_data["url"], state=auth_data["state"])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/callback")
async def spotify_callback(
    code: Optional[str] = Query(None),
    state: Optional[str] = Query(None),
    error: Optional[str] = Query(None)
):
    """
    OAuth callback endpoint. Spotify redirects here after user authorization.
    
    Args:
        code: Authorization code from Spotify
        state: State parameter for CSRF protection
        error: Error message if authorization failed
        
    Returns:
        HTML page with success/error message that can communicate with Flutter
    """
    if error:
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html>
        <head><title>Spotify Connection Failed</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>❌ Connection Failed</h1>
            <p>Error: {error}</p>
            <p>You can close this window and try again.</p>
            <script>
                // For Flutter web - post message to parent
                if (window.opener) {{
                    window.opener.postMessage({{type: 'spotify_auth', success: false, error: '{error}'}}, '*');
                }}
            </script>
        </body>
        </html>
        """, status_code=400)
    
    if not code or not state:
        return HTMLResponse(content="""
        <!DOCTYPE html>
        <html>
        <head><title>Invalid Request</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>❌ Invalid Request</h1>
            <p>Missing authorization code or state parameter.</p>
        </body>
        </html>
        """, status_code=400)
    
    spotify = get_spotify_service()
    
    try:
        # Exchange code for tokens
        tokens = await spotify.exchange_code_for_tokens(code, state)
        user = spotify.get_stored_user(state)
        
        # Return success page
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html>
        <head><title>Spotify Connected!</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>✅ Connected to Spotify!</h1>
            <p>Welcome, {user.display_name if user else 'User'}!</p>
            <p>Your session ID: <code style="background: #333; padding: 4px 8px; border-radius: 4px;">{state}</code></p>
            <p style="color: #888;">Save this ID to use with the app. You can close this window.</p>
            <script>
                // For Flutter web - post message to parent
                if (window.opener) {{
                    window.opener.postMessage({{
                        type: 'spotify_auth', 
                        success: true, 
                        sessionId: '{state}',
                        userName: '{user.display_name if user else ""}'
                    }}, '*');
                    setTimeout(() => window.close(), 3000);
                }}
            </script>
        </body>
        </html>
        """)
    
    except ValueError as e:
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html>
        <head><title>Connection Error</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>❌ Connection Error</h1>
            <p>{str(e)}</p>
            <p>Please try connecting again.</p>
        </body>
        </html>
        """, status_code=400)
    
    except Exception as e:
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html>
        <head><title>Server Error</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>❌ Server Error</h1>
            <p>Something went wrong. Please try again later.</p>
            <p style="color: #666; font-size: 12px;">{str(e)}</p>
        </body>
        </html>
        """, status_code=500)


# =============================================================================
# Status & Connection Endpoints
# =============================================================================

@router.get("/status", response_model=ConnectionStatus)
async def get_connection_status(session_id: Optional[str] = Query(None)):
    """
    Check if user is connected to Spotify.
    
    Args:
        session_id: Session ID from OAuth callback
        
    Returns:
        ConnectionStatus with connection state and user info
    """
    spotify = get_spotify_service()
    
    if not spotify.is_configured:
        return ConnectionStatus(connected=False)
    
    if not session_id:
        return ConnectionStatus(connected=False)
    
    tokens = spotify.get_stored_tokens(session_id)
    user = spotify.get_stored_user(session_id)
    
    if tokens and user:
        return ConnectionStatus(
            connected=True,
            user_id=user.id,
            display_name=user.display_name,
            product=user.product
        )
    
    return ConnectionStatus(connected=False)


# =============================================================================
# Playlist Creation Endpoints
# =============================================================================

@router.post("/create-playlist", response_model=PlaylistCreatedResponse)
async def create_spotify_playlist(request: CreatePlaylistRequest):
    """
    Create a Spotify playlist from Astro.FM generated songs.
    
    Searches Spotify for matching tracks and creates a playlist.
    
    Args:
        request: Playlist creation request with session_id, name, and songs
        
    Returns:
        PlaylistCreatedResponse with playlist URL and track matching results
    """
    spotify = get_spotify_service()
    
    # Validate session
    tokens = spotify.get_stored_tokens(request.session_id)
    user = spotify.get_stored_user(request.session_id)
    
    if not tokens or not user:
        raise HTTPException(
            status_code=401,
            detail="Not connected to Spotify. Please connect first."
        )
    
    # Try to refresh token if it might be expired
    # (In production, track expiry time and refresh proactively)
    try:
        # Search for each song and collect URIs
        track_uris = []
        not_found = []
        
        for song in request.songs:
            title = song.get("title", "")
            artist = song.get("artist", "")
            
            if not title:
                continue
            
            # Search Spotify for the track
            results = await spotify.search_track(
                access_token=tokens.access_token,
                query=title,
                artist=artist,
                limit=1
            )
            
            if results:
                track_uris.append(results[0].uri)
            else:
                not_found.append(f"{title} - {artist}")
        
        if not track_uris:
            raise HTTPException(
                status_code=404,
                detail="Could not find any matching tracks on Spotify"
            )
        
        # Create the playlist
        playlist = await spotify.create_playlist(
            access_token=tokens.access_token,
            user_id=user.id,
            name=request.name,
            description=request.description or "Created by Astro.FM 🌟",
            public=True,
            track_uris=track_uris
        )
        
        return PlaylistCreatedResponse(
            success=True,
            playlist_id=playlist["id"],
            playlist_url=playlist["url"],
            playlist_uri=playlist["uri"],
            tracks_added=len(track_uris),
            tracks_not_found=not_found
        )
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error creating playlist: {str(e)}"
        )


@router.post("/generate-from-library", response_model=LibraryPlaylistResponse)
async def generate_playlist_from_library(request: GenerateFromLibraryRequest):
    """
    Generate a cosmic playlist from user's saved Spotify tracks.
    
    Fetches user's library, gets audio features via RapidAPI,
    filters by cosmic energy/mood parameters, and creates a playlist
    with the best matching tracks.
    
    Args:
        request: Generation request with session_id, cosmic params, and playlist size
        
    Returns:
        PlaylistCreatedResponse with playlist URL
    """
    from services.audio_features_service import get_audio_features_service
    from models.audio_features import TrackInfo
    
    spotify = get_spotify_service()
    audio_service = get_audio_features_service()
    
    # Validate session
    tokens = spotify.get_stored_tokens(request.session_id)
    user = spotify.get_stored_user(request.session_id)
    
    if not tokens or not user:
        raise HTTPException(
            status_code=401,
            detail="Not connected to Spotify. Please connect first."
        )
    
    try:
        # Fetch user's saved tracks
        tracks = await spotify.get_user_saved_tracks(
            access_token=tokens.access_token,
            max_tracks=100  # Get recent 100 tracks
        )
        
        if not tracks:
            raise HTTPException(
                status_code=404,
                detail="No saved tracks found in your Spotify library"
            )
        
        # Build TrackInfo list for audio features lookup
        track_infos = [
            TrackInfo(
                track_id=t.id,
                name=t.name,
                artist=t.artists[0] if t.artists else ""
            )
            for t in tracks
        ]
        
        # Get audio features for all tracks (uses caching)
        print(f"Fetching audio features for {len(track_infos)} tracks...")
        features_map = await audio_service.get_batch_features(track_infos)
        
        # Score tracks based on how well they match targets
        scored_tracks = []
        for track in tracks:
            features = features_map.get(track.id)
            if features:
                # Calculate distance from target (lower = better match)
                energy_diff = abs(features.energy - request.energy_target)
                mood_diff = abs(features.valence - request.mood_target)
                tempo_ok = request.tempo_min <= features.tempo <= request.tempo_max
                
                # Combined score (lower = better)
                score = energy_diff + mood_diff
                if not tempo_ok:
                    score += 0.5  # Penalty for tempo mismatch
                
                scored_tracks.append({
                    "track": track,
                    "features": features,
                    "score": score
                })
        
        # Sort by score (best matches first) and take top N
        scored_tracks.sort(key=lambda x: x["score"])
        selected = scored_tracks[:request.playlist_size]
        
        if not selected:
            # Fallback to random if no tracks matched
            import random
            shuffled = list(tracks)
            random.shuffle(shuffled)
            selected = [{"track": t, "features": None, "score": 0} for t in shuffled[:request.playlist_size]]
        
        if not selected:
            raise HTTPException(
                status_code=404,
                detail="No tracks available for playlist"
            )
        
        # Create playlist with selected tracks
        track_uris = [s["track"].uri for s in selected]
        
        # Log what we're creating
        avg_energy = sum(s["features"].energy for s in selected if s["features"]) / len(selected) if selected else 0
        avg_valence = sum(s["features"].valence for s in selected if s["features"]) / len(selected) if selected else 0
        print(f"Creating playlist: {len(selected)} tracks, avg energy={avg_energy:.2f}, avg valence={avg_valence:.2f}")
        
        playlist = await spotify.create_playlist(
            access_token=tokens.access_token,
            user_id=user.id,
            name=request.name,
            description=request.description or f"Cosmic playlist from your library by Astro.FM 🌟 (Energy: {avg_energy:.0%}, Mood: {avg_valence:.0%})",
            public=True,
            track_uris=track_uris
        )
        
        # Build track list for response
        response_tracks = [
            LibraryTrack(
                id=s["track"].id,
                name=s["track"].name,
                artists=s["track"].artists,
                uri=s["track"].uri,
                url=s["track"].external_url,
                energy=s["features"].energy if s["features"] else None,
                valence=s["features"].valence if s["features"] else None,
                tempo=s["features"].tempo if s["features"] else None,
            )
            for s in selected
        ]
        
        return LibraryPlaylistResponse(
            success=True,
            playlist_id=playlist["id"],
            playlist_url=playlist["url"],
            playlist_uri=playlist["uri"],
            tracks_added=len(track_uris),
            tracks_not_found=[],
            tracks=response_tracks,
            avg_energy=avg_energy,
            avg_valence=avg_valence
        )
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error generating playlist from library: {str(e)}"
        )


# =============================================================================
# Audio Features Endpoints (via RapidAPI)
# =============================================================================

class AudioFeaturesResponse(BaseModel):
    """Response for audio features endpoint."""
    track_id: str
    energy: float
    valence: float
    tempo: float
    danceability: float
    key: Optional[str] = None
    mode: Optional[str] = None
    cached: bool = False


class AudioFeaturesQueryRequest(BaseModel):
    """Request for audio features by song name and artist."""
    song: str
    artist: str


class BatchAudioFeaturesRequest(BaseModel):
    """Request for batch audio features."""
    tracks: List[dict]  # List of {track_id, name, artist}


class CacheStatsResponse(BaseModel):
    """Response for cache statistics."""
    cached_tracks: int
    api_configured: bool


@router.get("/audio-features/{track_id}", response_model=AudioFeaturesResponse)
async def get_audio_features_by_id(track_id: str):
    """
    Get audio features for a track by Spotify ID.
    
    Uses RapidAPI Track Analysis service with caching.
    
    Args:
        track_id: Spotify track ID
        
    Returns:
        AudioFeaturesResponse with energy, valence, tempo, danceability
    """
    from services.audio_features_service import get_audio_features_service
    
    service = get_audio_features_service()
    
    if not service.is_configured:
        raise HTTPException(
            status_code=503,
            detail="Audio features service is not configured. Please add RAPIDAPI_KEY to .env"
        )
    
    # Check if it's cached
    cached = service.cache.get(track_id)
    
    features = await service.get_by_spotify_id(track_id)
    
    if features is None:
        raise HTTPException(
            status_code=404,
            detail=f"Could not fetch audio features for track: {track_id}"
        )
    
    return AudioFeaturesResponse(
        track_id=features.track_id,
        energy=features.energy,
        valence=features.valence,
        tempo=features.tempo,
        danceability=features.danceability,
        key=features.key,
        mode=features.mode,
        cached=(cached is not None)
    )


@router.post("/audio-features/query", response_model=AudioFeaturesResponse)
async def get_audio_features_by_query(request: AudioFeaturesQueryRequest):
    """
    Get audio features by searching for song name and artist.
    
    Slower than getting by Spotify ID but works without Spotify integration.
    
    Args:
        request: Song name and artist name
        
    Returns:
        AudioFeaturesResponse with energy, valence, tempo, danceability
    """
    from services.audio_features_service import get_audio_features_service
    
    service = get_audio_features_service()
    
    if not service.is_configured:
        raise HTTPException(
            status_code=503,
            detail="Audio features service is not configured. Please add RAPIDAPI_KEY to .env"
        )
    
    features = await service.get_by_query(request.song, request.artist)
    
    if features is None:
        raise HTTPException(
            status_code=404,
            detail=f"Could not find audio features for: {request.song} by {request.artist}"
        )
    
    return AudioFeaturesResponse(
        track_id=features.track_id,
        energy=features.energy,
        valence=features.valence,
        tempo=features.tempo,
        danceability=features.danceability,
        key=features.key,
        mode=features.mode,
        cached=False  # Query method generates new cache key
    )


@router.get("/audio-features-cache/stats", response_model=CacheStatsResponse)
async def get_audio_features_cache_stats():
    """
    Get audio features cache statistics.
    
    Returns:
        CacheStatsResponse with cache size and API configuration status
    """
    from services.audio_features_service import get_audio_features_service
    
    service = get_audio_features_service()
    stats = service.get_cache_stats()
    
    return CacheStatsResponse(
        cached_tracks=stats["cached_tracks"],
        api_configured=stats["api_configured"]
    )
