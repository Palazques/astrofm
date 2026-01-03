"""
Transit Alignment Service.

Calculates gap/resonance relationships between user's natal chart and current transits.
Provides planet-specific insights based on house-to-house transitions.

Structure: 10 planets × 144 house combos = 1,440 insight entries.
"""
from datetime import datetime, timezone
from typing import Optional

from services.alignment import (
    get_current_transits,
    detect_aspect,
    MAJOR_ORB,
)
from services.ephemeris import (
    datetime_to_julian,
    calculate_planet_position,
    calculate_ascendant,
    get_zodiac_sign,
    PLANETS,
)


# Planet symbols for display
PLANET_SYMBOLS = {
    "Sun": "☉",
    "Moon": "☽",
    "Mercury": "☿",
    "Venus": "♀",
    "Mars": "♂",
    "Jupiter": "♃",
    "Saturn": "♄",
    "Uranus": "♅",
    "Neptune": "♆",
    "Pluto": "♇",
}

# Planet colors (matching design system)
PLANET_COLORS = {
    "Sun": "#FAFF0E",      # Primary yellow
    "Moon": "#C0C0C0",     # Silver
    "Mercury": "#00D4AA",  # Teal
    "Venus": "#FF59D0",    # Pink
    "Mars": "#E84855",     # Red
    "Jupiter": "#FF8C42",  # Orange
    "Saturn": "#7D67FE",   # Purple
    "Uranus": "#00B4D8",   # Cyan
    "Neptune": "#9D4EDD",  # Deep purple
    "Pluto": "#6B7280",    # Gray
}

# House theme keywords
HOUSE_THEMES = {
    1: "Identity",
    2: "Resources",
    3: "Communication",
    4: "Foundation",
    5: "Expression",
    6: "Routine",
    7: "Partnership",
    8: "Depths",
    9: "Expansion",
    10: "Achievement",
    11: "Community",
    12: "Dissolution",
}

# Planet-specific insight structure (1,440 entries: 10 planets × 144 house combos)
# User will provide content from another source
TRANSIT_INSIGHTS: dict[str, dict[tuple[int, int], dict]] = {
    "sun": {},
    "moon": {},
    "mercury": {},
    "venus": {},
    "mars": {},
    "jupiter": {},
    "saturn": {},
    "uranus": {},
    "neptune": {},
    "pluto": {},
}


def determine_gap_or_resonance(
    natal_house: int,
    transit_house: int,
    natal_lon: float,
    transit_lon: float,
) -> str:
    """
    Determine if the natal-transit relationship is a gap or resonance.
    
    Gap (tension): Challenging aspects OR house distance >= 4
    Resonance (harmony): Harmonious aspects OR same/adjacent houses
    
    Args:
        natal_house: Natal planet's house (1-12)
        transit_house: Transit planet's house (1-12)
        natal_lon: Natal planet's ecliptic longitude
        transit_lon: Transit planet's ecliptic longitude
        
    Returns:
        'gap' or 'resonance'
    """
    # Check house distance (circular, so 1->12 is distance 1)
    house_distance = min(
        abs(natal_house - transit_house),
        12 - abs(natal_house - transit_house)
    )
    
    # Check for aspects
    aspect = detect_aspect(natal_lon, transit_lon, "Natal", "Transit")
    
    if aspect:
        aspect_name = aspect["aspect"]
        # Harmonious aspects = resonance
        if aspect_name in ["Conjunction", "Trine", "Sextile"]:
            return "resonance"
        # Challenging aspects = gap  
        if aspect_name in ["Opposition", "Square"]:
            return "gap"
    
    # Fallback to house distance
    if house_distance <= 1:  # Same or adjacent house
        return "resonance"
    elif house_distance >= 4:  # Significant distance
        return "gap"
    else:
        # Middle ground - slight tension
        return "gap"


def get_planet_insight(
    planet: str,
    natal_house: int,
    transit_house: int,
) -> dict:
    """
    Get planet-specific insight for a house-to-house transition.
    
    Args:
        planet: Planet name (lowercase)
        natal_house: Natal house (1-12)
        transit_house: Transit house (1-12)
        
    Returns:
        Dict with pull, feelings, practice keys.
        Returns placeholder if insight not found.
    """
    planet_key = planet.lower()
    house_key = (natal_house, transit_house)
    
    if planet_key in TRANSIT_INSIGHTS and house_key in TRANSIT_INSIGHTS[planet_key]:
        return TRANSIT_INSIGHTS[planet_key][house_key]
    
    # Placeholder insight when content not yet provided
    natal_theme = HOUSE_THEMES.get(natal_house, "Unknown")
    transit_theme = HOUSE_THEMES.get(transit_house, "Unknown")
    
    return {
        "pull": f"Your {planet} lives in {natal_theme}. Today it's being pulled toward {transit_theme}.",
        "feelings": [
            f"Tension between {natal_theme.lower()} and {transit_theme.lower()}",
            "Energy shifting between life areas",
            "Awareness of different priorities",
        ],
        "practice": f"Notice where {natal_theme.lower()} and {transit_theme.lower()} intersect in your life today.",
    }


