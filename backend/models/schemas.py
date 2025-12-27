"""
Pydantic models for request/response validation.
Implements H2 (Input Validation) rule.
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, field_validator


class BirthDataRequest(BaseModel):
    """
    Request model for birth data input.
    All fields are validated for proper format and ranges.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format (YYYY-MM-DDTHH:MM:SS)",
        examples=["1990-01-15T14:30:00"]
    )
    latitude: float = Field(
        ...,
        ge=-90.0,
        le=90.0,
        description="Birth location latitude (-90 to 90)"
    )
    longitude: float = Field(
        ...,
        ge=-180.0,
        le=180.0,
        description="Birth location longitude (-180 to 180)"
    )
    timezone: str = Field(
        default="UTC",
        description="Timezone name (e.g., 'America/New_York', 'UTC')"
    )

    @field_validator('datetime_str')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        """Validate datetime string is in proper ISO format."""
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class PlanetPosition(BaseModel):
    """
    Model for a single planet's position data.
    """
    name: str = Field(..., description="Planet name")
    longitude: float = Field(..., description="Ecliptic longitude (0-360 degrees)")
    latitude: float = Field(..., description="Ecliptic latitude")
    distance: float = Field(..., description="Distance from Earth in AU")
    speed: float = Field(..., description="Daily motion in degrees")
    sign: str = Field(..., description="Zodiac sign")
    sign_degree: float = Field(..., description="Degree within the sign (0-30)")
    house: int = Field(..., ge=1, le=12, description="House placement (1-12)")
    house_degree: float = Field(..., description="Degree within the house (0-30)")
    retrograde: bool = Field(..., description="Is the planet retrograde")


class NatalChartResponse(BaseModel):
    """
    Response model for natal chart calculation.
    """
    birth_datetime: str = Field(..., description="Input birth datetime")
    latitude: float = Field(..., description="Input latitude")
    longitude: float = Field(..., description="Input longitude")
    timezone: str = Field(..., description="Input timezone")
    ascendant: float = Field(..., description="Ascendant degree")
    ascendant_sign: str = Field(..., description="Ascendant zodiac sign")
    planets: list[PlanetPosition] = Field(..., description="List of planet positions")
    house_cusps: list[float] = Field(..., description="Whole sign house cusp degrees")


class HealthResponse(BaseModel):
    """
    Response model for health check endpoint.
    """
    status: str = Field(..., description="Service status")
    version: str = Field(..., description="API version")
    ephemeris_available: bool = Field(..., description="Swiss Ephemeris availability")



# AI Service Models (H2 - Input Validation)

class PlaylistParams(BaseModel):
    """
    Playlist generation parameters from AI.
    """
    bpm_min: int = Field(default=110, ge=60, le=200, description="Minimum BPM")
    bpm_max: int = Field(default=130, ge=60, le=200, description="Maximum BPM")
    energy: float = Field(default=0.6, ge=0.0, le=1.0, description="Energy level 0-1")
    valence: float = Field(default=0.5, ge=0.0, le=1.0, description="Positivity/valence 0-1")
    genres: list[str] = Field(default=["electronic", "ambient"], description="Recommended genres")
    key_mode: Optional[str] = Field(default="minor", description="Musical key mode")


