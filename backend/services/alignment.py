"""
Alignment calculation service.
Calculates resonance scores between natal charts and transits/other charts.

Implements aspect detection and scoring per astrology_vibe_logic.md:
- Major aspects: 8° orb (Conjunction, Opposition, Square, Trine, Sextile)
- Minor aspects: 3° orb (Semi-sextile, Quincunx, Semi-square, Sesqui-quadrate)
- Whole Sign House system for house placements
"""
from datetime import datetime, timezone
from typing import Optional
import swisseph as swe

from services.ephemeris import (
    datetime_to_julian,
    calculate_ascendant,
    calculate_planet_position,
    get_zodiac_sign,
    PLANETS,
    ZODIAC_SIGNS
)


# Aspect definitions: (name, angle, nature)
MAJOR_ASPECTS = [
    ("Conjunction", 0, "neutral"),    # Nature depends on planets involved
    ("Opposition", 180, "challenging"),
    ("Square", 90, "challenging"),
    ("Trine", 120, "harmonious"),
    ("Sextile", 60, "harmonious"),
]

MINOR_ASPECTS = [
    ("Semi-sextile", 30, "neutral"),
    ("Quincunx", 150, "challenging"),
    ("Semi-square", 45, "challenging"),
    ("Sesqui-quadrate", 135, "challenging"),
]

# Orbs per astrology_vibe_logic.md
MAJOR_ORB = 8.0
MINOR_ORB = 3.0

# Planet importance weights for scoring
# Sun/Moon are most important, then personal planets, then outer planets
PLANET_WEIGHTS = {
    "Sun": 1.0,
    "Moon": 1.0,
    "Mercury": 0.7,
    "Venus": 0.7,
    "Mars": 0.6,
    "Jupiter": 0.8,
    "Saturn": 0.6,
    "Uranus": 0.4,
    "Neptune": 0.4,
    "Pluto": 0.4,
}

# Benefic and malefic planets for conjunction nature
BENEFICS = ["Venus", "Jupiter"]
MALEFICS = ["Mars", "Saturn"]

# Moon phase names based on Sun-Moon angle
MOON_PHASES = [
    (0, 45, "New Moon"),
    (45, 90, "Waxing Crescent"),
    (90, 135, "First Quarter"),
    (135, 180, "Waxing Gibbous"),
    (180, 225, "Full Moon"),
    (225, 270, "Waning Gibbous"),
    (270, 315, "Third Quarter"),
    (315, 360, "Waning Crescent"),
]

# Energy type descriptions
ENERGY_DESCRIPTIONS = {
    "Harmonious": "A day of flow and ease. Supportive transits enhance creativity and relationships.",
    "Transformative": "Powerful energies are at work. Embrace change and personal growth.",
    "Dynamic": "Active, energizing aspects drive motivation and new beginnings.",
    "Reflective": "A contemplative period ideal for introspection and planning.",
    "Challenging": "Growth through tension. Face obstacles as opportunities for development.",
    "Balanced": "A mix of energies creating equilibrium. Steady progress is favored.",
}


def normalize_angle(angle: float) -> float:
    """
    Normalize angle to 0-360 range.
    
    Args:
        angle: Any angle in degrees
        
    Returns:
        Angle normalized to 0-360
    """
    while angle < 0:
        angle += 360
    while angle >= 360:
        angle -= 360
    return angle


def calculate_angular_distance(lon1: float, lon2: float) -> float:
    """
    Calculate the shortest angular distance between two longitudes.
    
    Args:
        lon1: First longitude (0-360)
        lon2: Second longitude (0-360)
        
    Returns:
        Shortest distance in degrees (0-180)
    """
    diff = abs(lon1 - lon2)
    if diff > 180:
        diff = 360 - diff
    return diff


def detect_aspect(
    planet1_lon: float,
    planet2_lon: float,
    planet1_name: str,
    planet2_name: str
) -> Optional[dict]:
    """
    Detect if an aspect exists between two planetary positions.
    
    Args:
        planet1_lon: Longitude of first planet (0-360)
        planet2_lon: Longitude of second planet (0-360)
        planet1_name: Name of first planet
        planet2_name: Name of second planet
        
    Returns:
        Aspect data dict if aspect found, None otherwise
    """
    distance = calculate_angular_distance(planet1_lon, planet2_lon)
    
    # Check major aspects first (8° orb)
    for aspect_name, aspect_angle, nature in MAJOR_ASPECTS:
        orb = abs(distance - aspect_angle)
        if orb <= MAJOR_ORB:
            # Special handling for conjunction - nature depends on planets
            actual_nature = nature
            if aspect_name == "Conjunction":
                if planet2_name in BENEFICS or planet1_name in BENEFICS:
                    actual_nature = "harmonious"
                elif planet2_name in MALEFICS or planet1_name in MALEFICS:
                    actual_nature = "challenging"
                else:
                    actual_nature = "neutral"
            
            return {
                "planet1": planet1_name,
                "planet2": planet2_name,
                "aspect": aspect_name,
                "orb": round(orb, 1),
                "nature": actual_nature
            }
    
    # Check minor aspects (3° orb)
    for aspect_name, aspect_angle, nature in MINOR_ASPECTS:
        orb = abs(distance - aspect_angle)
        if orb <= MINOR_ORB:
            return {
                "planet1": planet1_name,
                "planet2": planet2_name,
                "aspect": aspect_name,
                "orb": round(orb, 1),
                "nature": nature
            }
    
    return None


