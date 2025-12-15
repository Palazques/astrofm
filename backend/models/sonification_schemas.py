"""
Pydantic models for sonification data.
Implements validation for audio synthesis parameters.
"""
from pydantic import BaseModel, Field


class HouseTimbre(BaseModel):
    """
    Timbre/texture parameters for a house.
    Defines how planets in this house should sound.
    """
    house: int = Field(..., ge=1, le=12, description="House number (1-12)")
    life_area: str = Field(..., description="Life area this house represents")
    quality: str = Field(..., description="House quality (Angular/Succedent/Cadent)")
    sound_quality: str = Field(..., description="Descriptive sound quality")
    filter_type: str = Field(..., description="Filter type: high_pass, low_pass, band_pass, none")
    filter_cutoff: float = Field(..., ge=0, description="Filter cutoff frequency in Hz")
    attack: float = Field(..., ge=0, le=5, description="Attack time in seconds")
    decay: float = Field(..., ge=0, le=10, description="Decay time in seconds")
    reverb: float = Field(..., ge=0, le=1, description="Reverb wet/dry mix (0-1)")
    stereo_width: float = Field(..., ge=0, le=1, description="Stereo width (0-1)")


class PlanetSound(BaseModel):
    """
    Audio synthesis parameters for a single planet.
    Contains all information needed to generate the planet's tone.
    """
    planet: str = Field(..., description="Planet name")
    frequency: float = Field(..., gt=0, description="Base frequency in Hz")
    intensity: float = Field(..., ge=0, le=1, description="Volume/distinctness (0-1)")
    role: str = Field(..., description="Synthesis role: carrier, modulator, harmonic, etc.")
    filter_type: str = Field(..., description="Filter type from house timbre")
    filter_cutoff: float = Field(..., ge=0, description="Filter cutoff frequency in Hz")
    attack: float = Field(..., ge=0, description="Attack time in seconds")
    decay: float = Field(..., ge=0, description="Decay time in seconds")
    reverb: float = Field(..., ge=0, le=1, description="Reverb wet/dry mix (0-1)")
    pan: float = Field(..., ge=-1, le=1, description="Stereo pan (-1 left, 0 center, 1 right)")
    house: int = Field(..., ge=1, le=12, description="House placement (1-12)")
    house_degree: float = Field(..., ge=0, le=30, description="Degree within house (0-30)")
    sign: str = Field(..., description="Zodiac sign")


class ChartSonification(BaseModel):
    """
    Complete sonification data for an astrological chart.
    Contains all planet sounds plus overall metadata.
    """
    planets: list[PlanetSound] = Field(..., description="List of planet sounds")
    ascendant_sign: str = Field(..., description="Rising sign")
    dominant_frequency: float = Field(..., gt=0, description="Most prominent frequency in Hz")
    total_duration: float = Field(..., gt=0, description="Suggested playback duration in seconds")


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
