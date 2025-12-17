"""
Constants for Astro.FM playlist matching system.
Defines genres, moods, elements, planets, modalities, and time of day.

S2: Documentation Rule - All constants include clear descriptions.
"""
from typing import Dict, List

# =============================================================================
# GENRES (30 total)
# =============================================================================

GENRES: List[str] = [
    # Electronic (8)
    "Ambient",
    "Deep House",
    "Techno",
    "Trance",
    "Synthwave",
    "Downtempo",
    "Drum & Bass",
    "IDM",
    # Contemporary (7)
    "Pop",
    "Indie Pop",
    "Alternative",
    "R&B",
    "Neo-Soul",
    "Hip Hop",
    "Lo-fi Hip Hop",
    # Rock & Adjacent (5)
    "Rock",
    "Indie Rock",
    "Post-Rock",
    "Shoegaze",
    "Metal",
    # Acoustic & Classical (5)
    "Classical",
    "Jazz",
    "Folk",
    "Acoustic",
    "Singer-Songwriter",
    # World & Spiritual (5)
    "World Music",
    "New Age",
    "Meditation",
    "Afrobeat",
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
