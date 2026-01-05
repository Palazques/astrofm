"""
Astrology to Music Mapper.

Translates astrological factors (elements, planets, transits)
into musical attributes (energy, tempo, mood) for playlist generation.

S2: Documentation Rule - Clear docstrings for all functions.
"""
from typing import List, Dict, Tuple, Optional, Any
from dataclasses import dataclass
from datetime import datetime


@dataclass
class MusicPrompt:
    """Musical attributes derived from astrological data."""
    vibe_description: str  # Natural language description
    mood_keywords: List[str]  # Keywords for AI track generation
    genres: List[str]  # User's genre preferences
    energy_target: Tuple[float, float]  # (min, max) 0-1
    valence_target: Tuple[float, float]  # (min, max) 0-1 (sad to happy)
    tempo_range: Tuple[int, int]  # (min, max) BPM
    

# =============================================================================
# Element Mappings
# =============================================================================

ELEMENT_AUDIO_PROFILES = {
    "Fire": {
        "energy": (0.7, 1.0),
        "valence": (0.6, 0.9),
        "tempo": (120, 160),
        "keywords": ["energetic", "powerful", "bold", "driving", "uplifting"],
        "vibe": "fiery and energetic",
    },
    "Earth": {
        "energy": (0.3, 0.6),
        "valence": (0.4, 0.7),
        "tempo": (80, 110),
        "keywords": ["grounded", "steady", "organic", "warm", "sensual"],
        "vibe": "grounded and steady",
    },
    "Air": {
        "energy": (0.5, 0.8),
        "valence": (0.5, 0.8),
        "tempo": (100, 140),
        "keywords": ["light", "intellectual", "breezy", "curious", "social"],
        "vibe": "light and intellectual",
    },
    "Water": {
        "energy": (0.2, 0.5),
        "valence": (0.3, 0.6),
        "tempo": (70, 100),
        "keywords": ["emotional", "dreamy", "flowing", "introspective", "deep"],
        "vibe": "emotional and dreamy",
    },
}

# Zodiac sign to element mapping
SIGN_ELEMENTS = {
    "Aries": "Fire", "Taurus": "Earth", "Gemini": "Air", "Cancer": "Water",
    "Leo": "Fire", "Virgo": "Earth", "Libra": "Air", "Scorpio": "Water",
    "Sagittarius": "Fire", "Capricorn": "Earth", "Aquarius": "Air", "Pisces": "Water",
}

# Zodiac symbols for display
ZODIAC_SYMBOLS = {
    "Aries": "♈", "Taurus": "♉", "Gemini": "♊", "Cancer": "♋",
    "Leo": "♌", "Virgo": "♍", "Libra": "♎", "Scorpio": "♏",
    "Sagittarius": "♐", "Capricorn": "♑", "Aquarius": "♒", "Pisces": "♓",
}


# =============================================================================
# Planet Mappings
# =============================================================================

PLANET_VIBES = {
    "Sun": {
        "keywords": ["confident", "radiant", "expressive", "vital"],
        "modifier": "core identity and self-expression",
    },
    "Moon": {
        "keywords": ["emotional", "nurturing", "intuitive", "reflective"],
        "modifier": "emotional depth and inner world",
    },
    "Mercury": {
        "keywords": ["quick", "clever", "communicative", "witty"],
        "modifier": "mental agility and communication",
    },
    "Venus": {
        "keywords": ["romantic", "beautiful", "harmonious", "sensual"],
        "modifier": "love, beauty, and pleasure",
    },
    "Mars": {
        "keywords": ["driving", "aggressive", "passionate", "bold"],
        "modifier": "action and raw energy",
    },
    "Jupiter": {
        "keywords": ["expansive", "optimistic", "adventurous", "grand"],
        "modifier": "growth and abundance",
    },
    "Saturn": {
        "keywords": ["structured", "serious", "disciplined", "minimal"],
        "modifier": "discipline and maturity",
    },
    "Uranus": {
        "keywords": ["unconventional", "electric", "innovative", "rebellious"],
        "modifier": "innovation and surprise",
    },
    "Neptune": {
        "keywords": ["dreamy", "mystical", "ethereal", "transcendent"],
        "modifier": "imagination and spirituality",
    },
    "Pluto": {
        "keywords": ["intense", "transformative", "deep", "powerful"],
        "modifier": "transformation and depth",
    },
}


# =============================================================================
# Transit Modifiers
# =============================================================================

MOON_SIGN_MODIFIERS = {
    "Aries": {"energy": 0.15, "valence": 0.1, "keyword": "assertive"},
    "Taurus": {"energy": -0.1, "valence": 0.1, "keyword": "comforting"},
    "Gemini": {"energy": 0.1, "valence": 0.1, "keyword": "curious"},
    "Cancer": {"energy": -0.1, "valence": -0.05, "keyword": "nurturing"},
    "Leo": {"energy": 0.15, "valence": 0.15, "keyword": "dramatic"},
    "Virgo": {"energy": -0.05, "valence": 0.0, "keyword": "analytical"},
    "Libra": {"energy": 0.0, "valence": 0.1, "keyword": "harmonious"},
    "Scorpio": {"energy": 0.1, "valence": -0.1, "keyword": "intense"},
    "Sagittarius": {"energy": 0.15, "valence": 0.15, "keyword": "adventurous"},
    "Capricorn": {"energy": -0.05, "valence": -0.05, "keyword": "focused"},
    "Aquarius": {"energy": 0.1, "valence": 0.05, "keyword": "unconventional"},
    "Pisces": {"energy": -0.15, "valence": 0.0, "keyword": "dreamy"},
}


