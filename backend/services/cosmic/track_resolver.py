"""
Track Resolver - Spotify search pipeline.

Resolves AI track suggestions to actual Spotify track URIs
using progressive search strategies.

S2: Documentation Rule - Clear docstrings for all functions.
"""
import asyncio
from typing import List, Optional, Dict, Any
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor

from .app_spotify import get_app_spotify_service
from .track_generator import TrackSuggestion


@dataclass
class ResolvedTrack:
    """A track resolved to Spotify."""
    name: str
    artist: str
    uri: str
    url: str
    album_art: Optional[str] = None
    

class TrackResolver:
    """
    Resolves track suggestions to Spotify URIs.
    
    Uses progressive search strategies:
    1. Exact match (track:"X" artist:"Y")
    2. Fuzzy match (artist title)
    3. Artist fallback (random from artist's catalog)
    """
    
    def __init__(self):
        self.spotify = get_app_spotify_service()
        self._resolved_artists: Dict[str, bool] = {}  # Cache for artist existence
    
    async def resolve_batch(
        self,
        suggestions: List[TrackSuggestion],
        target_count: int = 20,
        batch_size: int = 10,
    ) -> List[ResolvedTrack]:
        """
        Resolve a batch of track suggestions to Spotify tracks.
        
        Uses parallel processing in batches for speed.
        
        Args:
            suggestions: List of AI-generated track suggestions
            target_count: Target number of tracks to return
            batch_size: Number of parallel searches per batch (default 10)
            
        Returns:
            List of resolved tracks (may be fewer than target if matches fail)
        """
        resolved = []
        seen_uris = set()
        artist_counts: Dict[str, int] = {}  # Limit per-artist tracks
        
        print(f"[TrackResolver] Resolving {len(suggestions)} suggestions in parallel (batch size {batch_size})...")
        
        # Process in batches of batch_size
        for i in range(0, len(suggestions), batch_size):
            if len(resolved) >= target_count:
                break
            
            batch = suggestions[i:i + batch_size]
            
            # Resolve batch in parallel
            tasks = [self._resolve_one(s) for s in batch]
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            # Process results
            for j, result in enumerate(results):
                if len(resolved) >= target_count:
                    break
                    
                if isinstance(result, Exception):
                    continue
                    
                track = result
                if track and track.uri not in seen_uris:
                    # Check artist limit
                    artist_key = batch[j].artist.lower()
                    if artist_counts.get(artist_key, 0) < 2:
                        resolved.append(track)
                        seen_uris.add(track.uri)
                        artist_counts[artist_key] = artist_counts.get(artist_key, 0) + 1
        
        print(f"[TrackResolver] Resolved {len(resolved)}/{len(suggestions)} tracks")
        return resolved
    
    async def _resolve_one(
        self, 
        suggestion: TrackSuggestion
    ) -> Optional[ResolvedTrack]:
        """
        Resolve a single track suggestion.
        
        Tries multiple search strategies in order.
        """
        # Strategy 1: Exact match
        track = await self._search_exact(suggestion.artist, suggestion.title)
        if track:
            return track
        
        # Strategy 2: Fuzzy match
        track = await self._search_fuzzy(suggestion.artist, suggestion.title)
        if track:
            return track
        
        # Strategy 3: Artist search (get any popular track by artist)
        # Only try if we haven't already checked this artist
        artist_key = suggestion.artist.lower()
        if artist_key not in self._resolved_artists:
            track = await self._search_artist_track(suggestion.artist)
            self._resolved_artists[artist_key] = track is not None
            if track:
                return track
        
        return None
    
    async def _search_exact(
        self, 
        artist: str, 
        title: str
    ) -> Optional[ResolvedTrack]:
        """
        Search with exact match query.
        
        Query format: track:"title" artist:"artist"
        """
        # Clean up title (remove featured artists, remixes, etc.)
        clean_title = title.split(" - ")[0].split(" (")[0].strip()
        clean_artist = artist.split(" feat")[0].split(" &")[0].strip()
        
        query = f'track:"{clean_title}" artist:"{clean_artist}"'
        
        try:
            result = await self.spotify.search_track(query)
            if result:
                return self._parse_track_result(result)
        except Exception as e:
            import traceback
            print(f"[TrackResolver] Exact search failed: {type(e).__name__}: {e}")
            traceback.print_exc()
        
        return None
    
    async def _search_fuzzy(
        self, 
        artist: str, 
        title: str
    ) -> Optional[ResolvedTrack]:
        """
        Search with looser fuzzy match.
        
        Query format: artist title
        """
        # Simple query without quotes
        clean_title = title.split(" - ")[0].split(" (")[0].strip()
        clean_artist = artist.split(" feat")[0].split(" &")[0].strip()
        
        query = f"{clean_artist} {clean_title}"
        
        try:
            result = await self.spotify.search_track(query)
            if result:
                # Verify it's a reasonable match
                result_artist = result.get("artists", [{}])[0].get("name", "").lower()
                result_title = result.get("name", "").lower()
                
                # Check if artist name is close enough
                if clean_artist.lower() in result_artist or result_artist in clean_artist.lower():
                    return self._parse_track_result(result)
        except Exception as e:
            print(f"[TrackResolver] Fuzzy search failed: {e}")
        
        return None
    
    async def _search_artist_track(
        self, 
        artist: str
    ) -> Optional[ResolvedTrack]:
        """
        Search for any popular track by the artist.
        
        Fallback when specific track isn't found.
        """
        clean_artist = artist.split(" feat")[0].split(" &")[0].strip()
        query = f'artist:"{clean_artist}"'
        
        try:
            result = await self.spotify.search_track(query, limit=5)
            if result:
                return self._parse_track_result(result)
        except Exception as e:
            print(f"[TrackResolver] Artist search failed: {e}")
        
        return None
    
    def _parse_track_result(self, track: Dict[str, Any]) -> ResolvedTrack:
        """Parse Spotify API track result into ResolvedTrack."""
        artists = track.get("artists", [])
        artist_name = artists[0].get("name", "Unknown") if artists else "Unknown"
        
        album = track.get("album", {})
        images = album.get("images", [])
        album_art = images[0].get("url") if images else None
        
        return ResolvedTrack(
            name=track.get("name", "Unknown"),
            artist=artist_name,
            uri=track.get("uri", ""),
            url=track.get("external_urls", {}).get("spotify", ""),
            album_art=album_art,
        )


# Singleton instance
_resolver_instance: Optional[TrackResolver] = None


def get_track_resolver() -> TrackResolver:
    """Get singleton instance of TrackResolver."""
    global _resolver_instance
    if _resolver_instance is None:
        _resolver_instance = TrackResolver()
    return _resolver_instance
