"""
Cosmic Playlist Models.

Request/Response schemas for the cosmic playlist API.

S2: Documentation Rule - Clear docstrings for all classes.
"""
from typing import List, Optional
from pydantic import BaseModel, Field


class CosmicPlaylistRequest(BaseModel):
    """Request to generate a cosmic playlist."""
    
    sun_sign: str = Field(..., description="User's Sun sign (e.g., 'Capricorn')")
    moon_sign: str = Field(..., description="User's Moon sign")
    rising_sign: str = Field(..., description="User's Rising/Ascendant sign")
    genre_preferences: List[str] = Field(
        ..., 
        min_items=1,
        max_items=10,
        description="User's preferred music genres"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "sun_sign": "Capricorn",
                "moon_sign": "Pisces",
                "rising_sign": "Scorpio",
                "genre_preferences": ["indie rock", "electronic", "ambient"],
            }
        }


class TrackInfo(BaseModel):
    """Information about a track in the playlist."""
    name: str
    artist: str
    url: str
    album_art: Optional[str] = None


class CosmicPlaylistResponse(BaseModel):
    """Response after generating a cosmic playlist."""
    
    success: bool
    playlist_url: Optional[str] = None
    playlist_name: Optional[str] = None
    track_count: int = 0
    vibe_summary: Optional[str] = None
    tracks: List[TrackInfo] = []
    sun_sign: Optional[str] = None
    element: Optional[str] = None
    error: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "playlist_url": "https://open.spotify.com/playlist/xyz",
                "playlist_name": "Astro.fm - Capricorn ♑ - Dec 27 2025 - a3f2",
                "track_count": 20,
                "vibe_summary": "Capricorn ♑ energy: grounded and steady...",
                "sun_sign": "Capricorn",
                "element": "Earth",
                "tracks": [
                    {
                        "name": "Everything In Its Right Place",
                        "artist": "Radiohead",
                        "url": "https://open.spotify.com/track/xyz",
                        "album_art": "https://i.scdn.co/image/xyz"
                    }
                ]
            }
        }
