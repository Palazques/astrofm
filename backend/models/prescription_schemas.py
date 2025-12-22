"""
Prescription schemas for Cosmic Prescription feature.

Defines models for brainwave recommendations based on transit-to-natal aspects.

S2: Documentation Rule - All models include clear docstrings.
"""
from enum import Enum
from typing import Optional, List
from pydantic import BaseModel, Field


class BrainwaveMode(str, Enum):
    """Brainwave frequency modes for cosmic prescription."""
    FOCUS = "focus"      # 18-22 Hz Beta - mental clarity
    CALM = "calm"        # 10 Hz Alpha - relaxation
    DEEP = "deep"        # 5-6 Hz Theta - subconscious processing
    EXPAND = "expand"    # 40 Hz Gamma - breakthrough integration
    REST = "rest"        # 2-3 Hz Delta - deep restoration
    NEUTRAL = "neutral"  # User choice - no specific recommendation


# Brainwave Hz values for each mode
BRAINWAVE_HZ = {
    BrainwaveMode.FOCUS: 18.0,
    BrainwaveMode.CALM: 10.0,
    BrainwaveMode.DEEP: 5.0,
    BrainwaveMode.EXPAND: 40.0,
    BrainwaveMode.REST: 2.0,
    BrainwaveMode.NEUTRAL: 10.0,  # Default to Alpha for neutral
}


# Cosmic Octave frequencies for each planet (Hz)
PLANET_FREQUENCIES = {
    "Sun": 126.22,
    "Moon": 210.42,
    "Mercury": 141.27,
    "Venus": 221.23,
    "Mars": 144.72,
    "Jupiter": 183.58,
    "Saturn": 147.85,
    "Uranus": 207.36,
    "Neptune": 211.44,
    "Pluto": 140.25,
}


class TransitPrescription(BaseModel):
    """A single transit-to-natal aspect for prescription."""
    transit_planet: str = Field(..., description="Transiting planet name")
    natal_planet: str = Field(..., description="Natal planet or point name")
    aspect: str = Field(..., description="Aspect type (Conjunction, Square, etc.)")
    orb: float = Field(..., description="Orb in degrees")
    nature: str = Field(..., description="Aspect nature: harmonious, challenging, neutral")


class PrescriptionRequest(BaseModel):
    """Request for cosmic prescription."""
    datetime_str: str = Field(..., alias="datetime", description="Birth datetime ISO string")
    latitude: float = Field(..., ge=-90, le=90, description="Birth latitude")
    longitude: float = Field(..., ge=-180, le=180, description="Birth longitude")
    timezone: str = Field(default="UTC", description="Timezone name")
    
    class Config:
        populate_by_name = True


class ModeInfo(BaseModel):
    """Information about a brainwave mode."""
    mode: BrainwaveMode
    name: str
    hz: float
    description: str
    icon: str  # Emoji for UI


class CosmicPrescription(BaseModel):
    """Complete cosmic prescription response."""
    # Transit data
    primary_transit: Optional[TransitPrescription] = Field(
        None, 
        description="The most significant active transit"
    )
    secondary_transits: List[TransitPrescription] = Field(
        default_factory=list,
        description="Additional active transits (up to 2)"
    )
    
    # Recommended prescription
    recommended_mode: BrainwaveMode = Field(
        ..., 
        description="AI-recommended brainwave mode"
    )
    brainwave_hz: float = Field(..., description="Brainwave frequency in Hz")
    carrier_frequency_hz: float = Field(
        ..., 
        description="Carrier frequency (planet's Cosmic Octave)"
    )
    carrier_planet: str = Field(..., description="Planet used for carrier frequency")
    
    # AI-generated prescription text
    whats_happening: str = Field(
        ..., 
        description="Plain language transit explanation"
    )
    how_it_feels: str = Field(
        ..., 
        description="Human experience of this transit"
    )
    what_it_does: str = Field(
        ..., 
        description="What the recommended frequency does"
    )
    
    # Metadata
    is_quiet_day: bool = Field(
        default=False, 
        description="True if no significant transits active"
    )
    transit_count: int = Field(default=0, description="Total active transit count")
    
    # All available modes for user override
    available_modes: List[ModeInfo] = Field(
        default_factory=list,
        description="All 6 modes with info for mode picker"
    )


# Default mode descriptions for UI
MODE_INFO = {
    BrainwaveMode.FOCUS: ModeInfo(
        mode=BrainwaveMode.FOCUS,
        name="Focus",
        hz=18.0,
        description="Sharpens mental clarity and concentration",
        icon="🎯"
    ),
    BrainwaveMode.CALM: ModeInfo(
        mode=BrainwaveMode.CALM,
        name="Calm",
        hz=10.0,
        description="Creates emotional breathing room and relaxation",
        icon="🌊"
    ),
    BrainwaveMode.DEEP: ModeInfo(
        mode=BrainwaveMode.DEEP,
        name="Deep",
        hz=5.0,
        description="Opens safe channel to subconscious processing",
        icon="🌙"
    ),
    BrainwaveMode.EXPAND: ModeInfo(
        mode=BrainwaveMode.EXPAND,
        name="Expand",
        hz=40.0,
        description="Integrates breakthrough energy and insights",
        icon="✨"
    ),
    BrainwaveMode.REST: ModeInfo(
        mode=BrainwaveMode.REST,
        name="Rest",
        hz=2.0,
        description="Deep restoration and recovery",
        icon="😴"
    ),
    BrainwaveMode.NEUTRAL: ModeInfo(
        mode=BrainwaveMode.NEUTRAL,
        name="Neutral",
        hz=10.0,
        description="Choose your own intention",
        icon="⚖️"
    ),
}
