"""
Playlist Builder - Main orchestrator for cosmic playlist generation.

Combines astrology mapping, AI track generation, and Spotify resolution
into a complete playlist creation pipeline.

S2: Documentation Rule - Clear docstrings for all functions.
"""
import hashlib
import secrets
from typing import List, Optional, Dict, Any
from datetime import datetime
from dataclasses import dataclass, asdict

from .app_spotify import get_app_spotify_service
from .astro_to_music import (
    generate_music_prompt, 
    get_zodiac_symbol, 
    get_element,
    MusicPrompt,
)
from .track_generator import generate_track_suggestions, generate_fallback_tracks
from .track_resolver import get_track_resolver, ResolvedTrack


@dataclass
class CosmicPlaylistResult:
    """Result of cosmic playlist generation."""
    success: bool
    playlist_url: str
    playlist_name: str
    track_count: int
    vibe_summary: str
    tracks: List[Dict[str, Any]]
    sun_sign: str
    element: str
    error: Optional[str] = None


# Simple in-memory cache (for production, use Redis)
_playlist_cache: Dict[str, CosmicPlaylistResult] = {}


class CosmicPlaylistBuilder:
    """
    Orchestrates the full cosmic playlist generation pipeline.
    
    Pipeline:
    1. Check cache (same input = same playlist)
    2. Map astrology to music attributes
    3. Generate AI track suggestions
    4. Resolve to Spotify tracks
    5. Create playlist on app's account
    6. Cache and return
    """
    
    def __init__(self):
        self.spotify = get_app_spotify_service()
        self.resolver = get_track_resolver()
    
    async def generate_playlist(
        self,
        sun_sign: str,
        moon_sign: str,
        rising_sign: str,
        current_moon_sign: str,
        genre_preferences: List[str],
        target_tracks: int = 20,
    ) -> CosmicPlaylistResult:
        """
        Generate a cosmic playlist.
        
        Args:
            sun_sign: User's Sun sign
            moon_sign: User's Moon sign  
            rising_sign: User's Rising sign
            current_moon_sign: Today's Moon sign
            genre_preferences: User's preferred genres
            target_tracks: Number of tracks to include
            
        Returns:
            CosmicPlaylistResult with playlist URL and track info
        """
        # Generate cache key
        cache_key = self._get_cache_key(
            sun_sign, moon_sign, rising_sign, 
            current_moon_sign, genre_preferences
        )
        
        # Check cache
        if cache_key in _playlist_cache:
            print(f"[PlaylistBuilder] Returning cached playlist")
            return _playlist_cache[cache_key]
        
        try:
            print(f"[PlaylistBuilder] Generating playlist for {sun_sign} Sun, {moon_sign} Moon")
            
            # Step 1: Map astrology to music attributes
            from services.transits import get_detailed_transit_summary
            transit_summary = get_detailed_transit_summary()
            
            music_prompt = generate_music_prompt(
                sun_sign=sun_sign,
                moon_sign=moon_sign,
                rising_sign=rising_sign,
                current_moon_sign=current_moon_sign,
                genre_preferences=genre_preferences,
                transit_summary=transit_summary,
            )
            
            print(f"[PlaylistBuilder] Music prompt: {music_prompt.vibe_description[:100]}...")
            
            # Step 2: Generate AI track suggestions (25 to allow for search failures)
            suggestions = await generate_track_suggestions(
                music_prompt=music_prompt,
                track_count=25,
            )
            
            if not suggestions:
                # Fallback to simpler genre-based generation
                print("[PlaylistBuilder] Main generation failed, trying fallback...")
                suggestions = await generate_fallback_tracks(
                    genres=genre_preferences,
                    count=25,
                )
            
            if not suggestions:
                return CosmicPlaylistResult(
                    success=False,
                    playlist_url="",
                    playlist_name="",
                    track_count=0,
                    vibe_summary="",
                    tracks=[],
                    sun_sign=sun_sign,
                    element=get_element(sun_sign),
                    error="Could not generate track suggestions",
                )
            
            # Step 3: Resolve to Spotify tracks
            resolved_tracks = await self.resolver.resolve_batch(
                suggestions=suggestions,
                target_count=target_tracks,
            )
            
            if len(resolved_tracks) < 5:
                return CosmicPlaylistResult(
                    success=False,
                    playlist_url="",
                    playlist_name="",
                    track_count=0,
                    vibe_summary="",
                    tracks=[],
                    sun_sign=sun_sign,
                    element=get_element(sun_sign),
                    error="Could not find enough tracks on Spotify",
                )
            
            # Step 4: Create playlist on app's Spotify account
            playlist_name = self._generate_playlist_name(sun_sign)
            track_uris = [t.uri for t in resolved_tracks]
            
            playlist = await self.spotify.create_playlist(
                name=playlist_name,
                description=f"🌟 {music_prompt.vibe_description} | Generated by Astro.fm",
                track_uris=track_uris,
                public=True,
            )
            
            # Build result
            result = CosmicPlaylistResult(
                success=True,
                playlist_url=playlist["url"],
                playlist_name=playlist_name,
                track_count=len(resolved_tracks),
                vibe_summary=music_prompt.vibe_description,
                tracks=[
                    {
                        "name": t.name,
                        "artist": t.artist,
                        "url": t.url,
                        "album_art": t.album_art,
                    }
                    for t in resolved_tracks
                ],
                sun_sign=sun_sign,
                element=get_element(sun_sign),
            )
            
            # Cache for 24 hours (in production, add TTL)
            _playlist_cache[cache_key] = result
            
            print(f"[PlaylistBuilder] Created playlist: {playlist_name} with {len(resolved_tracks)} tracks")
            return result
            
        except Exception as e:
            print(f"[PlaylistBuilder] Error: {e}")
            return CosmicPlaylistResult(
                success=False,
                playlist_url="",
                playlist_name="",
                track_count=0,
                vibe_summary="",
                tracks=[],
                sun_sign=sun_sign,
                element=get_element(sun_sign),
                error=str(e),
            )
    
    async def generate_seasonal_playlist(
        self,
        sign: str,
        element: str,
        theme: str,
        month: str,
        genre_preferences: List[str],
        target_tracks: int = 12,
    ) -> CosmicPlaylistResult:
        """
        Generate a global seasonal playlist for a specific theme.
        
        This creates shared playlists for all users based on the collective
        energy of the zodiac season and a specific life area theme.
        
        Args:
            sign: Zodiac sign (e.g., "Capricorn")
            element: Element (Fire, Earth, Air, Water)
            theme: Life area theme (e.g., "Professional Legacy")
            month: Month identifier for caching (e.g., "Jan_2026")
            genre_preferences: Genres to incorporate
            target_tracks: Number of tracks to include
            
        Returns:
            CosmicPlaylistResult with playlist URL and track info
        """
        # Generate cache key (global, not user-specific)
        cache_key = f"global_season_{sign.lower()}_{theme.lower().replace(' & ', '_').replace(' ', '_')}_{month}"
        
        # Check cache
        if cache_key in _playlist_cache:
            print(f"[PlaylistBuilder] Returning cached seasonal playlist: {cache_key}")
            return _playlist_cache[cache_key]
        
        try:
            print(f"[PlaylistBuilder] Generating seasonal playlist: {sign} - {theme}")
            
            # Import seasonal theme prompt generator
            from services.seasonal_themes import generate_theme_prompt
            
            # Generate the music prompt using seasonal theme logic
            prompt_text = generate_theme_prompt(
                sign=sign,
                element=element,
                theme=theme,
                genre_preferences=genre_preferences,
            )
            print(f"[PlaylistBuilder] Prompt generated: {prompt_text[:50]}...")
            
            # Convert to MusicPrompt format (properly matched to dataclass)
            from .astro_to_music import MusicPrompt, ELEMENT_AUDIO_PROFILES
            
            # Get base profile for the element
            profile = ELEMENT_AUDIO_PROFILES.get(element, ELEMENT_AUDIO_PROFILES["Fire"])
            
            music_prompt = MusicPrompt(
                vibe_description=prompt_text,
                mood_keywords=profile["keywords"] + [theme.lower()],
                genres=genre_preferences,
                energy_target=profile["energy"],
                valence_target=profile["valence"],
                tempo_range=profile["tempo"],
            )
            
            # Step 2: Generate AI track suggestions
            print(f"[PlaylistBuilder] Requesting track suggestions for {theme}...")
            suggestions = await generate_track_suggestions(
                music_prompt=music_prompt,
                track_count=target_tracks + 3,  # Get a few extra for filtering
            )
            print(f"[PlaylistBuilder] Suggestions received: {len(suggestions) if suggestions else 0}")
            
            if not suggestions:
                # Fallback to simple genre-based generation
                print(f"[PlaylistBuilder] Main generation failed for seasonal, trying fallback...")
                suggestions = await generate_fallback_tracks(
                    genres=genre_preferences,
                    count=target_tracks + 3,
                )
            
            if not suggestions:
                return CosmicPlaylistResult(
                    success=False,
                    playlist_url="",
                    playlist_name="",
                    track_count=0,
                    vibe_summary="",
                    tracks=[],
                    sun_sign=sign,
                    element=element,
                    error="Could not generate track suggestions for seasonal theme",
                )
            
            # Step 3: Resolve to Spotify tracks
            resolved_tracks = await self.resolver.resolve_batch(
                suggestions=suggestions,
                target_count=target_tracks,
            )
            
            if len(resolved_tracks) < 5:
                return CosmicPlaylistResult(
                    success=False,
                    playlist_url="",
                    playlist_name="",
                    track_count=0,
                    vibe_summary="",
                    tracks=[],
                    sun_sign=sign,
                    element=element,
                    error="Could not find enough tracks on Spotify for seasonal theme",
                )

            
            # Step 4: Create playlist on app's Spotify account
            playlist_name = f"{sign} Season: {theme}"
            track_uris = [t.uri for t in resolved_tracks]
            
            # Sanitize description (remove newlines from prompt text)
            clean_prompt = prompt_text[:120].replace("\n", " ").strip()
            
            playlist = await self.spotify.create_playlist(
                name=playlist_name,
                description=f"🌟 {clean_prompt}... | Global {sign} Season Playlist | Generated by Astro.fm",
                track_uris=track_uris,
                public=True,
            )
            
            # Build result
            result = CosmicPlaylistResult(
                success=True,
                playlist_url=playlist["url"],
                playlist_name=playlist_name,
                track_count=len(resolved_tracks),
                vibe_summary=f"{element} energy for {theme.lower()}",
                tracks=[
                    {
                        "name": t.name,
                        "artist": t.artist,
                        "url": t.url,
                        "album_art": t.album_art,
                    }
                    for t in resolved_tracks
                ],
                sun_sign=sign,
                element=element,
            )
            
            # Cache for entire month (global cache, not user-specific)
            _playlist_cache[cache_key] = result
            
            print(f"[PlaylistBuilder] Created seasonal playlist: {playlist_name} with {len(resolved_tracks)} tracks")
            return result
            
        except Exception as e:
            print(f"[PlaylistBuilder] Seasonal playlist error: {e}")
            import traceback
            traceback.print_exc()
            return CosmicPlaylistResult(
                success=False,
                playlist_url="",
                playlist_name="",
                track_count=0,
                vibe_summary="",
                tracks=[],
                sun_sign=sign,
                element=element,
                error=str(e),
            )

    
    def _generate_playlist_name(self, sun_sign: str) -> str:
        """Generate a unique playlist name."""
        symbol = get_zodiac_symbol(sun_sign)
        date_str = datetime.now().strftime("%b %d %Y")
        hash_suffix = secrets.token_hex(2)
        return f"Astro.fm - {sun_sign} {symbol} - {date_str} - {hash_suffix}"
    
    def _get_cache_key(
        self,
        sun_sign: str,
        moon_sign: str,
        rising_sign: str,
        current_moon_sign: str,
        genres: List[str],
    ) -> str:
        """Generate a cache key from inputs."""
        today = datetime.now().strftime("%Y-%m-%d")
        key_str = f"{sun_sign}:{moon_sign}:{rising_sign}:{current_moon_sign}:{','.join(sorted(genres))}:{today}"
        return hashlib.md5(key_str.encode()).hexdigest()


# Singleton instance
_builder_instance: Optional[CosmicPlaylistBuilder] = None


def get_playlist_builder() -> CosmicPlaylistBuilder:
    """Get singleton instance of CosmicPlaylistBuilder."""
    global _builder_instance
    if _builder_instance is None:
        _builder_instance = CosmicPlaylistBuilder()
    return _builder_instance