def calculate_natal_chart(
    birth_datetime: datetime,
    latitude: float,
    longitude: float,
) -> dict:
    """
    Calculate natal chart positions for all planets.
    
    Args:
        birth_datetime: User's birth datetime
        latitude: Birth location latitude
        longitude: Birth location longitude
        
    Returns:
        Dict with planets list containing name, longitude, sign, degree, house
    """
    julian_day = datetime_to_julian(birth_datetime)
    ascendant = calculate_ascendant(julian_day, latitude, longitude)
    
    planets = []
    for name, planet_id in PLANETS.items():
        position = calculate_planet_position(planet_id, julian_day, ascendant)
        sign, degree = get_zodiac_sign(position["longitude"])
        
        # Calculate house using Whole Sign system
        # House 1 starts at Ascendant's sign
        asc_sign_index = int(ascendant // 30)
        planet_sign_index = int(position["longitude"] // 30)
        house = ((planet_sign_index - asc_sign_index) % 12) + 1
        
        planets.append({
            "name": name,
            "longitude": position["longitude"],
            "sign": sign,
            "degree": degree,
            "house": house,
        })
    
    return {"planets": planets, "ascendant": ascendant}


def calculate_transit_alignment(
    birth_datetime: str,
    latitude: float,
    longitude: float,
    timezone_str: str,
    target_date: Optional[str] = None,
) -> dict:
    """
    Calculate transit alignment between natal chart and current transits.
    
    Args:
        birth_datetime: ISO format birth datetime string
        latitude: Birth location latitude
        longitude: Birth location longitude
        timezone_str: Timezone string (e.g., 'America/Los_Angeles')
        target_date: Optional target date for transits (defaults to now)
        
    Returns:
        Dict with planets array containing alignment data for each planet
    """
    # Parse birth datetime
    birth_dt = datetime.fromisoformat(birth_datetime.replace('Z', '+00:00'))
    if birth_dt.tzinfo:
        birth_dt = birth_dt.replace(tzinfo=None)
    
    # Calculate natal chart
    natal_chart = calculate_natal_chart(birth_dt, latitude, longitude)
    
    # Get current transits
    transit_dt = None
    if target_date:
        transit_dt = datetime.fromisoformat(target_date.replace('Z', '+00:00'))
        if transit_dt.tzinfo:
            transit_dt = transit_dt.replace(tzinfo=None)
    
    transits = get_current_transits(transit_dt)
    
    # Calculate ascendant for current transits (use birth location for house context)
    transit_jd = datetime_to_julian(transit_dt or datetime.now(timezone.utc).replace(tzinfo=None))
    transit_asc = calculate_ascendant(transit_jd, latitude, longitude)
    asc_sign_index = int(transit_asc // 30)
    
    # Build alignment data for each planet
    alignment_planets = []
    gap_count = 0
    resonance_count = 0
    
    for natal_planet in natal_chart["planets"]:
        # Find matching transit
        transit_planet = next(
            (t for t in transits if t["name"] == natal_planet["name"]),
            None
        )
        
        if not transit_planet:
            continue
        
        # Calculate transit house
        transit_sign_index = int(transit_planet["longitude"] // 30)
        transit_house = ((transit_sign_index - asc_sign_index) % 12) + 1
        
        # Determine gap or resonance
        status = determine_gap_or_resonance(
            natal_planet["house"],
            transit_house,
            natal_planet["longitude"],
            transit_planet["longitude"],
        )
        
        if status == "gap":
            gap_count += 1
        else:
            resonance_count += 1
        
        # Get planet-specific insight
        insight = get_planet_insight(
            natal_planet["name"],
            natal_planet["house"],
            transit_house,
        )
        
        planet_data = {
            "id": natal_planet["name"].lower(),
            "name": natal_planet["name"],
            "symbol": PLANET_SYMBOLS.get(natal_planet["name"], "?"),
            "color": PLANET_COLORS.get(natal_planet["name"], "#FFFFFF"),
            "natal": {
                "sign": natal_planet["sign"],
                "degree": round(natal_planet["degree"], 1),
                "house": natal_planet["house"],
            },
            "transit": {
                "sign": transit_planet["sign"],
                "degree": round(transit_planet["sign_degree"], 1),
                "house": transit_house,
                "retrograde": transit_planet.get("retrograde", False),
            },
            "status": status,
            "pull": insight["pull"],
            "feelings": insight["feelings"],
            "practice": insight["practice"],
        }
        
        alignment_planets.append(planet_data)
    
    return {
        "planets": alignment_planets,
        "gap_count": gap_count,
        "resonance_count": resonance_count,
    }
