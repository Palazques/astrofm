"""
Friend Harmony Service - "Listen to Your Friends Blend"

Calculates daily friend alignment suggestions based on current transits.
Uses lunar harmony, personal transits, and conflict detection.

TODO (Firebase): Real friend birth data will come from Firebase when integrated.
"""
from datetime import datetime, timezone, date
from typing import Optional
from dataclasses import dataclass

from services.transits import get_current_transits, get_current_moon_sign, get_detailed_transit_summary
from services.ephemeris import ZODIAC_SIGNS


# =============================================================================
# DATA CLASSES
# =============================================================================

@dataclass
class FriendHarmonySuggestion:
    """A single friend harmony suggestion with score and context."""
    friend_id: int
    score: int  # 0-100
    glow_color: str  # Hex color for UI glow
    context_string: str  # AI-generated reason
    harmony_type: str  # "lunar", "transit", "mixed"


# =============================================================================
# ZODIAC HARMONY MAPPING
# =============================================================================

# Signs that form harmonious aspects (Trine = same element, Sextile = compatible elements)
ELEMENT_MAP = {
    "Aries": "Fire", "Leo": "Fire", "Sagittarius": "Fire",
    "Taurus": "Earth", "Virgo": "Earth", "Capricorn": "Earth",
    "Gemini": "Air", "Libra": "Air", "Aquarius": "Air",
    "Cancer": "Water", "Scorpio": "Water", "Pisces": "Water",
}

# Trine signs (same element - 120°)
TRINE_GROUPS = [
    {"Aries", "Leo", "Sagittarius"},  # Fire
    {"Taurus", "Virgo", "Capricorn"},  # Earth
    {"Gemini", "Libra", "Aquarius"},  # Air
    {"Cancer", "Scorpio", "Pisces"},  # Water
]

# Sextile pairs (compatible elements - 60°)
SEXTILE_MAP = {
    "Aries": ["Gemini", "Aquarius"],
    "Taurus": ["Cancer", "Pisces"],
    "Gemini": ["Aries", "Leo"],
    "Cancer": ["Taurus", "Virgo"],
    "Leo": ["Gemini", "Libra"],
    "Virgo": ["Cancer", "Scorpio"],
    "Libra": ["Leo", "Sagittarius"],
    "Scorpio": ["Virgo", "Capricorn"],
    "Sagittarius": ["Libra", "Aquarius"],
    "Capricorn": ["Scorpio", "Pisces"],
    "Aquarius": ["Aries", "Sagittarius"],
    "Pisces": ["Taurus", "Capricorn"],
}

# Square signs (challenging - 90°)
SQUARE_MAP = {
    "Aries": ["Cancer", "Capricorn"],
    "Taurus": ["Leo", "Aquarius"],
    "Gemini": ["Virgo", "Pisces"],
    "Cancer": ["Aries", "Libra"],
    "Leo": ["Taurus", "Scorpio"],
    "Virgo": ["Gemini", "Sagittarius"],
    "Libra": ["Cancer", "Capricorn"],
    "Scorpio": ["Leo", "Aquarius"],
    "Sagittarius": ["Virgo", "Pisces"],
    "Capricorn": ["Aries", "Libra"],
    "Aquarius": ["Taurus", "Scorpio"],
    "Pisces": ["Gemini", "Sagittarius"],
}

# Glow colors for different harmony types
HARMONY_COLORS = {
    "lunar": "#7D67FE",   # Cosmic purple for moon harmony
    "transit": "#00D4AA",  # Teal for transit harmony
    "mixed": "#FF59D0",    # Hot pink for mixed harmony
    "default": "#FAFF0E",  # Electric yellow
}


# =============================================================================
# IN-MEMORY CACHE
# =============================================================================

_suggestions_cache: dict[str, dict] = {}


def _get_cache_key(user_id: str, cache_date: date) -> str:
    """Generate cache key for user + date."""
    return f"{user_id}_{cache_date.isoformat()}"


def _get_cached_suggestions(user_id: str) -> Optional[list[dict]]:
    """Get cached suggestions if still valid (same day)."""
    today = date.today()
    cache_key = _get_cache_key(user_id, today)
    
    if cache_key in _suggestions_cache:
        return _suggestions_cache[cache_key]["suggestions"]
    return None


def _set_cached_suggestions(user_id: str, suggestions: list[dict]) -> None:
    """Cache suggestions for the day."""
    today = date.today()
    cache_key = _get_cache_key(user_id, today)
    
    # Clear old entries for this user (different dates)
    keys_to_remove = [k for k in _suggestions_cache if k.startswith(f"{user_id}_") and k != cache_key]
    for k in keys_to_remove:
        del _suggestions_cache[k]
    
    _suggestions_cache[cache_key] = {
        "suggestions": suggestions,
        "cached_at": datetime.now(timezone.utc).isoformat()
    }


