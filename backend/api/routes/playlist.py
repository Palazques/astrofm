"""
Playlist generation API routes.
"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException

from models.playlist import PlaylistRequest, PlaylistResult
from models.track_model import GenrePreference
from services.ephemeris import calculate_natal_chart
from services.vibe_calculator import calculate_vibe_parameters
from services.playlist_matcher import generate_playlist, generate_blended_playlist

router = APIRouter(tags=["playlist"])


@router.post("/generate", response_model=PlaylistResult)
async def generate_playlist_endpoint(request: PlaylistRequest) -> PlaylistResult:
    """
    Generate a personalized playlist based on birth chart and current transits.
    
    Args:
        request: Playlist generation request with birth data and preferences
        
    Returns:
        PlaylistResult with ordered songs, energy arc, and metadata
        
    Raises:
        HTTPException: 400 for invalid input, 500 for calculation errors
    """
    try:
        # Parse birth datetime
        try:
            birth_dt = datetime.fromisoformat(request.birth_datetime.replace('Z', '+00:00'))
        except ValueError as e:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid birth_datetime format: {str(e)}. Use ISO format (YYYY-MM-DDTHH:MM:SS)"
            )
        
        # Convert to UTC if timezone is provided
        if request.timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.timezone)
                birth_dt = birth_dt.replace(tzinfo=local_tz)
                birth_dt = birth_dt.astimezone(ZoneInfo("UTC"))
                birth_dt = birth_dt.replace(tzinfo=None)  # Remove tzinfo for calculation
            except Exception as e:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid timezone: {request.timezone}"
                )
        
        # Parse current datetime (defaults to now if not provided)
        if request.current_datetime:
            try:
                current_dt = datetime.fromisoformat(request.current_datetime.replace('Z', '+00:00'))
                if request.timezone != "UTC":
                    current_dt = current_dt.replace(tzinfo=local_tz)
                    current_dt = current_dt.astimezone(ZoneInfo("UTC"))
                    current_dt = current_dt.replace(tzinfo=None)
            except ValueError as e:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid current_datetime format: {str(e)}"
                )
        else:
            current_dt = datetime.utcnow()
        
        # Use current location if provided, otherwise use birth location
        current_lat = request.current_latitude if request.current_latitude is not None else request.latitude
        current_lon = request.current_longitude if request.current_longitude is not None else request.longitude
        
        # Step 1: Calculate natal chart
        try:
            natal_chart = calculate_natal_chart(
                birth_datetime=birth_dt,
                latitude=request.latitude,
                longitude=request.longitude
            )
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Error calculating natal chart: {str(e)}"
            )
        
        # Step 2: Calculate vibe parameters from chart + transits
        try:
            vibe_params = calculate_vibe_parameters(
                natal_chart=natal_chart,
                current_datetime=current_dt,
                latitude=current_lat,
                longitude=current_lon,
                genre_preferences=request.genre_preferences
            )
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Error calculating vibe parameters: {str(e)}"
            )
        
        # Step 3: Generate playlist using the AI-driven CosmicPlaylistBuilder (SongToSpot method)
        from services.cosmic.playlist_builder import get_playlist_builder
        from services.transits import get_current_moon_sign
        from models.song import Song
        import uuid

        builder = get_playlist_builder()
        
        # Determine signs from chart
        sun_sign = next((p["sign"] for p in natal_chart["planets"] if p["name"] == "Sun"), "Aries")
        moon_sign = next((p["sign"] for p in natal_chart["planets"] if p["name"] == "Moon"), "Water")
        rising_sign = natal_chart.get("ascendant_sign", "Aries")
        current_moon_sign, _ = get_current_moon_sign()

        # Extract genre names
        genre_list = request.genre_preferences if request.genre_preferences else ["Pop", "Indie", "Electronic"]

        # Generate via AI pipeline
        cosmic_result = await builder.generate_playlist(
            sun_sign=sun_sign,
            moon_sign=moon_sign,
            rising_sign=rising_sign,
            current_moon_sign=current_moon_sign,
            genre_preferences=genre_list,
            target_tracks=request.playlist_size
        )

        if not cosmic_result.success:
            raise HTTPException(status_code=500, detail=cosmic_result.error or "AI Generation failed")

        # Map CosmicPlaylistResult tracks to Song objects for frontend compatibility
        from data.constants import GENRES, MOODS, ELEMENTS, PLANETS
        
        songs = []
        for i, t in enumerate(cosmic_result.tracks):
            # Ensure valid ID format song_XXX
            song_id = f"song_{str(i+1).zfill(3)}"
            
            # Sanitize genres (must be in GENRES list)
            valid_song_genres = [g for g in genre_list if g in GENRES]
            if not valid_song_genres:
                valid_song_genres = ["Electronic"] if "Electronic" in GENRES else [GENRES[0]]
            
            # Sanitize moods (must be in MOODS list)
            valid_song_moods = [m for m in vibe_params.mood_direction if m in MOODS]
            if len(valid_song_moods) < 2:
                # Add fillers from constants to satisfy min_length=2
                fillers = ["Dreamy", "Uplifting", "Atmospheric"]
                for f in fillers:
                    if f in MOODS and f not in valid_song_moods:
                        valid_song_moods.append(f)
                    if len(valid_song_moods) >= 2: break
            
            # Ensure intensity and energy are ints (averaging the target range)
            energy_val = sum(vibe_params.target_energy) // 2
            valence_val = sum(vibe_params.target_valence) // 2
            intensity_val = sum(vibe_params.intensity_range) // 2
            bpm_val = 110 + (energy_val - 50) // 2 # Simple proxy for BPM
            
            songs.append(Song(
                id=song_id,
                title=t["name"],
                artist=t["artist"],
                album="Cosmic Selection",
                duration_seconds=210,
                bpm=int(bpm_val),
                energy=int(energy_val),
                valence=int(valence_val),
                danceability=int(energy_val * 0.9), # Proxy
                acousticness=50,
                instrumentalness=20,
                genres=valid_song_genres[:3],
                moods=valid_song_moods[:4],
                elements=[cosmic_result.element],
                planetary_energy=vibe_params.active_planets[:3],
                intensity=intensity_val,
                spotify_id=t.get("url", "").split("/")[-1] if "/" in t.get("url", "") else "",
            ))

        # Build final response
        playlist = PlaylistResult(
            songs=songs,
            total_duration_seconds=len(songs) * 210,
            vibe_match_score=95.0,
            energy_arc=[s.energy for s in songs],
            element_distribution={cosmic_result.element: len(songs)},
            mood_distribution={m: 0 for m in MOODS}, # Initialize
            generation_metadata={
                "method": "SongToSpot (AI)",
                "vibe_summary": cosmic_result.vibe_summary,
                "playlist_url": cosmic_result.playlist_url,
                "app_account": "palazques@gmail.com"
            }
        )
        
        # Populate mood distribution
        for s in songs:
            for m in s.moods:
                playlist.mood_distribution[m] = playlist.mood_distribution.get(m, 0) + 1
        
        return playlist
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Unexpected error: {str(e)}"
        )


from pydantic import BaseModel, Field
from typing import Optional, List


class BlendedPlaylistRequest(BaseModel):
    """Request for blended playlist generation (user library + app dataset)."""
    birth_datetime: str = Field(..., description="Birth date/time in ISO format")
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    timezone: str = Field(default="UTC")
    playlist_size: int = Field(default=20, ge=10, le=30)
    current_datetime: Optional[str] = None
    current_latitude: Optional[float] = None
    current_longitude: Optional[float] = None
    # Genre preferences
    main_genres: List[str] = Field(default=[])
    subgenres: List[str] = Field(default=[])
    include_related: bool = Field(default=True)


@router.post("/generate-blended")
async def generate_blended_playlist_endpoint(request: BlendedPlaylistRequest):
    """
    Generate a blended playlist from user library and app dataset.
    
    If user has connected a music service (Spotify, etc.), their library
    tracks are matched against the day's astrology and blended with
    tracks from the app's dataset.
    
    Dynamic blending prioritizes high-scoring user library tracks.
    Falls back to dataset-only if no user library exists.
    """
    try:
        # Parse birth datetime
        try:
            birth_dt = datetime.fromisoformat(request.birth_datetime.replace('Z', '+00:00'))
        except ValueError as e:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid birth_datetime format: {str(e)}"
            )
        
        # Convert to UTC if timezone is provided
        if request.timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.timezone)
                birth_dt = birth_dt.replace(tzinfo=local_tz)
                birth_dt = birth_dt.astimezone(ZoneInfo("UTC"))
                birth_dt = birth_dt.replace(tzinfo=None)
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Invalid timezone: {request.timezone}")
        
        # Parse current datetime
        if request.current_datetime:
            current_dt = datetime.fromisoformat(request.current_datetime.replace('Z', '+00:00'))
            if request.timezone != "UTC":
                current_dt = current_dt.replace(tzinfo=local_tz)
                current_dt = current_dt.astimezone(ZoneInfo("UTC"))
                current_dt = current_dt.replace(tzinfo=None)
        else:
            current_dt = datetime.utcnow()
        
        current_lat = request.current_latitude or request.latitude
        current_lon = request.current_longitude or request.longitude
        
        # Calculate natal chart
        natal_chart = calculate_natal_chart(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        # Calculate vibe parameters
        vibe_params = calculate_vibe_parameters(
            natal_chart=natal_chart,
            current_datetime=current_dt,
            latitude=current_lat,
            longitude=current_lon
        )
        
        # Build genre preferences
        genre_prefs = None
        if request.main_genres or request.subgenres:
            genre_prefs = GenrePreference(
                main_genres=request.main_genres,
                subgenres=request.subgenres,
                include_related=request.include_related
            )
        
        # Generate blended playlist (parallel query to user library + dataset)
        result = await generate_blended_playlist(
            vibe_params=vibe_params,
            genre_preferences=genre_prefs,
            playlist_size=request.playlist_size
        )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating blended playlist: {str(e)}")

