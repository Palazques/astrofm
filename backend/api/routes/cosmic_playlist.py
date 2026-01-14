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
    ZodiacSeasonCardRequest,
    ZodiacSeasonCardResponse,
    PersonalInsight,
    SeasonTrackInfo,
)


router = APIRouter(tags=["cosmic-playlist"])


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


# =============================================================================
# Zodiac Season Card Endpoint (Personalized)
# =============================================================================

@router.post("/zodiac-season-card", response_model=ZodiacSeasonCardResponse)
async def get_zodiac_season_card(request: ZodiacSeasonCardRequest):
    """
    Get personalized zodiac season card with AI insights and seasonal playlist.
    
    Combines:
    - Current zodiac season info (sign, element, modality, ruling planet)
    - AI-generated personal connection based on user's natal chart houses
    - Curated seasonal playlist using existing playlist generation
    
    Cached for the entire zodiac season (~30 days).
    
    Args:
        request: User's chart data and genre preferences
        
    Returns:
        ZodiacSeasonCardResponse with season info, personal insight, and playlist
    """
    from datetime import datetime
    from services.cosmic.playlist_builder import get_playlist_builder
    from services.transits import get_current_moon_sign
    from services.zodiac_utils import (
        get_current_zodiac,
        get_next_zodiac_change_date,
        ZODIAC_ELEMENTS,
        ZODIAC_MODALITIES,
        ZODIAC_RULERS,
        ELEMENT_COLORS,
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
        modality = ZODIAC_MODALITIES.get(zodiac_sign, "Cardinal")
        ruling_planet, ruling_symbol = ZODIAC_RULERS.get(zodiac_sign, ("Saturn", "♄"))
        color1, color2 = ELEMENT_COLORS.get(element, ("#7D67FE", "#00D4AA"))
        
        # Generate cache key for this season
        today = datetime.now()
        zodiac_season_key = f"{zodiac_sign}_{today.year}"
        cached_until = get_next_zodiac_change_date()
        
        # Generate personalized AI insight
        ai_service = get_ai_service()
        insight_data = ai_service.generate_seasonal_personal_insight(
            current_season_sign=zodiac_sign,
            current_element=element,
            user_sun_sign=request.sun_sign,
            user_rising_sign=request.rising_sign,
            user_natal_planets=request.natal_planets,
        )
        
        personal_insight = PersonalInsight(
            headline=insight_data["headline"],
            subtext=insight_data["subtext"],
            meaning=insight_data["meaning"],
            focus_areas=insight_data["focus_areas"],
        )
        
        # Calculate which house the season activates for playlist naming
        zodiac_order = [
            "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
            "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
        ]
        rising_idx = zodiac_order.index(request.rising_sign) if request.rising_sign in zodiac_order else 0
        season_idx = zodiac_order.index(zodiac_sign) if zodiac_sign in zodiac_order else 0
        house_number = ((season_idx - rising_idx) % 12) + 1
        
        house_names = {
            1: "Self", 2: "Resources", 3: "Communication", 4: "Home",
            5: "Creativity", 6: "Health", 7: "Partnerships", 8: "Transformation",
            9: "Expansion", 10: "Career", 11: "Community", 12: "Spirituality"
        }
        house_name = house_names.get(house_number, "Focus")
        
        # Get current Moon sign for playlist variation
        try:
            current_moon_sign, _ = get_current_moon_sign()
        except Exception:
            current_moon_sign = "Capricorn"
        
        # Generate playlist using existing builder
        builder = get_playlist_builder()
        
        try:
            result = await builder.generate_playlist(
                sun_sign=request.sun_sign,
                moon_sign=request.moon_sign,
                rising_sign=request.rising_sign,
                current_moon_sign=current_moon_sign,
                genre_preferences=request.genre_preferences,
                target_tracks=12,  # Shorter playlist for season card
            )
            
            # If successful, process result
            if result.success:
                tracks = []
                total_seconds = 0
                for t in result.tracks[:12]:
                    duration_str = t.get("duration", "3:30")
                    tracks.append(SeasonTrackInfo(
                        id=t.get("id", ""),
                        title=t["name"],
                        artist=t["artist"],
                        duration=duration_str,
                        energy=int(t.get("energy", 0.7) * 100) if isinstance(t.get("energy"), float) else 70,
                        url=t.get("url"),
                    ))
                    try:
                        parts = duration_str.split(":")
                        total_seconds += int(parts[0]) * 60 + int(parts[1])
                    except:
                        total_seconds += 210
                
                total_duration = f"{total_seconds // 60} min"
                playlist_url = result.playlist_url
            else:
                # Handle logical failure (e.g. no tracks found)
                print(f"Playlist builder returned failure: {result.error}")
                tracks = []
                total_duration = "0 min"
                playlist_url = None
        except Exception as e:
            # Handle unexpected exceptions in builder
            print(f"Unexpected error in playlist builder: {e}")
            import traceback
            traceback.print_exc()
            tracks = []
            total_duration = "0 min"
            playlist_url = None
        
        # Generate vibe tags based on element
        element_vibes = {
            "Fire": ["Energetic", "Bold", "Passionate", "Driving"],
            "Earth": ["Structured", "Grounded", "Earthy", "Focused"],
            "Air": ["Eclectic", "Mental", "Light", "Social"],
            "Water": ["Emotional", "Dreamy", "Flowing", "Deep"],
        }
        vibe_tags = element_vibes.get(element, ["Cosmic", "Aligned", "Seasonal", "Personal"])
        
        return ZodiacSeasonCardResponse(
            success=True,
            # Season info
            zodiac_sign=zodiac_sign,
            symbol=symbol,
            element=element,
            modality=modality,
            date_range=date_range,
            ruling_planet=ruling_planet,
            ruling_symbol=ruling_symbol,
            color1=color1,
            color2=color2,
            # Personal insight
            personal_insight=personal_insight,
            # Playlist
            playlist_name=f"{zodiac_sign} Season × Your {house_number}{'st' if house_number == 1 else 'nd' if house_number == 2 else 'rd' if house_number == 3 else 'th'} House",
            playlist_description=f"{element} beats for {house_name.lower()} focus",
            total_duration=total_duration,
            vibe_tags=vibe_tags,
            tracks=tracks,
            playlist_url=playlist_url,
            # Cache metadata
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
            detail=f"Error generating zodiac season card: {str(e)}"
        )


# =============================================================================
# Seasonal Pulse Endpoint (Global Shared Playlists)
# =============================================================================

@router.get("/seasonal-pulse")
async def get_seasonal_pulse():
    """
    Get the current zodiac season's collective focus playlists.
    
    Returns 1-3 globally shared themed playlists generated once per month.
    All users receive the same playlists for collective seasonal alignment.
    
    Returns:
        JSON with active sign info and themed playlists
    """
    from datetime import datetime
    from services.cosmic.playlist_builder import get_playlist_builder
    from services.transits import get_current_moon_sign
    from services.zodiac_utils import (
        get_current_zodiac,
        get_next_zodiac_change_date,
        ZODIAC_ELEMENTS,
        ZODIAC_MODALITIES,
        ZODIAC_RULERS,
        ELEMENT_COLORS,
    )
    from services.seasonal_themes import (
        get_current_seasonal_themes,
        generate_theme_prompt,
        get_theme_metadata,
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
        modality = ZODIAC_MODALITIES.get(zodiac_sign, "Cardinal")
        ruling_planet, ruling_symbol = ZODIAC_RULERS.get(zodiac_sign, ("Saturn", "♄"))
        color1, color2 = ELEMENT_COLORS.get(element, ("#7D67FE", "#00D4AA"))
        
        # Get seasonal themes for this sign
        themes_list = get_current_seasonal_themes(zodiac_sign)
        print(f"[SeasonalPulse] Sign: {zodiac_sign}, Element: {element}, Themes: {themes_list}")
        
        # Generate cache key
        today = datetime.now()
        month_year = today.strftime("%b_%Y")
        cached_until = get_next_zodiac_change_date()
        
        # Build themed playlists
        builder = get_playlist_builder()
        print(f"[SeasonalPulse] Builder ready: {builder}")
        ai_service = get_ai_service()
        themed_playlists = []
        
        for theme in themes_list:
            print(f"[SeasonalPulse] Processing theme: {theme}")
            # Generate cache-friendly ID
            theme_id = f"{zodiac_sign.lower()}_{theme.lower().replace(' & ', '_').replace(' ', '_')}_{month_year}"
            
            # Get theme metadata
            metadata = get_theme_metadata(zodiac_sign, theme)
            
            # Generate AI monthly message for this theme
            try:
                monthly_message_data = ai_service.generate_seasonal_theme_message(
                    zodiac_sign=zodiac_sign,
                    element=element,
                    theme=theme,
                    month_year=today.strftime("%B %Y"),
                )
                print(f"[SeasonalPulse] Monthly message for {theme}: {monthly_message_data.get('message')}")
            except Exception as e:
                print(f"[SeasonalPulse] Monthly message error for {theme}: {e}")
                monthly_message_data = {"message": "Align with the collective energy of this season."}
            
            # Generate playlist using seasonal theme prompt
            try:
                # Use a basic genre set for global playlists
                default_genres = ["indie rock", "electronic", "pop", "alternative"]
                
                print(f"[SeasonalPulse] Calling builder for {theme}...")
                result = await builder.generate_seasonal_playlist(
                    sign=zodiac_sign,
                    element=element,
                    theme=theme,
                    month=month_year,
                    genre_preferences=default_genres,
                    target_tracks=12,
                )
                print(f"[SeasonalPulse] Builder result for {theme}: success={result.success}")
                
                if result.success:
                    tracks = []
                    total_seconds = 0
                    for t in result.tracks[:12]:
                        duration_str = t.get("duration", "3:30")
                        tracks.append({
                            "id": t.get("id", ""),
                            "title": t["name"],
                            "artist": t["artist"],
                            "duration": duration_str,
                            "energy": int(t.get("energy", 0.7) * 100) if isinstance(t.get("energy"), float) else 70,
                            "url": t.get("url"),
                        })
                        try:
                            parts = duration_str.split(":")
                            total_seconds += int(parts[0]) * 60 + int(parts[1])
                        except:
                            total_seconds += 210
                    
                    themed_playlists.append({
                        "id": theme_id,
                        "title": theme,
                        "glyph": metadata["glyph"],
                        "vibe_description": result.vibe_summary,
                        "monthly_message": monthly_message_data.get("message", ""),
                        "playlist_url": result.playlist_url,
                        "track_count": len(tracks),
                        "total_duration": f"{total_seconds // 60} min",
                        "tracks": tracks,
                    })
                else:
                    print(f"Failed to generate playlist for theme '{theme}': {result.error}")
            except Exception as e:
                print(f"Error generating playlist for theme '{theme}': {e}")
                import traceback
                traceback.print_exc()
        
        if not themed_playlists:
            print("[SeasonalPulse] No themes generated, adding dummy theme for debugging")
            themed_playlists.append({
                "id": "dummy_theme",
                "title": "Cosmic Alignment (Test)",
                "glyph": "✨",
                "vibe_description": "A placeholder vibe since generation is taking long",
                "monthly_message": "The universe is loading your seasonal focus. Please wait a moment and refresh.",
                "playlist_url": "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM3M",
                "track_count": 1,
                "total_duration": "3 min",
                "tracks": [{
                    "id": "test",
                    "title": "Stardust",
                    "artist": "The Universe",
                    "duration": "3:00",
                    "energy": 80,
                    "url": "https://spotify.com"
                }],
            })
        
        return {
            "active_sign": zodiac_sign,
            "symbol": symbol,
            "element": element,
            "modality": modality,
            "date_range": date_range,
            "ruling_planet": ruling_planet,
            "ruling_symbol": ruling_symbol,
            "color1": color1,
            "color2": color2,
            "cached_until": cached_until.isoformat(),
            "themes": themed_playlists,
        }
    
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Error generating seasonal pulse: {str(e)}"
        )
