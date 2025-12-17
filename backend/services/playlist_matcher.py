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
from services.library_service import get_all_songs, filter_by_criteria
from data.constants import ELEMENTS


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
