"""
Audio features caching layer for ASTRO.FM.

Provides persistent caching of track audio features to minimize
API calls to RapidAPI's Track Analysis service.

S2: Documentation Rule - All functions include clear docstrings.
C3: Least Privilege - No API keys needed for caching.
"""
import json
import os
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List
from models.audio_features import AudioFeatures


# Default cache file location
DEFAULT_CACHE_PATH = Path(__file__).parent.parent / "data" / "audio_features_cache.json"


class AudioFeaturesCache:
    """
    File-based cache for audio features.
    
    Stores audio features as JSON for persistence across server restarts.
    Phase 1 implementation using JSON file; can be upgraded to SQLite/Firebase later.
    """
    
    def __init__(self, cache_path: Optional[Path] = None):
        """
        Initialize the cache.
        
        Args:
            cache_path: Optional path to cache file. Defaults to data/audio_features_cache.json
        """
        self.cache_path = cache_path or DEFAULT_CACHE_PATH
        self._cache: Dict[str, dict] = {}
        self._load_cache()
    
    def _load_cache(self) -> None:
        """Load cache from disk."""
        if self.cache_path.exists():
            try:
                with open(self.cache_path, "r", encoding="utf-8") as f:
                    self._cache = json.load(f)
            except (json.JSONDecodeError, IOError):
                # If cache file is corrupted, start fresh
                self._cache = {}
        else:
            self._cache = {}
    
    def _save_cache(self) -> None:
        """Save cache to disk."""
        # Ensure directory exists
        self.cache_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(self.cache_path, "w", encoding="utf-8") as f:
            json.dump(self._cache, f, indent=2, default=str)
    
    def get(self, track_id: str) -> Optional[AudioFeatures]:
        """
        Get cached audio features for a track.
        
        Args:
            track_id: Spotify track ID
            
        Returns:
            AudioFeatures if found in cache, None otherwise
        """
        if track_id in self._cache:
            data = self._cache[track_id]
            # Convert fetched_at back to datetime if it's a string
            if isinstance(data.get("fetched_at"), str):
                data["fetched_at"] = datetime.fromisoformat(data["fetched_at"])
            return AudioFeatures(**data)
        return None
    
    def set(self, track_id: str, features: AudioFeatures) -> None:
        """
        Store audio features in cache.
        
        Args:
            track_id: Spotify track ID
            features: AudioFeatures to cache
        """
        self._cache[track_id] = features.model_dump()
        self._save_cache()
    
    def get_many(self, track_ids: List[str]) -> Dict[str, Optional[AudioFeatures]]:
        """
        Get cached audio features for multiple tracks.
        
        Args:
            track_ids: List of Spotify track IDs
            
        Returns:
            Dict mapping track_id to AudioFeatures (or None if not cached)
        """
        return {track_id: self.get(track_id) for track_id in track_ids}
    
    def set_many(self, features_dict: Dict[str, AudioFeatures]) -> None:
        """
        Store multiple audio features in cache.
        
        Args:
            features_dict: Dict mapping track_id to AudioFeatures
        """
        for track_id, features in features_dict.items():
            self._cache[track_id] = features.model_dump()
        self._save_cache()
    
    def has(self, track_id: str) -> bool:
        """Check if a track is in the cache."""
        return track_id in self._cache
    
    def get_uncached_ids(self, track_ids: List[str]) -> List[str]:
        """
        Get list of track IDs that are NOT in the cache.
        
        Args:
            track_ids: List of Spotify track IDs to check
            
        Returns:
            List of track IDs not found in cache
        """
        return [tid for tid in track_ids if tid not in self._cache]
    
    def size(self) -> int:
        """Get the number of tracks in the cache."""
        return len(self._cache)
    
    def clear(self) -> None:
        """Clear all cached data."""
        self._cache = {}
        self._save_cache()


# Singleton instance
_cache_instance: Optional[AudioFeaturesCache] = None


def get_audio_features_cache() -> AudioFeaturesCache:
    """Get or create the audio features cache singleton."""
    global _cache_instance
    if _cache_instance is None:
        _cache_instance = AudioFeaturesCache()
    return _cache_instance
