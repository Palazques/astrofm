"""
Audio Features Backfill Service for user library tracks.

Runs in background to fetch audio features for tracks with features_status='pending'.
Uses RapidAPI Track Analysis service (same as Spotify audio features fallback).

S2: Documentation Rule - All functions include clear docstrings.
"""
import asyncio
from typing import List, Optional
from datetime import datetime

from models.user_library_models import UserLibraryTrack
from services.user_library_db import (
    get_tracks_pending_features,
    update_features,
    mark_features_failed,
)
from services.audio_features_service import get_audio_features_service
from models.audio_features import TrackInfo


# Backfill configuration
BATCH_SIZE = 20  # Tracks to process per batch
BACKFILL_INTERVAL_SECONDS = 300  # 5 minutes between runs


async def backfill_pending_features(batch_size: int = BATCH_SIZE) -> dict:
    """
    Fetch audio features for pending tracks in the user library.
    
    Processes tracks in batches to avoid overwhelming the API.
    
    Args:
        batch_size: Number of tracks to process per batch
        
    Returns:
        Dict with processed count, success count, failed count
    """
    pending_tracks = get_tracks_pending_features(limit=batch_size)
    
    if not pending_tracks:
        return {"processed": 0, "success": 0, "failed": 0}
    
    print(f"[BackfillService] Processing {len(pending_tracks)} pending tracks...")
    
    audio_service = get_audio_features_service()
    
    if not audio_service.is_configured:
        print("[BackfillService] Audio features API not configured, skipping backfill")
        return {"processed": 0, "success": 0, "failed": 0, "error": "API not configured"}
    
    # Build TrackInfo list for batch fetch
    track_infos = []
    for track in pending_tracks:
        # Use Spotify ID if available, otherwise use name+artist
        spotify_id = track.provider_ids.get("spotify", "")
        track_infos.append(TrackInfo(
            track_id=spotify_id,
            name=track.display_name,
            artist=track.display_artist,
        ))
    
    # Fetch features in batch
    try:
        features_map = await audio_service.get_batch_features(track_infos)
    except Exception as e:
        print(f"[BackfillService] Batch fetch failed: {e}")
        return {"processed": len(pending_tracks), "success": 0, "failed": len(pending_tracks)}
    
    success_count = 0
    failed_count = 0
    
    for track, info in zip(pending_tracks, track_infos):
        # Get features by track ID or fallback key
        features = features_map.get(info.track_id)
        
        if features and features.energy is not None:
            # Convert AudioFeatures to dict for database update
            update_features(track.id, {
                "energy": features.energy,
                "valence": features.valence,
                "tempo": features.tempo,
                "danceability": features.danceability,
                "acousticness": features.acousticness,
                "instrumentalness": features.instrumentalness,
                "speechiness": features.speechiness,
                "liveness": features.liveness,
                "loudness": features.loudness,
                "mode": features.mode,
                "key": features.key,
            })
            success_count += 1
        else:
            mark_features_failed(track.id)
            failed_count += 1
    
    print(f"[BackfillService] Backfill complete: {success_count} success, {failed_count} failed")
    
    return {
        "processed": len(pending_tracks),
        "success": success_count,
        "failed": failed_count,
    }


async def start_backfill_loop():
    """
    Start a background loop that periodically backfills audio features.
    
    This should be called on app startup. Runs indefinitely until cancelled.
    """
    print(f"[BackfillService] Starting background backfill loop (interval: {BACKFILL_INTERVAL_SECONDS}s)")
    
    while True:
        try:
            result = await backfill_pending_features()
            
            if result.get("processed", 0) > 0:
                print(f"[BackfillService] Loop iteration: {result}")
            
        except Exception as e:
            print(f"[BackfillService] Error in backfill loop: {e}")
        
        await asyncio.sleep(BACKFILL_INTERVAL_SECONDS)


# Background task handle
_backfill_task: Optional[asyncio.Task] = None


def start_background_backfill():
    """Start the background backfill task if not already running."""
    global _backfill_task
    
    if _backfill_task is not None and not _backfill_task.done():
        print("[BackfillService] Background backfill already running")
        return
    
    try:
        loop = asyncio.get_event_loop()
        _backfill_task = loop.create_task(start_backfill_loop())
        print("[BackfillService] Background backfill task started")
    except RuntimeError:
        # No event loop running (e.g., during module import)
        print("[BackfillService] No event loop, will start on first request")


def stop_background_backfill():
    """Stop the background backfill task."""
    global _backfill_task
    
    if _backfill_task is not None:
        _backfill_task.cancel()
        _backfill_task = None
        print("[BackfillService] Background backfill task stopped")