class DailyReadingRequest(BaseModel):
    """
    Request model for daily reading generation.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format",
        examples=["1990-01-15T14:30:00"]
    )
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    timezone: str = Field(default="UTC")
    subject_name: Optional[str] = Field(
        default=None,
        description="Optional name of subject for third-person horoscope (e.g., friend's name)"
    )

    @field_validator('datetime_str')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class DailySignal(BaseModel):
    """
    Structured daily reading signal (Resonance, Feedback, or Dissonance).
    
    Each signal contains 3 message parts:
    - audio_message: Music/engineering metaphor (prominent)
    - cosmic_message: Light technical astrology (planet + feeling)
    - advice_message: Relatable, actionable wisdom
    """
    signal_type: str = Field(
        ...,
        description="Type: 'resonance' (positive), 'feedback' (warning), or 'dissonance' (challenge)"
    )
    category: str = Field(
        ...,
        description="Life area: Self, Communication, Love & Sex, Work, Creativity, etc."
    )
    category_meaning: str = Field(
        ...,
        description="Human-friendly explanation of the category"
    )
    message: str = Field(
        ...,
        description="Legacy single message (backward compat)"
    )
    audio_message: str = Field(
        default="",
        description="Music/audio engineering metaphor"
    )
    cosmic_message: str = Field(
        default="",
        description="Light technical astrology (planet name + accessible feeling)"
    )
    advice_message: str = Field(
        default="",
        description="Relatable, actionable wisdom (no astro/music terms)"
    )


class DailyReadingResponse(BaseModel):
    """
    Response model for AI-generated daily reading.
    
    Includes both the legacy 'reading' field (for backward compatibility)
    and the new 'signals' array for structured, categorized readings.
    """
    reading: str = Field(..., description="Personalized horoscope text (legacy)")
    signals: list[DailySignal] = Field(
        default=[],
        description="Structured reading signals: Resonance, Feedback, Dissonance"
    )
    playlist_params: PlaylistParams = Field(..., description="Playlist generation parameters")
    cosmic_weather: str = Field(..., description="Current cosmic weather summary")
    generated_at: str = Field(..., description="Generation timestamp ISO format")


class AlignmentRequest(BaseModel):
    """
    Request for alignment interpretation between two charts.
    """
    user_datetime: str = Field(..., description="User birth datetime ISO format")
    user_latitude: float = Field(..., ge=-90.0, le=90.0)
    user_longitude: float = Field(..., ge=-180.0, le=180.0)
    target_datetime: Optional[str] = Field(None, description="Target birth datetime (None for today)")
    target_latitude: Optional[float] = Field(None, ge=-90.0, le=90.0)
    target_longitude: Optional[float] = Field(None, ge=-180.0, le=180.0)


class AlignmentInterpretation(BaseModel):
    """
    Response for alignment interpretation.
    """
    interpretation: str = Field(..., description="AI-generated interpretation")
    resonance_score: int = Field(..., ge=0, le=100, description="Resonance percentage")
    harmonious_aspects: list[str] = Field(..., description="List of harmonious aspects")


class CompatibilityRequest(BaseModel):
    """
    Request for compatibility analysis between two people.
    """
    user_datetime: str = Field(..., description="User birth datetime ISO format")
    user_latitude: float = Field(..., ge=-90.0, le=90.0)
    user_longitude: float = Field(..., ge=-180.0, le=180.0)
    friend_datetime: str = Field(..., description="Friend birth datetime ISO format")
    friend_latitude: float = Field(..., ge=-90.0, le=90.0)
    friend_longitude: float = Field(..., ge=-180.0, le=180.0)
    friend_name: Optional[str] = Field(default=None, description="Friend's name for personalized narrative")


class CompatibilityResponse(BaseModel):
    """
    Response for compatibility analysis.
    """
    narrative: str = Field(..., description="Compatibility narrative")
    overall_score: int = Field(..., ge=0, le=100, description="Overall compatibility score")
    strengths: list[str] = Field(..., description="Relationship strengths")
    challenges: list[str] = Field(..., description="Potential challenges")
    shared_genres: list[str] = Field(..., description="Shared music genre recommendations")


# Alignment Calculation Models (Separate from AI interpretation models)

class AspectData(BaseModel):
    """
    Data for a single astrological aspect between two planets.
    """
    planet1: str = Field(..., description="First planet in the aspect")
    planet2: str = Field(..., description="Second planet in the aspect")
    aspect: str = Field(..., description="Aspect type (Conjunction, Trine, Square, etc.)")
    orb: float = Field(..., description="Orb in degrees (how exact the aspect is)")
    nature: str = Field(..., description="Aspect nature: harmonious, challenging, or neutral")


class TransitPosition(BaseModel):
    """
    Position data for a transiting planet.
    """
    name: str = Field(..., description="Planet name")
    sign: str = Field(..., description="Current zodiac sign")
    degree: float = Field(..., description="Degree within the sign (0-30)")
    house: Optional[int] = Field(None, ge=1, le=12, description="House placement if natal chart provided")
    retrograde: bool = Field(default=False, description="Is the planet retrograde")


class DailyAlignmentRequest(BaseModel):
    """
    Request model for daily alignment calculation.
    Uses same pattern as BirthDataRequest.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format (YYYY-MM-DDTHH:MM:SS)",
        examples=["1990-07-15T15:42:00"]
    )
    latitude: float = Field(
        ...,
        ge=-90.0,
        le=90.0,
        description="Birth location latitude (-90 to 90)"
    )
    longitude: float = Field(
        ...,
        ge=-180.0,
        le=180.0,
        description="Birth location longitude (-180 to 180)"
    )
    timezone: str = Field(
        default="UTC",
        description="Timezone name (e.g., 'America/Los_Angeles', 'UTC')"
    )

    @field_validator('datetime_str')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        """Validate datetime string is in proper ISO format."""
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class DailyAlignmentResponse(BaseModel):
    """
    Response model for daily alignment calculation.
    Contains score, active aspects, and interpretation.
    """
    score: int = Field(..., ge=0, le=100, description="Alignment score (0-100)")
    aspects: list[AspectData] = Field(..., description="List of active transit aspects")
    dominant_energy: str = Field(..., description="Dominant energy type (e.g., 'Harmonious', 'Transformative')")
    description: str = Field(..., description="Brief interpretation of current alignment")


