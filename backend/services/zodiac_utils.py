"""
Zodiac period utilities for monthly playlist generation.

Maps zodiac signs to their date ranges, elements, and audio feature profiles.

S2: Documentation Rule - All functions include clear docstrings.
H3: Unit Test Creation - Corresponding tests in tests/test_zodiac_utils.py.
"""
from datetime import date, datetime
from typing import Dict, Tuple, Optional


# =============================================================================
# ZODIAC DATE RANGES
# =============================================================================

# Zodiac periods: (start_month, start_day), (end_month, end_day)
ZODIAC_PERIODS: Dict[str, Tuple[Tuple[int, int], Tuple[int, int]]] = {
    "Capricorn": ((12, 22), (1, 19)),   # Crosses year boundary
    "Aquarius": ((1, 20), (2, 18)),
    "Pisces": ((2, 19), (3, 20)),
    "Aries": ((3, 21), (4, 19)),
    "Taurus": ((4, 20), (5, 20)),
    "Gemini": ((5, 21), (6, 20)),
    "Cancer": ((6, 21), (7, 22)),
    "Leo": ((7, 23), (8, 22)),
    "Virgo": ((8, 23), (9, 22)),
    "Libra": ((9, 23), (10, 22)),
    "Scorpio": ((10, 23), (11, 21)),
    "Sagittarius": ((11, 22), (12, 21)),
}

# Map zodiac signs to their elements
ZODIAC_ELEMENTS: Dict[str, str] = {
    "Aries": "Fire",
    "Leo": "Fire",
    "Sagittarius": "Fire",
    "Taurus": "Earth",
    "Virgo": "Earth",
    "Capricorn": "Earth",
    "Gemini": "Air",
    "Libra": "Air",
    "Aquarius": "Air",
    "Cancer": "Water",
    "Scorpio": "Water",
    "Pisces": "Water",
}

# Zodiac sign symbols/emojis for display
ZODIAC_SYMBOLS: Dict[str, str] = {
    "Aries": "♈",
    "Taurus": "♉",
    "Gemini": "♊",
    "Cancer": "♋",
    "Leo": "♌",
    "Virgo": "♍",
    "Libra": "♎",
    "Scorpio": "♏",
    "Sagittarius": "♐",
    "Capricorn": "♑",
    "Aquarius": "♒",
    "Pisces": "♓",
}


# =============================================================================
# ELEMENT-TO-AUDIO FEATURE PROFILES
# =============================================================================

# Audio feature ranges for each element (min, max)
# Used to filter Spotify tracks by element characteristics
ELEMENT_AUDIO_PROFILES: Dict[str, Dict[str, Tuple[float, float]]] = {
    "Fire": {
        # Fire: High energy, upbeat, empowering
        "energy": (0.7, 1.0),
        "valence": (0.6, 0.95),   # Happy, uplifting
        "tempo": (120.0, 160.0),
        "danceability": (0.6, 0.9),
    },
    "Earth": {
        # Earth: Grounded, steady, acoustic-friendly
        "energy": (0.3, 0.6),
        "valence": (0.4, 0.7),
        "tempo": (80.0, 115.0),
        "danceability": (0.3, 0.6),
    },
    "Air": {
        # Air: Eclectic, experimental, lyrical
        "energy": (0.5, 0.8),
        "valence": (0.5, 0.85),
        "tempo": (100.0, 140.0),
        "danceability": (0.5, 0.8),
    },
    "Water": {
        # Water: Emotional, atmospheric, introspective
        "energy": (0.2, 0.5),
        "valence": (0.2, 0.55),   # More melancholic allowed
        "tempo": (65.0, 105.0),
        "danceability": (0.3, 0.6),
    },
}

