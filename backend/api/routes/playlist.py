"""
Playlist generation API routes.
"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException

from models.playlist import PlaylistRequest, PlaylistResult
from services.ephemeris import calculate_natal_chart
from services.vibe_calculator import calculate_vibe_parameters
from services.playlist_matcher import generate_playlist

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