def detect_all_aspects(natal_planets: list, transit_planets: list) -> list:
    """
    Detect all aspects between two sets of planetary positions.
    
    Args:
        natal_planets: List of natal planet position dicts
        transit_planets: List of transit planet position dicts
        
    Returns:
        List of aspect data dicts
    """
    aspects = []
    
    for natal in natal_planets:
        for transit in transit_planets:
            aspect = detect_aspect(
                natal["longitude"],
                transit["longitude"],
                f"Natal {natal['name']}",
                f"Transit {transit['name']}"
            )
            if aspect:
                aspects.append(aspect)
    
    return aspects


def detect_synastry_aspects(user_planets: list, friend_planets: list) -> list:
    """
    Detect synastry aspects between two natal charts.
    
    Args:
        user_planets: User's natal planet positions
        friend_planets: Friend's natal planet positions
        
    Returns:
        List of synastry aspect dicts
    """
    aspects = []
    
    for user_p in user_planets:
        for friend_p in friend_planets:
            aspect = detect_aspect(
                user_p["longitude"],
                friend_p["longitude"],
                f"Your {user_p['name']}",
                f"Their {friend_p['name']}"
            )
            if aspect:
                aspects.append(aspect)
    
    return aspects


def calculate_aspect_score(aspect: dict) -> float:
    """
    Calculate the score contribution of a single aspect.
    
    Scoring per implementation plan:
    - Harmonious (Trine/Sextile): +3 to +8 points
    - Conjunction with benefics: +5 to +10 points
    - Conjunction with malefics: +1 to +3 points
    - Challenging (Square/Opposition): +1 to +4 points (complexity/growth)
    
    Args:
        aspect: Aspect data dict
        
    Returns:
        Score contribution (always positive per design)
    """
    nature = aspect["nature"]
    aspect_name = aspect["aspect"]
    orb = aspect["orb"]
    
    # Base score by aspect type
    if aspect_name in ["Trine", "Sextile"]:
        base_score = 5.0
    elif aspect_name == "Conjunction":
        if nature == "harmonious":
            base_score = 7.0
        elif nature == "challenging":
            base_score = 2.0
        else:
            base_score = 4.0
    elif aspect_name in ["Square", "Opposition"]:
        base_score = 2.5  # Complexity adds some positive energy for growth
    else:
        # Minor aspects
        base_score = 1.5
    
    # Tighter orbs are stronger - scale by orb tightness
    max_orb = MAJOR_ORB if aspect_name in [a[0] for a in MAJOR_ASPECTS] else MINOR_ORB
    orb_factor = 1.0 - (orb / max_orb) * 0.5  # 0.5 to 1.0 range
    
    # Get average weight of planets involved
    # Extract planet names (remove "Natal ", "Transit ", "Your ", "Their " prefixes)
    p1_name = aspect["planet1"].split()[-1]
    p2_name = aspect["planet2"].split()[-1]
    
    weight1 = PLANET_WEIGHTS.get(p1_name, 0.5)
    weight2 = PLANET_WEIGHTS.get(p2_name, 0.5)
    planet_weight = (weight1 + weight2) / 2
    
    return base_score * orb_factor * planet_weight


def determine_dominant_energy(aspects: list) -> str:
    """
    Determine the dominant energy type from a list of aspects.
    
    Args:
        aspects: List of aspect data dicts
        
    Returns:
        Dominant energy type string
    """
    if not aspects:
        return "Balanced"
    
    harmonious_count = sum(1 for a in aspects if a["nature"] == "harmonious")
    challenging_count = sum(1 for a in aspects if a["nature"] == "challenging")
    neutral_count = sum(1 for a in aspects if a["nature"] == "neutral")
    
    total = len(aspects)
    
    # Check for transformative (Pluto involved heavily)
    pluto_aspects = sum(1 for a in aspects if "Pluto" in a["planet1"] or "Pluto" in a["planet2"])
    if pluto_aspects >= 2:
        return "Transformative"
    
    # Determine by ratio
    if harmonious_count / total >= 0.6:
        return "Harmonious"
    elif challenging_count / total >= 0.6:
        return "Challenging"
    elif neutral_count / total >= 0.4:
        return "Reflective"
    elif harmonious_count > challenging_count:
        return "Dynamic"
    else:
        return "Balanced"


