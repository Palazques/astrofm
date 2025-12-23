"""
Constants for Astro.FM playlist matching system.
Defines genres, moods, elements, planets, modalities, and time of day.

S2: Documentation Rule - All constants include clear descriptions.
"""
from typing import Dict, List

# =============================================================================
# GENRES (24 total - Restructured)
# =============================================================================

GENRES: List[str] = [
    # Pop/Contemporary (4)
    "Pop",
    "K-Pop",
    "J-Pop",
    "Disco",
    # Rock & Adjacent (4)
    "Rock",
    "Indie",
    "Metal",
    "Punk",
    # Electronic (1 - includes Trance, House, Techno as subgenres)
    "Electronic",
    # Hip Hop & Soul (3)
    "Hip Hop / R&B",
    "Soul",
    "Funk",
    # Classical & Jazz (2)
    "Classical",
    "Jazz",
    # Acoustic & Folk (2)
    "Folk",
    "Country",
    # World Music & Latin (4)
    "Latin",
    "World Music",
    "Reggae",
    "Afrobeats",
    # Blues (1)
    "Blues",
    # Spiritual & Soundtrack (3)
    "New Age",
    "Religious",
    "Soundtrack",
]

# =============================================================================
# MOODS (25 total)
# =============================================================================

MOODS: List[str] = [
    # High Energy (5)
    "Energizing",
    "Euphoric",
    "Aggressive",
    "Empowering",
    "Playful",
    # Low Energy (5)
    "Peaceful",
    "Melancholic",
    "Dreamy",
    "Contemplative",
    "Lonely",
    # Emotional Tone (5)
    "Romantic",
    "Sensual",
    "Nostalgic",
    "Hopeful",
    "Bittersweet",
    # Atmospheric (5)
    "Mysterious",
    "Hypnotic",
    "Ethereal",
    "Dark",
    "Uplifting",
    # Mental State (5)
    "Focused",
    "Anxious",
    "Healing",
    "Rebellious",
    "Transcendent",
]

# =============================================================================
# ELEMENTS (4)
# =============================================================================

ELEMENTS: Dict[str, str] = {
    "Fire": "Passionate, action-oriented, bold",
    "Earth": "Grounded, stable, sensual",
    "Air": "Intellectual, communicative, light",
    "Water": "Emotional, intuitive, deep",
}

# =============================================================================
# PLANETS (10)
# =============================================================================

PLANETS: Dict[str, str] = {
    "Sun": "Identity, vitality, confidence",
    "Moon": "Emotions, intuition, comfort",
    "Mercury": "Communication, thought, learning",
    "Venus": "Love, beauty, pleasure",
    "Mars": "Drive, action, passion",
    "Jupiter": "Expansion, optimism, abundance",
    "Saturn": "Structure, discipline, lessons",
    "Uranus": "Innovation, disruption, freedom",
    "Neptune": "Dreams, spirituality, transcendence",
    "Pluto": "Transformation, intensity, power",
}

# =============================================================================
# MODALITIES (3)
# =============================================================================

MODALITIES: Dict[str, str] = {
    "Cardinal": "Initiating, leadership, action",
    "Fixed": "Stable, persistent, determined",
    "Mutable": "Adaptable, flexible, changeable",
}

# =============================================================================
# TIME OF DAY (4)
# =============================================================================

TIME_OF_DAY: List[str] = [
    "morning",
    "afternoon",
    "evening",
    "night",
]
