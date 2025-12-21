"""
Attunement calculation service.
Compares natal chart sonification to daily transit sonification to identify
gaps (what the day demands but user lacks) and resonances (natural alignment).

Uses intensity values from sonification service combined with house context
to provide actionable attunement recommendations.
"""
from datetime import datetime, timezone
from typing import Optional

from models.attunement_schemas import (
    PlanetAttunement,
    AttunementAnalysis,
    WeeklyDigest,
)
from services.sonification import (
    calculate_user_sonification,
    calculate_daily_sonification,
    PLANET_FREQUENCIES,
)
from services.alignment import get_current_transits, detect_aspect, MAJOR_ORB


# Personal planets - checked daily with standard threshold
PERSONAL_PLANETS = ["Sun", "Moon", "Mercury", "Venus", "Mars"]

# Outer planets - only flagged on exact aspects (within 1°)
OUTER_PLANETS = ["Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]

# Gap threshold: transit intensity must exceed natal by this much
GAP_THRESHOLD = 0.40  # 40%

# Resonance threshold: intensities within this range are considered matched
RESONANCE_THRESHOLD = 0.20  # 20%

# Outer planet aspect orb - tighter than normal
OUTER_PLANET_EXACT_ORB = 1.0  # 1 degree

# Alignment score thresholds
LOW_ALIGNMENT_THRESHOLD = 40  # Below this triggers notification
MAX_GAPS_PER_DAY = 2  # Limit gaps to keep it focused

# Planet energy descriptions for explanations
PLANET_ENERGIES = {
    "Sun": "vitality and self-expression",
    "Moon": "emotional attunement and intuition",
    "Mercury": "communication and mental clarity",
    "Venus": "harmony and connection",
    "Mars": "action and drive",
    "Jupiter": "expansion and optimism",
    "Saturn": "discipline and structure",
    "Uranus": "innovation and change",
    "Neptune": "spirituality and imagination",
    "Pluto": "transformation and depth",
}

# House life areas for context
HOUSE_AREAS = {
    1: "self-expression",
    2: "resources and values",
    3: "communication",
    4: "home and foundations",
    5: "creativity and joy",
    6: "health and service",
    7: "partnerships",
    8: "transformation",
    9: "expansion and beliefs",
    10: "career and purpose",
    11: "community and hopes",
    12: "spirituality and release",
}


def _is_outer_planet_active(
    planet_name: str,
    natal_longitude: float,
    transit_longitude: float
) -> bool:
    """
    Check if an outer planet should be flagged.
    Only returns True if making an exact aspect (within 1°) to natal position.
    
    Args:
        planet_name: Name of the planet
        natal_longitude: Natal planet longitude
        transit_longitude: Transit planet longitude
        
    Returns:
        True if outer planet is making exact aspect
    """
    if planet_name not in OUTER_PLANETS:
        return True  # Personal planets are always active
    
    # Check for exact conjunction with natal position
    aspect = detect_aspect(
        natal_longitude,
        transit_longitude,
        f"Natal {planet_name}",
        f"Transit {planet_name}"
    )
    
    if aspect and aspect["orb"] <= OUTER_PLANET_EXACT_ORB:
        return True
    
    return False


def _calculate_intensity_gap(
    natal_intensity: float,
    transit_intensity: float
) -> float:
    """
    Calculate the intensity gap between transit and natal.
    
    Positive = transit is stronger (user needs to attune)
    Negative = natal is stronger (user can amplify)
    
    Args:
        natal_intensity: Natal intensity (0-1)
        transit_intensity: Transit intensity (0-1)
        
    Returns:
        Gap value (-1 to 1)
    """
    return transit_intensity - natal_intensity


def _determine_status(
    gap: float,
    natal_house: int,
    transit_house: int
) -> str:
    """
    Determine if planet is a gap, resonance, or neutral.
    
    Gap: Transit significantly stronger AND different house context
    Resonance: Intensities match AND same/compatible house
    Neutral: Everything else
    
    Args:
        gap: Intensity gap value
        natal_house: Natal house placement
        transit_house: Transit house placement
        
    Returns:
        Status string: "gap", "resonance", or "neutral"
    """
    same_house = natal_house == transit_house
    compatible_house = abs(natal_house - transit_house) in [0, 4, 8]  # Trine houses
    
    # Gap: transit much stronger + different context
    if gap >= GAP_THRESHOLD and not same_house:
        return "gap"
    
    # Resonance: intensities close + same/compatible context
    if abs(gap) <= RESONANCE_THRESHOLD and (same_house or compatible_house):
        return "resonance"
    
    return "neutral"


def _generate_explanation(
    planet_name: str,
    status: str,
    natal_intensity: float,
    transit_intensity: float,
    natal_house: int,
    transit_house: int
) -> str:
    """
    Generate a brief explanation for why this planet needs attention.
    
    Args:
        planet_name: Name of the planet
        status: "gap", "resonance", or "neutral"
        natal_intensity: Natal intensity value
        transit_intensity: Transit intensity value
        natal_house: Natal house placement
        transit_house: Transit house placement
        
    Returns:
        Brief explanation string
    """
    energy = PLANET_ENERGIES.get(planet_name, "energy")
    natal_area = HOUSE_AREAS.get(natal_house, "life")
    transit_area = HOUSE_AREAS.get(transit_house, "life")
    
    if status == "gap":
        return (
            f"Today emphasizes {energy} in {transit_area}, "
            f"but your natal {planet_name} focuses on {natal_area}. "
            f"Attune to bridge this gap."
        )
    elif status == "resonance":
        return (
            f"Your natural {energy} aligns perfectly with today's cosmic weather. "
            f"Amplify to maximize this strength."
        )
    else:
        return f"Your {planet_name} is balanced with today's energy."


def calculate_attunement(
    birth_datetime: datetime,
    latitude: float,
    longitude: float,
    transit_datetime: Optional[datetime] = None
) -> AttunementAnalysis:
    """
    Calculate full attunement analysis comparing natal to daily transits.
    
    Args:
        birth_datetime: User's birth datetime
        latitude: Birth location latitude
        longitude: Birth location longitude
        transit_datetime: Optional datetime for transits (defaults to now)
        
    Returns:
        AttunementAnalysis with gaps, resonances, and recommendations
    """
    # Get natal sonification
    natal_sonification = calculate_user_sonification(
        birth_datetime=birth_datetime,
        latitude=latitude,
        longitude=longitude
    )
    
    # Get transit sonification
    transit_sonification = calculate_daily_sonification(
        latitude=latitude,
        longitude=longitude,
        target_datetime=transit_datetime
    )
    
    # Get raw transit positions for outer planet aspect checking
    transits = get_current_transits(transit_datetime)
    transit_longitudes = {t["name"]: t["longitude"] for t in transits}
    
    # Build planet comparisons
    all_planets: list[PlanetAttunement] = []
    
    for natal_planet in natal_sonification.planets:
        planet_name = natal_planet.planet
        
        # Find matching transit planet
        transit_planet = next(
            (p for p in transit_sonification.planets if p.planet == planet_name),
            None
        )
        
        if not transit_planet:
            continue
        
        # Check if outer planet should be considered
        # For outer planets, only flag if making exact aspect
        natal_lon = transit_longitudes.get(planet_name, 0)  # Approximate
        transit_lon = transit_longitudes.get(planet_name, 0)
        
        if planet_name in OUTER_PLANETS:
            if not _is_outer_planet_active(planet_name, natal_lon, transit_lon):
                # Skip this outer planet - not making exact aspect
                continue
        
        # Calculate gap
        gap = _calculate_intensity_gap(
            natal_planet.intensity,
            transit_planet.intensity
        )
        
        # Determine status
        status = _determine_status(
            gap,
            natal_planet.house,
            transit_planet.house
        )
        
        # Generate explanation
        explanation = _generate_explanation(
            planet_name,
            status,
            natal_planet.intensity,
            transit_planet.intensity,
            natal_planet.house,
            transit_planet.house
        )
        
        planet_attunement = PlanetAttunement(
            planet=planet_name,
            natal_intensity=natal_planet.intensity,
            natal_house=natal_planet.house,
            natal_sign=natal_planet.sign,
            natal_frequency=natal_planet.frequency,
            transit_intensity=transit_planet.intensity,
            transit_house=transit_planet.house,
            transit_sign=transit_planet.sign,
            transit_frequency=transit_planet.frequency,
            intensity_gap=round(gap, 3),
            status=status,
            explanation=explanation,
        )
        
        all_planets.append(planet_attunement)
    
    # Extract gaps and resonances
    gaps = [p for p in all_planets if p.status == "gap"]
    resonances = [p for p in all_planets if p.status == "resonance"]
    
    # Sort gaps by intensity gap (most severe first)
    gaps.sort(key=lambda p: p.intensity_gap, reverse=True)
    
    # Limit to MAX_GAPS_PER_DAY
    gaps = gaps[:MAX_GAPS_PER_DAY]
    
    # Assign priorities
    for i, gap in enumerate(gaps):
        gap.priority = i + 1
    
    for i, res in enumerate(resonances):
        res.priority = i + 1
    
    # Calculate alignment score
    # Higher score = better alignment (fewer gaps, more resonances)
    gap_penalty = len([p for p in all_planets if p.status == "gap"]) * 15
    resonance_bonus = len(resonances) * 10
    neutral_base = len([p for p in all_planets if p.status == "neutral"]) * 5
    
    alignment_score = max(0, min(100, 50 + resonance_bonus - gap_penalty + neutral_base))
    
    # Determine if should notify
    should_notify = False
    notification_reason = None
    
    if alignment_score < LOW_ALIGNMENT_THRESHOLD:
        should_notify = True
        notification_reason = "Low cosmic alignment today"
    elif any(g.intensity_gap >= 0.6 for g in gaps):  # Major gap
        should_notify = True
        if gaps:
            notification_reason = f"Significant {gaps[0].planet} transit today"
    
    # Determine dominant gap energy
    dominant_gap_energy = None
    if gaps:
        dominant_gap_energy = PLANET_ENERGIES.get(gaps[0].planet)
    
    # Get analysis date
    analysis_dt = transit_datetime or datetime.now(timezone.utc)
    analysis_date = analysis_dt.strftime("%Y-%m-%d")
    
    return AttunementAnalysis(
        planets=all_planets,
        gaps=gaps,
        resonances=resonances,
        alignment_score=alignment_score,
        should_notify=should_notify,
        notification_reason=notification_reason,
        analysis_date=analysis_date,
        dominant_gap_energy=dominant_gap_energy,
    )


def get_weekly_digest(
    birth_datetime: datetime,
    latitude: float,
    longitude: float,
    week_start: Optional[datetime] = None
) -> WeeklyDigest:
    """
    Generate weekly digest of attunement patterns.
    Analyzes 7 days and summarizes trends.
    
    Args:
        birth_datetime: User's birth datetime
        latitude: Birth location latitude
        longitude: Birth location longitude
        week_start: Start of week (defaults to 7 days ago)
        
    Returns:
        WeeklyDigest with summary statistics
    """
    from datetime import timedelta
    
    if week_start is None:
        week_start = datetime.now(timezone.utc) - timedelta(days=7)
    
    week_end = week_start + timedelta(days=6)
    
    # Calculate attunement for each day
    daily_scores = []
    all_gaps = []
    
    for day_offset in range(7):
        day = week_start + timedelta(days=day_offset)
        analysis = calculate_attunement(
            birth_datetime=birth_datetime,
            latitude=latitude,
            longitude=longitude,
            transit_datetime=day
        )
        
        daily_scores.append({
            "date": day.strftime("%A"),  # Day name
            "score": analysis.alignment_score
        })
        
        for gap in analysis.gaps:
            all_gaps.append(gap.planet)
    
    # Find best and worst days
    sorted_scores = sorted(daily_scores, key=lambda x: x["score"], reverse=True)
    best = sorted_scores[0]
    worst = sorted_scores[-1]
    
    # Count gap frequencies
    gap_counts = {}
    for planet in all_gaps:
        gap_counts[planet] = gap_counts.get(planet, 0) + 1
    
    common_gaps = sorted(gap_counts.keys(), key=lambda k: gap_counts[k], reverse=True)[:3]
    
    # Calculate average
    average = sum(d["score"] for d in daily_scores) // 7
    
    # Generate summary
    if average >= 70:
        summary = "A harmonious week ahead! Your natural frequencies align well with the cosmic weather."
    elif average >= 50:
        summary = "A balanced week with opportunities for growth. Pay attention to your attunement gaps."
    else:
        summary = "A dynamic week that calls for conscious attunement. Use the listening sessions to stay aligned."
    
    return WeeklyDigest(
        week_start=week_start.strftime("%Y-%m-%d"),
        week_end=week_end.strftime("%Y-%m-%d"),
        average_alignment=average,
        best_day=best["date"],
        best_day_score=best["score"],
        challenging_day=worst["date"],
        challenging_day_score=worst["score"],
        common_gaps=common_gaps,
        summary=summary,
    )
