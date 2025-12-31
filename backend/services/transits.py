"""
Transit calculations for current planetary positions.
Uses Swiss Ephemeris to get today's planetary transits.
"""
from datetime import datetime, timezone
from typing import Optional

from services.ephemeris import (
    calculate_natal_chart,
    datetime_to_julian,
    calculate_planet_position,
    calculate_ascendant,
    PLANETS,
    ZODIAC_SIGNS,
    get_zodiac_sign,
)


def get_current_transits(latitude: float = 0.0, longitude: float = 0.0) -> dict:
    """
    Get current planetary positions (transits) for the current moment.
    
    Args:
        latitude: Observer latitude (default: 0.0 for general transits)
        longitude: Observer longitude (default: 0.0 for general transits)
        
    Returns:
        Dictionary with current transit data
    """
    now = datetime.now(timezone.utc)
    return calculate_natal_chart(now, latitude, longitude)


def get_current_moon_sign() -> tuple[str, float]:
    """
    Get the current Moon sign and degree.
    
    Returns:
        Tuple of (sign_name, degree_in_sign)
    """
    now = datetime.now(timezone.utc)
    julian_day = datetime_to_julian(now)
    
    # Calculate Moon position (we just need longitude)
    import swisseph as swe
    result, _ = swe.calc_ut(julian_day, swe.MOON)
    moon_longitude = result[0]
    
    return get_zodiac_sign(moon_longitude)


def get_retrograde_period(planet_name: str) -> dict:
    """
    Calculate retrograde period for a planet if it's currently retrograde.
    Searches backwards/forwards from current date to find start/end.
    
    Args:
        planet_name: Name of the planet (e.g., "Mercury", "Mars")
        
    Returns:
        Dictionary with retrograde_start and retrograde_end ISO date strings,
        or empty dict if planet is not retrograde
    """
    import swisseph as swe
    from datetime import timedelta
    
    planet_ids = {
        "Mercury": swe.MERCURY,
        "Venus": swe.VENUS,
        "Mars": swe.MARS,
        "Jupiter": swe.JUPITER,
        "Saturn": swe.SATURN,
        "Uranus": swe.URANUS,
        "Neptune": swe.NEPTUNE,
        "Pluto": swe.PLUTO,
    }
    
    if planet_name not in planet_ids:
        return {}
    
    planet_id = planet_ids[planet_name]
    now = datetime.now(timezone.utc)
    jd_now = datetime_to_julian(now)
    
    # Check current retrograde status
    result, _ = swe.calc_ut(jd_now, planet_id)
    current_speed = result[3]
    
    if current_speed >= 0:
        # Not retrograde
        return {}
    
    # Search backwards for retrograde start (when speed went negative)
    retrograde_start = None
    for days_back in range(1, 120):
        check_date = now - timedelta(days=days_back)
        jd_check = datetime_to_julian(check_date)
        result, _ = swe.calc_ut(jd_check, planet_id)
        if result[3] >= 0:
            # Found the day before retrograde started
            retrograde_start = (now - timedelta(days=days_back - 1)).strftime("%Y-%m-%d")
            break
    
    # Search forwards for retrograde end (when speed goes positive)
    retrograde_end = None
    for days_forward in range(1, 120):
        check_date = now + timedelta(days=days_forward)
        jd_check = datetime_to_julian(check_date)
        result, _ = swe.calc_ut(jd_check, planet_id)
        if result[3] >= 0:
            # Found the day retrograde ends
            retrograde_end = check_date.strftime("%Y-%m-%d")
            break
    
    return {
        "retrograde_start": retrograde_start,
        "retrograde_end": retrograde_end
    }


def get_transit_summary() -> dict:
    """
    Get a summary of current transits for AI context.
    
    Returns:
        Dictionary with transit summary data
    """
    transits = get_current_transits()
    moon_sign, moon_degree = get_current_moon_sign()
    
    # Find Sun sign for current season
    sun_planet = next((p for p in transits["planets"] if p["name"] == "Sun"), None)
    sun_sign = sun_planet["sign"] if sun_planet else "Unknown"
    
    # Check for retrograde planets
    retrograde_planets = [p["name"] for p in transits["planets"] if p.get("retrograde", False)]
    
    return {
        "current_date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "moon_sign": moon_sign,
        "moon_degree": round(moon_degree, 1),
        "sun_sign": sun_sign,
        "season": f"{sun_sign} Season",
        "retrograde_planets": retrograde_planets,
        "planets": transits["planets"],
    }
