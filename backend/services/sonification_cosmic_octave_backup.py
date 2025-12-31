"""
Data Sonification Service.
Translates astrological chart data into audio synthesis parameters.

Implements logic from docs/astrology_vibe_logic.md:
- Section II: Planet-to-Tone Mapping
- Section III: House-to-Sound/Timbre Mapping  
- Section IV: Intensity and Distinctness Dynamic
"""
import math
from datetime import datetime
from typing import Optional

from models.sonification_schemas import (
    PlanetSound,
    ChartSonification,
    HouseTimbre,
)
from services.ephemeris import calculate_natal_chart, datetime_to_julian, PLANETS
import swisseph as swe


# Planet-to-Frequency Mapping (Section II of astrology_vibe_logic.md)
# Cosmic Octave method - pure frequencies in Hz
PLANET_FREQUENCIES: dict[str, float] = {
    "Sun": 126.22,      # B - Carrier/Foundation Tone
    "Moon": 210.42,     # G# - Rhythmic/Fluid Modulator
    "Mercury": 141.27,  # C# - High-Frequency Detail Tone
    "Venus": 221.23,    # A - Harmonic/Melodic Tone (Venus was missing, added)
    "Mars": 144.72,     # C# - Pulsing/Percussive Tone
    "Jupiter": 183.58,  # F# - Harmonic Layer Tone
    "Saturn": 147.85,   # D - Low-Frequency Grounding Drone
    "Uranus": 207.36,   # G# - Glitch/Unpredictable Filter Tone
    "Neptune": 211.44,  # G# - Reverb/Echo Ambient Tone
    "Pluto": 140.25,    # C# - Sub-Bass/Intense Filter Tone
}

# Tone output roles for each planet (affects synthesis behavior)
PLANET_ROLES: dict[str, str] = {
    "Sun": "carrier",           # Foundation tone, always present
    "Moon": "modulator",        # Rhythmic modulation
    "Mercury": "detail",        # High frequency detail
    "Venus": "harmonic",        # Melodic harmony layer
    "Mars": "percussive",       # Pulsing rhythm
    "Jupiter": "harmonic",      # Expansion layer
    "Saturn": "drone",          # Low grounding
    "Uranus": "glitch",         # Unpredictable filter
    "Neptune": "ambient",       # Reverb/echo
    "Pluto": "subbass",         # Deep intensity
}

