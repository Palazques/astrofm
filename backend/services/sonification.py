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


# =============================================================================
# STEINER ZODIAC TONE CIRCLE CONSTANTS
# New system for Sound Signature generation
# =============================================================================

# Planet Root Notes - Based on Circle of Fifths, derived from ruling sign
# Each planet's root note comes from its domicile sign's position
PLANET_ROOT_NOTES: dict[str, str] = {
    "Sun": "E",       # Rules Leo (E in Circle of Fifths)
    "Moon": "A",      # Rules Cancer (A in Circle of Fifths)
    "Mercury": "D",   # Rules Gemini/Virgo (D in Circle of Fifths)
    "Venus": "Bb",    # Rules Taurus/Libra (Bb in Circle of Fifths)
    "Mars": "C",      # Rules Aries (C in Circle of Fifths)
    "Jupiter": "F#",  # Rules Sagittarius (F# in Circle of Fifths)
    "Saturn": "B",    # Rules Capricorn (B in Circle of Fifths)
    "Uranus": "G#",   # Rules Aquarius (G# in Circle of Fifths)
    "Neptune": "F",   # Rules Pisces (F in Circle of Fifths)
    "Pluto": "C#",    # Rules Scorpio (C# in Circle of Fifths)
}

# Sign Chords - Major triad for each zodiac sign based on Circle of Fifths
# Ordered by position in the Circle of Fifths
SIGN_CHORDS: dict[str, tuple[str, str, str]] = {
    "Aries": ("C", "E", "G"),       # C Major - Cardinal Fire
    "Taurus": ("G", "B", "D"),      # G Major - Fixed Earth
    "Gemini": ("D", "F#", "A"),     # D Major - Mutable Air
    "Cancer": ("A", "C#", "E"),     # A Major - Cardinal Water
    "Leo": ("E", "G#", "B"),        # E Major - Fixed Fire
    "Virgo": ("B", "D#", "F#"),     # B Major - Mutable Earth
    "Libra": ("F#", "A#", "C#"),    # F# Major - Cardinal Air
    "Scorpio": ("C#", "E#", "G#"),  # C# Major - Fixed Water
    "Sagittarius": ("G#", "B#", "D#"),  # G#/Ab Major - Mutable Fire
    "Capricorn": ("Eb", "G", "Bb"), # Eb Major - Cardinal Earth
    "Aquarius": ("Bb", "D", "F"),   # Bb Major - Fixed Air
    "Pisces": ("F", "A", "C"),      # F Major - Mutable Water
}

# Chart Ruler Map - Traditional planetary rulers for each rising sign
CHART_RULER_MAP: dict[str, str] = {
    "Aries": "Mars",
    "Taurus": "Venus",
    "Gemini": "Mercury",
    "Cancer": "Moon",
    "Leo": "Sun",
    "Virgo": "Mercury",
    "Libra": "Venus",
    "Scorpio": "Pluto",      # Modern ruler (traditional: Mars)
    "Sagittarius": "Jupiter",
    "Capricorn": "Saturn",
    "Aquarius": "Uranus",    # Modern ruler (traditional: Saturn)
    "Pisces": "Neptune",     # Modern ruler (traditional: Jupiter)
}

# Aspect Intervals - Musical intervals and sound effects for each aspect type
ASPECT_INTERVALS: dict[str, dict[str, str]] = {
    "conjunction": {"interval": "P1", "effect": "unison", "max_orb": 8.0},
    "sextile": {"interval": "m3", "effect": "shimmer", "max_orb": 6.0},
    "square": {"interval": "TT", "effect": "ring_mod", "max_orb": 8.0},
    "trine": {"interval": "P5", "effect": "chorus", "max_orb": 8.0},
    "opposition": {"interval": "P8", "effect": "phase", "max_orb": 8.0},
}

# Aspect angles for detection
ASPECT_ANGLES: dict[str, float] = {
    "conjunction": 0.0,
    "sextile": 60.0,
    "square": 90.0,
    "trine": 120.0,
    "opposition": 180.0,
}

