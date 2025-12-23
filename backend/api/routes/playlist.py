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

router = APIRouter(prefix="/api/playlist", tags=["playlist"])


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
                longitude=current_lon
            )
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Error calculating vibe parameters: {str(e)}"
            )
        
        # Step 3: Generate playlist
        try:
            playlist = generate_playlist(
                vibe_params=vibe_params,
                playlist_size=request.playlist_size
            )
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Error generating playlist: {str(e)}"
            )
        
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

