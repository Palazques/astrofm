"""
Playlist matching algorithm for Astro.FM.
Selects and orders optimal songs based on VibeParameters.

S2: Documentation Rule - All functions include clear docstrings.
H3: Unit Test Creation - Corresponding tests in tests/test_playlist_matcher.py.
"""
from typing import List, Tuple, Dict, Optional, Any
from collections import Counter

from models.song import Song
from models.vibe import VibeParameters
from models.playlist import PlaylistResult
from models.track_model import Track, GenrePreference
from services.library_service import get_all_songs, filter_by_criteria
from data.constants import ELEMENTS
from data.genre_mapping import PreferenceWeights, get_related_genres


# =============================================================================
# SCORING WEIGHTS (must sum to 100 for perfect match)
# =============================================================================

SCORING_WEIGHTS = {
    "element": 25,      # Primary=25, Secondary=15, Other=3
    "planet": 20,       # First=10, Second=6, Third=4
    "mood": 20,         # Top 2=20, Others=12
    "energy": 15,       # 15 - (distance / 3)
    "valence": 10,      # 10 - (distance / 4)
    "intensity": 5,     # 5 if in range, else 0
    "modality": 3,      # 3 if matches
    "time_of_day": 2,   # 2 if matches
}


# =============================================================================
# CANDIDATE POOL FUNCTIONS
# =============================================================================

def get_candidate_pool(
    vibe_params: VibeParameters, 
    playlist_size: int = 20
) -> List[Song]:
    """
    Get filtered candidates with progressive relaxation.
    
    Args:
        vibe_params: Target parameters from vibe calculator
        playlist_size: Minimum songs needed
        
    Returns:
        List of candidate songs (target 40-80, minimum playlist_size)
    """
    # Combine primary and secondary elements
    all_elements = list(vibe_params.primary_elements) + list(vibe_params.secondary_elements)
    
    # Widen energy/valence ranges by 15 for initial filter
    energy_min = max(0, vibe_params.target_energy[0] - 15)
    energy_max = min(100, vibe_params.target_energy[1] + 15)
    valence_min = max(0, vibe_params.target_valence[0] - 15)
    valence_max = min(100, vibe_params.target_valence[1] + 15)
    
    # First attempt: Full criteria
    candidates = filter_by_criteria(
        elements=all_elements if all_elements else None,
        min_energy=energy_min,
        max_energy=energy_max,
        min_valence=valence_min,
        max_valence=valence_max,
        time_of_day=vibe_params.time_of_day
    )
    
    # Progressive relaxation if not enough candidates
    if len(candidates) < 30:
        # Drop time_of_day, widen ranges more
        candidates = filter_by_criteria(
            elements=all_elements if all_elements else None,
            min_energy=max(0, energy_min - 10),
            max_energy=min(100, energy_max + 10),
            min_valence=max(0, valence_min - 10),
            max_valence=min(100, valence_max + 10)
        )
    
    if len(candidates) < 20:
        # Drop element filter entirely
        candidates = filter_by_criteria(
            min_energy=max(0, energy_min - 10),
            max_energy=min(100, energy_max + 10)
        )
    
    if len(candidates) < playlist_size:
        # Use all songs
        candidates = get_all_songs()
    
    return candidates


# =============================================================================
# SCORING FUNCTIONS
# =============================================================================

