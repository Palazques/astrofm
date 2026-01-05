"""
Track Generator - AI-powered track suggestions.

Uses Gemini to generate specific track recommendations
based on astrological music prompts.

S2: Documentation Rule - Clear docstrings for all functions.
"""
import os
import json
import re
from typing import List, Optional
from dataclasses import dataclass

from .astro_to_music import MusicPrompt

# Import Gemini directly for track generation (separate from AIService to avoid system prompt)
try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

# Initialize Gemini model for track generation
_gemini_model = None

def _get_gemini_model():
    """Get or create a Gemini model for track generation."""
    global _gemini_model
    if _gemini_model is None and GEMINI_AVAILABLE:
        api_key = os.getenv("GEMINI_API_KEY")
        if api_key:
            genai.configure(api_key=api_key)
            _gemini_model = genai.GenerativeModel("gemini-2.0-flash")
            print("[TrackGenerator] Gemini model initialized")
    return _gemini_model

def _call_gemini_for_tracks(prompt: str) -> str:
    """Call Gemini directly for track generation (no system prompt)."""
    model = _get_gemini_model()
    if not model:
        raise RuntimeError("Gemini not configured for track generation")
    
    print("[TrackGenerator] Calling Gemini for tracks...")
    response = model.generate_content(
        prompt,
        generation_config=genai.GenerationConfig(
            max_output_tokens=2000,
            temperature=0.8,
        )
    )
    print("[TrackGenerator] Gemini response received")
    return response.text



@dataclass
class TrackSuggestion:
    """A track suggestion from the AI."""
    artist: str
    title: str
    reason: str  # Why this track fits the vibe


# Prompt template for track generation
TRACK_GENERATION_PROMPT = """You are a master music curator and intuitive astrologer. 
Your task is to translate a specific cosmic alignment into a {track_count}-song "Sonic Transit" (playlist).

### The Cosmic Vibe
**Astrological Narrative:** {vibe_description}
**Energy Signature:** {mood_keywords}
**Native Genres:** {genres}

### Audio Architecture
- **Energy Intensity:** {energy_range} (0=ambient/low, 1=high/driving)
- **Emotional Palette:** {valence_range} (0=melancholic/introspective, 1=euphoric/joyful)
- **Rhythmic Pulse:** {tempo_range} BPM

### Curation Guidelines
1. **Genre Synthesis:** 
   - 70% should stay within the "Native Genres."
   - 30% should be "Boundary Pushing" tracks—songs that technically live in other genres but perfectly capture the *astrological frequency* described above.
2. **Dynamic Flow:** The playlist should feel like a transit—starting with an entry point, reaching a "peak" of energy mid-way, and settling into a resolution.
3. **Selection Quality:** Mix well-known "Essential" tracks (60%) with hidden "Obsidian" deep cuts (40%). 
4. **Veracity:** Only suggest tracks that definitely exist on Spotify.

Return ONLY a valid JSON array of objects with these keys:
[
  {{"artist": "Name", "title": "Song", "reason": "Why this specific track connects to the {vibe_description}?"}},
  ...
]
"""


async def generate_track_suggestions(
    music_prompt: MusicPrompt,
    track_count: int = 35,
) -> List[TrackSuggestion]:
    """
    Generate track suggestions using AI.
    
    Args:
        music_prompt: Musical attributes from astrology mapping
        track_count: Number of tracks to generate (default 35 to allow for failures)
        
    Returns:
        List of TrackSuggestion objects
    """
    # Format the prompt
    prompt = TRACK_GENERATION_PROMPT.format(
        track_count=track_count,
        vibe_description=music_prompt.vibe_description,
        mood_keywords=", ".join(music_prompt.mood_keywords),
        genres=", ".join(music_prompt.genres),
        energy_range=f"{music_prompt.energy_target[0]:.1f}-{music_prompt.energy_target[1]:.1f}",
        valence_range=f"{music_prompt.valence_target[0]:.1f}-{music_prompt.valence_target[1]:.1f}",
        tempo_range=f"{music_prompt.tempo_range[0]}-{music_prompt.tempo_range[1]}",
    )
    
    try:
        # Use direct Gemini call (no system prompt interference)
        response_text = _call_gemini_for_tracks(prompt)
        
        # Parse JSON response
        suggestions = _parse_track_response(response_text)
        
        if not suggestions:
            print(f"[TrackGenerator] Warning: No tracks parsed from AI response")
            return []
        
        print(f"[TrackGenerator] Generated {len(suggestions)} track suggestions")
        return suggestions
        
    except Exception as e:
        print(f"[TrackGenerator] Error generating tracks: {e}")
        return []


def _parse_track_response(response_text: str) -> List[TrackSuggestion]:
    """
    Parse the AI response into TrackSuggestion objects.
    
    Handles various response formats and extracts JSON array.
    """
    # Log first 500 chars of response for debugging
    print(f"[TrackGenerator] Response preview: {response_text[:500]}...")
    
    # Remove markdown code block formatting if present
    cleaned = response_text
    if "```json" in cleaned:
        cleaned = cleaned.split("```json")[1]
    if "```" in cleaned:
        cleaned = cleaned.split("```")[0]
    
    # Try to extract JSON array from response
    json_match = re.search(r'\[[\s\S]*\]', cleaned)
    
    if not json_match:
        print(f"[TrackGenerator] Could not find JSON array in cleaned response")
        return []
    
    try:
        tracks_data = json.loads(json_match.group())
    except json.JSONDecodeError as e:
        print(f"[TrackGenerator] JSON parse error: {e}")
        return []
    
    suggestions = []
    for item in tracks_data:
        if isinstance(item, dict) and "artist" in item and "title" in item:
            suggestions.append(TrackSuggestion(
                artist=str(item.get("artist", "")).strip(),
                title=str(item.get("title", "")).strip(),
                reason=str(item.get("reason", "")).strip(),
            ))
    
    return suggestions


async def generate_fallback_tracks(
    genres: List[str],
    count: int = 10,
) -> List[TrackSuggestion]:
    """
    Generate fallback tracks when main generation fails.
    
    Uses a simpler prompt focused on genre popularity.
    """
    prompt = f"""Generate {count} popular songs from these genres: {', '.join(genres)}

Focus on well-known tracks that are on Spotify.

Return ONLY a JSON array:
[{{"artist": "Artist", "title": "Song Title", "reason": "Genre fit"}}]
"""
    
    try:
        response_text = _call_gemini_for_tracks(prompt)
        return _parse_track_response(response_text)
    except Exception as e:
        print(f"[TrackGenerator] Fallback generation failed: {e}")
        return []
