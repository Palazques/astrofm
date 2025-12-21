"""
Attunement API routes.
Endpoints for comparing natal chart to daily transits and identifying
attunement gaps and resonances. Premium feature.
"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException

from models.attunement_schemas import (
    AttunementAnalysis,
    AttunementRequest,
    WeeklyDigest,
)
from services.attunement import (
    calculate_attunement,
    get_weekly_digest,
)

router = APIRouter(prefix="/api/attunement", tags=["attunement"])


@router.post("/analyze", response_model=AttunementAnalysis)
async def analyze_attunement(request: AttunementRequest) -> AttunementAnalysis:
    """
    Analyze attunement between natal chart and today's transits.
    
    Compares the user's natal sonification to the current transit
    sonification to identify gaps (where attunement is needed) and
    resonances (where the user naturally aligns with today's energy).
    
    Returns max 2 gaps (prioritized) and all resonances.
    
    Args:
        request: User's birth date, time, and location
        
    Returns:
        AttunementAnalysis with gaps, resonances, and alignment score
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
        
        # Calculate attunement
        analysis = calculate_attunement(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        return analysis
        
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
            detail=f"Error analyzing attunement: {str(e)}"
        )


@router.post("/weekly-digest", response_model=WeeklyDigest)
async def get_weekly_attunement_digest(request: AttunementRequest) -> WeeklyDigest:
    """
    Get weekly digest of attunement patterns.
    
    Analyzes the past 7 days to show trends, best/worst days,
    and commonly appearing gaps. Displayed on Sound screen.
    
    Args:
        request: User's birth date, time, and location
        
    Returns:
        WeeklyDigest with alignment trends and summary
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
        
        # Get weekly digest
        digest = get_weekly_digest(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        return digest
        
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
            detail=f"Error generating weekly digest: {str(e)}"
        )
