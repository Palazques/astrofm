"""
AI API routes for generating personalized horoscopes and interpretations.
"""
from datetime import datetime
from fastapi import APIRouter, HTTPException

from models.schemas import (
    DailyReadingRequest,
    DailyReadingResponse,
    AlignmentRequest,
    AlignmentInterpretation,
    CompatibilityRequest,
    CompatibilityResponse,
    PlaylistParams,
)
from services.ai_service import get_ai_service
from services.ephemeris import calculate_natal_chart
from services.transits import get_transit_summary


router = APIRouter(prefix="/api/ai", tags=["ai"])


@router.post("/daily-reading", response_model=DailyReadingResponse)
async def generate_daily_reading(request: DailyReadingRequest) -> DailyReadingResponse:
    """
    Generate a personalized daily reading with playlist parameters.
    
    The reading combines the user's birth chart with current planetary transits
    to create a unique horoscope with sonic/musical guidance.
    """
    try:
        # Parse birth datetime
        birth_dt = datetime.fromisoformat(request.datetime_str)
        
        # Calculate user's natal chart
        birth_chart = calculate_natal_chart(birth_dt, request.latitude, request.longitude)
        
        # Get current transits
        current_transits = get_transit_summary()
        
        # Generate AI reading
        ai_service = get_ai_service()
        result = ai_service.generate_daily_reading(birth_chart, current_transits)
        
        return DailyReadingResponse(
            reading=result["reading"],
            playlist_params=PlaylistParams(**result["playlist_params"]),
            cosmic_weather=result["cosmic_weather"],
            generated_at=result["generated_at"],
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate reading: {e}")


@router.post("/interpret-alignment", response_model=AlignmentInterpretation)
async def interpret_alignment(request: AlignmentRequest) -> AlignmentInterpretation:
    """
    Generate an interpretation of alignment between user and target.
    
    If target datetime is not provided, aligns with today's transits.
    """
    try:
        # Parse user birth datetime
        user_dt = datetime.fromisoformat(request.user_datetime)
        user_chart = calculate_natal_chart(user_dt, request.user_latitude, request.user_longitude)
        
        # Calculate target chart (friend or today's transits)
        if request.target_datetime and request.target_latitude and request.target_longitude:
            target_dt = datetime.fromisoformat(request.target_datetime)
            target_chart = calculate_natal_chart(target_dt, request.target_latitude, request.target_longitude)
        else:
            target_chart = get_transit_summary()
        
        # Calculate resonance score (simplified - uses element compatibility)
        # This would be more sophisticated in production
        import random
        resonance_score = random.randint(60, 95)  # Placeholder - would calculate from aspects
        
        # Generate interpretation
        ai_service = get_ai_service()
        result = ai_service.generate_alignment_interpretation(user_chart, target_chart, resonance_score)
        
        return AlignmentInterpretation(
            interpretation=result["interpretation"],
            resonance_score=result["resonance_score"],
            harmonious_aspects=result["harmonious_aspects"],
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate interpretation: {e}")


@router.post("/compatibility", response_model=CompatibilityResponse)
async def analyze_compatibility(request: CompatibilityRequest) -> CompatibilityResponse:
    """
    Generate a compatibility analysis between two people.
    """
    try:
        # Parse datetimes
        user_dt = datetime.fromisoformat(request.user_datetime)
        friend_dt = datetime.fromisoformat(request.friend_datetime)
        
        # Calculate both charts
        user_chart = calculate_natal_chart(user_dt, request.user_latitude, request.user_longitude)
        friend_chart = calculate_natal_chart(friend_dt, request.friend_latitude, request.friend_longitude)
        
        # Generate compatibility narrative
        ai_service = get_ai_service()
        result = ai_service.generate_compatibility_narrative(user_chart, friend_chart)
        
        return CompatibilityResponse(
            narrative=result["narrative"],
            overall_score=result["overall_score"],
            strengths=result["strengths"],
            challenges=result["challenges"],
            shared_genres=result["shared_genres"],
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to analyze compatibility: {e}")
