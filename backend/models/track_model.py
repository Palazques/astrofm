"""
Track model for the music dataset.
Pydantic model with all audio features from the Spotify dataset.

S2: Documentation Rule - Clear docstrings for all fields.
"""
from pydantic import BaseModel, Field
from typing import Optional


class Track(BaseModel):
    """
    Represents a track from the 114K music dataset.
    Includes all Spotify audio features plus derived fields.
    """
    
    # Spotify Track Info
    track_id: str = Field(description="Spotify track ID")
    artists: str = Field(description="Artist name(s)")
    album_name: str = Field(description="Album name")
    track_name: str = Field(description="Track title")
    popularity: int = Field(ge=0, le=100, description="Spotify popularity score 0-100")
    duration_ms: int = Field(ge=0, description="Track duration in milliseconds")
    explicit: bool = Field(default=False, description="Contains explicit content")
    
    # Audio Features (0.0-1.0 normalized unless specified)
    danceability: float = Field(ge=0.0, le=1.0, description="How suitable for dancing")
    energy: float = Field(ge=0.0, le=1.0, description="Intensity and activity")
    key: int = Field(ge=0, le=11, description="Musical key (0=C, 1=C#, etc.)")
    loudness: float = Field(description="Overall loudness in dB (typically -60 to 0)")
    mode: int = Field(ge=0, le=1, description="0=minor, 1=major")
    speechiness: float = Field(ge=0.0, le=1.0, description="Presence of spoken words")
    acousticness: float = Field(ge=0.0, le=1.0, description="Acoustic vs electronic")
    instrumentalness: float = Field(ge=0.0, le=1.0, description="Lack of vocals")
    liveness: float = Field(ge=0.0, le=1.0, description="Presence of audience")
    valence: float = Field(ge=0.0, le=1.0, description="Musical positiveness (happy vs sad)")
    tempo: float = Field(ge=0.0, description="Beats per minute")
    time_signature: int = Field(ge=1, le=7, default=4, description="Time signature numerator")
    
    # Original dataset genre
    dataset_genre: str = Field(default="", description="Original genre from dataset")
    
    # Derived fields (set after loading)
    main_genre: Optional[str] = Field(default=None, description="Mapped app main genre")
    subgenre: Optional[str] = Field(default=None, description="Mapped app subgenre")
    element: Optional[str] = Field(default=None, description="Derived astrological element")
    
    class Config:
        """Pydantic model configuration."""
        json_schema_extra = {
            "example": {
                "track_id": "5SuOikwiRyPMVoIQDJUgSV",
                "artists": "Gen Hoshino",
                "album_name": "Comedy",
                "track_name": "Comedy",
                "popularity": 73,
                "duration_ms": 230666,
                "explicit": False,
                "danceability": 0.676,
                "energy": 0.461,
                "key": 1,
                "loudness": -6.746,
                "mode": 0,
                "speechiness": 0.143,
                "acousticness": 0.0322,
                "instrumentalness": 0.0,
                "liveness": 0.358,
                "valence": 0.715,
                "tempo": 87.917,
                "time_signature": 4,
                "dataset_genre": "acoustic",
                "main_genre": "Folk",
                "subgenre": "Acoustic Folk",
                "element": "Air",
            }
        }


class GenrePreference(BaseModel):
    """
    User's genre preferences for playlist generation.
    Used when storing and retrieving user profile preferences.
    """
    
    main_genres: list[str] = Field(
        default_factory=list,
        description="Main genres user selected (1.0x weight)"
    )
    subgenres: list[str] = Field(
        default_factory=list,
        description="Subgenres user explicitly selected (2.0x weight)"
    )
    include_related: bool = Field(
        default=True,
        description="Include related genres at 0.3x weight"
    )
    
    class Config:
        """Pydantic model configuration."""
        json_schema_extra = {
            "example": {
                "main_genres": ["Electronic", "Latin"],
                "subgenres": ["Trance", "Reggaeton"],
                "include_related": True,
            }
        }
