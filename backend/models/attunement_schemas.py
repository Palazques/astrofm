"""
Pydantic models for attunement data.
Compares natal chart to daily transits to identify gaps and resonances.
"""
from pydantic import BaseModel, Field
from typing import Optional


class PlanetAttunement(BaseModel):
    """
    Comparison of a single planet between natal and transit.
    Identifies whether the planet is a gap, resonance, or neutral.
    """
    planet: str = Field(..., description="Planet name")
    
    # Natal chart data
    natal_intensity: float = Field(..., ge=0, le=1, description="Natal intensity (0-1)")
    natal_house: int = Field(..., ge=1, le=12, description="Natal house placement")
    natal_sign: str = Field(..., description="Natal zodiac sign")
    natal_frequency: float = Field(..., gt=0, description="Natal frequency in Hz")
    
    # Transit data
    transit_intensity: float = Field(..., ge=0, le=1, description="Transit intensity (0-1)")
    transit_house: int = Field(..., ge=1, le=12, description="Transit house placement")
    transit_sign: str = Field(..., description="Transit zodiac sign")
    transit_frequency: float = Field(..., gt=0, description="Transit frequency in Hz")
    
    # Comparison results
    intensity_gap: float = Field(
        ..., 
        ge=-1, 
        le=1, 
        description="Transit - Natal intensity. Positive = gap (need to attune), negative = amplifiable"
    )
    status: str = Field(
        ..., 
        description="gap, resonance, or neutral"
    )
    priority: int = Field(
        default=0,
        ge=0,
        description="Priority ranking (1 = highest priority gap/resonance)"
    )
    explanation: str = Field(
        default="",
        description="AI-generated explanation of why this needs attention"
    )


class AttunementAnalysis(BaseModel):
    """
    Complete attunement analysis comparing natal to daily transits.
    """
    # Core planet comparisons
    planets: list[PlanetAttunement] = Field(
        ..., 
        description="All planet comparisons"
    )
    
    # Filtered lists for UI
    gaps: list[PlanetAttunement] = Field(
        default_factory=list,
        description="Planets needing attunement (max 2)"
    )
    resonances: list[PlanetAttunement] = Field(
        default_factory=list,
        description="Planets naturally aligned with today"
    )
    
    # Overall metrics
    alignment_score: int = Field(
        ...,
        ge=0,
        le=100,
        description="Overall alignment percentage (0-100)"
    )
    
    # Notification triggers
    should_notify: bool = Field(
        default=False,
        description="Whether to send notification (low alignment or major transit)"
    )
    notification_reason: Optional[str] = Field(
        default=None,
        description="Reason for notification if should_notify is True"
    )
    
    # Metadata
    analysis_date: str = Field(..., description="Date of analysis in ISO format")
    dominant_gap_energy: Optional[str] = Field(
        default=None,
        description="Energy type of the primary gap (e.g., 'action', 'communication')"
    )


class WeeklyDigest(BaseModel):
    """
    Weekly summary of attunement patterns.
    Displayed on Sound screen (not a notification).
    """
    week_start: str = Field(..., description="Week start date ISO format")
    week_end: str = Field(..., description="Week end date ISO format")
    
    average_alignment: int = Field(
        ...,
        ge=0,
        le=100,
        description="Average alignment score for the week"
    )
    
    best_day: str = Field(..., description="Day with highest alignment")
    best_day_score: int = Field(..., ge=0, le=100)
    
    challenging_day: str = Field(..., description="Day with lowest alignment")
    challenging_day_score: int = Field(..., ge=0, le=100)
    
    common_gaps: list[str] = Field(
        default_factory=list,
        description="Most frequently appearing gap planets this week"
    )
    
    summary: str = Field(
        default="",
        description="AI-generated weekly summary"
    )


class AttunementRequest(BaseModel):
    """
    Request model for attunement analysis.
    Same structure as birth data inputs.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format",
        examples=["1990-07-15T15:42:00"]
    )
    latitude: float = Field(
        ...,
        ge=-90.0,
        le=90.0,
        description="Birth location latitude"
    )
    longitude: float = Field(
        ...,
        ge=-180.0,
        le=180.0,
        description="Birth location longitude"
    )
    timezone: str = Field(
        default="UTC",
        description="Timezone name"
    )


class AttunementSessionRequest(BaseModel):
    """
    Request model for starting an attunement session.
    """
    datetime_str: str = Field(
        ...,
        alias="datetime",
        description="Birth date and time in ISO format"
    )
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    
    # Session configuration
    planets: list[str] = Field(
        ...,
        min_length=1,
        description="List of planet names to attune to"
    )
    mode: str = Field(
        default="standard",
        description="Session mode: quick (1 min), standard (3 min), meditate (loop)"
    )
    session_type: str = Field(
        default="attune",
        description="attune (play transit frequencies) or amplify (play natal frequencies)"
    )