# =============================================================================
# Main Mapping Function
# =============================================================================

def generate_music_prompt(
    sun_sign: str,
    moon_sign: str,
    rising_sign: str,
    current_moon_sign: str,
    genre_preferences: List[str],
    dominant_element: Optional[str] = None,
    transit_summary: Optional[Dict[str, Any]] = None,
) -> MusicPrompt:
    """
    Generate a music prompt from astrological data.
    
    Args:
        sun_sign: User's Sun sign
        moon_sign: User's Moon sign
        rising_sign: User's Rising/Ascendant sign
        current_moon_sign: Today's Moon sign (transit)
        genre_preferences: User's preferred genres
        dominant_element: Optional override for dominant element
        transit_summary: Optional detailed summary of today's transits
        
    Returns:
        MusicPrompt with audio targets and mood keywords
    """
    # Determine dominant element from big three
    elements = [
        SIGN_ELEMENTS.get(sun_sign, "Fire"),
        SIGN_ELEMENTS.get(moon_sign, "Water"),
        SIGN_ELEMENTS.get(rising_sign, "Earth"),
    ]
    
    if not dominant_element:
        # Count occurrences
        element_counts = {e: elements.count(e) for e in set(elements)}
        dominant_element = max(element_counts, key=element_counts.get)
    
    # Get base profile from dominant element
    profile = ELEMENT_AUDIO_PROFILES.get(dominant_element, ELEMENT_AUDIO_PROFILES["Fire"])
    
    # Get transit modifier (current Moon sign and weather)
    moon_mod = MOON_SIGN_MODIFIERS.get(current_moon_sign, {"energy": 0, "valence": 0, "keyword": "reflective"})
    
    # Calculate targets with modifiers
    energy_min = max(0, profile["energy"][0] + moon_mod["energy"])
    energy_max = min(1, profile["energy"][1] + moon_mod["energy"])
    valence_min = max(0, profile["valence"][0] + moon_mod["valence"])
    valence_max = min(1, profile["valence"][1] + moon_mod["valence"])
    
    # Adjust for day energy if transit summary exists
    if transit_summary:
        day_energy = transit_summary.get("day_energy", "Dynamic")
        if day_energy == "Intense":
            energy_min = min(1, energy_min + 0.1)
            energy_max = min(1, energy_max + 0.1)
        elif day_energy == "Flowing":
            valence_min = min(1, valence_min + 0.1)
            valence_max = min(1, valence_max + 0.1)
        elif day_energy == "Intuitive":
            energy_min = max(0, energy_min - 0.1)
            energy_max = max(0, energy_max - 0.1)
    
    # Collect mood keywords
    keywords = list(profile["keywords"])
    
    # Add Sun sign vibe
    sun_element = SIGN_ELEMENTS.get(sun_sign, "Fire")
    sun_profile = ELEMENT_AUDIO_PROFILES.get(sun_element, {})
    if "keywords" in sun_profile:
        keywords.extend(sun_profile["keywords"][:2])
    
    # Add Moon sign emotional undertone
    moon_element = SIGN_ELEMENTS.get(moon_sign, "Water")
    moon_profile = ELEMENT_AUDIO_PROFILES.get(moon_element, {})
    if "keywords" in moon_profile:
        keywords.append(moon_profile["keywords"][0])
    
    # Add today's transit keywords
    if moon_mod["keyword"]:
        keywords.append(moon_mod["keyword"])
        
    if transit_summary:
        keywords.append(transit_summary.get("day_energy", "Cosmic").lower())
        retro_planets = transit_summary.get("retrograde_planets", [])
        if retro_planets:
            keywords.append("introspective")
            keywords.append("nostalgic")
    
    # Deduplicate keywords
    keywords = list(dict.fromkeys(keywords))[:10]
    
    # Build rich vibe description
    sun_symbol = ZODIAC_SYMBOLS.get(sun_sign, "")
    base_vibe = (
        f"A personalized cosmic mix for a {sun_sign} {sun_symbol} (Sun), "
        f"{moon_sign} {ZODIAC_SYMBOLS.get(moon_sign, '')} (Moon), and "
        f"{rising_sign} rising."
    )
    
    weather_desc = ""
    if transit_summary:
        weather_desc = f" The current cosmic weather is {transit_summary.get('day_energy')} with {transit_summary.get('cosmic_weather')}."
    else:
        weather_desc = f" Today's {current_moon_sign} Moon brings a {moon_mod['keyword']} atmosphere."
        
    vibe_description = f"{base_vibe}{weather_desc} The focus is on {profile['vibe']} textures blended with {ELEMENT_AUDIO_PROFILES.get(SIGN_ELEMENTS.get(moon_sign, 'Water'), {}).get('vibe', 'watery')} undertones."
    
    return MusicPrompt(
        vibe_description=vibe_description,
        mood_keywords=keywords,
        genres=genre_preferences,
        energy_target=(energy_min, energy_max),
        valence_target=(valence_min, valence_max),
        tempo_range=profile["tempo"],
    )


def get_zodiac_symbol(sign: str) -> str:
    """Get the zodiac symbol for a sign."""
    return ZODIAC_SYMBOLS.get(sign, "")


def get_element(sign: str) -> str:
    """Get the element for a zodiac sign."""
    return SIGN_ELEMENTS.get(sign, "Fire")
