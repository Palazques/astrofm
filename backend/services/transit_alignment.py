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
    calculate_natal_chart,
    PLANETS,
)
from services.sonification import PLANET_ROOT_NOTES, note_to_frequency
from services.ai_service import get_ai_service


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


# Slow planets for gap/resonance counts and major life shift anchor
SLOW_PLANETS = {"Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"}

def get_planet_insight(planet_name: str, natal_house: int, transit_house: int) -> dict:
    """Fallback insight generator when AI bulk insights are missing."""
    p_key = planet_name.lower()
    
    # Check if we have hardcoded insight for this house combo
    if p_key in TRANSIT_INSIGHTS and (natal_house, transit_house) in TRANSIT_INSIGHTS[p_key]:
        return TRANSIT_INSIGHTS[p_key][(natal_house, transit_house)]
    
    # Otherwise, generate a template-based fallback
    natal_theme = HOUSE_THEMES.get(natal_house, "Life")
    transit_theme = HOUSE_THEMES.get(transit_house, "Now")
    
    return {
        "pull": f"The {planet_name} transitions from your house of {natal_theme} into the realm of {transit_theme}.",
        "feelings": [
            f"Focus on {natal_theme.lower()} matters",
            f"New energy in {transit_theme.lower()}",
            "Slight cosmic tension"
        ],
        "practice": f"Meditate on how {natal_theme.lower()} and {transit_theme.lower()} intersect today."
    }

def get_angular_distance(lon1: float, lon2: float) -> float:
    """Calculate the shortest angular distance between two longitudes."""
    diff = abs(lon1 - lon2) % 360
    return diff if diff <= 180 else 360 - diff

def determine_gap_or_resonance(
    natal_house: int,
    transit_house: int,
    natal_lon: float,
    transit_lon: float
) -> str:
    """
    Determine if the transit is a gap or resonance based on house distance and aspects.
    This is a legacy function kept for test compatibility.
    """
    # Check for aspects first
    dist = get_angular_distance(natal_lon, transit_lon)
    
    # Hard aspects = gap
    if abs(dist - 90) <= 8 or abs(dist - 180) <= 8:
        return "gap"
    
    # Soft aspects = resonance
    if abs(dist - 0) <= 8 or abs(dist - 60) <= 8 or abs(dist - 120) <= 8:
        return "resonance"
    
    # Fall back to house distance
    house_dist = min(abs(natal_house - transit_house), 12 - abs(natal_house - transit_house))
    
    if house_dist <= 1:
        return "resonance"
    elif house_dist >= 4:
        return "gap"
    else:
        return "resonance"

def get_astro_fidelity_status(
    natal_lon: float, 
    transit_lon: float,
    transit_velocity: float = 0.0,
) -> dict:
    """
    Determine aspect type, orb, and fidelity status (gap, resonance, alignment, integration).
    
    Rule: Orb <= 5° required for any aspect.
    Applying vs Separating based on transit velocity.
    """
    distance = get_angular_distance(natal_lon, transit_lon)
    
    aspects = {
        "Conjunction": 0.0,
        "Sextile": 60.0,
        "Square": 90.0,
        "Trine": 120.0,
        "Opposition": 180.0
    }
    
    best_aspect = "None"
    min_orb = 999.0
    
    for name, target in aspects.items():
        orb = abs(distance - target)
        if orb <= 5.0 and orb < min_orb:
            min_orb = orb
            best_aspect = name
            
    if best_aspect == "None":
        return {
            "status": "none",
            "aspect_type": "None",
            "orb": 0.0,
            "is_applying": False
        }

    # Simplified Applying/Separating logic
    # In astrology, a transit is applying if it hasn't reached exact degree yet
    # Since we don't have perfect velocity vectors here, we approximate:
    # Most transits move forward. If transit_lon < natal_lon (within orb), it is applying.
    # Exception: Retrograde.
    # More robust: check if (target - distance) is closing.
    # For now, let's assume if distance at exact aspect is target:
    # If currently moving TOWARDS the target degree.
    
    # Actually, let's use a simpler heuristic for now:
    # If the transit is within the orb and hasn't hit the exact target yet.
    # For Conjunction (target 0), if lon_diff is decreasing.
    
    # We'll set is_applying to True for now as a placeholder unless we pass velocity
    is_applying = True
    
    status = "resonance"
    if best_aspect in ["Square", "Opposition"]:
        status = "gap"
    elif best_aspect == "Conjunction":
        status = "alignment"
    
    # Status Tiers override
    if best_aspect in ["Trine", "Sextile"]:
        status = "resonance" # Ghostly static green

    return {
        "status": status,
        "aspect_type": best_aspect,
        "orb": round(min_orb, 2),
        "is_applying": is_applying
    }