def score_song(song: Song, vibe_params: VibeParameters) -> float:
    """
    Calculate match score 0-100 for a song against vibe parameters.
    
    Args:
        song: Song to score
        vibe_params: Target parameters
        
    Returns:
        Score from 0-100
    """
    score = 0.0
    
    # Element match (25 pts max)
    element_score = 0
    for elem in song.elements:
        if elem in vibe_params.primary_elements:
            element_score = max(element_score, 25)
        elif elem in vibe_params.secondary_elements:
            element_score = max(element_score, 15)
        else:
            element_score = max(element_score, 3)
    score += element_score
    
    # Planet match (20 pts max: 10 + 6 + 4)
    planet_score = 0
    planet_points = [10, 6, 4]
    matched = 0
    for planet in song.planetary_energy:
        if planet in vibe_params.active_planets and matched < 3:
            planet_score += planet_points[matched]
            matched += 1
    score += planet_score
    
    # Mood match (20 pts max)
    mood_score = 0
    top_moods = vibe_params.mood_direction[:2] if len(vibe_params.mood_direction) >= 2 else vibe_params.mood_direction
    other_moods = vibe_params.mood_direction[2:] if len(vibe_params.mood_direction) > 2 else []
    
    for mood in song.moods:
        if mood in top_moods:
            mood_score = max(mood_score, 20)
        elif mood in other_moods:
            mood_score = max(mood_score, 12)
    score += mood_score
    
    # Energy proximity (15 pts max)
    target_energy_mid = (vibe_params.target_energy[0] + vibe_params.target_energy[1]) / 2
    energy_distance = abs(song.energy - target_energy_mid)
    energy_score = max(0, 15 - (energy_distance / 3))
    score += energy_score
    
    # Valence proximity (10 pts max)
    target_valence_mid = (vibe_params.target_valence[0] + vibe_params.target_valence[1]) / 2
    valence_distance = abs(song.valence - target_valence_mid)
    valence_score = max(0, 10 - (valence_distance / 4))
    score += valence_score
    
    # Intensity match (5 pts)
    if vibe_params.intensity_range[0] <= song.intensity <= vibe_params.intensity_range[1]:
        score += 5
    
    # Modality bonus (3 pts)
    if vibe_params.modality_preference and song.modality == vibe_params.modality_preference:
        score += 3
    
    # Time of day bonus (2 pts)
    if vibe_params.time_of_day and song.time_of_day:
        if vibe_params.time_of_day in song.time_of_day:
            score += 2
    
    return round(min(100, score), 2)


# =============================================================================
# DIVERSITY ENFORCEMENT
# =============================================================================

def enforce_diversity(
    scored_songs: List[Tuple[Song, float]],
    playlist_size: int = 20,
    max_per_artist: int = 2,
    max_per_genre: int = 4
) -> List[Song]:
    """
    Select songs enforcing variety rules.
    
    Args:
        scored_songs: List of (song, score) tuples, sorted by score descending
        playlist_size: Target number of songs
        max_per_artist: Maximum songs from same artist
        max_per_genre: Maximum songs in same genre
        
    Returns:
        Selected songs respecting diversity rules
    """
    selected: List[Song] = []
    artist_counts: Dict[str, int] = {}
    genre_counts: Dict[str, int] = {}
    
    # First pass: respect all rules
    for song, score in scored_songs:
        if len(selected) >= playlist_size:
            break
        
        # Check artist limit
        if artist_counts.get(song.artist, 0) >= max_per_artist:
            continue
        
        # Check genre limits (song can have multiple genres)
        genre_violation = False
        for genre in song.genres:
            if genre_counts.get(genre, 0) >= max_per_genre:
                genre_violation = True
                break
        
        if genre_violation:
            continue
        
        # Add song
        selected.append(song)
        artist_counts[song.artist] = artist_counts.get(song.artist, 0) + 1
        for genre in song.genres:
            genre_counts[genre] = genre_counts.get(genre, 0) + 1
    
    # Second pass: if we couldn't fill playlist, relax rules
    if len(selected) < playlist_size:
        for song, score in scored_songs:
            if len(selected) >= playlist_size:
                break
            if song not in selected:
                selected.append(song)
    
    return selected


# =============================================================================
# ENERGY ARC ORDERING
# =============================================================================