# =============================================================================
# HARMONY CALCULATIONS
# =============================================================================

def is_trine(sign_a: str, sign_b: str) -> bool:
    """Check if two signs form a Trine aspect (same element)."""
    for group in TRINE_GROUPS:
        if sign_a in group and sign_b in group:
            return True
    return False


def is_sextile(sign_a: str, sign_b: str) -> bool:
    """Check if two signs form a Sextile aspect (compatible elements)."""
    return sign_b in SEXTILE_MAP.get(sign_a, [])


def is_square(sign_a: str, sign_b: str) -> bool:
    """Check if two signs form a Square aspect (challenging)."""
    return sign_b in SQUARE_MAP.get(sign_a, [])


def calculate_lunar_harmony(moon_sign: str, friend_sun: str, friend_moon: str) -> tuple[int, str]:
    """
    Calculate lunar harmony score (0-60 points).
    
    Args:
        moon_sign: Current transiting Moon sign
        friend_sun: Friend's natal Sun sign
        friend_moon: Friend's natal Moon sign
        
    Returns:
        Tuple of (score, reason_string)
    """
    score = 0
    reasons = []
    
    # Check Moon-Sun harmony
    if is_trine(moon_sign, friend_sun):
        score += 35
        reasons.append(f"Moon trine their Sun")
    elif is_sextile(moon_sign, friend_sun):
        score += 25
        reasons.append(f"Moon sextile their Sun")
    
    # Check Moon-Moon harmony
    if is_trine(moon_sign, friend_moon):
        score += 25
        reasons.append(f"Moon trine their Moon")
    elif is_sextile(moon_sign, friend_moon):
        score += 15
        reasons.append(f"Moon sextile their Moon")
    
    reason = " and ".join(reasons) if reasons else ""
    return min(score, 60), reason


def calculate_transit_bonus(transits: dict, friend_sun: str) -> tuple[int, str]:
    """
    Calculate transit bonus score (0-30 points).
    
    Checks if Venus/Mercury are in signs that relate to friendship/joy
    (simplified since we don't have friend's house cusps).
    
    Args:
        transits: Current transit data
        friend_sun: Friend's natal Sun sign (used as proxy for 5th/11th house calculation)
        
    Returns:
        Tuple of (score, reason_string)
    """
    score = 0
    reasons = []
    
    planets_data = transits.get("planets", {})
    
    # Get Venus and Mercury signs
    venus_sign = planets_data.get("Venus", {}).get("sign", "")
    mercury_sign = planets_data.get("Mercury", {}).get("sign", "")
    
    # Calculate friend's 11th house sign (friendship house = 11 signs from Sun)
    if friend_sun in ZODIAC_SIGNS:
        sun_index = ZODIAC_SIGNS.index(friend_sun)
        house_11_sign = ZODIAC_SIGNS[(sun_index + 10) % 12]  # 11th house = +10 signs
        house_5_sign = ZODIAC_SIGNS[(sun_index + 4) % 12]   # 5th house = +4 signs
        
        # Venus in 11th or 5th house
        if venus_sign == house_11_sign:
            score += 20
            reasons.append("Venus in their friendship house")
        elif venus_sign == house_5_sign:
            score += 15
            reasons.append("Venus in their joy house")
        
        # Mercury in 11th or 5th house
        if mercury_sign == house_11_sign:
            score += 10
            reasons.append("Mercury in their friendship house")
        elif mercury_sign == house_5_sign:
            score += 10
            reasons.append("Mercury energizing connection")
    
    reason = " and ".join(reasons) if reasons else ""
    return min(score, 30), reason


def calculate_conflict_penalty(transits: dict, friend_sun: str, friend_moon: str) -> tuple[int, str]:
    """
    Calculate conflict penalty (-10 points max).
    
    Checks for Saturn/Mars squares to friend's personal planets.
    
    Returns:
        Tuple of (penalty as negative number, reason_string)
    """
    penalty = 0
    reasons = []
    
    planets_data = transits.get("planets", {})
    
    saturn_sign = planets_data.get("Saturn", {}).get("sign", "")
    mars_sign = planets_data.get("Mars", {}).get("sign", "")
    
    # Saturn square Sun or Moon
    if is_square(saturn_sign, friend_sun):
        penalty -= 5
        reasons.append("Saturn challenges their Sun")
    if is_square(saturn_sign, friend_moon):
        penalty -= 3
    
    # Mars square Sun or Moon
    if is_square(mars_sign, friend_sun):
        penalty -= 3
    if is_square(mars_sign, friend_moon):
        penalty -= 2
    
    penalty = max(penalty, -10)  # Cap at -10
    reason = reasons[0] if reasons else ""
    return penalty, reason


