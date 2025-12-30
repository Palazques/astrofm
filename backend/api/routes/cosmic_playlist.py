"""
Cosmic Playlist API Routes.

New playlist generation system using the app's own Spotify account.
No user Spotify auth required.

S2: Documentation Rule - All endpoints include clear docstrings.
"""
from typing import Optional
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import HTMLResponse, RedirectResponse
from pydantic import BaseModel

from services.cosmic.app_spotify import get_app_spotify_service
from models.cosmic_models import (
    CosmicPlaylistRequest, 
    CosmicPlaylistResponse, 
    TrackInfo,
    ZodiacSeasonRequest,
    ZodiacSeasonResponse,
)


router = APIRouter(prefix="/api/cosmic", tags=["cosmic-playlist"])


# =============================================================================
# Response Models
# =============================================================================

class AppStatusResponse(BaseModel):
    """Status of the app's Spotify account."""
    configured: bool
    ready: bool
    message: str


class AuthUrlResponse(BaseModel):
    """Response for auth URL endpoint."""
    url: str
    state: str


# =============================================================================
# App Account Setup Endpoints (One-time use)
# =============================================================================

@router.get("/status", response_model=AppStatusResponse)
async def get_app_status():
    """
    Check if the app's Spotify account is configured and ready.
    
    Returns:
        AppStatusResponse with configuration status
    """
    service = get_app_spotify_service()
    
    if not service.is_configured:
        return AppStatusResponse(
            configured=False,
            ready=False,
            message="Spotify client credentials not configured in .env"
        )
    
    if not service.is_ready:
        return AppStatusResponse(
            configured=True,
            ready=False,
            message="Refresh token not configured. Run /app-auth to set up."
        )
    
    return AppStatusResponse(
        configured=True,
        ready=True,
        message="App Spotify account is ready for playlist creation."
    )


@router.get("/app-auth")
async def get_app_auth_url():
    """
    Get Spotify OAuth URL for one-time app account authorization.
    
    Visit this URL to authorize the app's Spotify account and get
    a refresh token. This only needs to be done once.
    
    Returns:
        Redirect to Spotify authorization page
    """
    service = get_app_spotify_service()
    
    if not service.is_configured:
        raise HTTPException(
            status_code=503,
            detail="Spotify credentials not configured. Add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET to .env"
        )
    
    auth_data = service.get_auth_url()
    
    # Redirect directly to Spotify
    return RedirectResponse(url=auth_data["url"])


