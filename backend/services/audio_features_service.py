"""
Audio Features Service for ASTRO.FM.

Fetches audio features from RapidAPI's Track Analysis API with caching
and rate limiting to stay within API limits (1 req/sec, 5000/month).

S2: Documentation Rule - All functions include clear docstrings.
C3: Least Privilege - API keys loaded via environment variables.
H4: Fidelity - Cross-referenced with RapidAPI documentation.
"""
import os
import asyncio
import time
from datetime import datetime
from typing import Optional, List, Dict
import httpx
from dotenv import load_dotenv

from models.audio_features import (
    AudioFeatures,
    RapidAPIResponse,
    TrackInfo,
    DEFAULT_AUDIO_FEATURES,
)
from services.audio_features_cache import get_audio_features_cache

# Load environment variables
load_dotenv()

# RapidAPI configuration
RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")
RAPIDAPI_HOST = os.getenv("RAPIDAPI_HOST", "track-analysis.p.rapidapi.com")
BASE_URL = f"https://{RAPIDAPI_HOST}"

# Rate limiting: 1 request per second
RATE_LIMIT_DELAY = 1.0  # seconds between requests


class AudioFeaturesService:
    """
    Service for fetching and caching audio features from RapidAPI.
    
    Supports two methods:
    - By Spotify track ID (faster, preferred for Spotify-connected users)
    - By song name + artist (slower, used as fallback)
    
    All responses are cached to minimize API usage.
    """
    
    _instance: Optional["AudioFeaturesService"] = None
    _last_request_time: float = 0.0
    
    def __new__(cls) -> "AudioFeaturesService":
        """Singleton pattern to ensure consistent rate limiting."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize with credentials from environment variables."""
        self.api_key = RAPIDAPI_KEY
        self.api_host = RAPIDAPI_HOST
        self.cache = get_audio_features_cache()
    
    @property
    def is_configured(self) -> bool:
        """Check if RapidAPI credentials are configured."""
        return bool(self.api_key)
    
    def _get_headers(self) -> dict:
        """Get headers for RapidAPI requests."""
        return {
            "x-rapidapi-key": self.api_key,
            "x-rapidapi-host": self.api_host,
        }
    
    async def _rate_limit(self) -> None:
        """Ensure we don't exceed 1 request per second."""
        now = time.time()
        elapsed = now - AudioFeaturesService._last_request_time
        if elapsed < RATE_LIMIT_DELAY:
            await asyncio.sleep(RATE_LIMIT_DELAY - elapsed)
        AudioFeaturesService._last_request_time = time.time()
    
    async def get_by_spotify_id(
        self,
        spotify_id: str,
        use_cache: bool = True
    ) -> Optional[AudioFeatures]:
        """
        Get audio features using Spotify track ID.
        
        This is the fastest endpoint, preferred when Spotify IDs are available.
        
        Args:
            spotify_id: Spotify track ID (e.g., "7s25THrKz86DM225dOYwnr")
            use_cache: Whether to check/update cache
            
        Returns:
            AudioFeatures if successful, None if failed
        """
        # Check cache first
        if use_cache:
            cached = self.cache.get(spotify_id)
            if cached:
                return cached
        
        if not self.is_configured:
            print("AudioFeaturesService: RapidAPI not configured")
            return None
        
        # Rate limit
        await self._rate_limit()
        
        url = f"{BASE_URL}/pktx/spotify/{spotify_id}"
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.get(url, headers=self._get_headers())
                
                if response.status_code == 200:
                    data = response.json()
                    api_response = RapidAPIResponse(**data)
                    features = api_response.to_audio_features(spotify_id)
                    
                    # Cache the result
                    if use_cache:
                        self.cache.set(spotify_id, features)
                    
                    return features
                    
                elif response.status_code == 429:
                    print(f"AudioFeaturesService: Rate limit exceeded")
                else:
                    print(f"AudioFeaturesService: Error {response.status_code}")
                    
            except Exception as e:
                print(f"AudioFeaturesService: Request error - {e}")
        
        return None
    
    async def get_by_query(
        self,
        song: str,
        artist: str,
        track_id: Optional[str] = None,
        use_cache: bool = True
    ) -> Optional[AudioFeatures]:
        """
        Get audio features by searching for song name and artist.
        
        Slower than Spotify ID method but works without Spotify integration.
        
        Args:
            song: Track name (e.g., "Blinding Lights")
            artist: Artist name (e.g., "The Weeknd")
            track_id: Optional ID to use for caching (defaults to generated key)
            use_cache: Whether to check/update cache
            
        Returns:
            AudioFeatures if successful, None if failed
        """
        # Generate cache key if not provided
        cache_key = track_id or f"{artist}:{song}".lower().replace(" ", "_")
        
        # Check cache first
        if use_cache:
            cached = self.cache.get(cache_key)
            if cached:
                return cached
        
        if not self.is_configured:
            print("AudioFeaturesService: RapidAPI not configured")
            return None
        
        # Rate limit
        await self._rate_limit()
        
        url = f"{BASE_URL}/pktx/analysis"
        params = {"song": song, "artist": artist}
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.get(
                    url, 
                    headers=self._get_headers(),
                    params=params
                )
                
                if response.status_code == 200:
                    data = response.json()
                    api_response = RapidAPIResponse(**data)
                    features = api_response.to_audio_features(cache_key)
                    
                    # Cache the result
                    if use_cache:
                        self.cache.set(cache_key, features)
                    
                    return features
                    
                elif response.status_code == 429:
                    print(f"AudioFeaturesService: Rate limit exceeded")
                else:
                    print(f"AudioFeaturesService: Error {response.status_code}")
                    
            except Exception as e:
                print(f"AudioFeaturesService: Request error - {e}")
        
        return None
    
    async def get_features(
        self,
        track_id: str,
        track_name: Optional[str] = None,
        artist: Optional[str] = None
    ) -> AudioFeatures:
        """
        Get audio features using the best available method.
        
        Tries Spotify ID first, falls back to query, returns defaults if both fail.
        
        Args:
            track_id: Spotify track ID
            track_name: Optional track name for fallback query
            artist: Optional artist name for fallback query
            
        Returns:
            AudioFeatures (never None - returns defaults if API fails)
        """
        # Try Spotify ID method first
        features = await self.get_by_spotify_id(track_id)
        
        # Fallback to query method if we have track name and artist
        if features is None and track_name and artist:
            features = await self.get_by_query(track_name, artist, track_id)
        
        # Return defaults if all methods fail
        if features is None:
            features = AudioFeatures(
                track_id=track_id,
                **DEFAULT_AUDIO_FEATURES
            )
        
        return features
    
    async def get_batch_features(
        self,
        tracks: List[TrackInfo]
    ) -> Dict[str, AudioFeatures]:
        """
        Get audio features for multiple tracks.
        
        Checks cache first, then fetches missing tracks from API
        with rate limiting (1 per second).
        
        Args:
            tracks: List of TrackInfo objects
            
        Returns:
            Dict mapping track_id to AudioFeatures
        """
        results: Dict[str, AudioFeatures] = {}
        uncached_tracks: List[TrackInfo] = []
        
        # Check cache for all tracks first
        for track in tracks:
            cached = self.cache.get(track.track_id)
            if cached:
                results[track.track_id] = cached
            else:
                uncached_tracks.append(track)
        
        print(f"AudioFeaturesService: {len(results)} cached, "
              f"{len(uncached_tracks)} to fetch")
        
        # Fetch uncached tracks (rate limited)
        for track in uncached_tracks:
            features = await self.get_features(
                track.track_id,
                track.name,
                track.artist
            )
            results[track.track_id] = features
        
        return results
    
    def get_cache_stats(self) -> dict:
        """Get cache statistics."""
        return {
            "cached_tracks": self.cache.size(),
            "api_configured": self.is_configured,
        }


# Singleton instance getter
_service_instance: Optional[AudioFeaturesService] = None


def get_audio_features_service() -> AudioFeaturesService:
    """Get or create the AudioFeaturesService singleton."""
    global _service_instance
    if _service_instance is None:
        _service_instance = AudioFeaturesService()
    return _service_instance
