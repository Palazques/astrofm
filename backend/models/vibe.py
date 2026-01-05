"""
Vibe parameter models for Astro.FM playlist matching.
Defines target parameters output by the Vibe Calculator.

S2: Documentation Rule - All models include clear docstrings.
"""
from pydantic import BaseModel, Field, field_validator
from typing import Optional, List, Tuple

from data.constants import ELEMENTS, PLANETS, MOODS, MODALITIES, TIME_OF_DAY


class TransitData(BaseModel):
    """Current planetary positions and moon phase data."""
    
    planet_positions: dict = Field(
        ...,
        description="Planet name -> {longitude, sign, degree, element, modality}"
    )
    moon_phase: str = Field(
        ...,
        description="Current moon phase name"
    )
    moon_phase_days: float = Field(
        ...,
        ge=0,
        le=29.5,
        description="Days into current lunar cycle (0-29.5)"
    )
    
    @field_validator('moon_phase')
    @classmethod
    def validate_moon_phase(cls, v: str) -> str:
        """Validate moon phase is a recognized phase name."""
        valid_phases = [
            "New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
            "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"
        ]
        if v not in valid_phases:
            raise ValueError(f"Invalid moon phase: '{v}'. Must be one of: {valid_phases}")
        return v


class VibeParameters(BaseModel):
    """Target parameters for playlist matching, output by the Vibe Calculator."""
    
    target_energy: Tuple[int, int] = Field(
        ..., 
        description="Min/max energy range (0-100)"
    )
    target_valence: Tuple[int, int] = Field(
        ..., 
        description="Min/max valence/positivity range (0-100)"
    )
    primary_elements: List[str] = Field(
        ..., 
        min_length=1, 
        max_length=2,
        description="Primary elements to match"
    )
    secondary_elements: List[str] = Field(
        default_factory=list,
        max_length=2,
        description="Secondary/fallback elements"
    )
    active_planets: List[str] = Field(
        ...,
        min_length=2,
        max_length=4,
        description="Currently emphasized planetary energies"
    )
    mood_direction: List[str] = Field(
        ...,
        min_length=3,
        max_length=5,
        description="Target moods for the playlist"
    )
    intensity_range: Tuple[int, int] = Field(
        ...,
        description="Min/max cosmic intensity (0-100)"
    )
    time_of_day: Optional[str] = Field(
        None,
        description="Current time period or None"
    )
    modality_preference: Optional[str] = Field(
        None,
        description="Cardinal, Fixed, Mutable, or None"
    )
    cosmic_weather_summary: str = Field(
        ...,
        min_length=50,
        max_length=500,
        description="2-3 sentence description of cosmic weather"
    )
    genres: List[str] = Field(
        default_factory=list,
        description="Musical genres mapping to this vibe"
    )
    
    @field_validator('target_energy', 'target_valence', 'intensity_range')
    @classmethod
    def validate_ranges(cls, v: Tuple[int, int]) -> Tuple[int, int]:
        """Validate ranges are within 0-100 and min <= max."""
        min_val, max_val = v
        if not (0 <= min_val <= 100 and 0 <= max_val <= 100):
            raise ValueError(f"Range values must be 0-100, got {v}")
        if min_val > max_val:
            raise ValueError(f"Min must be <= max, got {v}")
        return v
    
    @field_validator('primary_elements', 'secondary_elements')
    @classmethod
    def validate_elements(cls, v: List[str]) -> List[str]:
        """Validate all elements are from the defined list."""
        valid_elements = list(ELEMENTS.keys())
        for element in v:
            if element not in valid_elements:
                raise ValueError(f"Invalid element: '{element}'. Must be one of: {valid_elements}")
        return v
    
    @field_validator('active_planets')
    @classmethod
    def validate_planets(cls, v: List[str]) -> List[str]:
        """Validate all planets are from the defined list."""
        valid_planets = list(PLANETS.keys())
        for planet in v:
            if planet not in valid_planets:
                raise ValueError(f"Invalid planet: '{planet}'. Must be one of: {valid_planets}")
        return v
    
    @field_validator('mood_direction')
    @classmethod
    def validate_moods(cls, v: List[str]) -> List[str]:
        """Validate all moods are from the defined list."""
        for mood in v:
            if mood not in MOODS:
                raise ValueError(f"Invalid mood: '{mood}'. Must be one of: {MOODS}")
        return v
    
    @field_validator('time_of_day')
    @classmethod
    def validate_time_of_day(cls, v: Optional[str]) -> Optional[str]:
        """Validate time of day is from the defined list."""
        if v is not None and v not in TIME_OF_DAY:
            raise ValueError(f"Invalid time_of_day: '{v}'. Must be one of: {TIME_OF_DAY}")
        return v
    
    @field_validator('modality_preference')
    @classmethod
    def validate_modality(cls, v: Optional[str]) -> Optional[str]:
        """Validate modality is from the defined list."""
        if v is not None and v not in MODALITIES:
            raise ValueError(f"Invalid modality: '{v}'. Must be one of: {list(MODALITIES.keys())}")
        return v
