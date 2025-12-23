"""
User Library Models for multi-platform music service integration.

S2: Documentation Rule - All models include clear docstrings.
"""
from dataclasses import dataclass, field
from typing import Optional, Dict
from datetime import datetime


@dataclass
class UserLibraryTrack:
    """
    A track from a user's connected music service (Spotify, Apple Music, etc.).
    
    Stored in the shared user_library.db pool to grow the app's music library.
    Uses canonical names for deduplication across platforms.
    """
    id: Optional[int] = None  # Auto-increment ID from database
    
    # Canonical names for deduplication (lowercase, stripped)
    canonical_name: str = ""
    canonical_artist: str = ""
    
    # Display names (original formatting)
    display_name: str = ""
    display_artist: str = ""
    
    # Provider IDs for multi-platform support
    # e.g., {"spotify": "abc123", "apple_music": "xyz789"}
    provider_ids: Dict[str, str] = field(default_factory=dict)
    
    # Audio features (nullable until backfilled)
    energy: Optional[float] = None
    valence: Optional[float] = None
    tempo: Optional[float] = None
    danceability: Optional[float] = None
    acousticness: Optional[float] = None
    instrumentalness: Optional[float] = None
    speechiness: Optional[float] = None
    liveness: Optional[float] = None
    loudness: Optional[float] = None
    mode: Optional[int] = None  # 0 = minor, 1 = major
    key: Optional[int] = None   # 0-11 pitch class
    
    # Derived element (Fire/Earth/Air/Water)
    element: Optional[str] = None
    
    # Feature backfill status: "pending", "complete", "failed"
    features_status: str = "pending"
    
    # Timestamps
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    @property
    def has_features(self) -> bool:
        """Check if audio features have been backfilled."""
        return self.features_status == "complete" and self.energy is not None
    
    def add_provider_id(self, provider: str, provider_id: str) -> None:
        """Add a provider ID (e.g., when same track found on different platform)."""
        self.provider_ids[provider] = provider_id
    
    def get_provider_id(self, provider: str) -> Optional[str]:
        """Get the ID for a specific provider."""
        return self.provider_ids.get(provider)
    
    @staticmethod
    def canonicalize(text: str) -> str:
        """
        Normalize text for deduplication matching.
        
        Converts to lowercase, strips whitespace, removes common suffixes
        like "(Remastered)", "(feat. ...)", etc.
        """
        import re
        if not text:
            return ""
        
        # Lowercase and strip
        result = text.lower().strip()
        
        # Remove common suffixes in parentheses
        result = re.sub(r'\s*\([^)]*(?:remaster|remix|feat|ft\.|live|version|edit)[^)]*\)', '', result, flags=re.IGNORECASE)
        
        # Remove extra whitespace
        result = re.sub(r'\s+', ' ', result).strip()
        
        return result
    
    @classmethod
    def from_spotify_track(cls, spotify_track) -> 'UserLibraryTrack':
        """
        Create a UserLibraryTrack from a SpotifyTrack.
        
        Args:
            spotify_track: SpotifyTrack dataclass from spotify_service
            
        Returns:
            UserLibraryTrack with Spotify provider ID set
        """
        display_name = spotify_track.name
        display_artist = spotify_track.artists[0] if spotify_track.artists else ""
        
        track = cls(
            canonical_name=cls.canonicalize(display_name),
            canonical_artist=cls.canonicalize(display_artist),
            display_name=display_name,
            display_artist=display_artist,
            provider_ids={"spotify": spotify_track.id},
            # Copy audio features if available
            energy=spotify_track.energy,
            valence=spotify_track.valence,
            tempo=spotify_track.tempo,
            danceability=spotify_track.danceability,
            features_status="complete" if spotify_track.energy is not None else "pending",
        )
        
        return track


# Supported music providers
SUPPORTED_PROVIDERS = ["spotify", "apple_music", "youtube_music"]