# Note Frequencies - Equal temperament A4=440Hz, Octave 4
NOTE_FREQUENCIES: dict[str, float] = {
    "C": 261.63,
    "C#": 277.18,
    "Db": 277.18,
    "D": 293.66,
    "D#": 311.13,
    "Eb": 311.13,
    "E": 329.63,
    "E#": 349.23,  # Same as F
    "F": 349.23,
    "F#": 369.99,
    "Gb": 369.99,
    "G": 392.00,
    "G#": 415.30,
    "Ab": 415.30,
    "A": 440.00,
    "A#": 466.16,
    "Bb": 466.16,
    "B": 493.88,
    "B#": 523.25,  # Same as C5
}


# =============================================================================
# STEINER CORE FUNCTIONS
# =============================================================================

def get_chart_ruler(ascendant_sign: str) -> str:
    """
    Get the ruling planet for a given rising sign.
    
    Args:
        ascendant_sign: The ascendant/rising zodiac sign
        
    Returns:
        Name of the ruling planet
    """
    return CHART_RULER_MAP.get(ascendant_sign, "Sun")


def get_big_four(chart_data: dict) -> dict:
    """
    Extract the Big Four from chart data: Sun, Moon, Rising (Ascendant), Chart Ruler.
    
    The Big Four are the most significant points for the Sound Signature:
    - Sun: Core identity and vitality
    - Moon: Emotional nature and instincts
    - Rising: External persona and chart anchor
    - Chart Ruler: Planet that rules the Rising sign
    
    Args:
        chart_data: Chart data containing planets list and ascendant info
        
    Returns:
        Dict with keys: Sun, Moon, Rising, ChartRuler
        Each contains: sign, degree, longitude, house, house_degree
    """
    planets = {p["name"]: p for p in chart_data.get("planets", [])}
    ascendant_sign = chart_data.get("ascendant_sign", "Aries")
    chart_ruler_name = get_chart_ruler(ascendant_sign)
    
    # Find Rising/Ascendant - use Sun's house as placeholder for Rising position
    # In a proper implementation, we'd have the ascendant degree
    ascendant_degree = chart_data.get("ascendant", 0.0)
    
    big_four = {
        "Sun": {
            "sign": planets.get("Sun", {}).get("sign", "Aries"),
            "sign_degree": planets.get("Sun", {}).get("sign_degree", 15.0),
            "longitude": planets.get("Sun", {}).get("longitude", 0.0),
            "house": planets.get("Sun", {}).get("house", 1),
            "house_degree": planets.get("Sun", {}).get("house_degree", 15.0),
        },
        "Moon": {
            "sign": planets.get("Moon", {}).get("sign", "Cancer"),
            "sign_degree": planets.get("Moon", {}).get("sign_degree", 15.0),
            "longitude": planets.get("Moon", {}).get("longitude", 90.0),
            "house": planets.get("Moon", {}).get("house", 4),
            "house_degree": planets.get("Moon", {}).get("house_degree", 15.0),
        },
        "Rising": {
            "sign": ascendant_sign,
            "sign_degree": ascendant_degree % 30,
            "longitude": ascendant_degree,
            "house": 1,  # Rising is always on 1st house cusp
            "house_degree": 0.0,
        },
        "ChartRuler": {
            "planet": chart_ruler_name,
            "sign": planets.get(chart_ruler_name, {}).get("sign", ascendant_sign),
            "sign_degree": planets.get(chart_ruler_name, {}).get("sign_degree", 15.0),
            "longitude": planets.get(chart_ruler_name, {}).get("longitude", 0.0),
            "house": planets.get(chart_ruler_name, {}).get("house", 1),
            "house_degree": planets.get(chart_ruler_name, {}).get("house_degree", 15.0),
        },
    }
    
    return big_four


