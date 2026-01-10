"""
AI API routes for generating personalized horoscopes and interpretations.
"""
from datetime import datetime
from fastapi import APIRouter, HTTPException

from models.schemas import (
    DailyReadingRequest,
    DailyReadingResponse,
    DailySignal,
    AlignmentRequest,
    AlignmentInterpretation,
    CompatibilityRequest,
    CompatibilityResponse,
    PlaylistParams,
)
from services.ai_service import get_ai_service
from services.ephemeris import calculate_natal_chart
from services.transits import get_transit_summary, get_detailed_transit_summary


router = APIRouter(tags=["ai"])


@router.post("/daily-reading", response_model=DailyReadingResponse)
def generate_daily_reading(request: DailyReadingRequest) -> DailyReadingResponse:
    """
    Generate a transit-focused daily horoscope.
    
    Uses real astronomical data (Moon phase, planetary aspects, dominant element)
    to create a unique horoscope for the user's Sun sign.
    """
    try:
        # Parse birth datetime
        birth_dt = datetime.fromisoformat(request.datetime_str)
        
        # Calculate user's natal chart (mainly to get Sun sign)
        birth_chart = calculate_natal_chart(birth_dt, request.latitude, request.longitude)
        
        # Get detailed current transits with aspects, moon phase, dominant element
        current_transits = get_detailed_transit_summary()
        
        # Generate AI horoscope
        ai_service = get_ai_service()
        result = ai_service.generate_daily_reading(birth_chart, current_transits, request.subject_name)
        
        # Build response with new horoscope format
        return DailyReadingResponse(
            headline=result["headline"],
            subheadline=result.get("subheadline", ""),
            horoscope=result["horoscope"],
            cosmic_weather=result["cosmic_weather"],
            energy_level=result["energy_level"],
            focus_area=result["focus_area"],
            moon_phase=result["moon_phase"],
            dominant_element=result["dominant_element"],
            actionable_advice=result.get("actionable_advice", ""),
            energy_label=result.get("energy_label", "Intensity"),
            house_context=result.get("house_context", ""),
            playlist_params=PlaylistParams(**result["playlist_params"]),
            generated_at=result["generated_at"],
            # Legacy fields for backward compatibility
            reading=result.get("reading", result["horoscope"]),
            signals=[],
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate reading: {e}")


@router.post("/interpret-alignment", response_model=AlignmentInterpretation)
def interpret_alignment(request: AlignmentRequest) -> AlignmentInterpretation:
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
def analyze_compatibility(request: CompatibilityRequest) -> CompatibilityResponse:
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
        result = ai_service.generate_compatibility_narrative(user_chart, friend_chart, request.friend_name)
        
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


from models.schemas import TransitInterpretationResponse
from services.alignment import get_current_transits, get_moon_phase


@router.get("/transit-interpretation", response_model=TransitInterpretationResponse)
def get_transit_interpretation() -> TransitInterpretationResponse:
    """
    Generate AI interpretation of current planetary transits.
    
    Returns a cosmic weather summary, highlight planet, and energy description.
    Cached for 3 hours.
    """
    try:
        # Get current transits
        transits = get_current_transits()
        
        # Calculate moon phase
        sun_lon = next((t["longitude"] for t in transits if t["name"] == "Sun"), 0)
        moon_lon = next((t["longitude"] for t in transits if t["name"] == "Moon"), 0)
        moon_phase = get_moon_phase(sun_lon, moon_lon)
        
        # Get retrograde planets
        retrograde_planets = [t["name"] for t in transits if t["retrograde"]]
        
        # Convert transits to format expected by AI service
        transit_data = [
            {
                "name": t["name"],
                "sign": t["sign"],
                "degree": t["sign_degree"],
                "retrograde": t["retrograde"],
            }
            for t in transits
        ]
        
        # Generate AI interpretation
        ai_service = get_ai_service()
        result = ai_service.generate_transit_interpretation(
            transits=transit_data,
            moon_phase=moon_phase,
            retrograde_planets=retrograde_planets,
        )
        
        return TransitInterpretationResponse(
            interpretation=result["interpretation"],
            highlight_planet=result["highlight_planet"],
            highlight_reason=result["highlight_reason"],
            energy_description=result["energy_description"],
            moon_phase=result["moon_phase"],
            retrograde_planets=result["retrograde_planets"],
        )
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get transit interpretation: {e}")


from models.schemas import PlaylistInsightRequest, PlaylistInsightResponse
from services.ephemeris import calculate_natal_chart


@router.post("/playlist-insight", response_model=PlaylistInsightResponse)
def get_playlist_insight(request: PlaylistInsightRequest) -> PlaylistInsightResponse:
    """
    Generate a simple, relatable explanation for why this playlist was created.
    
    Takes user's birth data and playlist vibe parameters to create a personalized insight.
    """
    try:
        # Parse birth datetime
        birth_dt = datetime.fromisoformat(request.datetime_str)
        
        # Calculate natal chart to get signs
        natal_chart = calculate_natal_chart(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        # Extract signs from chart
        sun_sign = natal_chart.get("ascendant_sign", "Aries")  # Fallback
        moon_sign = "Unknown"
        ascendant_sign = natal_chart.get("ascendant_sign", "Unknown")
        
        for planet in natal_chart.get("planets", []):
            if planet["name"] == "Sun":
                sun_sign = planet["sign"]
            elif planet["name"] == "Moon":
                moon_sign = planet["sign"]
        
        # Generate AI insight
        ai_service = get_ai_service()
        result = ai_service.generate_playlist_insight(
            sun_sign=sun_sign,
            moon_sign=moon_sign,
            ascendant_sign=ascendant_sign,
            energy_percent=request.energy_percent,
            dominant_mood=request.dominant_mood,
            dominant_element=request.dominant_element,
            bpm_range=(request.bpm_min, request.bpm_max),
        )
        
        return PlaylistInsightResponse(
            insight=result["insight"],
            energy_percent=result["energy_percent"],
            dominant_mood=result["dominant_mood"],
            astro_highlight=result["astro_highlight"],
        )
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get playlist insight: {e}")


from models.schemas import SoundInterpretationRequest, SoundInterpretationResponse


@router.post("/sound-interpretation", response_model=SoundInterpretationResponse)
def get_sound_interpretation(request: SoundInterpretationRequest) -> SoundInterpretationResponse:
    """
    Generate AI interpretation of user's cosmic sound profile.
    
    Returns personality description, today's influence, and per-planet sound descriptions.
    """
    try:
        # Parse birth datetime
        birth_dt = datetime.fromisoformat(request.datetime_str)
        
        # Calculate natal chart to get signs
        natal_chart = calculate_natal_chart(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        # Extract signs from chart
        sun_sign = "Aries"  # Fallback
        moon_sign = "Unknown"
        ascendant_sign = natal_chart.get("ascendant_sign", "Unknown")
        
        for planet in natal_chart.get("planets", []):
            if planet["name"] == "Sun":
                sun_sign = planet["sign"]
            elif planet["name"] == "Moon":
                moon_sign = planet["sign"]
        
        # Convert planet data
        planets_data = [
            {
                "name": p.name,
                "sign": p.sign,
                "house": p.house,
                "frequency": p.frequency,
            }
            for p in request.planets
        ]
        
        # Generate AI interpretation
        ai_service = get_ai_service()
        result = ai_service.generate_sound_interpretation(
            sun_sign=sun_sign,
            moon_sign=moon_sign,
            ascendant_sign=ascendant_sign,
            dominant_element=request.dominant_element,
            planets=planets_data,
        )
        
        return SoundInterpretationResponse(
            personality=result["personality"],
            today_influence=result["today_influence"],
            shift=result["shift"],
            planet_descriptions=result["planet_descriptions"],
        )
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get sound interpretation: {e}")


from models.schemas import WelcomeMessageRequest, WelcomeMessageResponse


@router.post("/welcome", response_model=WelcomeMessageResponse)
def get_welcome_message(request: WelcomeMessageRequest) -> WelcomeMessageResponse:
    """
    Generate a warm, personalized welcome message for new users.
    
    Called at the end of onboarding to greet users with their cosmic profile.
    """
    try:
        # Parse birth datetime
        birth_dt = datetime.fromisoformat(request.datetime_str)
        
        # Calculate natal chart to get signs
        natal_chart = calculate_natal_chart(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        # Extract signs from chart
        sun_sign = "Aries"  # Fallback
        moon_sign = "Unknown"
        ascendant_sign = natal_chart.get("ascendant_sign", "Unknown")
        
        for planet in natal_chart.get("planets", []):
            if planet["name"] == "Sun":
                sun_sign = planet["sign"]
            elif planet["name"] == "Moon":
                moon_sign = planet["sign"]
        
        # Generate AI welcome message
        ai_service = get_ai_service()
        result = ai_service.generate_welcome_message(
            sun_sign=sun_sign,
            moon_sign=moon_sign,
            ascendant_sign=ascendant_sign,
        )
        
        return WelcomeMessageResponse(
            greeting=result["greeting"],
            personality=result["personality"],
            sound_teaser=result["sound_teaser"],
        )
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=f"AI service unavailable: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get welcome message: {e}")


from models.schemas import TransitAlignmentRequest, TransitAlignmentResponse
from services.transit_alignment import calculate_transit_alignment


@router.post("/transit-alignment", response_model=TransitAlignmentResponse)
def get_transit_alignment(request: TransitAlignmentRequest) -> TransitAlignmentResponse:
    """
    Calculate transit alignment between user's natal chart and current transits.
    
    Returns gap/resonance status and planet-specific insights for each planet.
    Insights are based on house-to-house transitions.
    """
    try:
        result = calculate_transit_alignment(
            birth_datetime=request.datetime_str,
            latitude=request.latitude,
            longitude=request.longitude,
            timezone_str=request.timezone,
            target_date=request.target_date,
        )
        
        return TransitAlignmentResponse(
            planets=result["planets"],
            gap_count=result["gap_count"],
            resonance_count=result["resonance_count"],
            is_major_life_shift=result.get("is_major_life_shift", False)
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to calculate transit alignment: {e}")

