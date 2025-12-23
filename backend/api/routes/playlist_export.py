"""
Playlist export API routes.
Provides endpoints for generating playlists from the music dataset
and exporting them as text or to Spotify.

S2: Documentation Rule - Clear docstrings for all endpoints.
H2: Input Validation - All inputs validated with Pydantic.
"""
from datetime import datetime
from typing import List, Optional
from zoneinfo import ZoneInfo
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from models.vibe import VibeParameters
from models.track_model import GenrePreference
from services.ephemeris import calculate_natal_chart
from services.vibe_calculator import calculate_vibe_parameters
from services.playlist_matcher import generate_playlist_from_dataset


router = APIRouter(prefix="/api/playlist", tags=["playlist-export"])


# =============================================================================
# REQUEST/RESPONSE MODELS
# =============================================================================

class DatasetPlaylistRequest(BaseModel):
    """Request model for dataset-based playlist generation."""
    
    # Birth data
    birth_datetime: str = Field(description="Birth datetime in ISO format")
    latitude: float = Field(ge=-90, le=90, description="Birth latitude")
    longitude: float = Field(ge=-180, le=180, description="Birth longitude")
    timezone: str = Field(default="UTC", description="Timezone name")
    
    # Current time/location (optional)
    current_datetime: Optional[str] = Field(default=None, description="Current datetime in ISO format")
    current_latitude: Optional[float] = Field(default=None, ge=-90, le=90)
    current_longitude: Optional[float] = Field(default=None, ge=-180, le=180)
    
    # Playlist preferences
    playlist_size: int = Field(default=20, ge=10, le=30, description="Number of tracks")
    
    # Genre preferences
    main_genres: List[str] = Field(default_factory=list, description="Selected main genres")
    subgenres: List[str] = Field(default_factory=list, description="Selected subgenres")
    include_related: bool = Field(default=True, description="Include related genres at 0.3x weight")


class TrackInfo(BaseModel):
    """Track information for export."""
    track_id: str
    track_name: str
    artists: str
    album_name: str
    duration_ms: int
    popularity: int
    energy: float
    valence: float
    danceability: float
    main_genre: Optional[str]
    subgenre: Optional[str]
    element: Optional[str]


class DatasetPlaylistResponse(BaseModel):
    """Response model for dataset-based playlist generation."""
    tracks: List[TrackInfo]
    total_duration_ms: int
    vibe_match_score: float
    energy_arc: List[float]
    element_distribution: dict
    genre_distribution: dict
    generation_metadata: dict


class TextExportResponse(BaseModel):
    """Response model for text export."""
    formatted_text: str
    track_count: int
    total_duration_formatted: str


# =============================================================================
# ENDPOINTS
# =============================================================================

@router.post("/generate-from-dataset", response_model=DatasetPlaylistResponse)
async def generate_from_dataset(request: DatasetPlaylistRequest) -> DatasetPlaylistResponse:
    """
    Generate a playlist from the 114K track music dataset.
    
    Uses genre preference weighting:
    - Subgenre selected: 2.0x weight
    - Main genre only: 1.0x weight
    - Related genres: 0.3x weight
    
    Args:
        request: Playlist generation request with birth data and genre preferences
        
    Returns:
        DatasetPlaylistResponse with tracks, metadata, and distributions
    """
    try:
        # Parse birth datetime
        try:
            birth_dt = datetime.fromisoformat(request.birth_datetime.replace('Z', '+00:00'))
        except ValueError as e:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid birth_datetime format: {str(e)}"
            )
        
        # Convert to UTC if timezone is provided
        if request.timezone != "UTC":
            try:
                local_tz = ZoneInfo(request.timezone)
                birth_dt = birth_dt.replace(tzinfo=local_tz)
                birth_dt = birth_dt.astimezone(ZoneInfo("UTC"))
                birth_dt = birth_dt.replace(tzinfo=None)
            except Exception:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid timezone: {request.timezone}"
                )
        
        # Parse current datetime
        if request.current_datetime:
            try:
                current_dt = datetime.fromisoformat(request.current_datetime.replace('Z', '+00:00'))
            except ValueError as e:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid current_datetime format: {str(e)}"
                )
        else:
            current_dt = datetime.utcnow()
        
        # Use current location if provided
        current_lat = request.current_latitude if request.current_latitude is not None else request.latitude
        current_lon = request.current_longitude if request.current_longitude is not None else request.longitude
        
        # Calculate natal chart
        natal_chart = calculate_natal_chart(
            birth_datetime=birth_dt,
            latitude=request.latitude,
            longitude=request.longitude
        )
        
        # Calculate vibe parameters
        vibe_params = calculate_vibe_parameters(
            natal_chart=natal_chart,
            current_datetime=current_dt,
            latitude=current_lat,
            longitude=current_lon
        )
        
        # Build genre preferences
        genre_preferences = GenrePreference(
            main_genres=request.main_genres,
            subgenres=request.subgenres,
            include_related=request.include_related
        )
        
        # Generate playlist from dataset
        result = generate_playlist_from_dataset(
            vibe_params=vibe_params,
            genre_preferences=genre_preferences,
            playlist_size=request.playlist_size
        )
        
        return DatasetPlaylistResponse(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error generating playlist: {str(e)}"
        )


@router.post("/export/text")
async def export_as_text(request: DatasetPlaylistRequest) -> TextExportResponse:
    """
    Generate a playlist and export as formatted text.
    
    Args:
        request: Playlist generation request
        
    Returns:
        TextExportResponse with formatted text list
    """
    # First generate the playlist
    playlist_response = await generate_from_dataset(request)
    
    # Format as text
    lines = ["🎵 Your Astrological Playlist 🎵", ""]
    
    for i, track in enumerate(playlist_response.tracks, 1):
        duration_min = track.duration_ms // 60000
        duration_sec = (track.duration_ms % 60000) // 1000
        lines.append(f"{i}. {track.track_name} - {track.artists}")
        lines.append(f"   📀 {track.album_name} | ⏱️ {duration_min}:{duration_sec:02d}")
        if track.main_genre:
            lines.append(f"   🎸 {track.main_genre}" + (f" / {track.subgenre}" if track.subgenre else ""))
        lines.append("")
    
    # Total duration
    total_min = playlist_response.total_duration_ms // 60000
    total_sec = (playlist_response.total_duration_ms % 60000) // 1000
    lines.append(f"📊 Total: {len(playlist_response.tracks)} tracks | ⏱️ {total_min}:{total_sec:02d}")
    lines.append(f"✨ Vibe Match Score: {playlist_response.vibe_match_score}%")
    
    return TextExportResponse(
        formatted_text="\n".join(lines),
        track_count=len(playlist_response.tracks),
        total_duration_formatted=f"{total_min}:{total_sec:02d}"
    )


@router.get("/dataset/stats")
async def get_dataset_stats():
    """
    Get statistics about the loaded music dataset.
    
    Returns:
        Dict with total tracks, genre counts, and distributions
    """
    try:
        from services.music_dataset_service import get_dataset_stats
        return get_dataset_stats()
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error loading dataset stats: {str(e)}"
        )