def note_to_frequency(note: str, octave: int = 4) -> float:
    """
    Convert a note name and octave to frequency in Hz.
    
    Uses equal temperament with A4 = 440Hz.
    
    Args:
        note: Note name (e.g., "C", "F#", "Bb")
        octave: Octave number (3=low, 4=mid, 5=high)
        
    Returns:
        Frequency in Hz
    """
    base_freq = NOTE_FREQUENCIES.get(note, 440.0)  # Default to A if not found
    # Adjust for octave (base is octave 4)
    octave_shift = octave - 4
    return round(base_freq * (2 ** octave_shift), 2)


def collect_notes(big_four: dict) -> list[dict]:
    """
    Collect all notes from the Big Four with their weights.
    
    For each of the Big Four:
    - Adds the planet's root note
    - Adds 3 notes from the sign's chord
    
    Weight is calculated using the bell curve based on house degree.
    
    Args:
        big_four: Dict containing Sun, Moon, Rising, ChartRuler data
        
    Returns:
        List of dicts with: note, weight, source
    """
    notes = []
    
    for point_name, point_data in big_four.items():
        # Get planet name (for ChartRuler, it's stored in 'planet' field)
        if point_name == "ChartRuler":
            planet_name = point_data.get("planet", "Sun")
        elif point_name == "Rising":
            # Rising doesn't have a planet root note, only sign chord
            planet_name = None
        else:
            planet_name = point_name
        
        sign = point_data.get("sign", "Aries")
        house_degree = point_data.get("house_degree", 15.0)
        
        # Calculate weight using bell curve
        weight = calculate_intensity(house_degree)
        
        # Add planet root note (if applicable)
        if planet_name and planet_name in PLANET_ROOT_NOTES:
            root_note = PLANET_ROOT_NOTES[planet_name]
            notes.append({
                "note": root_note,
                "weight": weight,
                "source": point_name,
            })
        
        # Add sign chord notes
        if sign in SIGN_CHORDS:
            chord = SIGN_CHORDS[sign]
            for chord_note in chord:
                notes.append({
                    "note": chord_note,
                    "weight": weight * 0.8,  # Slightly lower weight for chord notes
                    "source": point_name,
                })
    
    return notes


def build_sound_signature(notes: list[dict], count: int = 5) -> list[dict]:
    """
    Build the Sound Signature by selecting the top weighted notes.
    
    Aggregates duplicate notes from different sources, keeping highest weight.
    Returns top 5 (or count) notes spread across octaves.
    
    Args:
        notes: List of note dicts from collect_notes
        count: Number of notes to include (default 5)
        
    Returns:
        List of SoundSignatureNote-compatible dicts
    """
    from models.sonification_schemas import SoundSignatureNote
    
    # Aggregate notes by name, combining sources and keeping max weight
    note_map: dict[str, dict] = {}
    for n in notes:
        note_name = n["note"]
        if note_name in note_map:
            existing = note_map[note_name]
            existing["weight"] = max(existing["weight"], n["weight"])
            if n["source"] not in existing["sources"]:
                existing["sources"].append(n["source"])
        else:
            note_map[note_name] = {
                "note": note_name,
                "weight": n["weight"],
                "sources": [n["source"]],
            }
    
    # Sort by weight descending
    sorted_notes = sorted(note_map.values(), key=lambda x: x["weight"], reverse=True)
    
    # Take top notes
    top_notes = sorted_notes[:count]
    
    # Assign octaves for spread (low, mid-low, mid, mid-high, high)
    octave_spread = [3, 4, 4, 4, 5]
    
    result = []
    for i, note_data in enumerate(top_notes):
        octave = octave_spread[i] if i < len(octave_spread) else 4
        result.append(SoundSignatureNote(
            note=note_data["note"],
            frequency=note_to_frequency(note_data["note"], octave),
            octave=octave,
            weight=round(note_data["weight"], 4),
            sources=note_data["sources"],
        ))
    
    return result


def calculate_orb_intensity(orb: float, max_orb: float) -> float:
    """
    Calculate the intensity of an aspect based on its orb.
    
    Exact aspects (0° orb) have maximum intensity (1.0).
    Intensity fades linearly to 0 at the maximum orb.
    
    Args:
        orb: The actual orb (deviation from exact aspect) in degrees
        max_orb: The maximum allowable orb for this aspect type
        
    Returns:
        Intensity from 0.0 to 1.0
    """
    if orb >= max_orb:
        return 0.0
    return round(1.0 - (orb / max_orb), 4)