def calculate_transit_alignment(
    birth_datetime: str,
    latitude: float,
    longitude: float,
    timezone_str: str,
    target_date: Optional[str] = None,
) -> dict:
    """
    Calculate transit alignment between natal chart and current transits.
    Uses Astro-Fidelity logic with orbs and tiered priorities.
    """
    # Parse birth datetime
    birth_dt = datetime.fromisoformat(birth_datetime.replace('Z', '+00:00'))
    if birth_dt.tzinfo:
        birth_dt = birth_dt.replace(tzinfo=None)
    
    # Calculate natal chart
    natal_chart = calculate_natal_chart(birth_dt, latitude, longitude)
    
    # Get current transits
    curr_now = datetime.now(timezone.utc).replace(tzinfo=None)
    transit_dt = curr_now
    if target_date:
        transit_dt = datetime.fromisoformat(target_date.replace('Z', '+00:00'))
        if transit_dt.tzinfo:
            transit_dt = transit_dt.replace(tzinfo=None)
    
    transits = get_current_transits(transit_dt)
    
    # Get transits for 1 hour later to determine Applying/Separating
    import copy
    from datetime import timedelta
    later_dt = transit_dt + timedelta(hours=1)
    later_transits = get_current_transits(later_dt)
    
    # Calculate transit house context
    transit_jd = datetime_to_julian(transit_dt)
    transit_asc = calculate_ascendant(transit_jd, latitude, longitude)
    asc_sign_index = int(transit_asc // 30)
    
    # Find user's Sun sign for AI personalization
    user_sun_sign = next((p["sign"] for p in natal_chart["planets"] if p["name"] == "Sun"), "Aries")
    
    planet_moves = []
    planet_details = []
    
    for natal_planet in natal_chart["planets"]:
        name = natal_planet["name"]
        transit_p = next((t for t in transits if t["name"] == name), None)
        later_p = next((t for t in later_transits if t["name"] == name), None)
        
        if not transit_p or not later_p: continue
        
        # Calculate transit house
        transit_sign_index = int(transit_p["longitude"] // 30)
        transit_house = ((transit_sign_index - asc_sign_index) % 12) + 1
        
        # Calculate Astro-Fidelity Status
        # Check Applying/Separating by comparing orbs now vs later
        # We need to detect which aspect they are near first
        distance_now = get_angular_distance(natal_planet["longitude"], transit_p["longitude"])
        distance_later = get_angular_distance(natal_planet["longitude"], later_p["longitude"])
        
        # Aspect detection
        fidelity = get_astro_fidelity_status(natal_planet["longitude"], transit_p["longitude"])
        
        if fidelity["aspect_type"] != "None":
            target_deg = {"Conjunction":0, "Sextile":60, "Square":90, "Trine":120, "Opposition":180}[fidelity["aspect_type"]]
            orb_now = abs(distance_now - target_deg)
            orb_later = abs(distance_later - target_deg)
            # Applying if orb is decreasing
            fidelity["is_applying"] = orb_later < orb_now
            
            # If separating and not a conjunction/soft aspect, turn to Slate (integration)
            if not fidelity["is_applying"]:
                fidelity["status"] = "integration"
        else:
            # No aspect within 5 degrees
            continue # Only show active aspects on the wheel

        planet_moves.append({
            "planet": name,
            "natal_house": natal_planet["house"],
            "transit_house": transit_house
        })
        planet_details.append({
            "natal": natal_planet,
            "transit": transit_p,
            "transit_house": transit_house,
            "fidelity": fidelity
        })

    # 2. Fetch AI insights in bulk (only for those in aspect)
    # Temporarily disabled to speed up endpoint - using fallback insights
    bulk_insights = {}
    # TODO: Re-enable this when we have async/background processing
    # try:
    #     ai_service = get_ai_service()
    #     bulk_insights = ai_service.generate_bulk_transit_insights(user_sun_sign, planet_moves)
    # except Exception as e:
    #     print(f"[WARN] AI bulk insights failed, using fallback: {e}")
    #     bulk_insights = {}
    
    # 3. Build response
    alignment_planets = []
    major_gap_count = 0
    major_resonance_count = 0
    tight_aspect_count = 0
    has_slow_anchor = False
    
    for detail in planet_details:
        natal_p = detail["natal"]
        transit_p = detail["transit"]
        fid = detail["fidelity"]
        name = natal_p["name"]
        
        # Priority Counters (Mars-Pluto)
        if name in SLOW_PLANETS:
            if fid["status"] == "gap": major_gap_count += 1
            if fid["status"] == "resonance": major_resonance_count += 1
            
            # Anchor check for Stellium (orb <= 3)
            if fid["orb"] <= 3.0:
                has_slow_anchor = True
        
        if fid["orb"] <= 3.0:
            tight_aspect_count += 1

        # Insight
        planet_key = name.lower()
        if planet_key in bulk_insights:
            insight = bulk_insights[planet_key]
        else:
            insight = get_planet_insight(name, natal_p["house"], detail["transit_house"])
            
        # Frequency
        root_note = PLANET_ROOT_NOTES.get(name, "C")
        octave = 5 if name in ["Moon", "Mercury", "Venus"] else (3 if name in ["Saturn", "Uranus", "Neptune", "Pluto"] else 4)
        freq = note_to_frequency(root_note, octave)
        
        alignment_planets.append({
            "id": planet_key,
            "name": name,
            "symbol": PLANET_SYMBOLS.get(name, "?"),
            "color": PLANET_COLORS.get(name, "#FFFFFF"),
            "natal": {
                "sign": natal_p["sign"],
                "degree": round(natal_p["sign_degree"], 1),
                "house": natal_p["house"],
                "longitude": natal_p["longitude"]
            },
            "transit": {
                "sign": transit_p["sign"],
                "degree": round(transit_p["sign_degree"], 1),
                "house": detail["transit_house"],
                "retrograde": transit_p.get("retrograde", False),
                "longitude": transit_p["longitude"]
            },
            "frequency": freq,
            "status": fid["status"],
            "aspect_type": fid["aspect_type"],
            "orb": fid["orb"],
            "is_applying": fid["is_applying"],
            "pull": insight["pull"],
            "feelings": insight["feelings"],
            "practice": insight["practice"],
        })
    
    return {
        "planets": alignment_planets,
        "gap_count": major_gap_count,
        "resonance_count": major_resonance_count,
        "is_major_life_shift": (tight_aspect_count >= 3 and has_slow_anchor)
    }
