"""
Pydantic models for sonification data.
Implements validation for the Steiner Zodiac Tone Circle Sound Signature system.
"""
from pydantic import BaseModel, Field
from typing import Optional


# =============================================================================
# LEGACY MODELS (for backward compatibility during Steiner migration)
# TODO: Remove these after full migration to Steiner system
# =============================================================================

class HouseTimbre(BaseModel):
    """
    Legacy house timbre model for Cosmic Octave method.
    Defines filter and envelope characteristics per house.
    """
    house: int = Field(..., ge=1, le=12, description="House number (1-12)")
    life_area: str = Field(..., description="Life area this house represents")
    quality: str = Field(..., description="House quality: Angular, Succedent, or Cadent")
    sound_quality: str = Field(..., description="Descriptive sound quality")
    filter_type: str = Field(..., description="Filter type: low_pass, high_pass, band_pass, none")
    filter_cutoff: float = Field(..., ge=0, description="Filter cutoff frequency in Hz")
    attack: float = Field(..., ge=0, description="Attack time in seconds")
    decay: float = Field(..., ge=0, description="Decay time in seconds")
    reverb: float = Field(..., ge=0, le=1, description="Reverb amount (0-1)")
    stereo_width: float = Field(..., ge=0, le=1, description="Stereo width (0-1)")


class PlanetSound(BaseModel):
    """
    Legacy planet sound model for Cosmic Octave method.
    Contains all audio synthesis parameters for a planet.
    """
    planet: str = Field(..., description="Planet name")
    frequency: float = Field(..., gt=0, description="Frequency in Hz")
    intensity: float = Field(..., ge=0, le=1, description="Intensity/volume (0-1)")
    role: str = Field(..., description="Synthesis role: carrier, modulator, drone, etc.")
    filter_type: str = Field(..., description="Filter type from house timbre")
    filter_cutoff: float = Field(..., ge=0, description="Filter cutoff in Hz")
    attack: float = Field(..., ge=0, description="Attack time in seconds")
    decay: float = Field(..., ge=0, description="Decay time in seconds")
    reverb: float = Field(..., ge=0, le=1, description="Reverb amount (0-1)")
    pan: float = Field(..., ge=-1, le=1, description="Stereo pan (-1=left, 1=right)")
    house: int = Field(..., ge=1, le=12, description="House placement")
    house_degree: float = Field(..., ge=0, description="Degree within house (0-30)")
    sign: str = Field(..., description="Zodiac sign")


# =============================================================================
# NEW STEINER MODELS
# =============================================================================

class SoundSignatureNote(BaseModel):
    """
    A single note in the Sound Signature chord.
    """
    note: str = Field(..., description="Note name (e.g., 'E', 'A', 'B♭')")
    frequency: float = Field(..., gt=0, description="Frequency in Hz")
    octave: int = Field(..., ge=2, le=6, description="Octave number (3=low, 4=mid, 5=high)")
    weight: float = Field(..., ge=0, description="Weighted contribution score")
    sources: list[str] = Field(..., description="Which Big Four contributed this note")


class AspectModulation(BaseModel):
    """
    Sound modulation based on aspect between Big Four.
    """
    aspect_type: str = Field(..., description="Type: conjunction, sextile, square, trine, opposition")
    planet_a: str = Field(..., description="First planet/point")
    planet_b: str = Field(..., description="Second planet/point")
    orb: float = Field(..., ge=0, description="Orb in degrees")
    effect: str = Field(..., description="Sound effect: unison, shimmer, ring_mod, chorus, phase")
    intensity: float = Field(..., ge=0, le=1, description="Effect intensity based on orb (0-1)")


class TextureNote(BaseModel):
    """
    Background texture note from non-Big-Four planets.
    """
    planet: str = Field(..., description="Planet name")
    note: str = Field(..., description="Root note")
    frequency: float = Field(..., gt=0, description="Frequency in Hz")


class PlanetChord(BaseModel):
    """
    Chord-based planet sound using Steiner Zodiac Tone Circle.
    Each planet plays its sign's major triad (root, third, fifth).
    """
    planet: str = Field(..., description="Planet name")
    sign: str = Field(..., description="Zodiac sign the planet is in")
    house: int = Field(..., ge=1, le=12, description="House placement")
    house_degree: float = Field(..., ge=0, description="Degree within house")
    
    # The 3-note chord (triad) from the sign
    root_note: str = Field(..., description="Root note of sign chord")
    third_note: str = Field(..., description="Third of sign chord")
    fifth_note: str = Field(..., description="Fifth of sign chord")
    
    # Frequencies for each note
    root_frequency: float = Field(..., gt=0, description="Root note frequency in Hz")
    third_frequency: float = Field(..., gt=0, description="Third note frequency in Hz")
    fifth_frequency: float = Field(..., gt=0, description="Fifth note frequency in Hz")
    
    # Audio params
    intensity: float = Field(..., ge=0, le=1, description="Volume based on house degree")
    pan: float = Field(..., ge=-1, le=1, description="Stereo position")