def generate_context_string(
    friend_name: str,
    moon_sign: str,
    lunar_reason: str,
    transit_reason: str,
    score: int
) -> str:
    """Generate a human-readable context string for the suggestion."""
    
    if score >= 80:
        prefix = "Perfect timing!"
    elif score >= 60:
        prefix = "Great alignment today."
    elif score >= 40:
        prefix = "Good energy for connection."
    else:
        prefix = "Cosmic connection available."
    
    # Build the context
    if lunar_reason and transit_reason:
        return f"{prefix} The {moon_sign} Moon harmonizes with {friend_name}'s energy, and {transit_reason.lower()}."
    elif lunar_reason:
        return f"{prefix} The {moon_sign} Moon creates harmony with {friend_name}'s chart today."
    elif transit_reason:
        return f"{prefix} {transit_reason} — a great day to connect with {friend_name}."
    else:
        return f"Today's energy supports connecting with {friend_name}."


# =============================================================================
# MAIN SERVICE FUNCTION
# =============================================================================

def get_friend_suggestions(
    user_id: str,
    friends: list[dict],
    force_refresh: bool = False
) -> dict:
    """
    Get ranked friend alignment suggestions for today.
    
    Args:
        user_id: Unique user identifier for caching
        friends: List of friend dicts with keys:
            - id: int
            - name: str
            - sun_sign: str
            - moon_sign: str
            - avatar_colors: list[int] (optional, for glow color)
        force_refresh: If True, bypass cache
        
    Returns:
        {
            "suggestions": [FriendHarmonySuggestion as dict, ...],
            "current_moon_sign": str,
            "refresh_at": str (next midnight ISO)
        }
    """
    # Check cache first
    if not force_refresh:
        cached = _get_cached_suggestions(user_id)
        if cached is not None:
            moon_sign, _ = get_current_moon_sign()
            return {
                "suggestions": cached,
                "current_moon_sign": moon_sign,
                "refresh_at": _get_next_midnight_iso(),
                "from_cache": True
            }
    
    # Get current transits
    transits = get_detailed_transit_summary()
    moon_sign = transits.get("moon_sign", "Unknown")
    
    suggestions = []
    
    for friend in friends:
        friend_id = friend.get("id")
        friend_name = friend.get("name", "Friend").split()[0]  # First name only
        friend_sun = friend.get("sun_sign", "")
        friend_moon = friend.get("moon_sign", friend_sun)  # Default to sun if no moon
        avatar_colors = friend.get("avatar_colors", [])
        
        # Skip if no sign data
        if not friend_sun:
            continue
        
        # Calculate scores
        lunar_score, lunar_reason = calculate_lunar_harmony(moon_sign, friend_sun, friend_moon)
        transit_score, transit_reason = calculate_transit_bonus(transits, friend_sun)
        penalty, _ = calculate_conflict_penalty(transits, friend_sun, friend_moon)
        
        total_score = max(0, min(100, lunar_score + transit_score + penalty))
        
        # Determine harmony type
        if lunar_score > 30 and transit_score > 15:
            harmony_type = "mixed"
        elif lunar_score > 20:
            harmony_type = "lunar"
        elif transit_score > 10:
            harmony_type = "transit"
        else:
            harmony_type = "default"
        
        # Determine glow color
        if avatar_colors and len(avatar_colors) > 0:
            # Use friend's primary color
            glow_color = f"#{avatar_colors[0]:06X}"
        else:
            glow_color = HARMONY_COLORS.get(harmony_type, HARMONY_COLORS["default"])
        
        # Generate context string
        context = generate_context_string(
            friend_name, moon_sign, lunar_reason, transit_reason, total_score
        )
        
        suggestions.append({
            "friend_id": friend_id,
            "score": total_score,
            "glow_color": glow_color,
            "context_string": context,
            "harmony_type": harmony_type
        })
    
    # Sort by score descending, take top 3
    suggestions.sort(key=lambda x: x["score"], reverse=True)
    top_suggestions = suggestions[:3]
    
    # Cache results
    _set_cached_suggestions(user_id, top_suggestions)
    
    return {
        "suggestions": top_suggestions,
        "current_moon_sign": moon_sign,
        "refresh_at": _get_next_midnight_iso(),
        "from_cache": False
    }


def _get_next_midnight_iso() -> str:
    """Get ISO string for next midnight UTC."""
    now = datetime.now(timezone.utc)
    tomorrow = date.today() + __import__('datetime').timedelta(days=1)
    midnight = datetime.combine(tomorrow, datetime.min.time(), tzinfo=timezone.utc)
    return midnight.isoformat()
