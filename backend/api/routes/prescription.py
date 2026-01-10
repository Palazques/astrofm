"""
Prescription API routes for Cosmic Prescription feature.

Endpoints for getting personalized brainwave recommendations based on
transit-to-natal aspects.

S2: Documentation Rule - All endpoints include clear docstrings.
"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException

from models.prescription_schemas import (
    PrescriptionRequest,
    CosmicPrescription,
    BrainwaveMode,
)
from services.prescription_service import calculate_prescription
from services.ai_service import get_ai_service

router = APIRouter(tags=["prescription"])


@router.post("/cosmic", response_model=CosmicPrescription)
async def get_cosmic_prescription(request: PrescriptionRequest) -> CosmicPrescription:
    """
    Get personalized cosmic prescription based on current transits.
    
    Analyzes the user's natal chart against current planetary transits
    to recommend a brainwave frequency mode with AI-generated prescription text.
    
    The prescription includes:
    - Primary transit (most significant aspect)
    - Secondary transits (up to 2 more)
    - Recommended brainwave mode and frequency
    - AI-generated 3-part prescription:
        - What's happening (the transit)
        - How it might feel (human experience)
        - What the frequency does (the medicine)
    
    Args:
        request: User's birth data (datetime, lat, lon, timezone)
        
    Returns:
        CosmicPrescription with recommendation and prescription text
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
        
        # Calculate prescription data
        prescription_data = calculate_prescription(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude,
        )
        
        # Get AI service for text generation
        ai_service = get_ai_service()
        
        # Generate prescription text
        if prescription_data["is_quiet_day"]:
            ai_text = ai_service.generate_prescription_text(
                transit_planet="",
                natal_planet="",
                aspect="",
                recommended_mode=prescription_data["recommended_mode"].value,
                brainwave_hz=prescription_data["brainwave_hz"],
                effect_description=prescription_data.get("effect_description", ""),
                is_quiet_day=True,
            )
        else:
            primary = prescription_data["primary_transit"]
            ai_text = ai_service.generate_prescription_text(
                transit_planet=primary.transit_planet,
                natal_planet=primary.natal_planet,
                aspect=primary.aspect,
                recommended_mode=prescription_data["recommended_mode"].value,
                brainwave_hz=prescription_data["brainwave_hz"],
                effect_description=prescription_data.get("effect_description", ""),
                is_quiet_day=False,
            )
        
        # Build final response
        return CosmicPrescription(
            primary_transit=prescription_data["primary_transit"],
            secondary_transits=prescription_data["secondary_transits"],
            recommended_mode=prescription_data["recommended_mode"],
            brainwave_hz=prescription_data["brainwave_hz"],
            carrier_frequency_hz=prescription_data["carrier_frequency_hz"],
            carrier_planet=prescription_data["carrier_planet"],
            whats_happening=ai_text["whats_happening"],
            how_it_feels=ai_text["how_it_feels"],
            what_it_does=ai_text["what_it_does"],
            is_quiet_day=prescription_data["is_quiet_day"],
            transit_count=prescription_data["transit_count"],
            available_modes=prescription_data["available_modes"],
        )
        
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid datetime format: {str(e)}"
        )
    except Exception as e:
        print(f"[ERROR] Prescription calculation failed: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating prescription: {str(e)}"
        )
