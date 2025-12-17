"""
Vibe Calculator for Astro.FM playlist matching.
Takes birth chart + current transits and outputs target parameters for playlist matching.

S2: Documentation Rule - All functions include clear docstrings.
H4: Astrology Logic Fidelity - Cross-referenced with astrology_vibe_logic.md.
"""
from datetime import datetime
from typing import Optional, List, Dict, Tuple
import math

from services.ephemeris import (
    datetime_to_julian, 
    get_zodiac_sign, 
    calculate_natal_chart,
    calculate_planet_position,
    calculate_ascendant,
    PLANETS as EPHEMERIS_PLANETS,
    ZODIAC_SIGNS
)
from models.vibe import VibeParameters, TransitData
from data.constants import ELEMENTS, PLANETS, MOODS


# =============================================================================
# SIGN MAPPINGS
# =============================================================================

SIGN_TO_ELEMENT: Dict[str, str] = {
    "Aries": "Fire", "Leo": "Fire", "Sagittarius": "Fire",
    "Taurus": "Earth", "Virgo": "Earth", "Capricorn": "Earth",
    "Gemini": "Air", "Libra": "Air", "Aquarius": "Air",
    "Cancer": "Water", "Scorpio": "Water", "Pisces": "Water",
}

SIGN_TO_MODALITY: Dict[str, str] = {
    "Aries": "Cardinal", "Cancer": "Cardinal", "Libra": "Cardinal", "Capricorn": "Cardinal",
    "Taurus": "Fixed", "Leo": "Fixed", "Scorpio": "Fixed", "Aquarius": "Fixed",
    "Gemini": "Mutable", "Virgo": "Mutable", "Sagittarius": "Mutable", "Pisces": "Mutable",
}


# =============================================================================
# PLANETARY EFFECTS ON MUSIC PARAMETERS
# =============================================================================

PLANET_EFFECTS: Dict[str, Dict] = {
    "Sun": {"energy": 15, "valence": 20, "moods": ["Empowering", "Uplifting", "Energizing"]},
    "Moon": {"energy": -10, "valence": 0, "moods": ["Contemplative", "Nostalgic", "Dreamy"]},
    "Mercury": {"energy": 5, "valence": 10, "moods": ["Playful", "Focused", "Anxious"]},
    "Venus": {"energy": -5, "valence": 15, "moods": ["Romantic", "Sensual", "Peaceful"]},
    "Mars": {"energy": 25, "valence": -10, "moods": ["Aggressive", "Energizing", "Empowering"]},
    "Jupiter": {"energy": 10, "valence": 25, "moods": ["Euphoric", "Uplifting", "Hopeful"]},
    "Saturn": {"energy": -15, "valence": -20, "moods": ["Contemplative", "Melancholic", "Dark"]},
    "Uranus": {"energy": 10, "valence": 0, "moods": ["Rebellious", "Anxious", "Mysterious"]},
    "Neptune": {"energy": -20, "valence": 0, "moods": ["Dreamy", "Ethereal", "Transcendent"]},
    "Pluto": {"energy": 5, "valence": -25, "moods": ["Dark", "Mysterious", "Transcendent"]},
}


# =============================================================================
# MOON PHASE EFFECTS
# =============================================================================

MOON_PHASE_EFFECTS: Dict[str, Dict] = {
    "New Moon": {"energy": -10, "moods": ["Contemplative", "Mysterious"]},
    "Waxing Crescent": {"energy": 5, "moods": ["Hopeful"]},
    "First Quarter": {"energy": 10, "moods": ["Energizing"]},
    "Waxing Gibbous": {"energy": 15, "moods": ["Focused"]},
    "Full Moon": {"energy": 20, "moods": ["Euphoric", "Transcendent"]},
    "Waning Gibbous": {"energy": 5, "moods": ["Contemplative"]},
    "Last Quarter": {"energy": -5, "moods": ["Melancholic"]},
    "Waning Crescent": {"energy": -15, "moods": ["Peaceful", "Healing"]},
}


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def get_element_for_sign(sign: str) -> str:
    """
    Map zodiac sign to its element.
    
    Args:
        sign: Zodiac sign name (e.g., "Aries", "Taurus")
        
    Returns:
        Element name: "Fire", "Earth", "Air", or "Water"
        
    Raises:
        ValueError: If sign is not valid
    """
    if sign not in SIGN_TO_ELEMENT:
        raise ValueError(f"Invalid sign: '{sign}'. Must be one of: {list(SIGN_TO_ELEMENT.keys())}")
    return SIGN_TO_ELEMENT[sign]