def detect_aspects(big_four: dict) -> list:
    """
    Detect aspects between all pairs of Big Four points.
    
    Checks Sun, Moon, Rising, ChartRuler against each other for:
    - Conjunction (0° ±8°)
    - Sextile (60° ±6°)
    - Square (90° ±8°)
    - Trine (120° ±8°)
    - Opposition (180° ±8°)
    
    Args:
        big_four: Dict containing Big Four data with longitudes
        
    Returns:
        List of AspectModulation objects
    """
    from models.sonification_schemas import AspectModulation
    
    aspects = []
    points = list(big_four.keys())
    
    # Check all pairs
    for i, point_a in enumerate(points):
        for point_b in points[i + 1:]:
            long_a = big_four[point_a].get("longitude", 0.0)
            long_b = big_four[point_b].get("longitude", 0.0)
            
            # Calculate angular separation (0-180 range)
            diff = abs(long_a - long_b)
            if diff > 180:
                diff = 360 - diff
            
            # Check each aspect type
            for aspect_name, aspect_angle in ASPECT_ANGLES.items():
                orb = abs(diff - aspect_angle)
                aspect_info = ASPECT_INTERVALS.get(aspect_name, {})
                max_orb = float(aspect_info.get("max_orb", 8.0))
                
                if orb <= max_orb:
                    intensity = calculate_orb_intensity(orb, max_orb)
                    aspects.append(AspectModulation(
                        aspect_type=aspect_name,
                        planet_a=point_a,
                        planet_b=point_b,
                        orb=round(orb, 2),
                        effect=aspect_info.get("effect", "unison"),
                        intensity=intensity,
                    ))
    
    return aspects


def calculate_texture_layer(planets: list, big_four_names: set) -> list:
    """
    Calculate the texture layer from non-Big-Four planets.
    
    Returns root notes for planets not in the Big Four,
    providing subtle background texture.
    
    Args:
        planets: List of all planet position dicts
        big_four_names: Set of planet names in the Big Four
        
    Returns:
        List of TextureNote objects
    """
    from models.sonification_schemas import TextureNote
    
    texture = []
    
    for planet in planets:
        name = planet.get("name", "")
        if name not in big_four_names and name in PLANET_ROOT_NOTES:
            root_note = PLANET_ROOT_NOTES[name]
            texture.append(TextureNote(
                planet=name,
                note=root_note,
                frequency=note_to_frequency(root_note, 3),  # Low octave for texture
            ))
    
    return texture


# =============================================================================
# LEGACY FUNCTIONS (Cosmic Octave method - to be removed after migration)
# =============================================================================

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


def calculate_restored_planets(planets_data: list[dict]) -> list[PlanetSound]:
    """
    Calculate all 10 planets using Steiner tuning (Sign -> Root Note).
    Restores visualization/interaction for non-Big-Four planets.
    """
    restored = []
    
    for p in planets_data:
        name = p["name"]
        sign = p.get("sign", "Aries")
        house = p.get("house", 1)
        # Handle different field names for degree/lon
        house_degree = p.get("house_degree", p.get("degree", 15.0))
        
        # Use Sign's Root Note (Steiner system)
        # Each sign's chord starts with its root note
        sign_root = SIGN_CHORDS.get(sign, ("C", "E", "G"))[0]
        
        # Determine frequency using Steiner-compatible octaves
        octave = 4
        if name in ["Moon", "Mercury", "Venus"]: octave = 5
        elif name in ["Mars", "Sun", "Jupiter"]: octave = 4
        else: octave = 3 # Saturn, Uranus, Neptune, Pluto
        
        freq = note_to_frequency(sign_root, octave)
        
        # Get legacy params for visualization compatibility
        timbre = HOUSE_TIMBRES.get(house, HOUSE_TIMBRES[1])
        role = PLANET_ROLES.get(name, "harmonic")
        intensity = calculate_intensity(house_degree)
        pan = calculate_pan_position(name, house)

        restored.append(PlanetSound(
            planet=name,
            frequency=freq,
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
            sign=sign
        ))
        
    return restored


