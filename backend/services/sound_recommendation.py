"""
Sound Recommendation Service.

Generates personalized sound recommendations based on natal chart gaps and resonances.
Uses attunement analysis to identify which planetary frequencies the user should
listen to for specific life areas.

S2: Documentation Rule - All functions include clear docstrings.
H4: Astrology Logic Fidelity - Uses house-based life area mappings from astrology_vibe_logic.md.
"""
from datetime import datetime
from typing import Optional

from models.sound_recommendation_schemas import (
    SoundRecommendation,
    SoundRecommendationsResponse,
    AspectBlend,
    LIFE_AREA_KEYS,
    LIFE_AREA_LABELS,
)
from services.attunement import (
    calculate_attunement,
    PLANET_ENERGIES,
    HOUSE_AREAS,
)
from services.sonification import (
    PLANET_FREQUENCIES,
    ASPECT_INTERVALS,
    SIGN_CHORDS,
    note_to_frequency,
)


# House to natural ruling sign mapping
HOUSE_SIGNS = {
    1: "Aries", 2: "Taurus", 3: "Gemini", 4: "Cancer",
    5: "Leo", 6: "Virgo", 7: "Libra", 8: "Scorpio",
    9: "Sagittarius", 10: "Capricorn", 11: "Aquarius", 12: "Pisces"
}

# House to natural ruling planet mapping
HOUSE_PLANETS = {
    1: "Mars", 2: "Venus", 3: "Mercury", 4: "Moon",
    5: "Sun", 6: "Mercury", 7: "Venus", 8: "Pluto",
    9: "Jupiter", 10: "Saturn", 11: "Uranus", 12: "Neptune"
}


def _get_steiner_frequency(planet: str, sign: str) -> float:
    """
    Get frequency using Steiner Sign-based Tone Circle method.
    
    Args:
        planet: Planet name
        sign: Zodiac sign the planet is in
        
    Returns:
        Frequency in Hz based on sign's chord root note
    """
    chord = SIGN_CHORDS.get(sign, ("C", "E", "G"))
    root_note = chord[0]
    
    # Octave based on planet type (matching sonification.py)
    if planet in ["Moon", "Mercury", "Venus"]:
        octave = 5
    elif planet in ["Sun", "Mars", "Jupiter"]:
        octave = 4
    else:  # Saturn, Uranus, Neptune, Pluto
        octave = 3
    
    return note_to_frequency(root_note, octave)


def _get_house_frequency(house_num: int) -> float:
    """
    Get a frequency for a house number using Steiner method.
    Uses the house's natural ruling sign to determine the chord.
    
    Args:
        house_num: House number (1-12)
        
    Returns:
        Frequency in Hz
    """
    sign = HOUSE_SIGNS.get(house_num, "Aries")
    chord = SIGN_CHORDS.get(sign, ("C", "E", "G"))
    root_note = chord[0]
    return note_to_frequency(root_note, 4)  # Mid octave


def _get_aspect_blends(planet: str, natal_sign: str, transit_sign: str) -> list[AspectBlend]:
    """
    Get aspect blend frequencies for a planet based on its natal and transit positions.
    Uses Steiner method for frequencies.
    
    Args:
        planet: Planet name
        natal_sign: Natal zodiac sign
        transit_sign: Transit zodiac sign
        
    Returns:
        List of AspectBlend objects with frequencies
    """
    blends = []
    # Use Steiner frequency from natal sign
    base_freq = _get_steiner_frequency(planet, natal_sign)
    
    # Create a simple aspect blend based on natal/transit relationship
    # If same sign = conjunction (unison)
    # Different signs = create a tension/harmony blend
    if natal_sign == transit_sign:
        blends.append(AspectBlend(
            planets=f"{planet} Natal-Transit",
            aspect="conjunction",
            frequency=base_freq,
            effect="unison"
        ))
    else:
        # Create a slight detuning for tension/resolution effect
        blends.append(AspectBlend(
            planets=f"{planet} Natal-Transit",
            aspect="attunement",
            frequency=base_freq * 1.01,  # Slight beat frequency
            effect="shimmer"
        ))
    
    return blends