# House-to-Timbre Mapping (Section III of astrology_vibe_logic.md)
# Each house defines filter and envelope characteristics
HOUSE_TIMBRES: dict[int, HouseTimbre] = {
    1: HouseTimbre(
        house=1, life_area="Self", quality="Angular",
        sound_quality="Lead, Focused",
        filter_type="high_pass", filter_cutoff=800.0,
        attack=0.01, decay=0.3, reverb=0.1, stereo_width=0.2
    ),
    2: HouseTimbre(
        house=2, life_area="Money", quality="Succedent",
        sound_quality="Warm, Resonant",
        filter_type="low_pass", filter_cutoff=1200.0,
        attack=0.1, decay=0.5, reverb=0.3, stereo_width=0.4
    ),
    3: HouseTimbre(
        house=3, life_area="Communication", quality="Cadent",
        sound_quality="Fast, Repeating",
        filter_type="band_pass", filter_cutoff=2000.0,
        attack=0.01, decay=0.1, reverb=0.2, stereo_width=0.5
    ),
    4: HouseTimbre(
        house=4, life_area="Home", quality="Angular",
        sound_quality="Deep, Substantial",
        filter_type="low_pass", filter_cutoff=400.0,
        attack=0.2, decay=0.8, reverb=0.4, stereo_width=0.3
    ),
    5: HouseTimbre(
        house=5, life_area="Creativity", quality="Succedent",
        sound_quality="Bright, Expansive",
        filter_type="high_pass", filter_cutoff=600.0,
        attack=0.05, decay=0.4, reverb=0.5, stereo_width=0.9
    ),
    6: HouseTimbre(
        house=6, life_area="Service", quality="Cadent",
        sound_quality="Rhythmic, Structured",
        filter_type="band_pass", filter_cutoff=1000.0,
        attack=0.02, decay=0.2, reverb=0.15, stereo_width=0.3
    ),
    7: HouseTimbre(
        house=7, life_area="Partnership", quality="Angular",
        sound_quality="Layered, Counterpoint",
        filter_type="none", filter_cutoff=0.0,
        attack=0.05, decay=0.5, reverb=0.4, stereo_width=0.8
    ),
    8: HouseTimbre(
        house=8, life_area="Transformation", quality="Succedent",
        sound_quality="Deep, Unsettling",
        filter_type="low_pass", filter_cutoff=300.0,
        attack=0.3, decay=1.0, reverb=0.6, stereo_width=0.4
    ),
    9: HouseTimbre(
        house=9, life_area="Philosophy", quality="Cadent",
        sound_quality="Ascending, Open",
        filter_type="high_pass", filter_cutoff=500.0,
        attack=0.1, decay=0.6, reverb=0.7, stereo_width=0.7
    ),
    10: HouseTimbre(
        house=10, life_area="Career", quality="Angular",
        sound_quality="Apex, Authoritative",
        filter_type="none", filter_cutoff=0.0,
        attack=0.01, decay=0.3, reverb=0.2, stereo_width=0.5
    ),
    11: HouseTimbre(
        house=11, life_area="Groups", quality="Succedent",
        sound_quality="Synthetic, Interconnected",
        filter_type="band_pass", filter_cutoff=1500.0,
        attack=0.08, decay=0.4, reverb=0.5, stereo_width=0.9
    ),
    12: HouseTimbre(
        house=12, life_area="Subconscious", quality="Cadent",
        sound_quality="Ambient, Dissolving",
        filter_type="low_pass", filter_cutoff=600.0,
        attack=0.5, decay=2.0, reverb=0.9, stereo_width=0.6
    ),
}


def calculate_intensity(degree_in_house: float) -> float:
    """
    Calculate intensity/distinctness based on position within house.
    
    Per Section IV of astrology_vibe_logic.md:
    - Maximum intensity at 15° (center of house)
    - Fades to minimum at 0° and 30° (cusps)
    - Uses smooth sine curve
    
    Args:
        degree_in_house: Position within house (0-30)
        
    Returns:
        Intensity value from 0.0 to 1.0
    """
    # Normalize to 0-1 range, then apply sine for bell curve
    normalized = degree_in_house / 30.0
    intensity = math.sin(normalized * math.pi)
    return round(intensity, 4)


def calculate_pan_position(planet_name: str, house: int) -> float:
    """
    Calculate stereo pan position for a planet.
    
    Uses house number to distribute planets across stereo field.
    Houses 1-6 lean left, houses 7-12 lean right.
    
    Args:
        planet_name: Name of the planet
        house: House number (1-12)
        
    Returns:
        Pan value from -1.0 (left) to 1.0 (right)
    """
    # Map house to pan position
    # Houses 1-6: left to center, Houses 7-12: center to right
    if house <= 6:
        base_pan = -1.0 + (house - 1) * 0.33
    else:
        base_pan = (house - 7) * 0.33
    
    # Add slight variation based on planet for separation
    planet_offset = (hash(planet_name) % 10) / 50.0 - 0.1
    
    return round(max(-1.0, min(1.0, base_pan + planet_offset)), 2)


def calculate_degree_offset(zodiac_degree: float) -> float:
    """
    Calculate frequency offset based on zodiac degree position.
    
    Maps 0-360 degrees to ±1.5 Hz offset using sine wave.
    This creates smooth variation without harsh jumps at sign boundaries,
    making each user's sound signature unique based on exact planetary positions.
    
    Args:
        zodiac_degree: Planet's ecliptic longitude position (0-360)
        
    Returns:
        Frequency offset in Hz (-1.5 to +1.5)
    """
    # Normalize to 0-2π and apply sine for smooth variation
    normalized = (zodiac_degree / 360.0) * 2 * math.pi
    return round(math.sin(normalized) * 1.5, 4)  # ±1.5 Hz range