def _get_target_energy_for_position(position: int, total: int) -> int:
    """
    Calculate target energy for a specific playlist position.
    
    Arc:
    - Opening (0-15%): 55 - moderate, inviting
    - Build-up (15-40%): 65→85 - rising
    - Peak (40-65%): 85 - highest
    - Cool-down (65-85%): 85→65 - decreasing
    - Resolution (85-100%): 50 - moderate close
    """
    if total <= 1:
        return 60
    
    progress = position / (total - 1)
    
    if progress < 0.15:
        return 55
    elif progress < 0.40:
        # Linear interpolation from 65 to 85
        t = (progress - 0.15) / 0.25
        return int(65 + t * 20)
    elif progress < 0.65:
        return 85
    elif progress < 0.85:
        # Linear interpolation from 85 to 65
        t = (progress - 0.65) / 0.20
        return int(85 - t * 20)
    else:
        return 50


def order_by_energy_arc(songs: List[Song], playlist_size: int = 20) -> List[Song]:
    """
    Reorder songs for optimal energy flow.
    
    Args:
        songs: Unordered list of selected songs
        playlist_size: Total playlist size (for arc calculation)
        
    Returns:
        Songs reordered for energy arc
    """
    if len(songs) <= 1:
        return songs
    
    # Create list of (position, target_energy) sorted by how extreme the target is
    # Prioritize filling extreme positions first
    positions_with_targets = [
        (i, _get_target_energy_for_position(i, len(songs)))
        for i in range(len(songs))
    ]
    
    # Sort by distance from median (fill extremes first)
    median_energy = 67  # Approximate median of our arc
    positions_with_targets.sort(
        key=lambda x: -abs(x[1] - median_energy)
    )
    
    # Available songs sorted by energy
    available = sorted(songs, key=lambda s: s.energy)
    result: List[Optional[Song]] = [None] * len(songs)
    
    for position, target_energy in positions_with_targets:
        # Find closest available song to target energy
        best_song = None
        best_distance = float('inf')
        
        for song in available:
            distance = abs(song.energy - target_energy)
            if distance < best_distance:
                best_distance = distance
                best_song = song
        
        if best_song:
            result[position] = best_song
            available.remove(best_song)
    
    # Filter out any None values (shouldn't happen but safety)
    return [s for s in result if s is not None]


# =============================================================================
# MAIN ORCHESTRATION
# =============================================================================

def generate_playlist(
    vibe_params: VibeParameters,
    playlist_size: int = 20
) -> PlaylistResult:
    """
    Main function: Generate complete playlist from vibe parameters.
    
    Args:
        vibe_params: Target parameters from vibe calculator
        playlist_size: Number of songs (10-30)
        
    Returns:
        PlaylistResult with ordered songs and metadata
    """
    # Clamp playlist size
    playlist_size = max(10, min(30, playlist_size))
    
    # Step 1: Get candidate pool
    candidates = get_candidate_pool(vibe_params, playlist_size)
    
    # Step 2: Score all candidates
    scored_songs: List[Tuple[Song, float]] = [
        (song, score_song(song, vibe_params))
        for song in candidates
    ]
    
    # Sort by score descending
    scored_songs.sort(key=lambda x: -x[1])
    
    # Step 3: Enforce diversity
    selected_songs = enforce_diversity(scored_songs, playlist_size)
    
    # Step 4: Order by energy arc
    ordered_songs = order_by_energy_arc(selected_songs, playlist_size)
    
    # Step 5: Build result
    total_duration = sum(song.duration_seconds for song in ordered_songs)
    
    # Calculate average match score
    song_scores = {song.id: score for song, score in scored_songs}
    avg_score = sum(song_scores.get(song.id, 0) for song in ordered_songs) / len(ordered_songs) if ordered_songs else 0
    
    # Build energy arc
    energy_arc = [song.energy for song in ordered_songs]
    
    # Calculate element distribution
    element_dist: Dict[str, int] = {}
    for song in ordered_songs:
        for elem in song.elements:
            element_dist[elem] = element_dist.get(elem, 0) + 1
    
    # Calculate mood distribution
    mood_dist: Dict[str, int] = {}
    for song in ordered_songs:
        for mood in song.moods:
            mood_dist[mood] = mood_dist.get(mood, 0) + 1
    
    # Generation metadata
    metadata = {
        "candidates_found": len(candidates),
        "playlist_size_requested": playlist_size,
        "songs_selected": len(ordered_songs),
        "target_energy": vibe_params.target_energy,
        "target_valence": vibe_params.target_valence,
        "primary_elements": vibe_params.primary_elements,
        "active_planets": vibe_params.active_planets,
        "mood_direction": vibe_params.mood_direction,
    }
    
    return PlaylistResult(
        songs=ordered_songs,
        total_duration_seconds=total_duration,
        vibe_match_score=round(avg_score, 2),
        energy_arc=energy_arc,
        element_distribution=element_dist,
        mood_distribution=mood_dist,
        generation_metadata=metadata
    )