def get_moon_phase(sun_lon: float, moon_lon: float) -> str:
    """
    Calculate the current moon phase.
    
    Args:
        sun_lon: Sun's ecliptic longitude
        moon_lon: Moon's ecliptic longitude
        
    Returns:
        Moon phase name
    """
    # Calculate the angle from Sun to Moon (going forward through the zodiac)
    angle = normalize_angle(moon_lon - sun_lon)
    
    for start, end, phase_name in MOON_PHASES:
        if start <= angle < end:
            return phase_name
    
    return "New Moon"  # Default for exact 0°


def get_current_transits(datetime_utc: Optional[datetime] = None) -> list:
    """
    Get current planetary positions for transit calculations.
    Uses Swiss Ephemeris via existing ephemeris.py service.
    
    Args:
        datetime_utc: Optional datetime in UTC (defaults to now)
        
    Returns:
        List of planet position dicts with name, longitude, sign, retrograde
    """
    if datetime_utc is None:
        datetime_utc = datetime.now(timezone.utc).replace(tzinfo=None)
    
    julian_day = datetime_to_julian(datetime_utc)
    
    transits = []
    for name, planet_id in PLANETS.items():
        result, _ = swe.calc_ut(julian_day, planet_id)
        longitude = result[0]
        speed = result[3]
        
        sign, sign_degree = get_zodiac_sign(longitude)
        
        transits.append({
            "name": name,
            "longitude": round(longitude, 4),
            "sign": sign,
            "sign_degree": round(sign_degree, 2),
            "retrograde": speed < 0
        })
    
    return transits


def calculate_daily_alignment(
    natal_chart: dict,
    transit_datetime: Optional[datetime] = None
) -> dict:
    """
    Calculate daily alignment between a natal chart and current transits.
    
    Args:
        natal_chart: User's natal chart data with planets list
        transit_datetime: Optional datetime for transits (defaults to now UTC)
        
    Returns:
        Dictionary with score, aspects, dominant_energy, description
    """
    # Get current transits
    transits = get_current_transits(transit_datetime)
    
    # Detect all aspects between natal and transit positions
    aspects = detect_all_aspects(natal_chart["planets"], transits)
    
    # Calculate total score
    base_score = 50  # Start at neutral
    aspect_scores = sum(calculate_aspect_score(a) for a in aspects)
    
    # Normalize and clamp to 0-100
    final_score = int(min(100, max(0, base_score + aspect_scores)))
    
    # Determine dominant energy
    dominant_energy = determine_dominant_energy(aspects)
    
    # Get description
    description = ENERGY_DESCRIPTIONS.get(
        dominant_energy,
        "The cosmic energies are aligning in unique ways today."
    )
    
    return {
        "score": final_score,
        "aspects": aspects,
        "dominant_energy": dominant_energy,
        "description": description
    }


def calculate_friend_alignment(
    user_natal: dict,
    friend_natal: dict
) -> dict:
    """
    Calculate synastry alignment between two natal charts.
    
    Args:
        user_natal: User's natal chart data
        friend_natal: Friend's natal chart data
        
    Returns:
        Dictionary with score, aspects, dominant_energy, description,
        strengths, and challenges
    """
    # Detect synastry aspects
    aspects = detect_synastry_aspects(
        user_natal["planets"],
        friend_natal["planets"]
    )
    
    # Calculate score
    base_score = 50
    aspect_scores = sum(calculate_aspect_score(a) for a in aspects)
    final_score = int(min(100, max(0, base_score + aspect_scores)))
    
    # Determine dominant energy
    dominant_energy = determine_dominant_energy(aspects)
    
    # Categorize strengths and challenges from aspects
    strengths = []
    challenges = []
    
    for aspect in aspects:
        aspect_desc = f"{aspect['planet1']} {aspect['aspect']} {aspect['planet2']}"
        if aspect["nature"] == "harmonious":
            strengths.append(aspect_desc)
        elif aspect["nature"] == "challenging":
            challenges.append(aspect_desc)
    
    # Limit to top 5 each
    strengths = strengths[:5]
    challenges = challenges[:5]
    
    # Generate description
    if final_score >= 70:
        description = "Strong cosmic connection! Your charts show natural harmony and mutual understanding."
    elif final_score >= 50:
        description = "Balanced energies between your charts. Growth potential through both support and challenges."
    else:
        description = "Dynamic connection with growth opportunities. Differences can lead to complementary strengths."
    
    return {
        "score": final_score,
        "aspects": aspects,
        "dominant_energy": dominant_energy,
        "description": description,
        "strengths": strengths,
        "challenges": challenges
    }
