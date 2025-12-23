"""
Music Dataset Service for the 114K track library.
Handles SQLite database queries, filtering, and preference-weighted track selection.

H3: Unit Test Creation - All public functions must have corresponding tests.
S2: Documentation Rule - Clear docstrings for all functions.
"""
import random
from typing import List, Dict, Optional, Tuple, Set

from models.track_model import Track
from data.genre_mapping import (
    GENRE_MAPPING,
    RELATED_GENRES,
    PreferenceWeights,
    get_app_genre,
    get_related_genres,
    get_subgenres,
)
from services.zodiac_utils import ELEMENT_AUDIO_PROFILES
from services.db_service import (
    execute_query,
    execute_scalar,
    get_tracks_by_genre_sql,
    get_tracks_by_subgenre_sql,
    get_tracks_by_element_sql,
    search_tracks_sql,
    get_tracks_with_filters,
    get_genre_distribution,
    get_element_distribution,
    get_genre_index as db_get_genre_index,
    get_subgenre_index as db_get_subgenre_index,
    get_total_tracks,
)


# =============================================================================
# HELPER: ROW TO TRACK CONVERSION
# =============================================================================

def row_to_track(row) -> Track:
    """Convert a database row to a Track object."""
    return Track(
        track_id=row['track_id'],
        artists=row['artists'] or '',
        album_name=row['album_name'] or '',
        track_name=row['track_name'] or '',
        popularity=row['popularity'] or 0,
        duration_ms=row['duration_ms'] or 0,
        explicit=bool(row['explicit']),
        danceability=row['danceability'] or 0.0,
        energy=row['energy'] or 0.0,
        key=row['key'] or 0,
        loudness=row['loudness'] or 0.0,
        mode=row['mode'] or 0,
        speechiness=row['speechiness'] or 0.0,
        acousticness=row['acousticness'] or 0.0,
        instrumentalness=row['instrumentalness'] or 0.0,
        liveness=row['liveness'] or 0.0,
        valence=row['valence'] or 0.0,
        tempo=row['tempo'] or 0.0,
        time_signature=row['time_signature'] or 4,
        dataset_genre=row['dataset_genre'] or '',
        main_genre=row['main_genre'] or '',
        subgenre=row['subgenre'] or '',
        element=row['element'] or '',
    )


# =============================================================================
# CACHED INDEXES (for backward compatibility)
# =============================================================================

_genre_index_cache: Optional[Dict[str, int]] = None
_subgenre_index_cache: Optional[Dict[str, int]] = None


def load_dataset() -> List[Track]:
    """
    Load tracks from the database.
    Note: This is now a expensive operation - use specific query functions instead.
    
    Returns:
        List of all Track objects (114,000+ tracks)
    """
    rows = execute_query("SELECT * FROM tracks")
    return [row_to_track(row) for row in rows]


def clear_cache():
    """Clear the index cache. Useful for testing."""
    global _genre_index_cache, _subgenre_index_cache
    _genre_index_cache = None
    _subgenre_index_cache = None


def _get_genre_index() -> Dict[str, int]:
    """Get genre index (cached)."""
    global _genre_index_cache
    if _genre_index_cache is None:
        _genre_index_cache = db_get_genre_index()
    return _genre_index_cache


def _get_subgenre_index() -> Dict[str, int]:
    """Get subgenre index (cached)."""
    global _subgenre_index_cache
    if _subgenre_index_cache is None:
        _subgenre_index_cache = db_get_subgenre_index()
    return _subgenre_index_cache


# =============================================================================
# ELEMENT DERIVATION (kept for compatibility, but now pre-computed in DB)
# =============================================================================

def derive_element(track: 'Track') -> str:
    """
    Derive astrological element from audio features.
    Note: Element is now pre-computed in the database. This function
    is kept for backward compatibility with any code that needs it.
    
    Fire: High energy (>0.7) and high valence (>0.6)
    Earth: High acousticness (>0.5) and moderate tempo (80-120 BPM)
    Air: High danceability (>0.6) and moderate energy (0.4-0.7)
    Water: High acousticness (>0.5) or low energy (<0.4) with low valence (<0.4)
    
    Args:
        track: Track object with audio features
        
    Returns:
        Element string: "Fire", "Earth", "Air", or "Water"
    """
    energy = track.energy
    valence = track.valence
    danceability = track.danceability
    acousticness = track.acousticness
    tempo = track.tempo
    
    # Fire: High energy + positive mood
    if energy > 0.7 and valence > 0.6:
        return "Fire"
    
    # Water: Low energy + melancholic mood
    if (energy < 0.4 and valence < 0.4) or (acousticness > 0.6 and valence < 0.4):
        return "Water"
    
    # Earth: Grounded, stable, acoustic
    if acousticness > 0.5 and 80 <= tempo <= 120:
        return "Earth"
    
    # Air: Light, danceable, moderate energy
    if danceability > 0.6 and 0.4 <= energy <= 0.7:
        return "Air"
    
    # Default based on energy level
    if energy > 0.6:
        return "Fire"
    elif energy < 0.3:
        return "Water"
    elif acousticness > 0.4:
        return "Earth"
    else:
        return "Air"


# =============================================================================
# TRACK FILTERING & SELECTION
# =============================================================================

def get_tracks_by_genre(main_genre: str, limit: int = 100) -> List[Track]:
    """
    Get tracks matching a main genre.
    
    Args:
        main_genre: Main app genre (e.g., "Electronic")
        limit: Maximum number of tracks to return
        
    Returns:
        List of Track objects
    """
    rows = get_tracks_by_genre_sql(main_genre, limit)
    return [row_to_track(row) for row in rows]