# =============================================================================
# DATASET-BASED PLAYLIST GENERATION (with Genre Preferences)
# =============================================================================

def score_track(track: Track, vibe_params: VibeParameters, genre_weight: float = 1.0) -> float:
    """
    Calculate match score 0-100 for a dataset track against vibe parameters.
    Applies genre preference weight multiplier.
    
    Args:
        track: Track from the 114K dataset
        vibe_params: Target parameters
        genre_weight: Preference weight (2.0 for subgenre, 1.0 for main, 0.3 for related)
        
    Returns:
        Weighted score
    """
    score = 0.0
    
    # Element match (25 pts max)
    if track.element:
        if track.element in vibe_params.primary_elements:
            score += 25
        elif track.element in vibe_params.secondary_elements:
            score += 15
        else:
            score += 3
    
    # Energy proximity (15 pts max) - energy is 0-1 in dataset, convert to 0-100
    track_energy = track.energy * 100
    target_energy_mid = (vibe_params.target_energy[0] + vibe_params.target_energy[1]) / 2
    energy_distance = abs(track_energy - target_energy_mid)
    energy_score = max(0, 15 - (energy_distance / 3))
    score += energy_score
    
    # Valence proximity (10 pts max) - valence is 0-1 in dataset, convert to 0-100
    track_valence = track.valence * 100
    target_valence_mid = (vibe_params.target_valence[0] + vibe_params.target_valence[1]) / 2
    valence_distance = abs(track_valence - target_valence_mid)
    valence_score = max(0, 10 - (valence_distance / 4))
    score += valence_score
    
    # Danceability as mood proxy (10 pts max)
    if track.danceability > 0.7:
        score += 10
    elif track.danceability > 0.5:
        score += 6
    elif track.danceability > 0.3:
        score += 3
    
    # Acousticness for Earth/Water elements (5 pts max)
    if "Earth" in vibe_params.primary_elements or "Water" in vibe_params.primary_elements:
        if track.acousticness > 0.5:
            score += 5
    
    # Popularity bonus (5 pts max) - prefer popular tracks
    popularity_score = (track.popularity / 100) * 5
    score += popularity_score
    
    # Apply genre preference weight
    weighted_score = score * genre_weight
    
    return round(min(100, weighted_score), 2)


