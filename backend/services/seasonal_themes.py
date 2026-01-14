"""
Seasonal Themes Service.

Defines predefined zodiac-to-life-area mappings for collective seasonal playlists.
Each zodiac sign has 1-3 key themes that represent the collective focus for that season.

S2: Documentation Rule - Clear docstrings for all functions.
"""
from typing import List, Dict, Tuple
from datetime import datetime


# Predefined zodiac-to-life-area mapping
ZODIAC_LIFE_AREAS: Dict[str, List[str]] = {
    "Aries": ["Initiative & Action", "Physical Vitality"],
    "Taurus": ["Material Abundance", "Sensory Grounding"],
    "Gemini": ["Social Connection", "Idea Exchange"],
    "Cancer": ["Emotional Safety", "Home & Family"],
    "Leo": ["Creative Expression", "Radiant Leadership"],
    "Virgo": ["Health & Wellness", "Precision & Craft"],
    "Libra": ["Partnership Harmony", "Aesthetic Beauty"],
    "Scorpio": ["Deep Transformation", "Authentic Power"],
    "Sagittarius": ["Expansive Wisdom", "Adventure & Travel"],
    "Capricorn": ["Professional Legacy", "Financial Structure"],
    "Aquarius": ["Community Vision", "Innovation & Future"],
    "Pisces": ["Spiritual Peace", "Creative Flow"],
}


def get_current_seasonal_themes(zodiac_sign: str) -> List[str]:
    """
    Get the predefined life area themes for a zodiac sign.
    
    Args:
        zodiac_sign: The zodiac sign (e.g., "Capricorn")
        
    Returns:
        List of 1-3 theme strings for that sign
        
    Raises:
        ValueError: If zodiac sign is not recognized
    """
    if zodiac_sign not in ZODIAC_LIFE_AREAS:
        raise ValueError(f"Unknown zodiac sign: {zodiac_sign}")
    
    return ZODIAC_LIFE_AREAS[zodiac_sign]


def generate_theme_prompt(
    sign: str,
    element: str,
    theme: str,
    genre_preferences: List[str]
) -> str:
    """
    Generate an AI prompt for creating a seasonal themed playlist.
    
    This creates a "pure energy" prompt focused on the collective archetype
    rather than individual birth data.
    
    Args:
        sign: Zodiac sign (e.g., "Capricorn")
        element: Element (Fire, Earth, Air, Water)
        theme: Life area theme (e.g., "Professional Legacy")
        genre_preferences: List of genres to incorporate
        
    Returns:
        Formatted prompt string for AI playlist generation
    """
    element_descriptions = {
        "Fire": "energetic, bold, passionate, driving",
        "Earth": "structured, grounded, steady, focused",
        "Air": "eclectic, mental, light, social",
        "Water": "emotional, dreamy, flowing, deep",
    }
    
    element_vibe = element_descriptions.get(element, "cosmic, aligned")
    genre_str = ", ".join(genre_preferences[:3]) if genre_preferences else "eclectic"
    
    prompt = f"""Create a playlist for {sign} Season focusing on "{theme}".

{sign} is a {element} sign with {element_vibe} energy. This playlist should embody the collective archetype of {sign} while specifically supporting {theme.lower()}.

Musical direction:
- Element vibe: {element_vibe}
- Primary genres: {genre_str}
- Energy: Match the {element} element's natural rhythm
- Purpose: Help listeners align with {theme.lower()} intentions

This is a shared global playlist for all users during {sign} season. Create 12-15 tracks that capture the pure essence of this seasonal focus."""
    
    return prompt


def get_theme_metadata(sign: str, theme: str) -> Dict[str, str]:
    """
    Get metadata about a specific theme for UI display.
    
    Args:
        sign: Zodiac sign
        theme: Life area theme
        
    Returns:
        Dictionary with glyph, description, and other metadata
    """
    # Map themes to symbolic glyphs for UI
    theme_glyphs = {
        "Initiative & Action": "⚡",
        "Physical Vitality": "✧",
        "Material Abundance": "◆",
        "Sensory Grounding": "◉",
        "Social Connection": "◈",
        "Idea Exchange": "⬡",
        "Emotional Safety": "◎",
        "Home & Family": "⬢",
        "Creative Expression": "✦",
        "Radiant Leadership": "☀",
        "Health & Wellness": "♢",
        "Precision & Craft": "⬟",
        "Partnership Harmony": "◇",
        "Aesthetic Beauty": "✧",
        "Deep Transformation": "⬢",
        "Authentic Power": "◆",
        "Expansive Wisdom": "△",
        "Adventure & Travel": "⬡",
        "Professional Legacy": "⬟",
        "Financial Structure": "◼",
        "Community Vision": "⬡",
        "Innovation & Future": "◈",
        "Spiritual Peace": "◎",
        "Creative Flow": "〰",
    }
    
    return {
        "glyph": theme_glyphs.get(theme, "◆"),
        "title": theme,
    }
