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
    AlignmentResponse,
    FriendAlignmentRequest,
)
from services.sonification import (
    calculate_user_sonification,
    calculate_daily_sonification,
)
from services.alignment_sound import (
    compare_signatures,
    generate_alignment_sound,
)

router = APIRouter(tags=["sonification"])


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
            except Exception as e:
                print(f"[WARN] Timezone conversion failed for '{request.timezone}': {e}")
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


@router.post("/alignment", response_model=AlignmentResponse)
async def get_alignment_sound(request: SonificationRequest) -> AlignmentResponse:
    """
    Generate alignment sound between personal and daily Sound Signatures.
    
    Compares the user's natal Sound Signature with today's transit
    Sound Signature, identifies harmonies and tensions, and generates
    a meditation sound to help align with the day's energy.
    
    Args:
        request: User's birth data (datetime, latitude, longitude)
        
    Returns:
        AlignmentResponse with analysis, sound, and AI explanation
    """
    try:
        # Parse datetime
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
        
        # Get personal Sound Signature
        personal = calculate_user_sonification(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        # Get daily Sound Signature (using user's location)
        daily = calculate_daily_sonification(
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        # Compare signatures
        analysis = compare_signatures(personal, daily)
        
        # Generate alignment sound
        sound = generate_alignment_sound(analysis, personal, daily)
        
        # Generate AI explanation (placeholder for now)
        # TODO: Integrate with AI service
        explanation = _generate_simple_explanation(analysis)
        
        return AlignmentResponse(
            analysis=analysis,
            sound=sound,
            personal_signature=personal,
            daily_signature=daily,
            explanation=explanation
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating alignment: {str(e)}"
        )


def _generate_simple_explanation(analysis) -> str:
    """Generate a simple explanation without AI (placeholder)."""
    parts = []
    
    if analysis.shared_notes:
        notes = ", ".join(analysis.shared_notes)
        parts.append(f"Your Sound Signature shares {len(analysis.shared_notes)} note(s) with today's energy: {notes}. These are your anchor points - you're already naturally aligned here.")
    
    if analysis.daily_unique:
        notes = ", ".join(analysis.daily_unique)
        parts.append(f"Today's unique notes are: {notes}. The alignment sound helps you gently attune to this energy.")
    
    if analysis.tension_pairs:
        pairs = [f"{p.note_a}-{p.note_b} ({p.interval})" for p in analysis.tension_pairs]
        parts.append(f"There's some creative tension between: {', '.join(pairs)}. The bridge note in the meditation helps resolve this.")
    
    if analysis.alignment_score >= 80:
        parts.append(f"With an alignment score of {analysis.alignment_score}%, you and the day are in great harmony!")
    elif analysis.alignment_score >= 50:
        parts.append(f"Your alignment score is {analysis.alignment_score}%. A short meditation will help you sync up.")
    else:
        parts.append(f"With an alignment score of {analysis.alignment_score}%, today's energy is quite different from your signature. Take some extra time with the meditation.")
    
    return " ".join(parts)


def _generate_friend_explanation(analysis, friend_name: str = None) -> str:
    """Generate explanation for friend alignment."""
    name = friend_name or "your friend"
    parts = []
    
    if analysis.shared_notes:
        notes = ", ".join(analysis.shared_notes)
        parts.append(f"You and {name} share {len(analysis.shared_notes)} note(s): {notes}. These create natural harmony between you.")
    
    if analysis.personal_unique:
        notes = ", ".join(analysis.personal_unique)
        parts.append(f"Your unique notes ({notes}) bring your individual energy to the connection.")
    
    if analysis.daily_unique:
        notes = ", ".join(analysis.daily_unique)
        parts.append(f"{name.capitalize()}'s unique notes ({notes}) complement yours.")
    
    if analysis.tension_pairs:
        pairs = [f"{p.note_a}-{p.note_b} ({p.interval})" for p in analysis.tension_pairs]
        parts.append(f"The creative tension between {', '.join(pairs)} adds dynamic energy. The bridge note helps harmonize this.")
    
    if analysis.alignment_score >= 80:
        parts.append(f"With {analysis.alignment_score}% alignment, your Sound Signatures resonate beautifully!")
    elif analysis.alignment_score >= 50:
        parts.append(f"At {analysis.alignment_score}% alignment, you complement each other well with room for growth.")
    else:
        parts.append(f"At {analysis.alignment_score}% alignment, your different energies create interesting dynamics. The meditation sound bridges these differences.")
    
    return " ".join(parts)


@router.post("/friend-alignment", response_model=AlignmentResponse)
async def get_friend_alignment_sound(request: FriendAlignmentRequest) -> AlignmentResponse:
    """
    Generate alignment sound between user and friend Sound Signatures.
    
    Compares two natal Sound Signatures, identifies harmonies and tensions,
    and generates a meditation sound to strengthen the connection.
    
    Args:
        request: User and friend birth data
        
    Returns:
        AlignmentResponse with analysis, sound, and explanation
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
                raise HTTPException(status_code=400, detail=f"Invalid user timezone: {request.user_timezone}")
        
        # Parse friend datetime
        friend_dt = datetime.fromisoformat(request.friend_datetime)
        if request.friend_timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.friend_timezone)
                friend_dt = friend_dt.replace(tzinfo=local_tz)
                friend_dt = friend_dt.astimezone(ZoneInfo("UTC"))
                friend_dt = friend_dt.replace(tzinfo=None)
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Invalid friend timezone: {request.friend_timezone}")
        
        # Get user's Sound Signature
        user_signature = calculate_user_sonification(
            birth_datetime=user_dt,
            latitude=request.user_latitude,
            longitude=request.user_longitude
        )
        
        # Get friend's Sound Signature
        friend_signature = calculate_user_sonification(
            birth_datetime=friend_dt,
            latitude=request.friend_latitude,
            longitude=request.friend_longitude
        )
        
        # Compare signatures
        analysis = compare_signatures(user_signature, friend_signature)
        
        # Generate alignment sound
        sound = generate_alignment_sound(analysis, user_signature, friend_signature)
        
        # Generate explanation
        explanation = _generate_friend_explanation(analysis, request.friend_name)
        
        return AlignmentResponse(
            analysis=analysis,
            sound=sound,
            personal_signature=user_signature,
            daily_signature=friend_signature,  # Reusing field for friend signature
            explanation=explanation
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating friend alignment: {str(e)}"
        )

