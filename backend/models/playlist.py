"""
Playlist models for Astro.FM matching algorithm.
Defines PlaylistResult and PlaylistRequest for playlist generation.

S2: Documentation Rule - All models include clear docstrings.
"""
from pydantic import BaseModel, Field, field_validator, computed_field
from typing import Optional, List, Dict, Any
from datetime import datetime

from models.song import Song


class PlaylistResult(BaseModel):
    """Result of playlist generation including songs and metadata."""
    
    songs: List[Song] = Field(
        ...,
        min_length=1,
        max_length=50,
        description="Ordered list of selected songs"
    )
    total_duration_seconds: int = Field(
        ...,
        ge=0,
        description="Sum of all song durations"
    )
    vibe_match_score: float = Field(
        ...,
        ge=0,
        le=100,
        description="Overall playlist match quality (0-100)"
    )
    energy_arc: List[int] = Field(
        ...,
        description="Energy value for each song position"
    )
    element_distribution: Dict[str, int] = Field(
        ...,
        description="Count per element"
    )
    mood_distribution: Dict[str, int] = Field(
        ...,
        description="Count per mood"
    )
    generation_metadata: Dict[str, Any] = Field(
        default_factory=dict,
        description="Debug/transparency info"
    )
    
    @computed_field
    @property
    def duration_minutes(self) -> float:
        """Total duration in minutes."""
        return round(self.total_duration_seconds / 60, 1)
    
    @computed_field
    @property
    def song_count(self) -> int:
        """Number of songs in playlist."""
        return len(self.songs)
    
    @field_validator('energy_arc')
    @classmethod
    def validate_energy_arc(cls, v: List[int]) -> List[int]:
        """Validate all energy values are 0-100."""
        for energy in v:
            if not 0 <= energy <= 100:
                raise ValueError(f"Energy values must be 0-100, got {energy}")
        return v


class PlaylistRequest(BaseModel):
    """Request parameters for playlist generation (for API use in Phase 4)."""
    
    birth_datetime: str = Field(
        ...,
        description="Birth date/time in ISO format"
    )
    latitude: float = Field(
        ...,
        ge=-90,
        le=90,
        description="Birth location latitude"
    )
    longitude: float = Field(
        ...,
        ge=-180,
        le=180,
        description="Birth location longitude"
    )
    timezone: str = Field(
        default="UTC",
        description="Timezone for birth time interpretation"
    )
    playlist_size: int = Field(
        default=20,
        ge=10,
        le=30,
        description="Number of songs to include (10-30)"
    )
    current_datetime: Optional[str] = Field(
        None,
        description="Current date/time for transits (defaults to now)"
    )
    current_latitude: Optional[float] = Field(
        None,
        ge=-90,
        le=90,
        description="Current location latitude (defaults to birth location)"
    )
    current_longitude: Optional[float] = Field(
        None,
        ge=-180,
        le=180,
        description="Current location longitude (defaults to birth location)"
    )
    genre_preferences: List[str] = Field(
        default_factory=list,
        description="User's preferred music genres"
    )
    
    @field_validator('birth_datetime', 'current_datetime')
    @classmethod
    def validate_datetime_format(cls, v: Optional[str]) -> Optional[str]:
        """Validate datetime is in parseable format."""
        if v is None:
            return v
        try:
            # Try parsing ISO format
            datetime.fromisoformat(v.replace('Z', '+00:00'))
        except ValueError:
            raise ValueError(f"Invalid datetime format: '{v}'. Use ISO format (YYYY-MM-DDTHH:MM:SS)")
        return v