def get_tracks_by_subgenre(subgenre: str, limit: int = 100) -> List[Track]:
    """
    Get tracks matching a specific subgenre.
    
    Args:
        subgenre: Subgenre name (e.g., "Trance")
        limit: Maximum number of tracks to return
        
    Returns:
        List of Track objects
    """
    rows = get_tracks_by_subgenre_sql(subgenre, limit)
    return [row_to_track(row) for row in rows]


def get_tracks_by_preference(
    selected_genres: List[str],
    selected_subgenres: List[str],
    include_related: bool = True,
    total_tracks: int = 20,
) -> List[Tuple[Track, float]]:
    """
    Get tracks weighted by user's genre preferences.
    
    Preference weights:
    - Subgenre explicitly selected: 2.0x
    - Main genre only selected: 1.0x (includes all subgenres at this weight)
    - Related genres: 0.3x (if include_related is True)
    
    Args:
        selected_genres: List of main genres user selected (e.g., ["Electronic", "Latin"])
        selected_subgenres: List of subgenres user explicitly selected (e.g., ["Trance", "Reggaeton"])
        include_related: Whether to include related genres at 0.3x weight
        total_tracks: Number of tracks to return
        
    Returns:
        List of (Track, weight) tuples sorted by weight (highest first)
    """
    weighted_tracks: List[Tuple[Track, float]] = []
    seen_ids: Set[str] = set()
    
    # Weight 2.0x: Explicitly selected subgenres (highest priority)
    for subgenre in selected_subgenres:
        rows = get_tracks_by_subgenre_sql(subgenre, limit=200)
        for row in rows:
            track = row_to_track(row)
            if track.track_id not in seen_ids:
                weighted_tracks.append((track, PreferenceWeights.SUBGENRE_SELECTED))
                seen_ids.add(track.track_id)
    
    # Weight 1.0x: Main genres (includes all subgenres at this weight)
    for genre in selected_genres:
        rows = get_tracks_by_genre_sql(genre, limit=500)
        for row in rows:
            track = row_to_track(row)
            if track.track_id not in seen_ids:
                weighted_tracks.append((track, PreferenceWeights.MAIN_GENRE_ONLY))
                seen_ids.add(track.track_id)
    
    # Weight 0.3x: Related genres (if enabled)
    if include_related:
        related_set: Set[str] = set()
        for genre in selected_genres:
            related_set.update(get_related_genres(genre))
        
        # Remove already-selected genres from related
        related_set -= set(selected_genres)
        
        for related_genre in related_set:
            rows = get_tracks_by_genre_sql(related_genre, limit=200)
            for row in rows:
                track = row_to_track(row)
                if track.track_id not in seen_ids:
                    weighted_tracks.append((track, PreferenceWeights.RELATED_GENRE))
                    seen_ids.add(track.track_id)
    
    # Sort by weight (descending) and apply weighted random selection
    weighted_tracks.sort(key=lambda x: x[1], reverse=True)
    
    if len(weighted_tracks) <= total_tracks:
        return weighted_tracks
    
    # Weighted random selection: higher weights = higher probability
    selected = _weighted_random_selection(weighted_tracks, total_tracks)
    return selected


def _weighted_random_selection(
    weighted_tracks: List[Tuple[Track, float]],
    count: int,
) -> List[Tuple[Track, float]]:
    """
    Select tracks using weighted random sampling.
    Higher weight = higher probability of selection.
    
    Args:
        weighted_tracks: List of (Track, weight) tuples
        count: Number of tracks to select
        
    Returns:
        Selected tracks with their weights
    """
    if not weighted_tracks:
        return []
    
    # Normalize weights to probabilities
    total_weight = sum(w for _, w in weighted_tracks)
    if total_weight == 0:
        return random.sample(weighted_tracks, min(count, len(weighted_tracks)))
    
    # Weighted sampling without replacement
    selected = []
    remaining = list(weighted_tracks)
    
    for _ in range(min(count, len(weighted_tracks))):
        if not remaining:
            break
        
        # Calculate cumulative weights
        total = sum(w for _, w in remaining)
        r = random.uniform(0, total)
        cumulative = 0
        
        for i, (track, weight) in enumerate(remaining):
            cumulative += weight
            if r <= cumulative:
                selected.append((track, weight))
                remaining.pop(i)
                break
    
    return selected


def get_tracks_by_element(element: str, limit: int = 100) -> List[Track]:
    """
    Get tracks matching an astrological element.
    
    Args:
        element: Element name ("Fire", "Earth", "Air", "Water")
        limit: Maximum number of tracks to return
        
    Returns:
        List of Track objects
    """
    rows = get_tracks_by_element_sql(element, limit)
    return [row_to_track(row) for row in rows]


def search_tracks(query: str, limit: int = 20) -> List[Track]:
    """
    Search tracks by name or artist.
    
    Args:
        query: Search query string
        limit: Maximum number of results
        
    Returns:
        List of matching Track objects
    """
    rows = search_tracks_sql(query, limit)
    return [row_to_track(row) for row in rows]


def get_dataset_stats() -> Dict:
    """
    Get statistics about the loaded dataset.
    
    Returns:
        Dict with total_tracks, genres_count, genre_distribution, etc.
    """
    genre_dist = get_genre_distribution()
    element_dist = get_element_distribution()
    subgenre_index = _get_subgenre_index()
    
    return {
        "total_tracks": get_total_tracks(),
        "main_genres": list(genre_dist.keys()),
        "main_genres_count": len(genre_dist),
        "subgenres_count": len(subgenre_index),
        "genre_distribution": genre_dist,
        "element_distribution": element_dist,
    }