def get_modality_for_sign(sign: str) -> str:
    """
    Map zodiac sign to its modality.
    
    Args:
        sign: Zodiac sign name
        
    Returns:
        Modality: "Cardinal", "Fixed", or "Mutable"
        
    Raises:
        ValueError: If sign is not valid
    """
    if sign not in SIGN_TO_MODALITY:
        raise ValueError(f"Invalid sign: '{sign}'. Must be one of: {list(SIGN_TO_MODALITY.keys())}")
    return SIGN_TO_MODALITY[sign]


def calculate_aspect(pos1: float, pos2: float) -> Optional[str]:
    """
    Determine aspect between two planetary positions.
    
    Args:
        pos1: First planet's ecliptic longitude (0-360)
        pos2: Second planet's ecliptic longitude (0-360)
        
    Returns:
        Aspect name ("conjunction", "opposition", "square", "trine", "sextile") or None
    """
    diff = abs(pos1 - pos2)
    if diff > 180:
        diff = 360 - diff
    
    # Check aspects with orbs
    if diff <= 8:
        return "conjunction"
    elif 172 <= diff <= 188:
        return "opposition"
    elif 82 <= diff <= 98:
        return "square"
    elif 112 <= diff <= 128:
        return "trine"
    elif 52 <= diff <= 68:
        return "sextile"
    return None


def get_moon_phase(julian_day: float) -> Tuple[str, float]:
    """
    Calculate moon phase from Julian day.
    
    Uses the synodic month (29.53059 days) to determine phase.
    
    Args:
        julian_day: Julian Day number
        
    Returns:
        Tuple of (phase_name, days_into_cycle)
    """
    # Reference new moon: January 6, 2000 at 18:14 UT
    # Julian Day for this date: 2451550.26
    reference_new_moon = 2451550.26
    synodic_month = 29.53059
    
    # Calculate days since reference new moon
    days_since = julian_day - reference_new_moon
    
    # Get position in current cycle (0 to synodic_month)
    days_into_cycle = days_since % synodic_month
    
    # Determine phase based on position in cycle
    if days_into_cycle < 1.85:
        phase = "New Moon"
    elif days_into_cycle < 7.38:
        phase = "Waxing Crescent"
    elif days_into_cycle < 9.23:
        phase = "First Quarter"
    elif days_into_cycle < 14.77:
        phase = "Waxing Gibbous"
    elif days_into_cycle < 16.61:
        phase = "Full Moon"
    elif days_into_cycle < 22.15:
        phase = "Waning Gibbous"
    elif days_into_cycle < 24.00:
        phase = "Last Quarter"
    else:
        phase = "Waning Crescent"
    
    return phase, round(days_into_cycle, 2)


def calculate_current_transits(current_datetime: datetime) -> TransitData:
    """
    Calculate current planetary positions using ephemeris.
    
    Args:
        current_datetime: Current date/time for transit calculations
        
    Returns:
        TransitData with positions for all planets and moon phase
    """
    julian_day = datetime_to_julian(current_datetime)
    
    # Calculate positions for all planets
    # Use 0 for ascendant since we don't need house placements for transits
    planet_positions = {}
    
    for planet_name, planet_id in EPHEMERIS_PLANETS.items():
        position = calculate_planet_position(planet_id, julian_day, 0.0)
        sign = position["sign"]
        
        planet_positions[planet_name] = {
            "longitude": position["longitude"],
            "sign": sign,
            "degree": position["sign_degree"],
            "element": get_element_for_sign(sign),
            "modality": get_modality_for_sign(sign),
            "retrograde": position["retrograde"]
        }
    
    # Calculate moon phase
    moon_phase, moon_phase_days = get_moon_phase(julian_day)
    
    return TransitData(
        planet_positions=planet_positions,
        moon_phase=moon_phase,
        moon_phase_days=moon_phase_days
    )


