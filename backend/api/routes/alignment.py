"""
Alignment calculation API routes.
Provides endpoints for daily alignment scores and current transits.
"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException

from models.schemas import (
    DailyAlignmentRequest,
    DailyAlignmentResponse,
    FriendAlignmentRequest,
    FriendAlignmentResponse,
    TransitsResponse,
    TransitPosition,
    AspectData,
)
from services.ephemeris import calculate_natal_chart
from services.transits import get_retrograde_period
from services.alignment import (
    get_current_transits,
    calculate_daily_alignment,
    calculate_friend_alignment,
    get_moon_phase,
)

router = APIRouter(prefix="/api/alignment", tags=["alignment"])


@router.post("/daily", response_model=DailyAlignmentResponse)
async def get_daily_alignment(birth_data: DailyAlignmentRequest) -> DailyAlignmentResponse:
    """
    Calculate daily alignment score between natal chart and current transits.
    
    The alignment score (0-100) indicates how harmoniously the current
    planetary transits interact with the user's natal chart.
    
    Args:
        birth_data: User's birth date, time, and location
        
    Returns:
        Alignment score, active aspects, dominant energy, and interpretation
    """
    try:
        # Parse datetime string
        birth_dt = datetime.fromisoformat(birth_data.datetime_str)
        
        # Convert to UTC if timezone is provided
        if birth_data.timezone != "UTC":
            try:
                local_tz = ZoneInfo(birth_data.timezone)
                birth_dt = birth_dt.replace(tzinfo=local_tz)
                birth_dt = birth_dt.astimezone(ZoneInfo("UTC"))
                birth_dt = birth_dt.replace(tzinfo=None)  # Remove tzinfo for calculation
            except Exception as e:
                print(f"[WARN] Timezone conversion failed for '{birth_data.timezone}': {e}")
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid timezone: {birth_data.timezone}"
                )
        
        # Calculate natal chart
        natal_chart = calculate_natal_chart(
            birth_datetime=birth_dt,
            latitude=birth_data.latitude,
            longitude=birth_data.longitude
        )
        
        # Calculate alignment with current transits
        alignment = calculate_daily_alignment(natal_chart)
        
        # Build response with properly typed aspects
        aspects = [
            AspectData(
                planet1=a["planet1"],
                planet2=a["planet2"],
                aspect=a["aspect"],
                orb=a["orb"],
                nature=a["nature"]
            )
            for a in alignment["aspects"]
        ]
        
        return DailyAlignmentResponse(
            score=alignment["score"],
            aspects=aspects,
            dominant_energy=alignment["dominant_energy"],
            description=alignment["description"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating alignment: {str(e)}"
        )


@router.post("/friend", response_model=FriendAlignmentResponse)
async def get_friend_alignment(request: FriendAlignmentRequest) -> FriendAlignmentResponse:
    """
    Calculate synastry alignment between two natal charts.
    
    Compares the planetary positions of two birth charts to determine
    compatibility and relationship dynamics.
    
    Args:
        request: Birth data for both user and friend
        
    Returns:
        Compatibility score, synastry aspects, strengths, and challenges
    """
    try:
        # Parse user datetime
        user_dt = datetime.fromisoformat(request.user_datetime)
        if request.user_timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.user_timezone)
                user_dt = user_dt.replace(tzinfo=local_tz)
                user_dt = user_dt.astimezone(ZoneInfo("UTC"))
                user_dt = user_dt.replace(tzinfo=None)
            except Exception as e:
                print(f"[WARN] User timezone conversion failed for '{request.user_timezone}': {e}")
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid user timezone: {request.user_timezone}"
                )
        
        # Parse friend datetime
        friend_dt = datetime.fromisoformat(request.friend_datetime)
        if request.friend_timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.friend_timezone)
                friend_dt = friend_dt.replace(tzinfo=local_tz)
                friend_dt = friend_dt.astimezone(ZoneInfo("UTC"))
                friend_dt = friend_dt.replace(tzinfo=None)
            except Exception as e:
                print(f"[WARN] Friend timezone conversion failed for '{request.friend_timezone}': {e}")
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid friend timezone: {request.friend_timezone}"
                )
        
        # Calculate both natal charts
        user_natal = calculate_natal_chart(
            birth_datetime=user_dt,
            latitude=request.user_latitude,
            longitude=request.user_longitude
        )
        
        friend_natal = calculate_natal_chart(
            birth_datetime=friend_dt,
            latitude=request.friend_latitude,
            longitude=request.friend_longitude
        )
        
        # Calculate synastry
        synastry = calculate_friend_alignment(user_natal, friend_natal)
        
        # Build response
        aspects = [
            AspectData(
                planet1=a["planet1"],
                planet2=a["planet2"],
                aspect=a["aspect"],
                orb=a["orb"],
                nature=a["nature"]
            )
            for a in synastry["aspects"]
        ]
        
        return FriendAlignmentResponse(
            score=synastry["score"],
            aspects=aspects,
            dominant_energy=synastry["dominant_energy"],
            description=synastry["description"],
            strengths=synastry["strengths"],
            challenges=synastry["challenges"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating friend alignment: {str(e)}"
        )


@router.get("/transits", response_model=TransitsResponse)
async def get_transits() -> TransitsResponse:
    """
    Get current planetary transit positions.
    
    Returns the current positions of all planets including their
    zodiac sign, degree, and retrograde status.
    
    Returns:
        Current planetary positions, moon phase, and retrograde planets
    """
    try:
        transits = get_current_transits()
        
        # Find Sun and Moon for moon phase calculation
        sun_lon = next((t["longitude"] for t in transits if t["name"] == "Sun"), 0)
        moon_lon = next((t["longitude"] for t in transits if t["name"] == "Moon"), 0)
        moon_phase = get_moon_phase(sun_lon, moon_lon)
        
        # Get list of retrograde planets
        retrograde = [t["name"] for t in transits if t["retrograde"]]
        
        # Build response with retrograde period data
        planets = []
        for t in transits:
            retro_period = get_retrograde_period(t["name"]) if t["retrograde"] else {}
            planets.append(TransitPosition(
                name=t["name"],
                sign=t["sign"],
                degree=t["sign_degree"],
                house=None,  # No house without natal chart
                retrograde=t["retrograde"],
                retrograde_start=retro_period.get("retrograde_start"),
                retrograde_end=retro_period.get("retrograde_end")
            ))
        
        return TransitsResponse(
            planets=planets,
            moon_phase=moon_phase,
            retrograde=retrograde
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error getting transits: {str(e)}"
        )
