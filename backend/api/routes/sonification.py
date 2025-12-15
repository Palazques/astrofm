"""
Sonification API routes.
Endpoints for generating audio parameters from astrological data.
"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException, Query

from models.sonification_schemas import (
    ChartSonification,
    SonificationRequest,
    DailySonificationRequest,
)
from services.sonification import (
    calculate_user_sonification,
    calculate_daily_sonification,
)

router = APIRouter(prefix="/api/sonification", tags=["sonification"])


@router.post("/user", response_model=ChartSonification)
async def get_user_sonification(request: SonificationRequest) -> ChartSonification:
    """
    Generate sonification for a user's birth chart.
    
    Returns audio synthesis parameters for all planets based on
    their positions in the natal chart.
    
    Args:
        request: Birth date, time, and location
        
    Returns:
        ChartSonification with all planet sounds and metadata
    """
    try:
        # Parse datetime string
        birth_dt = datetime.fromisoformat(request.datetime_str)
        
        # Convert to UTC if timezone is provided
        if request.timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.timezone)
                birth_dt = birth_dt.replace(tzinfo=local_tz)
                birth_dt = birth_dt.astimezone(ZoneInfo("UTC"))
                birth_dt = birth_dt.replace(tzinfo=None)
            except Exception:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid timezone: {request.timezone}"
                )
        
        # Calculate sonification
        sonification = calculate_user_sonification(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        return sonification
        
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid datetime format: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating sonification: {str(e)}"
        )


@router.get("/daily", response_model=ChartSonification)
async def get_daily_sonification(
    latitude: float = Query(
        default=0.0,
        ge=-90.0,
        le=90.0,
        description="Observer latitude"
    ),
    longitude: float = Query(
        default=0.0,
        ge=-180.0,
        le=180.0,
        description="Observer longitude"
    )
) -> ChartSonification:
    """
    Generate sonification for today's planetary transits.
    
    Returns audio synthesis parameters based on current planetary
    positions. Location affects house placements.
    
    Args:
        latitude: Observer location latitude (optional)
        longitude: Observer location longitude (optional)
        
    Returns:
        ChartSonification for current transits
    """
    try:
        sonification = calculate_daily_sonification(
            latitude=latitude,
            longitude=longitude
        )
        
        return sonification
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating daily sonification: {str(e)}"
        )


@router.post("/daily", response_model=ChartSonification)
async def get_daily_sonification_post(
    request: DailySonificationRequest
) -> ChartSonification:
    """
    Generate sonification for today's planetary transits (POST variant).
    
    Same as GET /daily but accepts JSON body for location.
    
    Args:
        request: Optional location data
        
    Returns:
        ChartSonification for current transits
    """
    try:
        sonification = calculate_daily_sonification(
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        return sonification
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating daily sonification: {str(e)}"
        )