def _generate_gap_explanation(
    planet: str,
    life_area: str,
    natal_house: int,
    transit_house: int,
    intensity_gap: float
) -> str:
    """
    Generate a clear explanation for why this gap needs attention.
    
    Args:
        planet: Planet name
        life_area: Life area label
        natal_house: Natal house placement
        transit_house: Transit house placement  
        intensity_gap: Intensity gap value
        
    Returns:
        Human-readable explanation string
    """
    energy = PLANET_ENERGIES.get(planet, "energy")
    natal_area = HOUSE_AREAS.get(natal_house, "life")
    transit_area = HOUSE_AREAS.get(transit_house, "life")
    
    intensity_word = "significant" if intensity_gap > 0.5 else "notable"
    
    return (
        f"Today's cosmic weather emphasizes {energy} in the area of {transit_area}, "
        f"but your natal {planet} naturally expresses through {natal_area}. "
        f"This creates a {intensity_word} gap that listening to {planet}'s frequency "
        f"can help bridge. Focus on {life_area.lower()} to align with today's energy."
    )


def _generate_resonance_explanation(
    planet: str,
    life_area: str,
    natal_house: int
) -> str:
    """
    Generate a clear explanation for why this resonance should be amplified.
    
    Args:
        planet: Planet name
        life_area: Life area label
        natal_house: Natal house placement
        
    Returns:
        Human-readable explanation string
    """
    energy = PLANET_ENERGIES.get(planet, "energy")
    
    return (
        f"Your natural {energy} is perfectly aligned with today's cosmic weather. "
        f"This is an excellent time to amplify your {life_area.lower()} through "
        f"listening to {planet}'s frequency. Your innate strengths in this area "
        f"are enhanced—lean into this cosmic support."
    )


def get_sound_recommendations(
    birth_datetime: datetime,
    latitude: float,
    longitude: float,
    transit_datetime: Optional[datetime] = None
) -> SoundRecommendationsResponse:
    """
    Get personalized sound recommendations based on natal chart gaps and resonances.
    
    Uses the attunement analysis to identify which planetary frequencies
    the user should listen to, with explanations for why each recommendation
    is relevant to their current cosmic weather.
    
    Args:
        birth_datetime: User's birth datetime
        latitude: Birth location latitude
        longitude: Birth location longitude
        transit_datetime: Optional datetime for transits (defaults to now)
        
    Returns:
        SoundRecommendationsResponse with primary and all recommendations
    """
    # Get attunement analysis
    analysis = calculate_attunement(
        birth_datetime=birth_datetime,
        latitude=latitude,
        longitude=longitude,
        transit_datetime=transit_datetime
    )
    
    all_recommendations: list[SoundRecommendation] = []
    gaps: list[SoundRecommendation] = []
    resonances: list[SoundRecommendation] = []
    
    # Process all planets from attunement analysis
    for planet_attunement in analysis.planets:
        planet = planet_attunement.planet
        natal_house = planet_attunement.natal_house
        transit_house = planet_attunement.transit_house
        status = planet_attunement.status
        
        # Get life area from transit house (where the energy is asking to be expressed)
        # For gaps: use transit house (where user needs to attune)
        # For resonances: use natal house (where user is naturally strong)
        if status == "gap":
            target_house = transit_house
        else:
            target_house = natal_house
            
        life_area = LIFE_AREA_LABELS.get(target_house, "Life")
        life_area_key = LIFE_AREA_KEYS.get(target_house, "life")
        
        # Get planetary frequency using Steiner method (sign -> chord -> root note)
        frequency = _get_steiner_frequency(planet, planet_attunement.natal_sign)
        
        # Get aspect blends
        aspect_blends = _get_aspect_blends(
            planet,
            planet_attunement.natal_sign,
            planet_attunement.transit_sign
        )
        
        # Generate explanation based on status
        if status == "gap":
            explanation = _generate_gap_explanation(
                planet, life_area, natal_house, transit_house,
                planet_attunement.intensity_gap
            )
        elif status == "resonance":
            explanation = _generate_resonance_explanation(
                planet, life_area, natal_house
            )
        else:
            # Neutral - less urgent but still valid
            explanation = (
                f"Your {planet} energy is balanced today. "
                f"Listening to {planet}'s frequency can support your {life_area.lower()}."
            )
        
        recommendation = SoundRecommendation(
            planet=planet,
            life_area=life_area,
            life_area_key=life_area_key,
            house=target_house,
            sign=planet_attunement.natal_sign if status == "resonance" else planet_attunement.transit_sign,
            status=status,
            explanation=explanation,
            frequency=frequency,
            aspect_blends=aspect_blends,
            intensity_gap=planet_attunement.intensity_gap,
            priority=planet_attunement.priority
        )
        
        all_recommendations.append(recommendation)
        
        if status == "gap":
            gaps.append(recommendation)
        elif status == "resonance":
            resonances.append(recommendation)
    
    # Sort by priority (gaps first, then resonances, then neutral)
    gaps.sort(key=lambda r: r.priority)
    resonances.sort(key=lambda r: r.priority)
    
    # Determine primary recommendation (prefer gaps as they need attention)
    primary = None
    if gaps:
        primary = gaps[0]
    elif resonances:
        primary = resonances[0]
    elif all_recommendations:
        primary = all_recommendations[0]
    
    return SoundRecommendationsResponse(
        primary_recommendation=primary,
        all_recommendations=all_recommendations,
        gaps=gaps,
        resonances=resonances,
        gaps_count=len(gaps),
        resonances_count=len(resonances),
        alignment_score=analysis.alignment_score
    )