def generate_playlist_from_dataset(
    vibe_params: VibeParameters,
    genre_preferences: Optional[GenrePreference] = None,
    playlist_size: int = 20
) -> Dict[str, Any]:
    """
    Generate playlist using the 114K track dataset with genre preferences.
    
    Preference weights:
    - Subgenre selected: 2.0x weight
    - Main genre only: 1.0x weight  
    - Related genres: 0.3x weight
    
    Args:
        vibe_params: Target parameters from vibe calculator
        genre_preferences: User's genre selections (main genres and subgenres)
        playlist_size: Number of tracks (10-30)
        
    Returns:
        Dict with tracks, metadata, and generation info
    """
    # Import here to avoid circular imports
    from services.music_dataset_service import (
        load_dataset,
        get_tracks_by_preference,
        get_tracks_by_element,
    )
    
    # Clamp playlist size
    playlist_size = max(10, min(30, playlist_size))
    
    # Ensure dataset is loaded
    load_dataset()
    
    scored_tracks: List[Tuple[Track, float]] = []
    
    if genre_preferences and (genre_preferences.main_genres or genre_preferences.subgenres):
        # Use preference-weighted selection
        weighted_tracks = get_tracks_by_preference(
            selected_genres=genre_preferences.main_genres,
            selected_subgenres=genre_preferences.subgenres,
            include_related=genre_preferences.include_related,
            total_tracks=playlist_size * 10,  # Get 10x pool for scoring
        )
        
        # Score each track with its preference weight
        for track, pref_weight in weighted_tracks:
            score = score_track(track, vibe_params, pref_weight)
            scored_tracks.append((track, score))
    else:
        # No genre preferences - filter by element
        element_to_use = (
            list(vibe_params.primary_elements)[0] 
            if vibe_params.primary_elements 
            else "Fire"
        )
        candidate_tracks = get_tracks_by_element(element_to_use, limit=playlist_size * 5)
        
        for track in candidate_tracks:
            score = score_track(track, vibe_params, 1.0)
            scored_tracks.append((track, score))
    
    # Sort by score descending
    scored_tracks.sort(key=lambda x: -x[1])
    
    # Enforce diversity (max 2 per artist)
    selected_tracks: List[Track] = []
    artist_counts: Dict[str, int] = {}
    genre_counts: Dict[str, int] = {}
    
    for track, score in scored_tracks:
        if len(selected_tracks) >= playlist_size:
            break
        
        # Check artist limit
        if artist_counts.get(track.artists, 0) >= 2:
            continue
        
        # Check genre limit
        if track.main_genre and genre_counts.get(track.main_genre, 0) >= 4:
            continue
        
        selected_tracks.append(track)
        artist_counts[track.artists] = artist_counts.get(track.artists, 0) + 1
        if track.main_genre:
            genre_counts[track.main_genre] = genre_counts.get(track.main_genre, 0) + 1
    
    # Order by energy arc
    ordered_tracks = _order_tracks_by_energy_arc(selected_tracks)
    
    # Build result
    total_duration = sum(t.duration_ms for t in ordered_tracks)
    track_scores = {t.track_id: s for t, s in scored_tracks}
    avg_score = (
        sum(track_scores.get(t.track_id, 0) for t in ordered_tracks) / len(ordered_tracks)
        if ordered_tracks else 0
    )
    
    # Element distribution
    element_dist: Dict[str, int] = {}
    for track in ordered_tracks:
        if track.element:
            element_dist[track.element] = element_dist.get(track.element, 0) + 1
    
    # Genre distribution
    genre_dist: Dict[str, int] = {}
    for track in ordered_tracks:
        if track.main_genre:
            genre_dist[track.main_genre] = genre_dist.get(track.main_genre, 0) + 1
    
    return {
        "tracks": [
            {
                "track_id": t.track_id,
                "track_name": t.track_name,
                "artists": t.artists,
                "album_name": t.album_name,
                "duration_ms": t.duration_ms,
                "popularity": t.popularity,
                "energy": t.energy,
                "valence": t.valence,
                "danceability": t.danceability,
                "main_genre": t.main_genre,
                "subgenre": t.subgenre,
                "element": t.element,
            }
            for t in ordered_tracks
        ],
        "total_duration_ms": total_duration,
        "vibe_match_score": round(avg_score, 2),
        "energy_arc": [t.energy for t in ordered_tracks],
        "element_distribution": element_dist,
        "genre_distribution": genre_dist,
        "generation_metadata": {
            "source": "music_dataset",
            "playlist_size_requested": playlist_size,
            "tracks_selected": len(ordered_tracks),
            "genre_preferences": {
                "main_genres": genre_preferences.main_genres if genre_preferences else [],
                "subgenres": genre_preferences.subgenres if genre_preferences else [],
                "include_related": genre_preferences.include_related if genre_preferences else True,
            } if genre_preferences else None,
            "target_energy": vibe_params.target_energy,
            "target_valence": vibe_params.target_valence,
            "primary_elements": list(vibe_params.primary_elements),
        },
    }