class FriendAlignmentRequest(BaseModel):
    """
    Request model for synastry alignment between two people.
    """
    user_datetime: str = Field(..., description="User birth datetime ISO format")
    user_latitude: float = Field(..., ge=-90.0, le=90.0)
    user_longitude: float = Field(..., ge=-180.0, le=180.0)
    user_timezone: str = Field(default="UTC")
    friend_datetime: str = Field(..., description="Friend birth datetime ISO format")
    friend_latitude: float = Field(..., ge=-90.0, le=90.0)
    friend_longitude: float = Field(..., ge=-180.0, le=180.0)
    friend_timezone: str = Field(default="UTC")

    @field_validator('user_datetime', 'friend_datetime')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class FriendAlignmentResponse(BaseModel):
    """
    Response model for synastry alignment between two people.
    """
    score: int = Field(..., ge=0, le=100, description="Compatibility alignment score")
    aspects: list[AspectData] = Field(..., description="Synastry aspects between charts")
    dominant_energy: str = Field(..., description="Dominant relationship energy")
    description: str = Field(..., description="Brief compatibility interpretation")
    strengths: list[str] = Field(..., description="Relationship strengths from aspects")
    challenges: list[str] = Field(..., description="Growth areas from aspects")


class TransitsResponse(BaseModel):
    """
    Response model for current planetary transits.
    """
    planets: list[TransitPosition] = Field(..., description="Current planetary positions")
    moon_phase: str = Field(..., description="Current moon phase name")
    retrograde: list[str] = Field(..., description="List of retrograde planets")


class TransitInterpretationResponse(BaseModel):
    """
    Response model for AI-generated transit interpretation.
    """
    interpretation: str = Field(..., description="AI-generated cosmic weather summary")
    highlight_planet: str = Field(..., description="Most significant planet to highlight")
    highlight_reason: str = Field(..., description="Why this planet is significant")
    energy_description: str = Field(..., description="One-word energy description")
    moon_phase: str = Field(..., description="Current moon phase")
    retrograde_planets: list[str] = Field(..., description="Planets currently retrograde")


class PlaylistInsightRequest(BaseModel):
    """
    Request model for playlist insight generation.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format",
    )
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    energy_percent: int = Field(..., ge=0, le=100, description="Playlist energy level")
    dominant_mood: str = Field(..., description="Most common mood in playlist")
    dominant_element: str = Field(..., description="Most common element (Fire/Earth/Air/Water)")
    bpm_min: int = Field(..., ge=60, le=200, description="Minimum BPM in playlist")
    bpm_max: int = Field(..., ge=60, le=200, description="Maximum BPM in playlist")

    @field_validator('datetime_str')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class PlaylistInsightResponse(BaseModel):
    """
    Response model for AI-generated playlist insight.
    """
    insight: str = Field(..., description="Simple, relatable playlist explanation")
    energy_percent: int = Field(..., ge=0, le=100, description="Playlist energy level")
    dominant_mood: str = Field(..., description="Dominant mood in playlist")
    astro_highlight: str = Field(..., description="Key astrological placement")


class PlanetSoundData(BaseModel):
    """Planet data for sound interpretation request."""
    name: str = Field(..., description="Planet name")
    sign: str = Field(..., description="Zodiac sign")
    house: int = Field(..., ge=1, le=12, description="House placement")
    frequency: float = Field(..., ge=0, description="Frequency in Hz")


class SoundInterpretationRequest(BaseModel):
    """
    Request model for sound interpretation generation.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format",
    )
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    dominant_element: str = Field(..., description="Dominant element (Fire/Earth/Air/Water)")
    planets: list[PlanetSoundData] = Field(..., description="Planet sound data")

    @field_validator('datetime_str')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class SoundInterpretationResponse(BaseModel):
    """
    Response model for AI-generated sound interpretation.
    """
    personality: str = Field(..., description="Overall sonic personality description")
    today_influence: str = Field(..., description="Today's transit effect on sound")
    shift: str = Field(..., description="Short label for today's shift")
    planet_descriptions: dict[str, str] = Field(..., description="Per-planet sound descriptions")


class WelcomeMessageRequest(BaseModel):
    """
    Request model for personalized welcome message.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format",
    )
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)

    @field_validator('datetime_str')
    @classmethod
    def validate_datetime(cls, v: str) -> str:
        try:
            datetime.fromisoformat(v)
        except ValueError:
            raise ValueError("datetime must be in ISO format: YYYY-MM-DDTHH:MM:SS")
        return v


class WelcomeMessageResponse(BaseModel):
    """
    Response model for AI-generated welcome message for new users.
    """
    greeting: str = Field(..., description="Personalized warm welcome")
    personality: str = Field(..., description="Friendly personality description")
    sound_teaser: str = Field(..., description="Intriguing hint about their unique sound")