def find_active_transits(
    natal_chart: dict, 
    current_transits: TransitData
) -> List[Dict]:
    """
    Find significant aspects between transits and natal positions.
    
    Args:
        natal_chart: Output from ephemeris.calculate_natal_chart()
        current_transits: Current transit data
        
    Returns:
        List of {transit_planet, natal_planet, aspect, orb}
    """
    active_aspects = []
    
    # Get natal planet positions
    natal_positions = {p["name"]: p["longitude"] for p in natal_chart["planets"]}
    natal_asc = natal_chart["ascendant"]
    
    # Check each transit planet against natal positions
    for transit_name, transit_data in current_transits.planet_positions.items():
        transit_long = transit_data["longitude"]
        
        # Check against natal planets
        for natal_name, natal_long in natal_positions.items():
            aspect = calculate_aspect(transit_long, natal_long)
            if aspect:
                orb = abs(transit_long - natal_long)
                if orb > 180:
                    orb = 360 - orb
                
                active_aspects.append({
                    "transit_planet": transit_name,
                    "natal_planet": natal_name,
                    "aspect": aspect,
                    "orb": round(orb, 2)
                })
        
        # Check against Ascendant
        aspect = calculate_aspect(transit_long, natal_asc)
        if aspect:
            orb = abs(transit_long - natal_asc)
            if orb > 180:
                orb = 360 - orb
            
            active_aspects.append({
                "transit_planet": transit_name,
                "natal_planet": "Ascendant",
                "aspect": aspect,
                "orb": round(orb, 2)
            })
    
    return active_aspects


def _determine_primary_elements(natal_chart: dict) -> Tuple[List[str], List[str]]:
    """
    Determine primary and secondary elements from natal chart.
    
    Looks at Sun, Moon, and Ascendant signs.
    
    Returns:
        Tuple of (primary_elements, secondary_elements)
    """
    # Get Sun, Moon, and Ascendant signs
    planets = {p["name"]: p["sign"] for p in natal_chart["planets"]}
    sun_sign = planets.get("Sun")
    moon_sign = planets.get("Moon")
    asc_sign = natal_chart.get("ascendant_sign")
    
    # Map to elements
    sun_element = get_element_for_sign(sun_sign) if sun_sign else None
    moon_element = get_element_for_sign(moon_sign) if moon_sign else None
    asc_element = get_element_for_sign(asc_sign) if asc_sign else None
    
    # Count elements
    element_counts: Dict[str, int] = {}
    element_priority: Dict[str, int] = {}  # Lower = higher priority
    
    for i, element in enumerate([sun_element, moon_element, asc_element]):
        if element:
            element_counts[element] = element_counts.get(element, 0) + 1
            if element not in element_priority:
                element_priority[element] = i  # First occurrence gets priority
    
    # Sort by count (desc) then by priority (asc)
    sorted_elements = sorted(
        element_counts.keys(),
        key=lambda e: (-element_counts[e], element_priority[e])
    )
    
    # Primary = most common (up to 2)
    primary = sorted_elements[:1] if sorted_elements else ["Fire"]  # Default fallback
    
    # Secondary = next most common, or Moon's element if different
    secondary = []
    if len(sorted_elements) > 1:
        secondary = [sorted_elements[1]]
    elif moon_element and moon_element not in primary:
        secondary = [moon_element]
    
    return primary, secondary


def _get_time_of_day(current_datetime: datetime) -> str:
    """Map current hour to time period."""
    hour = current_datetime.hour
    
    if 5 <= hour < 12:
        return "morning"
    elif 12 <= hour < 17:
        return "afternoon"
    elif 17 <= hour < 21:
        return "evening"
    else:
        return "night"


def _calculate_intensity(active_aspects: List[Dict], moon_phase: str) -> Tuple[int, int]:
    """Calculate intensity range based on aspects and moon phase."""
    base_intensity = 50
    
    # Add for each aspect found
    aspect_scores = {
        "conjunction": 15,
        "opposition": 12,
        "square": 10,
        "trine": 8,
        "sextile": 5
    }
    
    for aspect_data in active_aspects:
        aspect = aspect_data["aspect"]
        base_intensity += aspect_scores.get(aspect, 0)
    
    # Moon phase bonus
    if moon_phase == "Full Moon":
        base_intensity += 15
    elif moon_phase == "New Moon":
        base_intensity += 10
    
    # Cap at 100
    intensity_max = min(base_intensity, 100)
    intensity_min = max(intensity_max - 30, 20)
    
    return (intensity_min, intensity_max)