def _order_tracks_by_energy_arc(tracks: List[Track]) -> List[Track]:
    """
    Reorder tracks for optimal energy flow (same arc as order_by_energy_arc).
    
    Args:
        tracks: Unordered list of selected tracks
        
    Returns:
        Tracks reordered for energy arc
    """
    if len(tracks) <= 1:
        return tracks
    
    # Create list of (position, target_energy) sorted by how extreme the target is
    positions_with_targets = [
        (i, _get_target_energy_for_position(i, len(tracks)))
        for i in range(len(tracks))
    ]
    
    # Sort by distance from median (fill extremes first)
    median_energy = 67
    positions_with_targets.sort(key=lambda x: -abs(x[1] - median_energy))
    
    # Available tracks sorted by energy (convert 0-1 to 0-100 for comparison)
    available = sorted(tracks, key=lambda t: t.energy * 100)
    result: List[Optional[Track]] = [None] * len(tracks)
    
    for position, target_energy in positions_with_targets:
        best_track = None
        best_distance = float('inf')
        
        for track in available:
            track_energy = track.energy * 100
            distance = abs(track_energy - target_energy)
            if distance < best_distance:
                best_distance = distance
                best_track = track
        
        if best_track:
            result[position] = best_track
            available.remove(best_track)
    
    return [t for t in result if t is not None]


# =============================================================================
# BLENDED PLAYLIST GENERATION (User Library + App Dataset)
# =============================================================================

def score_user_library_track(
    track: 'UserLibraryTrack',
    vibe_params: VibeParameters
) -> float:
    """
    Calculate match score 0-100 for a user library track against vibe parameters.
    
    Args:
        track: UserLibraryTrack from user_library.db
        vibe_params: Target parameters
        
    Returns:
        Score from 0-100
    """
    from models.user_library_models import UserLibraryTrack
    
    score = 0.0
    
    # Element match (25 pts max)
    if track.element:
        if track.element in vibe_params.primary_elements:
            score += 25
        elif track.element in vibe_params.secondary_elements:
            score += 15
        else:
            score += 3
    
    # Energy proximity (15 pts max) - energy is 0-1, convert to 0-100
    if track.energy is not None:
        track_energy = track.energy * 100
        target_energy_mid = (vibe_params.target_energy[0] + vibe_params.target_energy[1]) / 2
        energy_distance = abs(track_energy - target_energy_mid)
        energy_score = max(0, 15 - (energy_distance / 3))
        score += energy_score
    
    # Valence proximity (10 pts max)
    if track.valence is not None:
        track_valence = track.valence * 100
        target_valence_mid = (vibe_params.target_valence[0] + vibe_params.target_valence[1]) / 2
        valence_distance = abs(track_valence - target_valence_mid)
        valence_score = max(0, 10 - (valence_distance / 4))
        score += valence_score
    
    # Danceability bonus (10 pts max)
    if track.danceability is not None:
        if track.danceability > 0.7:
            score += 10
        elif track.danceability > 0.5:
            score += 6
        elif track.danceability > 0.3:
            score += 3
    
    # Acousticness for Earth/Water elements (5 pts max)
    if track.acousticness is not None:
        if "Earth" in vibe_params.primary_elements or "Water" in vibe_params.primary_elements:
            if track.acousticness > 0.5:
                score += 5
    
    return round(min(100, score), 2)