# Additional element characteristics for AI prompt context
ELEMENT_DESCRIPTIONS: Dict[str, Dict[str, str]] = {
    "Fire": {
        "mood": "passionate, bold, adventurous",
        "sound": "high-energy anthems, driving beats, powerful vocals",
        "advice_tone": "embrace courage and take action",
    },
    "Earth": {
        "mood": "grounded, practical, sensual",
        "sound": "steady rhythms, rich bass, acoustic warmth",
        "advice_tone": "focus on stability and building foundations",
    },
    "Air": {
        "mood": "curious, social, intellectual",
        "sound": "eclectic mixes, clever lyrics, experimental sounds",
        "advice_tone": "communicate openly and explore new ideas",
    },
    "Water": {
        "mood": "emotional, intuitive, dreamy",
        "sound": "atmospheric textures, deep bass, flowing melodies",
        "advice_tone": "trust your intuition and honor your feelings",
    },
}


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def get_zodiac_for_date(target_date: date) -> str:
    """
    Get the zodiac sign for a given date.
    
    Args:
        target_date: The date to check
        
    Returns:
        Zodiac sign name (e.g., "Sagittarius")
    """
    month = target_date.month
    day = target_date.day
    
    for sign, ((start_m, start_d), (end_m, end_d)) in ZODIAC_PERIODS.items():
        # Handle Capricorn which crosses the year boundary
        if start_m > end_m:  # e.g., Dec 22 - Jan 19
            if (month == start_m and day >= start_d) or (month == end_m and day <= end_d):
                return sign
        else:
            # Normal case: start and end in same year progression
            if (month == start_m and day >= start_d) or \
               (month == end_m and day <= end_d) or \
               (start_m < month < end_m):
                return sign
    
    # Fallback (shouldn't happen with complete data)
    return "Aries"


def get_current_zodiac() -> Tuple[str, str, str, str]:
    """
    Get the current zodiac sign based on today's date.
    
    Returns:
        Tuple of (sign_name, element, date_range_display, symbol)
        Example: ("Sagittarius", "Fire", "Nov 22 - Dec 21", "♐")
    """
    today = date.today()
    sign = get_zodiac_for_date(today)
    element = ZODIAC_ELEMENTS[sign]
    symbol = ZODIAC_SYMBOLS[sign]
    
    # Format date range for display
    (start_m, start_d), (end_m, end_d) = ZODIAC_PERIODS[sign]
    month_names = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    date_range = f"{month_names[start_m]} {start_d} - {month_names[end_m]} {end_d}"
    
    return sign, element, date_range, symbol


def get_element_audio_profile(element: str) -> Dict[str, Tuple[float, float]]:
    """
    Get the audio feature ranges for a zodiac element.
    
    Args:
        element: "Fire", "Earth", "Air", or "Water"
        
    Returns:
        Dict with keys: energy, valence, tempo, danceability
        Each value is (min, max) tuple
    """
    return ELEMENT_AUDIO_PROFILES.get(element, ELEMENT_AUDIO_PROFILES["Fire"])


def get_element_description(element: str) -> Dict[str, str]:
    """
    Get descriptive text for an element (for AI prompts).
    
    Args:
        element: "Fire", "Earth", "Air", or "Water"
        
    Returns:
        Dict with keys: mood, sound, advice_tone
    """
    return ELEMENT_DESCRIPTIONS.get(element, ELEMENT_DESCRIPTIONS["Fire"])


def get_next_zodiac_change_date(from_date: Optional[date] = None) -> date:
    """
    Get the date when the zodiac sign will change next.
    
    Args:
        from_date: Starting date (defaults to today)
        
    Returns:
        Date of next zodiac period change
    """
    if from_date is None:
        from_date = date.today()
    
    current_sign = get_zodiac_for_date(from_date)
    (_, _), (end_m, end_d) = ZODIAC_PERIODS[current_sign]
    
    # Calculate the end date
    year = from_date.year
    
    # Handle year boundary for Capricorn
    if current_sign == "Capricorn" and from_date.month == 12:
        year += 1
    
    try:
        end_date = date(year, end_m, end_d)
    except ValueError:
        # Handle leap year edge case for Feb 29
        end_date = date(year, end_m, 28)
    
    # The next period starts the day after
    return end_date


def get_cache_key_for_month() -> str:
    """
    Generate a cache key for the current zodiac period.
    
    Returns:
        Cache key string like "zodiac_2024_sagittarius"
    """
    today = date.today()
    sign = get_zodiac_for_date(today)
    return f"zodiac_{today.year}_{sign.lower()}"
