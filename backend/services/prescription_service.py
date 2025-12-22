"""
Prescription service for Cosmic Prescription feature.

Calculates transit-to-natal aspects and recommends brainwave modes.

S2: Documentation Rule - All functions include clear docstrings.
H4: Astrology Logic Fidelity - Uses orb and aspect definitions from alignment service.
"""
from datetime import datetime, timezone
from typing import List, Optional, Dict, Tuple

from models.prescription_schemas import (
    BrainwaveMode,
    TransitPrescription,
    CosmicPrescription,
    ModeInfo,
    MODE_INFO,
    BRAINWAVE_HZ,
    PLANET_FREQUENCIES,
)
from services.ephemeris import calculate_natal_chart
from services.alignment import (
    get_current_transits,
    detect_all_aspects,
    PLANET_WEIGHTS,
)


# Transit-to-mode mapping based on planet and aspect nature
# Format: (transit_planet, aspect_nature) -> (mode, reasoning)
TRANSIT_MODE_MAP: Dict[Tuple[str, str], Tuple[BrainwaveMode, str]] = {
    # Mercury transits - mental energy
    ("Mercury", "challenging"): (BrainwaveMode.FOCUS, "synchronizes scattered mental energy"),
    ("Mercury", "harmonious"): (BrainwaveMode.FOCUS, "amplifies natural mental clarity"),
    ("Mercury", "neutral"): (BrainwaveMode.FOCUS, "supports clear communication"),
    
    # Mars transits - action energy
    ("Mars", "challenging"): (BrainwaveMode.FOCUS, "channels raw energy into directed action"),
    ("Mars", "harmonious"): (BrainwaveMode.EXPAND, "amplifies drive and motivation"),
    ("Mars", "neutral"): (BrainwaveMode.FOCUS, "directs physical energy productively"),
    
    # Moon transits - emotional energy
    ("Moon", "challenging"): (BrainwaveMode.CALM, "creates emotional breathing room"),
    ("Moon", "harmonious"): (BrainwaveMode.CALM, "deepens emotional receptivity"),
    ("Moon", "neutral"): (BrainwaveMode.CALM, "supports emotional processing"),
    
    # Venus transits - harmony and pleasure
    ("Venus", "challenging"): (BrainwaveMode.CALM, "soothes relationship tensions"),
    ("Venus", "harmonious"): (BrainwaveMode.CALM, "amplifies receptivity to beauty"),
    ("Venus", "neutral"): (BrainwaveMode.CALM, "opens heart to connection"),
    
    # Sun transits - identity and vitality
    ("Sun", "challenging"): (BrainwaveMode.FOCUS, "centers your sense of self"),
    ("Sun", "harmonious"): (BrainwaveMode.EXPAND, "amplifies confidence and vitality"),
    ("Sun", "neutral"): (BrainwaveMode.FOCUS, "supports authentic expression"),
    
    # Jupiter transits - expansion
    ("Jupiter", "challenging"): (BrainwaveMode.CALM, "grounds excessive optimism"),
    ("Jupiter", "harmonious"): (BrainwaveMode.EXPAND, "amplifies growth and abundance"),
    ("Jupiter", "neutral"): (BrainwaveMode.EXPAND, "opens to opportunity"),
    
    # Saturn transits - structure and lessons
    ("Saturn", "challenging"): (BrainwaveMode.REST, "creates space around heaviness"),
    ("Saturn", "harmonious"): (BrainwaveMode.CALM, "supports steady discipline"),
    ("Saturn", "neutral"): (BrainwaveMode.CALM, "grounds ambition"),
    
    # Uranus transits - disruption and innovation
    ("Uranus", "challenging"): (BrainwaveMode.EXPAND, "harmonizes with change energy"),
    ("Uranus", "harmonious"): (BrainwaveMode.EXPAND, "integrates breakthrough insights"),
    ("Uranus", "neutral"): (BrainwaveMode.EXPAND, "opens to innovation"),
    
    # Neptune transits - dreams and spirituality
    ("Neptune", "challenging"): (BrainwaveMode.FOCUS, "anchors against mental drift"),
    ("Neptune", "harmonious"): (BrainwaveMode.DEEP, "deepens spiritual connection"),
    ("Neptune", "neutral"): (BrainwaveMode.DEEP, "opens intuitive channels"),
    
    # Pluto transits - transformation
    ("Pluto", "challenging"): (BrainwaveMode.DEEP, "metabolizes emotional depth"),
    ("Pluto", "harmonious"): (BrainwaveMode.DEEP, "integrates transformation"),
    ("Pluto", "neutral"): (BrainwaveMode.DEEP, "supports deep processing"),
}


