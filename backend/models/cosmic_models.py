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


class ZodiacSeasonRequest(BaseModel):
    """Request to generate a zodiac season playlist."""
    
    sun_sign: str = Field(..., description="User's Sun sign")
    moon_sign: str = Field(..., description="User's Moon sign")
    rising_sign: str = Field(..., description="User's Rising/Ascendant sign")
    genre_preferences: List[str] = Field(
        default=["indie rock", "electronic", "pop"],
        min_items=1,
        max_items=10,
        description="User's preferred music genres"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "sun_sign": "Leo",
                "moon_sign": "Pisces",
                "rising_sign": "Scorpio",
                "genre_preferences": ["indie rock", "electronic", "ambient"],
            }
        }


class ZodiacSeasonResponse(BaseModel):
    """Response for zodiac season playlist."""
    
    success: bool
    zodiac_sign: str = Field(..., description="Current zodiac season sign")
    symbol: str = Field(..., description="Zodiac symbol emoji")
    element: str = Field(..., description="Element (Fire/Earth/Air/Water)")
    date_range: str = Field(..., description="Date range for this zodiac season")
    element_qualities: str = Field(..., description="User-facing description of element qualities")
    horoscope: str = Field(..., description="AI-generated horoscope for the season")
    vibe_summary: str = Field(..., description="Music vibe description")
    playlist_url: Optional[str] = None
    playlist_id: Optional[str] = None
    track_count: int = 0
    tracks: List[TrackInfo] = []
    zodiac_season_key: str = Field(..., description="Cache key like 'Capricorn_2024'")
    cached_until: str = Field(..., description="ISO date when cache expires")
    error: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "zodiac_sign": "Capricorn",
                "symbol": "♑",
                "element": "Earth",
                "date_range": "Dec 22 - Jan 19",
                "element_qualities": "Grounded, sensual, and steady...",
                "horoscope": "This Capricorn season invites you to...",
                "vibe_summary": "Grounded ambition meets steady rhythm",
                "playlist_url": "https://open.spotify.com/playlist/xyz",
                "playlist_id": "xyz123",
                "track_count": 20,
                "zodiac_season_key": "Capricorn_2024",
                "cached_until": "2025-01-19",
                "tracks": []
            }
        }


class PersonalInsight(BaseModel):
    """Personalized insight about how the zodiac season affects the user."""
    headline: str = Field(..., description="Short headline e.g. 'Your Opposite Sign Season'")
    subtext: str = Field(..., description="Context e.g. 'Capricorn activates your 7th house'")
    meaning: str = Field(..., description="Full interpretation paragraph")
    focus_areas: List[str] = Field(..., description="Life areas to focus on")


class SeasonTrackInfo(BaseModel):
    """Track info with energy level for display."""
    id: str
    title: str
    artist: str
    duration: str
    energy: int = Field(..., ge=0, le=100, description="Energy level 0-100")
    url: Optional[str] = None


class ZodiacSeasonCardRequest(BaseModel):
    """Request for personalized zodiac season card."""
    
    sun_sign: str = Field(..., description="User's Sun sign")
    moon_sign: str = Field(..., description="User's Moon sign")
    rising_sign: str = Field(..., description="User's Rising/Ascendant sign")
    natal_planets: List[dict] = Field(
        default=[],
        description="User's natal planets [{name, sign, house}, ...]"
    )
    genre_preferences: List[str] = Field(
        default=["indie rock", "electronic", "pop"],
        description="User's preferred music genres"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "sun_sign": "Cancer",
                "moon_sign": "Pisces",
                "rising_sign": "Gemini",
                "natal_planets": [
                    {"name": "Sun", "sign": "Cancer", "house": 2},
                    {"name": "Moon", "sign": "Pisces", "house": 10},
                ],
                "genre_preferences": ["indie rock", "electronic"]
            }
        }


class ZodiacSeasonCardResponse(BaseModel):
    """Response for personalized zodiac season card."""
    
    success: bool
    # Season info
    zodiac_sign: str = Field(..., description="Current zodiac season sign")
    symbol: str = Field(..., description="Unicode zodiac symbol")
    element: str = Field(..., description="Element (Fire/Earth/Air/Water)")
    modality: str = Field(..., description="Modality (Cardinal/Fixed/Mutable)")
    date_range: str = Field(..., description="Date range for this season")
    ruling_planet: str = Field(..., description="Ruling planet name")
    ruling_symbol: str = Field(..., description="Ruling planet symbol")
    color1: str = Field(..., description="Primary hex color for theming")
    color2: str = Field(..., description="Secondary hex color for theming")
    # Personal connection
    personal_insight: PersonalInsight
    # Playlist
    playlist_name: str = Field(..., description="Playlist display name")
    playlist_description: str = Field(..., description="Playlist vibe description")
    total_duration: str = Field(..., description="Total duration e.g. '47 min'")
    vibe_tags: List[str] = Field(..., description="Vibe tags e.g. ['Structured', 'Earthy']")
    tracks: List[SeasonTrackInfo] = []
    playlist_url: Optional[str] = None
    # Cache metadata
    zodiac_season_key: str = Field(..., description="Cache key e.g. 'Capricorn_2026'")
    cached_until: str = Field(..., description="ISO date when cache expires")
    error: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "zodiac_sign": "Capricorn",
                "symbol": "♑",
                "element": "Earth",
                "modality": "Cardinal",
                "date_range": "Dec 22 - Jan 19",
                "ruling_planet": "Saturn",
                "ruling_symbol": "♄",
                "color1": "#7D67FE",
                "color2": "#00D4AA",
                "personal_insight": {
                    "headline": "Your Opposite Sign Season",
                    "subtext": "Capricorn activates your 7th house of partnerships",
                    "meaning": "This season illuminates your relationships...",
                    "focus_areas": ["Partnerships", "Boundaries", "Commitments"]
                },
                "playlist_name": "Capricorn Season × Your 7th House",
                "playlist_description": "Grounded beats for partnership focus",
                "total_duration": "47 min",
                "vibe_tags": ["Structured", "Ambitious", "Earthy"],
                "tracks": [],
                "zodiac_season_key": "Capricorn_2026",
                "cached_until": "2026-01-19"
            }
        }