def calculate_planet_chords(planets_data: list[dict]) -> list:
    """
    Calculate chord-based sounds for all planets using Steiner Zodiac Tone Circle.
    
    Each planet gets its sign's major triad (root, third, fifth).
    Example: Venus in Taurus gets G Major (G, B, D).
    """
    from models.sonification_schemas import PlanetChord
    
    chords = []
    
    for p in planets_data:
        name = p["name"]
        sign = p.get("sign", "Aries")
        house = p.get("house", 1)
        house_degree = p.get("house_degree", p.get("degree", 15.0))
        
        # Get the sign's chord triad from SIGN_CHORDS
        chord_notes = SIGN_CHORDS.get(sign, ("C", "E", "G"))
        root_note, third_note, fifth_note = chord_notes
        
        # Determine octave based on planet type
        octave = 4
        if name in ["Moon", "Mercury", "Venus"]: octave = 5
        elif name in ["Mars", "Sun", "Jupiter"]: octave = 4
        else: octave = 3  # Saturn, Uranus, Neptune, Pluto
        
        # Calculate frequencies for all 3 notes
        root_freq = note_to_frequency(root_note, octave)
        third_freq = note_to_frequency(third_note, octave)
        fifth_freq = note_to_frequency(fifth_note, octave)
        
        # Get audio params
        intensity = calculate_intensity(house_degree)
        pan = calculate_pan_position(name, house)
        
        chords.append(PlanetChord(
            planet=name,
            sign=sign,
            house=house,
            house_degree=round(house_degree, 2),
            root_note=root_note,
            third_note=third_note,
            fifth_note=fifth_note,
            root_frequency=root_freq,
            third_frequency=third_freq,
            fifth_frequency=fifth_freq,
            intensity=intensity,
            pan=pan
        ))
    
    return chords


def calculate_chart_sonification(chart_data: dict) -> ChartSonification:
    """
    Calculate complete sonification for a natal chart using Steiner Tone Circle.
    
    Uses the Big Four (Sun, Moon, Rising, Chart Ruler) to generate a 5-note
    Sound Signature chord with aspect modulations and texture layer.
    
    Args:
        chart_data: Chart data from ephemeris calculation
            Must contain: planets (list), ascendant_sign, ascendant
            
    Returns:
        ChartSonification with Sound Signature, aspects, and texture
    """
    # Step 1: Extract Big Four
    big_four = get_big_four(chart_data)
    ascendant_sign = chart_data.get("ascendant_sign", "Aries")
    chart_ruler = get_chart_ruler(ascendant_sign)
    
    # Step 2: Collect notes from Big Four
    notes = collect_notes(big_four)
    
    # Step 3: Build Sound Signature (top 5 weighted notes)
    sound_signature = build_sound_signature(notes, count=5)
    
    # Step 4: Detect aspects between Big Four
    aspects = detect_aspects(big_four)
    
    # Step 5: Calculate texture layer from other planets
    big_four_planet_names = {"Sun", "Moon", chart_ruler}
    texture_layer = calculate_texture_layer(
        chart_data.get("planets", []), 
        big_four_planet_names
    )
    
    # Step 6: Restore full planet list for visualization (legacy)
    restored_planets = calculate_restored_planets(chart_data.get("planets", []))
    
    # Step 7: Calculate chord-based planet sounds (new Steiner model)
    planet_chords = calculate_planet_chords(chart_data.get("planets", []))
    
    return ChartSonification(
        sound_signature=sound_signature,
        aspects=aspects,
        texture_layer=texture_layer,
        ascendant_sign=ascendant_sign,
        chart_ruler=chart_ruler,
        big_four=big_four,
        planets=restored_planets,
        planet_chords=planet_chords
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
