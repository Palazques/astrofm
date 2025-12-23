"""
User Library Sync Service for importing tracks from connected music services.

Handles syncing user's Spotify/Apple Music/YouTube Music libraries
with hybrid deduplication (provider ID first, then fuzzy name+artist).

S2: Documentation Rule - All functions include clear docstrings.
H2: Input Validation - All external data validated before processing.
"""
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
from enum import Enum

from models.user_library_models import UserLibraryTrack, SUPPORTED_PROVIDERS
from services.user_library_db import (
    find_by_provider_id,
    find_by_name_artist,
    insert_track,
    update_provider_id,
    get_stats,
)
from services.spotify_service import get_spotify_service, SpotifyTrack


class SyncResult(Enum):
    """Result of syncing a single track."""
    INSERTED = "inserted"      # New track added
    DUPLICATE_ID = "duplicate_id"  # Same provider ID already exists
    DUPLICATE_NAME = "duplicate_name"  # Same name+artist exists (cross-platform)
    SKIPPED = "skipped"        # Skipped (e.g., missing data)


@dataclass
class SyncSummary:
    """Summary of a sync operation."""
    total_processed: int
    inserted: int
    duplicate_id: int
    duplicate_name: int
    skipped: int
    
    @property
    def success_rate(self) -> float:
        """Percentage of tracks that were new additions."""
        if self.total_processed == 0:
            return 0.0
        return (self.inserted / self.total_processed) * 100


async def sync_spotify_library(
    access_token: str,
    max_tracks: int = 500
) -> SyncSummary:
    """
    Sync user's Spotify library to the shared track pool.
    
    Fetches saved tracks from Spotify and deduplicates them using
    hybrid matching (provider ID first, then name+artist).
    
    Args:
        access_token: Valid Spotify access token
        max_tracks: Maximum number of tracks to sync
        
    Returns:
        SyncSummary with counts of inserted/duplicate tracks
    """
    spotify = get_spotify_service()
    
    # Fetch user's saved tracks with audio features
    print(f"[SyncService] Fetching up to {max_tracks} tracks from Spotify...")
    spotify_tracks = await spotify.get_saved_tracks_with_features(
        access_token, 
        max_tracks=max_tracks
    )
    print(f"[SyncService] Fetched {len(spotify_tracks)} tracks from Spotify")
    
    # Process and deduplicate
    return _deduplicate_and_save(spotify_tracks, "spotify")


def _deduplicate_and_save(
    tracks: List[SpotifyTrack],
    provider: str
) -> SyncSummary:
    """
    Process tracks with hybrid deduplication and save to database.
    
    Deduplication Flow:
    1. Check if provider_id exists → Skip (DUPLICATE_ID)
    2. Check if name+artist fuzzy match exists → Add provider_id (DUPLICATE_NAME)
    3. No match → Insert new track (INSERTED)
    
    Args:
        tracks: List of SpotifyTrack objects
        provider: Provider name (e.g., "spotify")
        
    Returns:
        SyncSummary with operation counts
    """
    counts = {
        SyncResult.INSERTED: 0,
        SyncResult.DUPLICATE_ID: 0,
        SyncResult.DUPLICATE_NAME: 0,
        SyncResult.SKIPPED: 0,
    }
    
    for track in tracks:
        result = _process_single_track(track, provider)
        counts[result] += 1
    
    summary = SyncSummary(
        total_processed=len(tracks),
        inserted=counts[SyncResult.INSERTED],
        duplicate_id=counts[SyncResult.DUPLICATE_ID],
        duplicate_name=counts[SyncResult.DUPLICATE_NAME],
        skipped=counts[SyncResult.SKIPPED],
    )
    
    print(f"[SyncService] Sync complete: {summary.inserted} new, "
          f"{summary.duplicate_id + summary.duplicate_name} duplicates, "
          f"{summary.skipped} skipped")
    
    return summary


def _process_single_track(track: SpotifyTrack, provider: str) -> SyncResult:
    """
    Process a single track with hybrid deduplication.
    
    Args:
        track: SpotifyTrack to process
        provider: Provider name
        
    Returns:
        SyncResult indicating what happened
    """
    # Validate track has required data
    if not track.name or not track.artists:
        return SyncResult.SKIPPED
    
    provider_id = track.id
    
    # Step 1: Check by provider ID (fast path)
    existing = find_by_provider_id(provider, provider_id)
    if existing:
        return SyncResult.DUPLICATE_ID
    
    # Step 2: Check by name+artist (fuzzy fallback)
    artist_name = track.artists[0] if track.artists else ""
    existing = find_by_name_artist(track.name, artist_name)
    
    if existing:
        # Same song found from different platform - add this provider's ID
        update_provider_id(existing.id, provider, provider_id)
        return SyncResult.DUPLICATE_NAME
    
    # Step 3: New track - insert
    user_track = UserLibraryTrack.from_spotify_track(track)
    insert_track(user_track)
    
    return SyncResult.INSERTED


async def get_sync_stats() -> Dict:
    """
    Get statistics about the user library.
    
    Returns:
        Dict with total_tracks, feature counts, element distribution
    """
    return get_stats()


# Future: Add Apple Music and YouTube Music sync functions
# async def sync_apple_music_library(access_token: str, max_tracks: int = 500) -> SyncSummary:
#     """Sync user's Apple Music library."""
#     pass

# async def sync_youtube_music_library(access_token: str, max_tracks: int = 500) -> SyncSummary:
#     """Sync user's YouTube Music library."""
#     pass