def get_recommendations_by_life_area(
    birth_datetime: datetime,
    latitude: float,
    longitude: float,
    life_area_key: str,
    transit_datetime: Optional[datetime] = None
) -> Optional[SoundRecommendation]:
    """
    Get sound recommendation for a specific life area.
    
    Filters the full recommendations to find the most relevant planet
    for the requested life area (e.g., "career_purpose" for 10th house).
    
    Args:
        birth_datetime: User's birth datetime
        latitude: Birth location latitude
        longitude: Birth location longitude
        life_area_key: Life area key (e.g., "career_purpose")
        transit_datetime: Optional datetime for transits
        
    Returns:
        SoundRecommendation for the life area, or None if not found
    """
    response = get_sound_recommendations(
        birth_datetime=birth_datetime,
        latitude=latitude,
        longitude=longitude,
        transit_datetime=transit_datetime
    )
    
    # Find recommendation matching the life area
    for rec in response.all_recommendations:
        if rec.life_area_key == life_area_key:
            return rec
    
    # If no exact match, find the planet that rules this house
    # and return a generic recommendation
    house_num = None
    for h, key in LIFE_AREA_KEYS.items():
        if key == life_area_key:
            house_num = h
            break
    
    if house_num:
        # Return a house-specific recommendation with unique frequency
        house_planet = HOUSE_PLANETS.get(house_num, "Sun")
        house_sign = HOUSE_SIGNS.get(house_num, "Aries")
        house_freq = _get_house_frequency(house_num)
        
        return SoundRecommendation(
            planet=house_planet,
            life_area=LIFE_AREA_LABELS.get(house_num, "Life"),
            life_area_key=life_area_key,
            house=house_num,
            sign=house_sign,
            status="neutral",
            explanation=f"Focus on {LIFE_AREA_LABELS.get(house_num, 'this area').lower()} through {house_planet}'s healing frequency.",
            frequency=house_freq,
            aspect_blends=[],
            intensity_gap=0.0,
            priority=0
        )
    
    return None