def _determine_modality_preference(transits: TransitData) -> Optional[str]:
    """Determine modality preference from current transits."""
    modality_counts = {"Cardinal": 0, "Fixed": 0, "Mutable": 0}
    
    for planet_data in transits.planet_positions.values():
        modality = planet_data["modality"]
        modality_counts[modality] += 1
    
    # Check if any modality has 3+ planets
    for modality, count in modality_counts.items():
        if count >= 3:
            return modality
    
    return None


def generate_cosmic_summary(
    moon_sign: str,
    moon_phase: str,
    active_planets: List[str],
    primary_element: str,
    energy_direction: str
) -> str:
    """
    Generate the 2-3 sentence cosmic weather description.
    
    Args:
        moon_sign: Current Moon sign
        moon_phase: Current moon phase name
        active_planets: List of currently active planet names
        primary_element: User's primary element
        energy_direction: "high", "moderate", or "low"
        
    Returns:
        2-3 sentence cosmic weather summary
    """
    # Element qualities
    element_qualities = {
        "Fire": "passionate and action-oriented",
        "Earth": "grounded and sensual",
        "Air": "intellectual and communicative",
        "Water": "emotional and intuitive"
    }
    
    # Planet qualities
    planet_qualities = {
        "Sun": "self-expression and vitality",
        "Moon": "emotional depth",
        "Mercury": "mental agility",
        "Venus": "beauty and pleasure",
        "Mars": "drive and determination",
        "Jupiter": "expansion and optimism",
        "Saturn": "discipline and structure",
        "Uranus": "innovation and change",
        "Neptune": "dreams and inspiration",
        "Pluto": "transformation and power"
    }
    
    # Energy descriptions
    energy_desc = {
        "high": "This is a high-energy moment—lean into bold, uplifting sounds.",
        "moderate": "The cosmic weather today is balanced—explore a mix of moods.",
        "low": "Today calls for introspection—softer, deeper music will resonate."
    }
    
    # Build summary
    moon_element = get_element_for_sign(moon_sign)
    moon_quality = element_qualities.get(moon_element, "dynamic")
    
    # First sentence: Moon position
    sentence1 = f"The {moon_phase} in {moon_sign} brings {moon_quality} energy to your day."
    
    # Second sentence: Active planets
    if active_planets:
        main_planet = active_planets[0]
        planet_qual = planet_qualities.get(main_planet, "cosmic energy")
        sentence2 = f"With {main_planet} active, expect themes of {planet_qual}."
    else:
        sentence2 = f"Your {primary_element} nature is amplified today."
    
    # Third sentence: Energy direction
    sentence3 = energy_desc.get(energy_direction, energy_desc["moderate"])
    
    return f"{sentence1} {sentence2} {sentence3}"


