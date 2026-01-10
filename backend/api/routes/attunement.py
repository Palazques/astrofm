"""
Attunement API routes.
Endpoints for comparing natal chart to daily transits and identifying
attunement gaps and resonances. Premium feature.
"""
from datetime import datetime
from typing import Optional
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from models.attunement_schemas import (
    AttunementAnalysis,
    AttunementRequest,
    WeeklyDigest,
)
from models.sound_recommendation_schemas import (
    SoundRecommendation,
    SoundRecommendationsResponse,
)
from services.attunement import (
    calculate_attunement,
    get_weekly_digest,
)
from services.sound_recommendation import (
    get_sound_recommendations,
    get_recommendations_by_life_area,
)

router = APIRouter(tags=["attunement"])


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
            except Exception as e:
                print(f"[WARN] Timezone conversion failed for '{request.timezone}': {e}")
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
            except Exception as e:
                print(f"[WARN] Timezone conversion failed for '{request.timezone}': {e}")
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


# Request model for life area filtering
class LifeAreaRequest(BaseModel):
    """Request with optional life area filter."""
    datetime_str: str
    latitude: float
    longitude: float
    timezone: str = "UTC"
    life_area_key: Optional[str] = None  # e.g., "career_purpose"


@router.post("/sound-recommendations", response_model=SoundRecommendationsResponse)
async def get_sound_recommendations_endpoint(request: AttunementRequest) -> SoundRecommendationsResponse:
    """
    Get personalized sound recommendations based on natal chart gaps and resonances.
    
    Returns planetary frequencies the user should listen to, with explanations
    for why each recommendation is relevant. Prioritizes gaps (areas needing
    attunement) over resonances (areas to amplify).
    
    Args:
        request: User's birth date, time, and location
        
    Returns:
        SoundRecommendationsResponse with primary and all recommendations
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
            except Exception as e:
                print(f"[WARN] Timezone conversion failed for '{request.timezone}': {e}")
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid timezone: {request.timezone}"
                )
        
        # Get sound recommendations
        recommendations = get_sound_recommendations(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        return recommendations
        
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
            detail=f"Error generating sound recommendations: {str(e)}"
        )


@router.post("/sound-recommendations/by-life-area", response_model=SoundRecommendation)
async def get_sound_recommendation_by_life_area(request: LifeAreaRequest) -> SoundRecommendation:
    """
    Get sound recommendation for a specific life area.
    
    Filters recommendations to find the most relevant planet and frequency
    for the requested life area (e.g., "career_purpose" for 10th house topics).
    
    Args:
        request: User's birth data plus life_area_key to filter by
        
    Returns:
        SoundRecommendation for the specified life area
    """
    try:
        if not request.life_area_key:
            raise HTTPException(
                status_code=400,
                detail="life_area_key is required"
            )
        
        # Parse datetime string
        birth_dt = datetime.fromisoformat(request.datetime_str)
        
        # Convert to UTC if timezone is provided
        if request.timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.timezone)
                birth_dt = birth_dt.replace(tzinfo=local_tz)
                birth_dt = birth_dt.astimezone(ZoneInfo("UTC"))
                birth_dt = birth_dt.replace(tzinfo=None)
            except Exception as e:
                print(f"[WARN] Timezone conversion failed for '{request.timezone}': {e}")
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid timezone: {request.timezone}"
                )
        
        # Get recommendation for life area
        recommendation = get_recommendations_by_life_area(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude,
            life_area_key=request.life_area_key
        )
        
        if not recommendation:
            raise HTTPException(
                status_code=404,
                detail=f"No recommendation found for life area: {request.life_area_key}"
            )
        
        return recommendation
        
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
            detail=f"Error generating life area recommendation: {str(e)}"
        )
