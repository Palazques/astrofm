"""
User Library API routes for syncing and managing user-contributed tracks.

S2: Documentation Rule - All endpoints include clear docstrings.
H2: Input Validation - All inputs validated via Pydantic models.
"""
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from typing import Optional

from services.user_library_sync_service import sync_spotify_library, get_sync_stats
from services.user_library_db import get_stats, get_total_tracks
from services.features_backfill_service import backfill_pending_features


router = APIRouter(prefix="/api/user-library", tags=["user-library"])


class SpotifySyncRequest(BaseModel):
    """Request for Spotify library sync."""
    access_token: str
    max_tracks: int = 500


class SyncResponse(BaseModel):
    """Response from library sync operation."""
    success: bool
    total_processed: int
    inserted: int
    duplicate_id: int
    duplicate_name: int
    skipped: int
    message: str


class LibraryStatsResponse(BaseModel):
    """Response with library statistics."""
    total_tracks: int
    complete_features: int
    pending_features: int
    failed_features: int
    element_distribution: dict


@router.post("/sync/spotify", response_model=SyncResponse)
async def sync_spotify(request: SpotifySyncRequest):
    """
    Sync user's Spotify library to the shared track pool.
    
    Fetches saved tracks from Spotify and deduplicates them using
    hybrid matching (provider ID first, then name+artist).
    
    Tracks are saved immediately; audio features are backfilled in background.
    """
    try:
        summary = await sync_spotify_library(
            access_token=request.access_token,
            max_tracks=request.max_tracks
        )
        
        return SyncResponse(
            success=True,
            total_processed=summary.total_processed,
            inserted=summary.inserted,
            duplicate_id=summary.duplicate_id,
            duplicate_name=summary.duplicate_name,
            skipped=summary.skipped,
            message=f"Synced {summary.inserted} new tracks to library"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/stats", response_model=LibraryStatsResponse)
async def get_library_stats():
    """
    Get statistics about the shared user library.
    
    Returns total tracks, feature status counts, and element distribution.
    """
    stats = get_stats()
    
    return LibraryStatsResponse(
        total_tracks=stats.get("total_tracks", 0),
        complete_features=stats.get("complete_features", 0),
        pending_features=stats.get("pending_features", 0),
        failed_features=stats.get("failed_features", 0),
        element_distribution=stats.get("element_distribution", {})
    )


@router.post("/backfill-features")
async def trigger_backfill(
    batch_size: int = Query(default=20, ge=1, le=100)
):
    """
    Manually trigger audio features backfill.
    
    Normally runs in background, but can be triggered manually for testing.
    """
    result = await backfill_pending_features(batch_size=batch_size)
    
    return {
        "success": True,
        "processed": result.get("processed", 0),
        "success_count": result.get("success", 0),
        "failed_count": result.get("failed", 0),
    }


# Future: Apple Music and YouTube Music sync endpoints
# @router.post("/sync/apple-music")
# async def sync_apple_music(request: AppleMusicSyncRequest):
#     pass

# @router.post("/sync/youtube-music")
# async def sync_youtube_music(request: YouTubeMusicSyncRequest):
#     pass
