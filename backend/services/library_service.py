"""
Library service for loading and querying the song mock library.
Implements filtering by element, planet, genre, mood, and combined criteria.

S2 (Documentation Rule) - All functions include clear docstrings.
H3 (Unit Test Creation) - Corresponding tests in tests/test_library_service.py.
"""
import json
from functools import lru_cache
from pathlib import Path
from typing import List, Optional, Dict, Any

from models.song import Song
from data.constants import ELEMENTS, PLANETS, GENRES, MOODS


# Cache the library to avoid repeated file reads
_library_cache: Optional[List[Song]] = None


def _get_library_path() -> Path:
    """Get the path to the mock library JSON file."""
    return Path(__file__).parent.parent / "data" / "mock_library.json"


def load_library() -> List[Song]:
    """
    Load and validate the mock library from JSON.
    
    Returns:
        List of validated Song objects.
        
    Raises:
        FileNotFoundError: If mock_library.json doesn't exist.
        ValidationError: If any song fails Pydantic validation.
    """
    global _library_cache
    
    if _library_cache is not None:
        return _library_cache
    
    library_path = _get_library_path()
    
    with open(library_path, "r", encoding="utf-8") as f:
        raw_songs = json.load(f)
    
    # Validate each song through Pydantic
    songs = [Song(**song_data) for song_data in raw_songs]
    
    _library_cache = songs
    return songs


def get_all_songs() -> List[Song]:
    """
    Get all songs from the library.
    
    Returns:
        List of all Song objects.
    """
    return load_library()


def get_song_by_id(song_id: str) -> Optional[Song]:
    """
    Get a single song by its ID.
    
    Args:
        song_id: The unique song identifier (e.g., "song_001").
        
    Returns:
        The Song object if found, None otherwise.
    """
    songs = load_library()
    for song in songs:
        if song.id == song_id:
            return song
    return None


def filter_by_element(element: str) -> List[Song]:
    """
    Filter songs by astrological element.
    
    Args:
        element: One of "Fire", "Earth", "Air", "Water".
        
    Returns:
        List of songs containing that element.
        
    Raises:
        ValueError: If element is not valid.
    """
    if element not in ELEMENTS:
        raise ValueError(f"Invalid element: '{element}'. Must be one of: {list(ELEMENTS.keys())}")
    
    songs = load_library()
    return [song for song in songs if element in song.elements]


def filter_by_planet(planet: str) -> List[Song]:
    """
    Filter songs by planetary energy.
    
    Args:
        planet: One of the 10 planetary bodies.
        
    Returns:
        List of songs with that planetary energy.
        
    Raises:
        ValueError: If planet is not valid.
    """
    if planet not in PLANETS:
        raise ValueError(f"Invalid planet: '{planet}'. Must be one of: {list(PLANETS.keys())}")
    
    songs = load_library()
    return [song for song in songs if planet in song.planetary_energy]


def filter_by_genre(genre: str) -> List[Song]:
    """
    Filter songs by genre.
    
    Args:
        genre: One of the 30 defined genres.
        
    Returns:
        List of songs in that genre.
        
    Raises:
        ValueError: If genre is not valid.
    """
    if genre not in GENRES:
        raise ValueError(f"Invalid genre: '{genre}'. Must be one of: {GENRES}")
    
    songs = load_library()
    return [song for song in songs if genre in song.genres]


def filter_by_mood(mood: str) -> List[Song]:
    """
    Filter songs by mood.
    
    Args:
        mood: One of the 25 defined moods.
        
    Returns:
        List of songs with that mood.
        
    Raises:
        ValueError: If mood is not valid.
    """
    if mood not in MOODS:
        raise ValueError(f"Invalid mood: '{mood}'. Must be one of: {MOODS}")
    
    songs = load_library()
    return [song for song in songs if mood in song.moods]


def filter_by_criteria(
    elements: Optional[List[str]] = None,
    planets: Optional[List[str]] = None,
    genres: Optional[List[str]] = None,
    moods: Optional[List[str]] = None,
    min_energy: Optional[int] = None,
    max_energy: Optional[int] = None,
    min_valence: Optional[int] = None,
    max_valence: Optional[int] = None,
    min_bpm: Optional[int] = None,
    max_bpm: Optional[int] = None,
    modality: Optional[str] = None,
    time_of_day: Optional[str] = None,
) -> List[Song]:
    """
    Filter songs by multiple criteria combined.
    
    All provided criteria must match (AND logic).
    For list criteria (elements, planets, genres, moods), 
    a song matches if it contains ANY of the specified values (OR within category).
    
    Args:
        elements: List of elements to match (song must have at least one).
        planets: List of planets to match (song must have at least one).
        genres: List of genres to match (song must have at least one).
        moods: List of moods to match (song must have at least one).
        min_energy: Minimum energy level (0-100).
        max_energy: Maximum energy level (0-100).
        min_valence: Minimum valence (0-100).
        max_valence: Maximum valence (0-100).
        min_bpm: Minimum BPM.
        max_bpm: Maximum BPM.
        modality: Specific modality to match.
        time_of_day: Specific time of day to match.
        
    Returns:
        List of songs matching all criteria.
    """
    songs = load_library()
    results = []
    
    for song in songs:
        # Check elements (OR within category)
        if elements:
            if not any(e in song.elements for e in elements):
                continue
        
        # Check planets (OR within category)
        if planets:
            if not any(p in song.planetary_energy for p in planets):
                continue
        
        # Check genres (OR within category)
        if genres:
            if not any(g in song.genres for g in genres):
                continue
        
        # Check moods (OR within category)
        if moods:
            if not any(m in song.moods for m in moods):
                continue
        
        # Check energy range
        if min_energy is not None and song.energy < min_energy:
            continue
        if max_energy is not None and song.energy > max_energy:
            continue
        
        # Check valence range
        if min_valence is not None and song.valence < min_valence:
            continue
        if max_valence is not None and song.valence > max_valence:
            continue
        
        # Check BPM range
        if min_bpm is not None and song.bpm < min_bpm:
            continue
        if max_bpm is not None and song.bpm > max_bpm:
            continue
        
        # Check modality
        if modality is not None and song.modality != modality:
            continue
        
        # Check time of day
        if time_of_day is not None:
            if song.time_of_day is None or time_of_day not in song.time_of_day:
                continue
        
        results.append(song)
    
    return results


def clear_cache() -> None:
    """Clear the library cache, forcing a reload on next access."""
    global _library_cache
    _library_cache = None
