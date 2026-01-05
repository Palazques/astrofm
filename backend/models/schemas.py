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
    DEPRECATED: Kept for backward compatibility. New apps should use DailyHoroscopeResponse.
    
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
    Response model for AI-generated daily horoscope.
    
    Transit-focused general horoscope that reflects what today holds based on
    actual planetary positions, personalized by Sun sign.
    """
    headline: str = Field(..., description="Short punchy headline (3-5 words)")
    subheadline: str = Field(default="", description="Contextual subtitle (e.g. house placement)")
    horoscope: str = Field(..., description="2-3 sentence daily horoscope")
    cosmic_weather: str = Field(..., description="Today's cosmic weather summary with real transit data")
    energy_level: int = Field(..., ge=0, le=100, description="Day's energy level 0-100")
    focus_area: str = Field(..., description="Life area to focus on today")
    moon_phase: str = Field(..., description="Current moon phase name")
    dominant_element: str = Field(..., description="Dominant element today (Fire/Earth/Air/Water)")
    actionable_advice: str = Field(default="", description="Specific, actionable advice for today (the 'So What?')")
    energy_label: str = Field(default="Intensity", description="Label for the energy bar (Volatility or Vitality)")
    house_context: str = Field(default="", description="The specific life area (natal house) being activated")
    playlist_params: PlaylistParams = Field(..., description="Playlist generation parameters")
    generated_at: str = Field(..., description="Generation timestamp ISO format")
    
    # Legacy fields for backward compatibility
    reading: str = Field(default="", description="Legacy reading text (deprecated, use horoscope)")
    signals: list[DailySignal] = Field(
        default=[],
        description="DEPRECATED: Structured signals (use horoscope instead)"
    )


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
    retrograde_start: Optional[str] = Field(None, description="Retrograde start date (ISO format) if retrograde")
    retrograde_end: Optional[str] = Field(None, description="Retrograde end date (ISO format) if retrograde")


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


# Transit Alignment Models (for comparing natal chart with current transits)

class NatalPositionData(BaseModel):
    """Natal planet position data."""
    sign: str = Field(..., description="Zodiac sign")
    degree: float = Field(..., ge=0, le=30, description="Degree within sign (0-30)")
    house: int = Field(..., ge=1, le=12, description="House placement (1-12)")
    longitude: Optional[float] = Field(None, description="Absolute longitude (0-360)")


class TransitPositionData(BaseModel):
    """Transit planet position data."""
    sign: str = Field(..., description="Zodiac sign")
    degree: float = Field(..., ge=0, le=30, description="Degree within sign (0-30)")
    house: int = Field(..., ge=1, le=12, description="House placement (1-12)")
    retrograde: bool = Field(default=False, description="Is planet retrograde")
    longitude: Optional[float] = Field(None, description="Absolute longitude (0-360)")


class TransitAlignmentPlanet(BaseModel):
    """
    Complete alignment data for a single planet.
    Combines natal and transit positions with gap/resonance status and insight.
    """
    id: str = Field(..., description="Planet identifier (lowercase name)")
    name: str = Field(..., description="Planet name")
    symbol: str = Field(..., description="Planet unicode symbol")
    color: str = Field(..., description="Planet color hex code")
    natal: NatalPositionData = Field(..., description="Natal position")
    transit: TransitPositionData = Field(..., description="Current transit position")
    frequency: float = Field(..., ge=0, description="Steiner-accurate frequency in Hz")
    status: str = Field(..., description="'gap', 'resonance', 'alignment', or 'integration'")
    aspect_type: str = Field("None", description="Type of aspect (e.g., 'Square', 'Conjunction')")
    orb: float = Field(0.0, description="Distance from exact aspect in degrees")
    is_applying: bool = Field(True, description="True if the aspect is closing/building")
    pull: str = Field(..., description="Explanation of the tension/harmony")
    feelings: list[str] = Field(..., description="3-4 symptom descriptions")
    practice: str = Field(..., description="Actionable guidance")


class TransitAlignmentRequest(BaseModel):
    """
    Request model for transit alignment calculation.
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
    target_date: Optional[str] = Field(
        default=None,
        description="Optional target date for transits (ISO format, defaults to now)"
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


class TransitAlignmentResponse(BaseModel):
    """
    Response model for transit alignment calculation.
    Contains planet alignments with gap/resonance status and insights.
    """
    planets: list[TransitAlignmentPlanet] = Field(
        ...,
        description="Alignment data for each planet"
    )
    gap_count: int = Field(..., ge=0, description="Number of major gaps (Mars-Pluto)")
    resonance_count: int = Field(..., ge=0, description="Number of major resonances")
    is_major_life_shift: bool = Field(False, description="True if 3+ planets are in tight aspect with an anchor planet")


# Friend Harmony Suggestions Models (for "Listen to Your Friends Blend")

class FriendDataForSuggestion(BaseModel):
    """Friend data required for harmony suggestion calculation."""
    id: int = Field(..., description="Friend's unique ID")
    name: str = Field(..., description="Friend's display name")
    sun_sign: str = Field(..., description="Friend's natal Sun sign")
    moon_sign: Optional[str] = Field(None, description="Friend's natal Moon sign (optional)")
    rising_sign: Optional[str] = Field(None, description="Friend's rising sign (optional)")
    avatar_colors: Optional[list[int]] = Field(None, description="Avatar gradient color hex values")


class FriendSuggestionsRequest(BaseModel):
    """Request model for friend alignment suggestions."""
    user_id: str = Field(default="default", description="User ID for caching")
    friends: list[FriendDataForSuggestion] = Field(..., description="List of friends to analyze")
    force_refresh: bool = Field(default=False, description="Bypass cache if True")


class FriendHarmonySuggestion(BaseModel):
    """A single friend harmony suggestion."""
    friend_id: int = Field(..., description="Friend's unique ID")
    score: int = Field(..., ge=0, le=100, description="Harmony score 0-100")
    glow_color: str = Field(..., description="Hex color for UI glow effect")
    context_string: str = Field(..., description="Human-readable reason for suggestion")
    harmony_type: str = Field(..., description="Type: 'lunar', 'transit', or 'mixed'")


class FriendSuggestionsResponse(BaseModel):
    """Response model for friend alignment suggestions."""
    suggestions: list[FriendHarmonySuggestion] = Field(..., description="Top 3 friend suggestions")
    current_moon_sign: str = Field(..., description="Current Moon sign for context")
    refresh_at: str = Field(..., description="Next refresh time (ISO format)")
    from_cache: bool = Field(default=False, description="True if returned from cache")
