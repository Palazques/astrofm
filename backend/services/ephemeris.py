"""
Swiss Ephemeris wrapper service.
Implements astrological calculations per astrology_vibe_logic.md.

Uses Whole Sign House system as specified in documentation.
"""
import swisseph as swe
from datetime import datetime
from typing import Optional
import os

# Zodiac signs in order
ZODIAC_SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", 
    "Leo", "Virgo", "Libra", "Scorpio",
    "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

# Planet constants with their Swiss Ephemeris IDs
PLANETS = {
    "Sun": swe.SUN,
    "Moon": swe.MOON,
    "Mercury": swe.MERCURY,
    "Venus": swe.VENUS,
    "Mars": swe.MARS,
    "Jupiter": swe.JUPITER,
    "Saturn": swe.SATURN,
    "Uranus": swe.URANUS,
    "Neptune": swe.NEPTUNE,
    "Pluto": swe.PLUTO
}


def init_ephemeris(ephe_path: Optional[str] = None) -> bool:
    """
    Initialize Swiss Ephemeris with optional custom path.
    
    Args:
        ephe_path: Optional path to ephemeris files
        
    Returns:
        True if initialization successful
    """
    if ephe_path:
        swe.set_ephe_path(ephe_path)
    return True


def datetime_to_julian(dt: datetime) -> float:
    """
    Convert datetime to Julian Day number.
    
    Args:
        dt: Python datetime object
        
    Returns:
        Julian Day number as float
    """
    return swe.julday(
        dt.year, 
        dt.month, 
        dt.day, 
        dt.hour + dt.minute / 60.0 + dt.second / 3600.0
    )


def get_zodiac_sign(longitude: float) -> tuple[str, float]:
    """
    Get zodiac sign and degree within sign from ecliptic longitude.
    
    Args:
        longitude: Ecliptic longitude (0-360)
        
    Returns:
        Tuple of (sign_name, degree_in_sign)
    """
    sign_index = int(longitude / 30)
    degree_in_sign = longitude % 30
    return ZODIAC_SIGNS[sign_index], degree_in_sign


def calculate_whole_sign_house(planet_longitude: float, ascendant_longitude: float) -> tuple[int, float]:
    """
    Calculate house placement using Whole Sign House system.
    Per astrology_vibe_logic.md: Each house is a full 30 degrees.
    
    Args:
        planet_longitude: Planet's ecliptic longitude
        ascendant_longitude: Ascendant's ecliptic longitude
        
    Returns:
        Tuple of (house_number 1-12, degree_in_house 0-30)
    """
    # Get the sign of the Ascendant (this becomes the 1st house)
    asc_sign_index = int(ascendant_longitude / 30)
    
    # Get the sign of the planet
    planet_sign_index = int(planet_longitude / 30)
    
    # Calculate house (1-12) based on sign distance from Ascendant sign
    house = ((planet_sign_index - asc_sign_index) % 12) + 1
    
    # Degree within the house is the same as degree within the sign
    degree_in_house = planet_longitude % 30
    
    return house, degree_in_house


def calculate_ascendant(julian_day: float, latitude: float, longitude: float) -> float:
    """
    Calculate the Ascendant (rising sign) for given time and location.
    
    Args:
        julian_day: Julian Day number
        latitude: Geographic latitude
        longitude: Geographic longitude
        
    Returns:
        Ascendant ecliptic longitude
    """
    # Calculate houses using Placidus (just to get Ascendant, we use Whole Sign for actual houses)
    cusps, ascmc = swe.houses(julian_day, latitude, longitude, b'P')
    return ascmc[0]  # Ascendant


def calculate_planet_position(
    planet_id: int, 
    julian_day: float, 
    ascendant: float
) -> dict:
    """
    Calculate a single planet's position.
    
    Args:
        planet_id: Swiss Ephemeris planet ID
        julian_day: Julian Day number
        ascendant: Ascendant longitude for house calculation
        
    Returns:
        Dictionary with planet position data
    """
    # Calculate planet position
    result, ret_flag = swe.calc_ut(julian_day, planet_id)
    
    longitude = result[0]
    latitude = result[1]
    distance = result[2]
    speed = result[3]
    
    # Get zodiac sign
    sign, sign_degree = get_zodiac_sign(longitude)
    
    # Calculate house using Whole Sign system
    house, house_degree = calculate_whole_sign_house(longitude, ascendant)
    
    # Check if retrograde (negative speed)
    retrograde = speed < 0
    
    return {
        "longitude": round(longitude, 4),
        "latitude": round(latitude, 4),
        "distance": round(distance, 6),
        "speed": round(speed, 4),
        "sign": sign,
        "sign_degree": round(sign_degree, 2),
        "house": house,
        "house_degree": round(house_degree, 2),
        "retrograde": retrograde
    }


def calculate_natal_chart(
    birth_datetime: datetime,
    latitude: float,
    longitude: float
) -> dict:
    """
    Calculate complete natal chart.
    
    Args:
        birth_datetime: Birth date and time
        latitude: Birth location latitude
        longitude: Birth location longitude
        
    Returns:
        Dictionary with complete chart data
    """
    # Convert to Julian Day
    julian_day = datetime_to_julian(birth_datetime)
    
    # Calculate Ascendant
    ascendant = calculate_ascendant(julian_day, latitude, longitude)
    asc_sign, _ = get_zodiac_sign(ascendant)
    
    # Calculate all planet positions
    planets = []
    for name, planet_id in PLANETS.items():
        position = calculate_planet_position(planet_id, julian_day, ascendant)
        position["name"] = name
        planets.append(position)
    
    # Generate Whole Sign house cusps (each sign = one house, starting from Ascendant sign)
    asc_sign_index = int(ascendant / 30)
    house_cusps = []
    for i in range(12):
        cusp_longitude = ((asc_sign_index + i) % 12) * 30.0
        house_cusps.append(cusp_longitude)
    
    return {
        "ascendant": round(ascendant, 4),
        "ascendant_sign": asc_sign,
        "planets": planets,
        "house_cusps": house_cusps
    }


def check_ephemeris_available() -> bool:
    """
    Check if Swiss Ephemeris is properly initialized.
    
    Returns:
        True if ephemeris is available
    """
    try:
        # Try a simple calculation to verify
        jd = swe.julday(2000, 1, 1, 12.0)
        swe.calc_ut(jd, swe.SUN)
        return True
    except Exception as e:
        print(f"[WARN] Ephemeris check failed: {e}")
        return False