async def query_user_library(
    vibe_params: VibeParameters,
    limit: int = 20
) -> List[Tuple[Any, float]]:
    """
    Query user library for tracks matching vibe parameters.
    
    Args:
        vibe_params: Target parameters from vibe calculator
        limit: Maximum tracks to return
        
    Returns:
        List of (UserLibraryTrack, score) tuples sorted by score descending
    """
    from services.user_library_db import get_tracks_with_features
    
    # Get tracks with complete features
    element_to_use = (
        list(vibe_params.primary_elements)[0]
        if vibe_params.primary_elements
        else None
    )
    
    # Fetch more than needed to allow for scoring/filtering
    pool_size = limit * 5
    user_tracks = get_tracks_with_features(limit=pool_size, element=element_to_use)
    
    # If not enough from primary element, get more without filter
    if len(user_tracks) < pool_size // 2:
        additional = get_tracks_with_features(limit=pool_size - len(user_tracks))
        # Dedupe by ID
        existing_ids = {t.id for t in user_tracks}
        for t in additional:
            if t.id not in existing_ids:
                user_tracks.append(t)
    
    # Score all tracks
    scored_tracks = [
        (track, score_user_library_track(track, vibe_params))
        for track in user_tracks
    ]
    
    # Sort by score descending
    scored_tracks.sort(key=lambda x: -x[1])
    
    return scored_tracks[:limit * 2]  # Return 2x for blending