def calculate_vibe_parameters(
    natal_chart: dict,
    current_datetime: datetime,
    latitude: float,
    longitude: float
) -> VibeParameters:
    """
    Main function: Calculate playlist vibe parameters from chart and transits.
    
    Args:
        natal_chart: Output from ephemeris.calculate_natal_chart()
        current_datetime: Current date/time for transits
        latitude: User's current location latitude
        longitude: User's current location longitude
    
    Returns:
        VibeParameters with all targeting data for playlist matching
    """
    # 1. Determine primary/secondary elements from birth chart
    primary_elements, secondary_elements = _determine_primary_elements(natal_chart)
    
    # 2. Calculate current transits
    transits = calculate_current_transits(current_datetime)
    
    # 3. Find active planetary aspects
    active_aspects = find_active_transits(natal_chart, transits)
    
    # 4. Determine which planets are most active
    planet_activity: Dict[str, int] = {}
    for aspect_data in active_aspects:
        transit_planet = aspect_data["transit_planet"]
        planet_activity[transit_planet] = planet_activity.get(transit_planet, 0) + 1
    
    # Sort by activity, take top 2-4
    sorted_planets = sorted(planet_activity.keys(), key=lambda p: -planet_activity[p])
    active_planets = sorted_planets[:4] if len(sorted_planets) >= 4 else sorted_planets
    
    # Ensure we have at least 2 planets
    if len(active_planets) < 2:
        # Add Sun and Moon as defaults
        for default_planet in ["Sun", "Moon", "Mercury"]:
            if default_planet not in active_planets:
                active_planets.append(default_planet)
            if len(active_planets) >= 2:
                break
    
    # 5. Apply planetary effects to energy/valence
    base_energy_min, base_energy_max = 50, 70
    base_valence_min, base_valence_max = 40, 60
    mood_set: set = set()
    
    for planet in active_planets:
        effects = PLANET_EFFECTS.get(planet, {})
        energy_mod = effects.get("energy", 0)
        valence_mod = effects.get("valence", 0)
        
        base_energy_min += energy_mod
        base_energy_max += energy_mod
        base_valence_min += valence_mod
        base_valence_max += valence_mod
        
        for mood in effects.get("moods", []):
            mood_set.add(mood)
    
    # 6. Apply moon phase effects
    moon_phase = transits.moon_phase
    phase_effects = MOON_PHASE_EFFECTS.get(moon_phase, {})
    phase_energy = phase_effects.get("energy", 0)
    
    base_energy_min += phase_energy
    base_energy_max += phase_energy
    
    for mood in phase_effects.get("moods", []):
        mood_set.add(mood)
    
    # 7. Clamp values to 0-100
    target_energy = (
        max(0, min(100, base_energy_min)),
        max(0, min(100, base_energy_max))
    )
    target_valence = (
        max(0, min(100, base_valence_min)),
        max(0, min(100, base_valence_max))
    )
    
    # Ensure min <= max
    if target_energy[0] > target_energy[1]:
        target_energy = (target_energy[1], target_energy[0])
    if target_valence[0] > target_valence[1]:
        target_valence = (target_valence[1], target_valence[0])
    
    # 8. Select 3-5 moods
    mood_list = list(mood_set)[:5]
    while len(mood_list) < 3:
        # Add default moods based on primary element
        element_moods = {
            "Fire": ["Energizing", "Empowering", "Euphoric"],
            "Earth": ["Peaceful", "Sensual", "Contemplative"],
            "Air": ["Playful", "Uplifting", "Focused"],
            "Water": ["Dreamy", "Melancholic", "Ethereal"]
        }
        default_moods = element_moods.get(primary_elements[0], ["Contemplative", "Peaceful", "Dreamy"])
        for m in default_moods:
            if m not in mood_list:
                mood_list.append(m)
            if len(mood_list) >= 3:
                break
    
    # 9. Calculate intensity
    intensity_range = _calculate_intensity(active_aspects, moon_phase)
    
    # 10. Determine time of day
    time_of_day = _get_time_of_day(current_datetime)
    
    # 11. Determine modality preference
    modality_preference = _determine_modality_preference(transits)
    
    # 12. Determine energy direction for summary
    avg_energy = (target_energy[0] + target_energy[1]) / 2
    if avg_energy >= 70:
        energy_direction = "high"
    elif avg_energy <= 40:
        energy_direction = "low"
    else:
        energy_direction = "moderate"
    
    # 13. Generate cosmic summary
    moon_sign = transits.planet_positions["Moon"]["sign"]
    cosmic_weather_summary = generate_cosmic_summary(
        moon_sign=moon_sign,
        moon_phase=moon_phase,
        active_planets=active_planets,
        primary_element=primary_elements[0],
        energy_direction=energy_direction
    )
    
    return VibeParameters(
        target_energy=target_energy,
        target_valence=target_valence,
        primary_elements=primary_elements,
        secondary_elements=secondary_elements,
        active_planets=active_planets[:4],  # Ensure max 4
        mood_direction=mood_list[:5],  # Ensure max 5
        intensity_range=intensity_range,
        time_of_day=time_of_day,
        modality_preference=modality_preference,
        cosmic_weather_summary=cosmic_weather_summary
    )
