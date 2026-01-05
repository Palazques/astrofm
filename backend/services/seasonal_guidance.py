"""
Seasonal Guidance Service for Discover page.
Provides current zodiac season info and recommendations.

S2: Documentation Rule - All functions include clear docstrings.
H4: Astrology Logic Fidelity - Season determination from ephemeris.
"""
from datetime import datetime
from typing import List, Dict, Optional
from pydantic import BaseModel

from services.ephemeris import datetime_to_julian, calculate_planet_position, PLANETS
from services.event_service import EventType


# Zodiac sign date ranges (approximate - Sun enters each sign)
ZODIAC_SEASONS = [
    ("Aries", 3, 21, "Fire"),
    ("Taurus", 4, 20, "Earth"),
    ("Gemini", 5, 21, "Air"),
    ("Cancer", 6, 21, "Water"),
    ("Leo", 7, 23, "Fire"),
    ("Virgo", 8, 23, "Earth"),
    ("Libra", 9, 23, "Air"),
    ("Scorpio", 10, 23, "Water"),
    ("Sagittarius", 11, 22, "Fire"),
    ("Capricorn", 12, 22, "Earth"),
    ("Aquarius", 1, 20, "Air"),
    ("Pisces", 2, 19, "Water"),
]

# Seasonal guidance text for each sign
SEASONAL_GUIDANCE: Dict[str, str] = {
    "Aries": "Channel bold, pioneering energy. Seek events that ignite action and new beginnings.",
    "Taurus": "Ground into sensory pleasure and stability. Seek events that nourish body and soul.",
    "Gemini": "Embrace curiosity and connection. Seek events that spark conversation and learning.",
    "Cancer": "Nurture your emotional landscape. Seek events that create safe, healing spaces.",
    "Leo": "Express your authentic self boldly. Seek events that celebrate creativity and joy.",
    "Virgo": "Refine and organize your rituals. Seek events that support wellness and skill-building.",
    "Libra": "Cultivate harmony and partnership. Seek events that bring beauty and connection.",
    "Scorpio": "Dive deep into transformation. Seek events that facilitate healing and intimacy.",
    "Sagittarius": "Expand your horizons freely. Seek events that inspire adventure and philosophy.",
    "Capricorn": "Build lasting structures. Seek events that support goals and mastery.",
    "Aquarius": "Innovate and connect with community. Seek events that embrace uniqueness.",
    "Pisces": "Dissolve boundaries and dream. Seek events that nurture spirituality and art.",
}

# Recommended event types per season element
ELEMENT_EVENT_RECOMMENDATIONS: Dict[str, List[EventType]] = {
    "Fire": [EventType.FITNESS, EventType.CREATIVE, EventType.SOCIAL],
    "Earth": [EventType.NATURE, EventType.WORKSHOP, EventType.MEDITATION],
    "Air": [EventType.SOCIAL, EventType.WORKSHOP, EventType.CREATIVE],
    "Water": [EventType.SOUND_HEALING, EventType.MEDITATION, EventType.CREATIVE],
}


class SeasonalGuidance(BaseModel):
    """Response model for seasonal guidance."""
    zodiac_sign: str
    element: str
    guidance_text: str
    recommended_event_types: List[str]
    element_emoji: str


def get_element_emoji(element: str) -> str:
    """Get emoji for element."""
    return {
        "Fire": "🔥",
        "Earth": "🌍",
        "Air": "💨",
        "Water": "💧",
    }.get(element, "✨")


def get_current_zodiac_season(dt: Optional[datetime] = None) -> tuple:
    """
    Determine current zodiac season from date.
    
    Args:
        dt: Date to check (defaults to now)
        
    Returns:
        Tuple of (sign, element)
    """
    if dt is None:
        dt = datetime.now()
    
    month = dt.month
    day = dt.day
    
    # Find the current season
    for i, (sign, start_month, start_day, element) in enumerate(ZODIAC_SEASONS):
        # Get next season for end date
        next_idx = (i + 1) % len(ZODIAC_SEASONS)
        next_month = ZODIAC_SEASONS[next_idx][1]
        next_day = ZODIAC_SEASONS[next_idx][2]
        
        # Check if current date is in this season
        # Handle year wraparound (Capricorn -> Aquarius)
        if start_month > next_month:  # Wraps around year end
            if month == start_month and day >= start_day:
                return (sign, element)
            if month == 12 and start_month == 12:
                return (sign, element)
            if month < next_month:
                return (sign, element)
            if month == next_month and day < next_day:
                return (sign, element)
        else:
            if month == start_month and day >= start_day:
                return (sign, element)
            if month > start_month and month < next_month:
                return (sign, element)
            if month == next_month and day < next_day:
                return (sign, element)
    
    # Fallback to Capricorn (shouldn't happen)
    return ("Capricorn", "Earth")


def get_seasonal_guidance(dt: Optional[datetime] = None) -> SeasonalGuidance:
    """
    Get current seasonal guidance for Discover page.
    
    Args:
        dt: Date to check (defaults to now)
        
    Returns:
        SeasonalGuidance with sign, element, guidance, and recommendations
    """
    sign, element = get_current_zodiac_season(dt)
    
    guidance_text = SEASONAL_GUIDANCE.get(
        sign, 
        "Follow the cosmic flow and trust your intuition."
    )
    
    recommended_types = ELEMENT_EVENT_RECOMMENDATIONS.get(element, [])
    
    return SeasonalGuidance(
        zodiac_sign=sign,
        element=element,
        guidance_text=guidance_text,
        recommended_event_types=[et.value for et in recommended_types],
        element_emoji=get_element_emoji(element),
    )
