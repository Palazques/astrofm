"""
Pydantic models for audio features data.

S2: Documentation Rule - All classes include clear docstrings.
H2: Input Validation - Strict typing and validation using Pydantic.
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class AudioFeatures(BaseModel):
    """
    Audio features for a track, normalized to 0.0-1.0 scale.
    
    Note: RapidAPI returns 0-100 integers, so we normalize them.
    Also, RapidAPI uses 'happiness' instead of 'valence'.
    """
    track_id: str
    energy: float = Field(ge=0.0, le=1.0)
    valence: float = Field(ge=0.0, le=1.0)  # Called 'happiness' in RapidAPI
    tempo: float = Field(ge=0.0)
    danceability: float = Field(ge=0.0, le=1.0)
    key: Optional[str] = None  # e.g., "C", "G#"
    mode: Optional[str] = None  # "major" or "minor"
    acousticness: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    instrumentalness: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    liveness: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    speechiness: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    fetched_at: datetime = Field(default_factory=datetime.utcnow)


class TrackInfo(BaseModel):
    """
    Minimal track info needed to fetch audio features.
    """
    track_id: str  # Spotify track ID or internal ID
    name: str
    artist: str


class RapidAPIResponse(BaseModel):
    """
    Raw response from RapidAPI Track Analysis.
    Values are 0-100 integers except tempo and loudness.
    """
    id: Optional[str] = None
    name: Optional[str] = None
    album: Optional[str] = None
    key: Optional[str] = None
    mode: Optional[str] = None
    camelot: Optional[str] = None
    tempo: Optional[int] = None
    duration: Optional[str] = None
    popularity: Optional[int] = None
    energy: Optional[int] = None  # 0-100
    danceability: Optional[int] = None  # 0-100
    happiness: Optional[int] = None  # 0-100 (= valence)
    acousticness: Optional[int] = None  # 0-100
    instrumentalness: Optional[int] = None  # 0-100
    liveness: Optional[int] = None  # 0-100
    speechiness: Optional[int] = None  # 0-100
    loudness: Optional[str] = None  # e.g., "-5 dB"
    
    def to_audio_features(self, track_id: str) -> AudioFeatures:
        """Convert RapidAPI response to normalized AudioFeatures."""
        return AudioFeatures(
            track_id=track_id,
            energy=(self.energy or 50) / 100.0,
            valence=(self.happiness or 50) / 100.0,  # happiness -> valence
            tempo=float(self.tempo or 120),
            danceability=(self.danceability or 50) / 100.0,
            key=self.key,
            mode=self.mode,
            acousticness=(self.acousticness / 100.0) if self.acousticness else None,
            instrumentalness=(self.instrumentalness / 100.0) if self.instrumentalness else None,
            liveness=(self.liveness / 100.0) if self.liveness else None,
            speechiness=(self.speechiness / 100.0) if self.speechiness else None,
        )


class AudioFeaturesRequest(BaseModel):
    """Request model for batch audio features endpoint."""
    track_ids: list[str] = Field(..., min_length=1, max_length=100)


class AudioFeaturesResponse(BaseModel):
    """Response model for audio features endpoint."""
    track_id: str
    energy: float
    valence: float
    tempo: float
    danceability: float
    key: Optional[str] = None
    mode: Optional[str] = None
    cached: bool = False


# Default fallback values when features cannot be fetched
DEFAULT_AUDIO_FEATURES = {
    "energy": 0.5,
    "valence": 0.5,
    "tempo": 120.0,
    "danceability": 0.5,
    "key": None,
    "mode": None,
}
