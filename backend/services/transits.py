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


def get_detailed_transit_summary() -> dict:
    """
    Get rich transit data for AI horoscope generation.
    Includes planet-to-planet aspects, moon phase details, and dominant element.
    
    Returns:
        Dictionary with detailed transit data for AI prompt
    """
    import swisseph as swe
    from datetime import timedelta
    
    now = datetime.now(timezone.utc)
    julian_day = datetime_to_julian(now)
    
    # Get all planet positions
    planets_data = {}
    for name, planet_id in PLANETS.items():
        result, _ = swe.calc_ut(julian_day, planet_id)
        planets_data[name] = {
            "longitude": result[0],
            "speed": result[3],
            "sign": get_zodiac_sign(result[0])[0],
            "degree": get_zodiac_sign(result[0])[1],
            "retrograde": result[3] < 0
        }
    
    # Calculate Moon phase
    sun_lon = planets_data["Sun"]["longitude"]
    moon_lon = planets_data["Moon"]["longitude"]
    moon_angle = (moon_lon - sun_lon) % 360
    moon_phase_percent = round((moon_angle / 360) * 100)
    
    # Moon phase names
    if moon_angle < 45:
        moon_phase = "New Moon"
    elif moon_angle < 90:
        moon_phase = "Waxing Crescent"
    elif moon_angle < 135:
        moon_phase = "First Quarter"
    elif moon_angle < 180:
        moon_phase = "Waxing Gibbous"
    elif moon_angle < 225:
        moon_phase = "Full Moon"
    elif moon_angle < 270:
        moon_phase = "Waning Gibbous"
    elif moon_angle < 315:
        moon_phase = "Third Quarter"
    else:
        moon_phase = "Waning Crescent"
    
    # Calculate major aspects between transiting planets
    major_aspects = []
    aspect_angles = [
        (0, "Conjunction", 8),
        (60, "Sextile", 6),
        (90, "Square", 8),
        (120, "Trine", 8),
        (180, "Opposition", 8),
    ]
    
    # Check aspects between key planet pairs
    planet_pairs = [
        ("Sun", "Moon"),
        ("Venus", "Mars"),
        ("Mercury", "Venus"),
        ("Sun", "Venus"),
        ("Moon", "Venus"),
        ("Mars", "Saturn"),
        ("Jupiter", "Saturn"),
        ("Sun", "Mars"),
        ("Moon", "Mars"),
        ("Mercury", "Mars"),
    ]
    
    for p1, p2 in planet_pairs:
        if p1 in planets_data and p2 in planets_data:
            lon1 = planets_data[p1]["longitude"]
            lon2 = planets_data[p2]["longitude"]
            diff = abs(lon1 - lon2)
            if diff > 180:
                diff = 360 - diff
            
            for angle, aspect_name, orb in aspect_angles:
                if abs(diff - angle) <= orb:
                    major_aspects.append({
                        "planets": f"{p1}-{p2}",
                        "aspect": aspect_name,
                        "orb": round(abs(diff - angle), 1),
                        "nature": "harmonious" if aspect_name in ["Trine", "Sextile"] else 
                                  "challenging" if aspect_name in ["Square", "Opposition"] else "neutral"
                    })
                    break
    
    # Sort by tightest orb (most exact)
    major_aspects.sort(key=lambda x: x["orb"])
    
    # Calculate dominant element
    element_map = {
        "Aries": "Fire", "Leo": "Fire", "Sagittarius": "Fire",
        "Taurus": "Earth", "Virgo": "Earth", "Capricorn": "Earth",
        "Gemini": "Air", "Libra": "Air", "Aquarius": "Air",
        "Cancer": "Water", "Scorpio": "Water", "Pisces": "Water",
    }
    
    element_counts = {"Fire": 0, "Earth": 0, "Air": 0, "Water": 0}
    for name, data in planets_data.items():
        element = element_map.get(data["sign"], "Unknown")
        if element in element_counts:
            element_counts[element] += 1
    
    dominant_element = max(element_counts, key=element_counts.get)
    
    # Determine day energy based on aspects and moon phase
    harmonious_count = sum(1 for a in major_aspects if a["nature"] == "harmonious")
    challenging_count = sum(1 for a in major_aspects if a["nature"] == "challenging")
    
    if moon_phase in ["New Moon", "Full Moon"]:
        day_energy = "Powerful"
    elif harmonious_count > challenging_count + 1:
        day_energy = "Flowing"
    elif challenging_count > harmonious_count + 1:
        day_energy = "Intense"
    elif dominant_element == "Fire":
        day_energy = "Dynamic"
    elif dominant_element == "Earth":
        day_energy = "Grounding"
    elif dominant_element == "Air":
        day_energy = "Stimulating"
    else:
        day_energy = "Intuitive"
    
    # Get retrograde planets
    retrograde_planets = [name for name, data in planets_data.items() if data["retrograde"]]
    
    # Build cosmic weather string
    retro_text = f"{', '.join(retrograde_planets)} retrograde" if retrograde_planets else "No retrogrades"
    aspects_text = "; ".join([f"{a['planets']} {a['aspect']}" for a in major_aspects[:3]]) if major_aspects else "No major aspects"
    
    cosmic_weather = f"{moon_phase} Moon in {planets_data['Moon']['sign']} ({moon_phase_percent}%). {retro_text}. Key aspects: {aspects_text}."
    
    return {
        "date": now.strftime("%Y-%m-%d"),
        "sun_sign": planets_data["Sun"]["sign"],
        "moon_sign": planets_data["Moon"]["sign"],
        "moon_phase": moon_phase,
        "moon_phase_percent": moon_phase_percent,
        "retrograde_planets": retrograde_planets,
        "major_aspects": major_aspects[:5],  # Top 5 tightest aspects
        "dominant_element": dominant_element,
        "element_counts": element_counts,
        "day_energy": day_energy,
        "cosmic_weather": cosmic_weather,
        "planets": planets_data,
    }