@router.get("/app-callback")
async def app_auth_callback(
    code: Optional[str] = Query(None),
    state: Optional[str] = Query(None),
    error: Optional[str] = Query(None),
):
    """
    OAuth callback for app account authorization.
    
    Displays the refresh token for you to copy to .env
    """
    if error:
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html>
        <head><title>Authorization Failed</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>❌ Authorization Failed</h1>
            <p>Error: {error}</p>
            <p>Please try again.</p>
        </body>
        </html>
        """, status_code=400)
    
    if not code:
        return HTMLResponse(content="""
        <!DOCTYPE html>
        <html>
        <head><title>Invalid Request</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>❌ Invalid Request</h1>
            <p>Missing authorization code.</p>
        </body>
        </html>
        """, status_code=400)
    
    service = get_app_spotify_service()
    
    try:
        tokens = await service.exchange_code_for_tokens(code)
        refresh_token = tokens["refresh_token"]
        
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html>
        <head><title>App Account Authorized!</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>✅ App Account Authorized!</h1>
            <p>Copy this refresh token to your <code>.env</code> file:</p>
            <div style="background: #333; padding: 20px; margin: 20px auto; max-width: 800px; border-radius: 8px; word-break: break-all;">
                <code style="font-size: 14px; color: #00ff88;">ASTROFM_SPOTIFY_REFRESH_TOKEN={refresh_token}</code>
            </div>
            <p style="margin-top: 20px;">
                <button onclick="navigator.clipboard.writeText('ASTROFM_SPOTIFY_REFRESH_TOKEN={refresh_token}')" 
                        style="padding: 10px 20px; font-size: 16px; cursor: pointer; background: #1DB954; color: white; border: none; border-radius: 20px;">
                    📋 Copy to Clipboard
                </button>
            </p>
            <p style="color: #888; margin-top: 30px;">
                After adding to .env, restart the backend server.
            </p>
        </body>
        </html>
        """)
    
    except Exception as e:
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html>
        <head><title>Token Exchange Failed</title></head>
        <body style="font-family: system-ui; text-align: center; padding: 50px; background: #1a1a2e; color: white;">
            <h1>❌ Token Exchange Failed</h1>
            <p style="color: #ff6b6b;">{str(e)}</p>
            <p>Please try the authorization again.</p>
        </body>
        </html>
        """, status_code=500)


# =============================================================================
# Playlist Generation Endpoints
# =============================================================================

@router.post("/generate")
async def generate_cosmic_playlist(request: CosmicPlaylistRequest):
    """
    Generate a cosmic playlist based on astrological birth data and genres.
    
    No Spotify auth required - uses the app's own Spotify account.
    
    Args:
        request: Birth chart data and genre preferences
        
    Returns:
        CosmicPlaylistResponse with playlist URL and track info
    """
    # Models imported at top of file
    from services.cosmic.playlist_builder import get_playlist_builder
    from services.transits import get_current_moon_sign
    
    service = get_app_spotify_service()
    
    if not service.is_ready:
        raise HTTPException(
            status_code=503,
            detail="App Spotify account not configured. Contact support."
        )
    
    # Get current Moon sign for daily variation
    try:
        current_moon_sign, _ = get_current_moon_sign()  # Returns (sign, degree)
    except Exception:
        current_moon_sign = "Capricorn"  # Fallback
    
    # Generate the playlist
    builder = get_playlist_builder()
    
    result = await builder.generate_playlist(
        sun_sign=request.sun_sign,
        moon_sign=request.moon_sign,
        rising_sign=request.rising_sign,
        current_moon_sign=current_moon_sign,
        genre_preferences=request.genre_preferences,
        target_tracks=20,
    )
    
    if not result.success:
        raise HTTPException(
            status_code=500,
            detail=result.error or "Failed to generate playlist"
        )
    
    return CosmicPlaylistResponse(
        success=True,
        playlist_url=result.playlist_url,
        playlist_name=result.playlist_name,
        track_count=result.track_count,
        vibe_summary=result.vibe_summary,
        sun_sign=result.sun_sign,
        element=result.element,
        tracks=[
            TrackInfo(
                name=t["name"],
                artist=t["artist"],
                url=t["url"],
                album_art=t.get("album_art"),
            )
            for t in result.tracks
        ],
    )


# =============================================================================
# Zodiac Season Playlist Endpoint
# =============================================================================

@router.post("/zodiac-season", response_model=ZodiacSeasonResponse)
async def generate_zodiac_season_playlist(request: ZodiacSeasonRequest):
    """
    Generate a zodiac season playlist based on the current astrological season.
    
    Uses AI to curate tracks that match the current zodiac's element energy.
    No Spotify auth required - uses the app's own Spotify account.
    
    The playlist is designed to be cached for the entire zodiac season (~30 days).
    
    Args:
        request: User's chart data and genre preferences
        
    Returns:
        ZodiacSeasonResponse with zodiac info, element qualities, horoscope,
        playlist URL, and track info
    """
    from datetime import datetime
    from services.cosmic.playlist_builder import get_playlist_builder
    from services.transits import get_current_moon_sign
    from services.zodiac_utils import (
        get_current_zodiac,
        get_element_qualities,
        get_next_zodiac_change_date,
        ZODIAC_ELEMENTS,
    )
    from services.ai_service import get_ai_service
    
    service = get_app_spotify_service()
    
    if not service.is_ready:
        raise HTTPException(
            status_code=503,
            detail="App Spotify account not configured. Contact support."
        )
    
    try:
        # Get current zodiac info
        zodiac_sign, element, date_range, symbol = get_current_zodiac()
        element_qualities = get_element_qualities(element)
        
        # Generate cache key for this season
        today = datetime.now()
        zodiac_season_key = f"{zodiac_sign}_{today.year}"
        cached_until = get_next_zodiac_change_date()
        
        # Get month/year for horoscope context
        month_year = today.strftime("%B %Y")
        
        # Generate AI horoscope for the zodiac season
        ai_service = get_ai_service()
        horoscope_data = ai_service.generate_monthly_horoscope(
            zodiac_sign=zodiac_sign,
            element=element,
            date_range=date_range,
            month_year=month_year,
        )
        
        # Get current Moon sign for playlist variation
        try:
            current_moon_sign, _ = get_current_moon_sign()
        except Exception:
            current_moon_sign = "Capricorn"  # Fallback
        
        # Generate the playlist using CosmicPlaylistBuilder
        builder = get_playlist_builder()
        
        result = await builder.generate_playlist(
            sun_sign=request.sun_sign,
            moon_sign=request.moon_sign,
            rising_sign=request.rising_sign,
            current_moon_sign=current_moon_sign,
            genre_preferences=request.genre_preferences,
            target_tracks=20,
        )
        
        if not result.success:
            raise HTTPException(
                status_code=500,
                detail=result.error or "Failed to generate zodiac season playlist"
            )
        
        return ZodiacSeasonResponse(
            success=True,
            zodiac_sign=zodiac_sign,
            symbol=symbol,
            element=element,
            date_range=date_range,
            element_qualities=element_qualities,
            horoscope=horoscope_data["horoscope"],
            vibe_summary=horoscope_data.get("vibe_summary", result.vibe_summary),
            playlist_url=result.playlist_url,
            playlist_id=result.playlist_url.split("/")[-1] if result.playlist_url else None,
            track_count=result.track_count,
            tracks=[
                TrackInfo(
                    name=t["name"],
                    artist=t["artist"],
                    url=t["url"],
                    album_art=t.get("album_art"),
                )
                for t in result.tracks
            ],
            zodiac_season_key=zodiac_season_key,
            cached_until=cached_until.isoformat(),
        )
    
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Error generating zodiac season playlist: {str(e)}"
        )