def prioritize_transits(aspects: List[dict]) -> List[dict]:
    """
    Prioritize transits for prescription recommendation.
    
    Sorting criteria (highest priority first):
    1. Tightest orb (most exact aspect)
    2. Outer planets over inner (Pluto > Mercury)
    3. Challenging aspects over harmonious (need more support)
    
    Args:
        aspects: List of aspect dicts from detect_all_aspects
        
    Returns:
        Sorted list with highest priority first
    """
    def priority_score(aspect: dict) -> tuple:
        # Extract planet name from "Transit Mercury" format
        transit_planet = aspect["planet2"].replace("Transit ", "")
        
        # Lower orb = higher priority (negate for sorting)
        orb_score = -aspect["orb"]
        
        # Planet weight (outer planets have lower weight, so negate)
        planet_weight = -PLANET_WEIGHTS.get(transit_planet, 0.5)
        
        # Challenging aspects get priority (needs more support)
        nature_score = 0 if aspect["nature"] == "challenging" else 1
        
        return (nature_score, planet_weight, orb_score)
    
    return sorted(aspects, key=priority_score)


def get_mode_for_transit(transit_planet: str, nature: str) -> Tuple[BrainwaveMode, str]:
    """
    Get recommended brainwave mode for a transit.
    
    Args:
        transit_planet: Name of transiting planet
        nature: Aspect nature (harmonious, challenging, neutral)
        
    Returns:
        Tuple of (BrainwaveMode, effect_description)
    """
    key = (transit_planet, nature)
    if key in TRANSIT_MODE_MAP:
        return TRANSIT_MODE_MAP[key]
    
    # Default fallback
    return (BrainwaveMode.CALM, "supports your current energy")


def get_carrier_frequency(planet: str) -> float:
    """
    Get Cosmic Octave frequency for a planet.
    
    Args:
        planet: Planet name
        
    Returns:
        Frequency in Hz
    """
    return PLANET_FREQUENCIES.get(planet, 126.22)  # Default to Sun


def get_all_mode_info() -> List[ModeInfo]:
    """Get info for all available brainwave modes."""
    return list(MODE_INFO.values())


def calculate_prescription(
    birth_datetime: datetime,
    latitude: float,
    longitude: float,
) -> dict:
    """
    Calculate cosmic prescription from birth data and current transits.
    
    This is the main calculation function that:
    1. Calculates natal chart
    2. Gets current transits
    3. Finds all aspects between transits and natal
    4. Prioritizes and selects top 3
    5. Determines recommended mode
    
    Args:
        birth_datetime: Birth date and time (UTC)
        latitude: Birth location latitude
        longitude: Birth location longitude
        
    Returns:
        Dictionary with prescription data (without AI text - that's added by API route)
    """
    # Calculate natal chart
    natal_chart = calculate_natal_chart(birth_datetime, latitude, longitude)
    natal_planets = natal_chart["planets"]
    
    # Get current transits
    current_transits = get_current_transits()
    
    # Find all aspects between transits and natal positions
    all_aspects = detect_all_aspects(natal_planets, current_transits)
    
    # Prioritize aspects
    prioritized = prioritize_transits(all_aspects)
    
    # Check if quiet day (no significant transits)
    is_quiet_day = len(prioritized) == 0
    
    if is_quiet_day:
        # No transits - recommend neutral mode
        return {
            "primary_transit": None,
            "secondary_transits": [],
            "recommended_mode": BrainwaveMode.NEUTRAL,
            "brainwave_hz": BRAINWAVE_HZ[BrainwaveMode.NEUTRAL],
            "carrier_frequency_hz": PLANET_FREQUENCIES["Sun"],  # Default to Sun
            "carrier_planet": "Sun",
            "effect_description": "choose your own intention",
            "is_quiet_day": True,
            "transit_count": 0,
            "available_modes": get_all_mode_info(),
        }
    
    # Get primary transit (highest priority)
    primary = prioritized[0]
    transit_planet = primary["planet2"].replace("Transit ", "")
    natal_planet = primary["planet1"].replace("Natal ", "")
    
    # Get recommended mode
    mode, effect_desc = get_mode_for_transit(transit_planet, primary["nature"])
    
    # Create transit prescription objects
    primary_prescription = TransitPrescription(
        transit_planet=transit_planet,
        natal_planet=natal_planet,
        aspect=primary["aspect"],
        orb=primary["orb"],
        nature=primary["nature"],
    )
    
    # Get up to 2 secondary transits
    secondary_prescriptions = []
    for aspect in prioritized[1:3]:
        t_planet = aspect["planet2"].replace("Transit ", "")
        n_planet = aspect["planet1"].replace("Natal ", "")
        secondary_prescriptions.append(TransitPrescription(
            transit_planet=t_planet,
            natal_planet=n_planet,
            aspect=aspect["aspect"],
            orb=aspect["orb"],
            nature=aspect["nature"],
        ))
    
    return {
        "primary_transit": primary_prescription,
        "secondary_transits": secondary_prescriptions,
        "recommended_mode": mode,
        "brainwave_hz": BRAINWAVE_HZ[mode],
        "carrier_frequency_hz": get_carrier_frequency(transit_planet),
        "carrier_planet": transit_planet,
        "effect_description": effect_desc,
        "is_quiet_day": False,
        "transit_count": len(prioritized),
        "available_modes": get_all_mode_info(),
    }