class ChartSonification(BaseModel):
    """
    Complete Sound Signature data for an astrological chart.
    Uses Steiner Zodiac Tone Circle method.
    """
    sound_signature: list[SoundSignatureNote] = Field(
        ..., 
        min_length=1,
        max_length=5,
        description="The 5-note Sound Signature chord"
    )
    aspects: list[AspectModulation] = Field(
        default_factory=list,
        description="Aspects between Big Four with sound modulations"
    )
    texture_layer: list[TextureNote] = Field(
        default_factory=list,
        description="Background texture from other planets"
    )
    ascendant_sign: str = Field(..., description="Rising sign")
    chart_ruler: str = Field(..., description="Planet ruling the ascendant")
    big_four: dict[str, dict] = Field(
        ..., 
        description="Big Four data: Sun, Moon, Rising, ChartRuler with sign/degree"
    )
    planets: list[PlanetSound] = Field(
        default_factory=list,
        description="All individual planet sounds (legacy - for visualization)"
    )
    planet_chords: list[PlanetChord] = Field(
        default_factory=list,
        description="Chord-based planet sounds (new Steiner model)"
    )


class SonificationRequest(BaseModel):
    """
    Request model for user sonification.
    Uses same structure as birth data for charts.
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


class DailySonificationRequest(BaseModel):
    """
    Optional request model for daily sonification.
    Location affects ascendant calculation for house placement.
    """
    latitude: float = Field(
        default=0.0,
        ge=-90.0,
        le=90.0,
        description="Observer latitude (default: equator)"
    )
    longitude: float = Field(
        default=0.0,
        ge=-180.0,
        le=180.0,
        description="Observer longitude (default: prime meridian)"
    )


class FriendAlignmentRequest(BaseModel):
    """
    Request model for friend Sound Signature alignment.
    Compares user's natal chart with friend's natal chart.
    """
    # User birth data
    user_datetime: str = Field(
        ...,
        description="User birth date and time in ISO format",
        examples=["1990-07-15T15:42:00"]
    )
    user_latitude: float = Field(..., ge=-90.0, le=90.0, description="User birth latitude")
    user_longitude: float = Field(..., ge=-180.0, le=180.0, description="User birth longitude")
    user_timezone: str = Field(default="UTC", description="User timezone")
    
    # Friend birth data
    friend_datetime: str = Field(
        ...,
        description="Friend birth date and time in ISO format",
        examples=["1992-03-21T14:30:00"]
    )
    friend_latitude: float = Field(..., ge=-90.0, le=90.0, description="Friend birth latitude")
    friend_longitude: float = Field(..., ge=-180.0, le=180.0, description="Friend birth longitude")
    friend_timezone: str = Field(default="UTC", description="Friend timezone")
    
    # Optional friend name for personalized explanation
    friend_name: Optional[str] = Field(None, description="Friend's name for personalized explanation")


# =============================================================================
# ALIGNMENT SOUND MODELS
# Compare personal and daily Sound Signatures to create alignment meditation
# =============================================================================

class NotePair(BaseModel):
    """A pair of notes for harmonic/tension analysis."""
    note_a: str = Field(..., description="First note")
    note_b: str = Field(..., description="Second note")
    interval: str = Field(..., description="Musical interval between notes")
    quality: str = Field(..., description="Interval quality: consonant, dissonant, neutral")


class AlignmentAnalysis(BaseModel):
    """
    Analysis of alignment between personal and daily Sound Signatures.
    """
    shared_notes: list[str] = Field(
        default_factory=list,
        description="Notes present in both signatures (anchor points)"
    )
    personal_unique: list[str] = Field(
        default_factory=list,
        description="Notes only in personal signature (your unique energy)"
    )
    daily_unique: list[str] = Field(
        default_factory=list,
        description="Notes only in daily signature (what to attune to)"
    )
    harmonic_pairs: list[NotePair] = Field(
        default_factory=list,
        description="Note pairs that form harmonious intervals"
    )
    tension_pairs: list[NotePair] = Field(
        default_factory=list,
        description="Note pairs that form dissonant intervals"
    )
    alignment_score: int = Field(
        ..., 
        ge=0, 
        le=100, 
        description="Overall alignment score (0=clashing, 100=perfect harmony)"
    )


class AlignmentSound(BaseModel):
    """
    The alignment meditation sound composition.
    """
    anchor_notes: list[SoundSignatureNote] = Field(
        ...,
        description="Shared notes played at full volume (where you're already aligned)"
    )
    attune_notes: list[SoundSignatureNote] = Field(
        ...,
        description="Daily-unique notes played softly (what to lean into)"
    )
    bridge_note: Optional[SoundSignatureNote] = Field(
        None,
        description="A resolving note that bridges tensions (if any exist)"
    )
    suggested_duration: float = Field(
        default=180.0,
        description="Suggested meditation duration in seconds"
    )


class AlignmentResponse(BaseModel):
    """
    Complete response for alignment sound request.
    """
    analysis: AlignmentAnalysis = Field(..., description="Comparison analysis")
    sound: AlignmentSound = Field(..., description="The alignment meditation sound")
    personal_signature: ChartSonification = Field(..., description="User's natal Sound Signature")
    daily_signature: ChartSonification = Field(..., description="Today's transit Sound Signature")
    explanation: str = Field(..., description="AI-generated explanation of the alignment")
