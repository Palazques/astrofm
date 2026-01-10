"""
Sound Recommendation schemas for the Cosmic Sound Prescription feature.

These models define the response structure for personalized sound recommendations
based on natal chart gaps and resonances.
"""
from typing import Optional
from pydantic import BaseModel


class AspectBlend(BaseModel):
    """Frequency blend from an aspect between planets."""
    planets: str  # e.g., "Sun-Venus"
    aspect: str   # e.g., "trine"
    frequency: float
    effect: str   # e.g., "shimmer", "tension"


class SoundRecommendation(BaseModel):
    """A single sound recommendation for a life area."""
    planet: str           # e.g., "Venus"
    life_area: str        # e.g., "Partnerships"
    life_area_key: str    # e.g., "partnerships" (for filtering)
    house: int            # House number (1-12)
    sign: str             # Zodiac sign
    status: str           # "gap" or "resonance"
    explanation: str      # Why user should listen to this sound
    frequency: float      # Primary planetary frequency in Hz
    aspect_blends: list[AspectBlend] = []  # Related aspect frequencies
    intensity_gap: float  # Gap value (-1 to 1)
    priority: int = 0     # Priority order (1 = highest)


class SoundRecommendationsResponse(BaseModel):
    """Complete response with all sound recommendations."""
    primary_recommendation: Optional[SoundRecommendation] = None
    all_recommendations: list[SoundRecommendation]
    gaps: list[SoundRecommendation]
    resonances: list[SoundRecommendation]
    gaps_count: int
    resonances_count: int
    alignment_score: int


# Life area key mappings for filtering
LIFE_AREA_KEYS = {
    1: "self_expression",
    2: "resources_values",
    3: "communication",
    4: "home_foundations",
    5: "creativity_joy",
    6: "health_service",
    7: "partnerships",
    8: "transformation",
    9: "expansion_beliefs",
    10: "career_purpose",
    11: "community_hopes",
    12: "spirituality_release",
}

LIFE_AREA_LABELS = {
    1: "Self-Expression",
    2: "Resources & Values",
    3: "Communication",
    4: "Home & Foundations",
    5: "Creativity & Joy",
    6: "Health & Service",
    7: "Partnerships",
    8: "Transformation",
    9: "Expansion & Beliefs",
    10: "Career & Purpose",
    11: "Community & Hopes",
    12: "Spirituality & Release",
}
