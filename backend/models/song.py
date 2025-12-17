"""
Pydantic model for Song data in Astro.FM playlist system.
Implements H2 (Input Validation) with strict field validation.
S2 (Documentation Rule) - All fields include clear docstrings.
"""
from typing import List, Optional
from pydantic import BaseModel, Field, field_validator

from data.constants import GENRES, MOODS, ELEMENTS, PLANETS, MODALITIES, TIME_OF_DAY


class Song(BaseModel):
    """
    Song model representing a track with musical and astrological attributes.
    
    Musical attributes mirror Spotify Audio Features.
    Astrological attributes will be derived from musical attributes in production.
    """
    
    # Identification
    id: str = Field(
        ...,
        pattern=r"^song_\d{3}$",
        description="Unique identifier (format: 'song_001')",
        examples=["song_001", "song_042", "song_100"]
    )
    title: str = Field(
        ...,
        min_length=1,
        max_length=200,
        description="Actual song title"
    )
    artist: str = Field(
        ...,
        min_length=1,
        max_length=200,
        description="Actual artist name"
    )
    album: str = Field(
        ...,
        min_length=1,
        max_length=200,
        description="Actual album name"
    )
    duration_seconds: int = Field(
        ...,
        ge=30,
        le=900,
        description="Track length in seconds (30-900 typical)"
    )
    
    # Musical attributes (mirrors Spotify Audio Features)
    bpm: int = Field(
        ...,
        ge=40,
        le=200,
        description="Tempo in beats per minute (40-200)"
    )
    energy: int = Field(
        ...,
        ge=0,
        le=100,
        description="Intensity measure (0-100)"
    )
    valence: int = Field(
        ...,
        ge=0,
        le=100,
        description="Positivity measure (0-100, low=sad, high=happy)"
    )
    danceability: int = Field(
        ...,
        ge=0,
        le=100,
        description="Groove factor (0-100)"
    )
    acousticness: int = Field(
        ...,
        ge=0,
        le=100,
        description="Acoustic vs electronic (0-100)"
    )
    instrumentalness: int = Field(
        ...,
        ge=0,
        le=100,
        description="Vocals vs instrumental (0-100)"
    )
    
    # Classification
    genres: List[str] = Field(
        ...,
        min_length=1,
        max_length=3,
        description="1-3 genres from the defined list"
    )
    moods: List[str] = Field(
        ...,
        min_length=2,
        max_length=4,
        description="2-4 moods from the defined list"
    )
    
    # Astrological mapping
    elements: List[str] = Field(
        ...,
        min_length=1,
        max_length=2,
        description="1-2 elements (Fire, Earth, Air, Water)"
    )
    planetary_energy: List[str] = Field(
        ...,
        min_length=1,
        max_length=3,
        description="1-3 planets representing the song's energy"
    )
    intensity: int = Field(
        ...,
        ge=0,
        le=100,
        description="Cosmic intensity (0-100)"
    )
    modality: Optional[str] = Field(
        default=None,
        description="Cardinal, Fixed, Mutable, or null"
    )
    time_of_day: Optional[List[str]] = Field(
        default=None,
        description="When this song fits best, or null"
    )
    
    # Validators
    @field_validator('genres')
    @classmethod
    def validate_genres(cls, v: List[str]) -> List[str]:
        """Validate all genres are from the defined list."""
        for genre in v:
            if genre not in GENRES:
                raise ValueError(f"Invalid genre: '{genre}'. Must be one of: {GENRES}")
        return v
    
    @field_validator('moods')
    @classmethod
    def validate_moods(cls, v: List[str]) -> List[str]:
        """Validate all moods are from the defined list."""
        for mood in v:
            if mood not in MOODS:
                raise ValueError(f"Invalid mood: '{mood}'. Must be one of: {MOODS}")
        return v
    
    @field_validator('elements')
    @classmethod
    def validate_elements(cls, v: List[str]) -> List[str]:
        """Validate all elements are from the defined list."""
        valid_elements = list(ELEMENTS.keys())
        for element in v:
            if element not in valid_elements:
                raise ValueError(f"Invalid element: '{element}'. Must be one of: {valid_elements}")
        return v
    
    @field_validator('planetary_energy')
    @classmethod
    def validate_planetary_energy(cls, v: List[str]) -> List[str]:
        """Validate all planets are from the defined list."""
        valid_planets = list(PLANETS.keys())
        for planet in v:
            if planet not in valid_planets:
                raise ValueError(f"Invalid planet: '{planet}'. Must be one of: {valid_planets}")
        return v
    
    @field_validator('modality')
    @classmethod
    def validate_modality(cls, v: Optional[str]) -> Optional[str]:
        """Validate modality is from the defined list or null."""
        if v is not None:
            valid_modalities = list(MODALITIES.keys())
            if v not in valid_modalities:
                raise ValueError(f"Invalid modality: '{v}'. Must be one of: {valid_modalities}")
        return v
    
    @field_validator('time_of_day')
    @classmethod
    def validate_time_of_day(cls, v: Optional[List[str]]) -> Optional[List[str]]:
        """Validate all time periods are from the defined list."""
        if v is not None:
            for time in v:
                if time not in TIME_OF_DAY:
                    raise ValueError(f"Invalid time_of_day: '{time}'. Must be one of: {TIME_OF_DAY}")
        return v