def calculate_planet_sound(planet_position: dict) -> PlanetSound:
    """
    Calculate audio synthesis parameters for a single planet.
    
    Args:
        planet_position: Planet position data from ephemeris calculation
            Must contain: name, house, house_degree
            
    Returns:
        PlanetSound with all synthesis parameters
    """
    planet_name = planet_position["name"]
    house = planet_position["house"]
    house_degree = planet_position["house_degree"]
    
    # Get base frequency from cosmic octave mapping
    base_frequency = PLANET_FREQUENCIES.get(planet_name, 200.0)
    
    # Apply micro-detuning based on zodiac degree for unique sound signature
    zodiac_degree = planet_position.get("longitude", 0.0)
    frequency_offset = calculate_degree_offset(zodiac_degree)
    frequency = round(base_frequency + frequency_offset, 4)

    
    # Get house timbre parameters
    timbre = HOUSE_TIMBRES.get(house, HOUSE_TIMBRES[1])
    
    # Calculate intensity based on position in house
    intensity = calculate_intensity(house_degree)
    
    # Calculate pan position
    pan = calculate_pan_position(planet_name, house)
    
    # Get planet's role for synthesis behavior
    role = PLANET_ROLES.get(planet_name, "harmonic")
    
    return PlanetSound(
        planet=planet_name,
        frequency=frequency,
        intensity=intensity,
        role=role,
        filter_type=timbre.filter_type,
        filter_cutoff=timbre.filter_cutoff,
        attack=timbre.attack,
        decay=timbre.decay,
        reverb=timbre.reverb,
        pan=pan,
        house=house,
        house_degree=round(house_degree, 2),
        sign=planet_position.get("sign", "Unknown"),
    )


def calculate_chart_sonification(chart_data: dict) -> ChartSonification:
    """
    Calculate complete sonification for a natal chart.
    
    Args:
        chart_data: Chart data from ephemeris calculation
            Must contain: planets (list), ascendant_sign
            
    Returns:
        ChartSonification with all planet sounds and metadata
    """
    planet_sounds = []
    
    for planet in chart_data["planets"]:
        sound = calculate_planet_sound(planet)
        planet_sounds.append(sound)
    
    # Determine dominant frequency (highest intensity planet)
    if planet_sounds:
        dominant = max(planet_sounds, key=lambda p: p.intensity)
        dominant_frequency = dominant.frequency
    else:
        dominant_frequency = 126.22  # Default to Sun
    
    # Calculate suggested duration based on number of prominent planets
    prominent_count = sum(1 for p in planet_sounds if p.intensity > 0.5)
    total_duration = 10.0 + (prominent_count * 2.0)  # 10-30 seconds
    
    return ChartSonification(
        planets=planet_sounds,
        ascendant_sign=chart_data.get("ascendant_sign", "Unknown"),
        dominant_frequency=dominant_frequency,
        total_duration=total_duration,
    )


def calculate_user_sonification(
    birth_datetime: datetime,
    latitude: float,
    longitude: float
) -> ChartSonification:
    """
    Calculate sonification for a user's birth chart.
    
    Args:
        birth_datetime: User's birth date and time
        latitude: Birth location latitude
        longitude: Birth location longitude
        
    Returns:
        ChartSonification for the user's natal chart
    """
    chart_data = calculate_natal_chart(birth_datetime, latitude, longitude)
    return calculate_chart_sonification(chart_data)


def calculate_daily_sonification(
    latitude: float = 0.0,
    longitude: float = 0.0,
    target_datetime: Optional[datetime] = None
) -> ChartSonification:
    """
    Calculate sonification for current planetary transits.
    
    Creates a "daily sound" based on where planets are in the sky
    right now, calculated for a given location.
    
    Args:
        latitude: Observer location latitude (default: 0, equator)
        longitude: Observer location longitude (default: 0, prime meridian)
        target_datetime: Datetime for transits (default: now)
        
    Returns:
        ChartSonification for current transits
    """
    if target_datetime is None:
        target_datetime = datetime.utcnow()
    
    chart_data = calculate_natal_chart(target_datetime, latitude, longitude)
    return calculate_chart_sonification(chart_data)