async def generate_blended_playlist(
    vibe_params: VibeParameters,
    genre_preferences: Optional[GenrePreference] = None,
    playlist_size: int = 20,
) -> Dict[str, Any]:
    """
    Generate playlist from both user library and app dataset in parallel.
    
    Dynamic blending: Prioritize user library tracks with good scores,
    fill rest from app dataset. Ensures diversity across both sources.
    
    Args:
        vibe_params: Target parameters from vibe calculator
        genre_preferences: User's genre selections
        playlist_size: Target number of tracks (10-30)
        
    Returns:
        Dict with tracks, metadata, and source attribution
    """
    import asyncio
    from services.user_library_db import get_total_tracks, get_stats
    
    playlist_size = max(10, min(30, playlist_size))
    
    # Check if user library has any tracks
    user_library_stats = get_stats()
    has_user_library = user_library_stats.get("complete_features", 0) > 0
    
    if not has_user_library:
        # No user library - just use dataset
        result = generate_playlist_from_dataset(vibe_params, genre_preferences, playlist_size)
        result["generation_metadata"]["source"] = "dataset_only"
        result["generation_metadata"]["user_library_tracks"] = 0
        return result
    
    # Parallel queries to both sources
    user_task = asyncio.create_task(query_user_library(vibe_params, playlist_size))
    
    # Dataset query (synchronous but wrapped)
    loop = asyncio.get_event_loop()
    dataset_task = loop.run_in_executor(
        None,
        lambda: generate_playlist_from_dataset(vibe_params, genre_preferences, playlist_size)
    )
    
    user_scored, dataset_result = await asyncio.gather(user_task, dataset_task)
    
    # Extract dataset tracks
    dataset_tracks = dataset_result.get("tracks", [])
    
    # Blend: Dynamic ratio based on user library quality
    # Take user tracks scoring above threshold (50+)
    min_user_score = 50
    quality_user_tracks = [(t, s) for t, s in user_scored if s >= min_user_score]
    
    # Target: up to 50% from user library
    max_user_tracks = playlist_size // 2
    selected_user_tracks = quality_user_tracks[:max_user_tracks]
    
    # Diversity enforcement for user tracks
    final_user_tracks = []
    user_artists: Dict[str, int] = {}
    
    for track, score in selected_user_tracks:
        artist = track.display_artist
        if user_artists.get(artist, 0) < 2:  # Max 2 per artist
            final_user_tracks.append((track, score))
            user_artists[artist] = user_artists.get(artist, 0) + 1
    
    # Fill rest from dataset
    needed_from_dataset = playlist_size - len(final_user_tracks)
    
    # Convert user tracks to output format
    blended_tracks = []
    
    for track, score in final_user_tracks:
        blended_tracks.append({
            "track_id": f"user_{track.id}",
            "track_name": track.display_name,
            "artists": track.display_artist,
            "album_name": None,  # User library doesn't store album
            "duration_ms": 0,    # Not tracked
            "popularity": 0,
            "energy": track.energy,
            "valence": track.valence,
            "danceability": track.danceability,
            "main_genre": None,
            "subgenre": None,
            "element": track.element,
            "source": "user_library",
            "match_score": score,
        })
    
    # Add dataset tracks (skip if artist already represented)
    dataset_idx = 0
    while len(blended_tracks) < playlist_size and dataset_idx < len(dataset_tracks):
        dt = dataset_tracks[dataset_idx]
        dataset_idx += 1
        
        # Check artist diversity
        if user_artists.get(dt.get("artists", ""), 0) >= 2:
            continue
        
        dt["source"] = "app_dataset"
        dt["match_score"] = dataset_result.get("vibe_match_score", 0)
        blended_tracks.append(dt)
        user_artists[dt.get("artists", "")] = user_artists.get(dt.get("artists", ""), 0) + 1
    
    # Order by energy arc
    blended_tracks = _order_blended_by_energy_arc(blended_tracks)
    
    # Calculate stats
    user_count = sum(1 for t in blended_tracks if t.get("source") == "user_library")
    dataset_count = sum(1 for t in blended_tracks if t.get("source") == "app_dataset")
    
    # Element distribution
    element_dist: Dict[str, int] = {}
    for t in blended_tracks:
        elem = t.get("element")
        if elem:
            element_dist[elem] = element_dist.get(elem, 0) + 1
    
    avg_score = sum(t.get("match_score", 0) for t in blended_tracks) / len(blended_tracks) if blended_tracks else 0
    
    return {
        "tracks": blended_tracks,
        "total_duration_ms": sum(t.get("duration_ms", 0) for t in blended_tracks),
        "vibe_match_score": round(avg_score, 2),
        "energy_arc": [t.get("energy", 0.5) for t in blended_tracks],
        "element_distribution": element_dist,
        "genre_distribution": dataset_result.get("genre_distribution", {}),
        "generation_metadata": {
            "source": "blended",
            "user_library_tracks": user_count,
            "dataset_tracks": dataset_count,
            "playlist_size_requested": playlist_size,
            "tracks_selected": len(blended_tracks),
            "target_energy": vibe_params.target_energy,
            "target_valence": vibe_params.target_valence,
            "primary_elements": list(vibe_params.primary_elements),
            "user_library_pool_size": user_library_stats.get("complete_features", 0),
        },
    }


def _order_blended_by_energy_arc(tracks: List[Dict]) -> List[Dict]:
    """
    Reorder blended tracks for optimal energy flow.
    
    Args:
        tracks: List of track dicts with 'energy' field
        
    Returns:
        Tracks reordered for energy arc
    """
    if len(tracks) <= 1:
        return tracks
    
    positions_with_targets = [
        (i, _get_target_energy_for_position(i, len(tracks)))
        for i in range(len(tracks))
    ]
    
    median_energy = 67
    positions_with_targets.sort(key=lambda x: -abs(x[1] - median_energy))
    
    # Energy is 0-1, convert to 0-100 for comparison
    available = sorted(tracks, key=lambda t: (t.get("energy") or 0.5) * 100)
    result: List[Optional[Dict]] = [None] * len(tracks)
    
    for position, target_energy in positions_with_targets:
        best_track = None
        best_distance = float('inf')
        
        for track in available:
            track_energy = (track.get("energy") or 0.5) * 100
            distance = abs(track_energy - target_energy)
            if distance < best_distance:
                best_distance = distance
                best_track = track
        
        if best_track:
            result[position] = best_track
            available.remove(best_track)
    
    return [t for t in result if t is not None]


