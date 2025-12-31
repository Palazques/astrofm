"""
Alignment Sound Service.
Compares personal and daily Sound Signatures to create an alignment meditation sound.
"""
from typing import Optional

from models.sonification_schemas import (
    ChartSonification,
    SoundSignatureNote,
    AlignmentAnalysis,
    AlignmentSound,
    AlignmentResponse,
    NotePair,
)
from services.sonification import note_to_frequency, NOTE_FREQUENCIES


# Musical intervals between notes (in semitones)
# Used to determine harmonic vs dissonant relationships
NOTE_ORDER = ["C", "C#", "Db", "D", "D#", "Eb", "E", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B"]

# Normalize note names (handle enharmonic equivalents)
NOTE_NORMALIZE = {
    "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#",
    "E#": "F", "B#": "C",
}

# Interval classifications
CONSONANT_INTERVALS = {0, 3, 4, 5, 7, 8, 9, 12}  # Unison, m3, M3, P4, P5, m6, M6, Octave
DISSONANT_INTERVALS = {1, 2, 6, 10, 11}  # m2, M2, tritone, m7, M7

# Interval names
INTERVAL_NAMES = {
    0: "unison", 1: "minor 2nd", 2: "major 2nd", 3: "minor 3rd",
    4: "major 3rd", 5: "perfect 4th", 6: "tritone", 7: "perfect 5th",
    8: "minor 6th", 9: "major 6th", 10: "minor 7th", 11: "major 7th", 12: "octave"
}


def normalize_note(note: str) -> str:
    """Normalize note name to standard form (sharps preferred)."""
    return NOTE_NORMALIZE.get(note, note)


def get_note_index(note: str) -> int:
    """Get the chromatic index (0-11) of a note."""
    normalized = normalize_note(note)
    # Create a mapping from normalized names to indices
    note_to_index = {
        "C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5,
        "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11
    }
    return note_to_index.get(normalized, 0)


def calculate_interval(note_a: str, note_b: str) -> int:
    """Calculate the interval in semitones between two notes (0-12)."""
    idx_a = get_note_index(note_a)
    idx_b = get_note_index(note_b)
    interval = abs(idx_b - idx_a)
    if interval > 6:
        interval = 12 - interval  # Invert to find smallest interval
    return interval


def get_interval_quality(interval: int) -> str:
    """Determine if an interval is consonant, dissonant, or neutral."""
    if interval in CONSONANT_INTERVALS:
        return "consonant"
    elif interval in DISSONANT_INTERVALS:
        return "dissonant"
    return "neutral"


def compare_signatures(
    personal: ChartSonification, 
    daily: ChartSonification
) -> AlignmentAnalysis:
    """
    Compare personal and daily Sound Signatures.
    
    Identifies:
    - Shared notes (anchor points)
    - Personal-unique notes (your energy)
    - Daily-unique notes (what to attune to)
    - Harmonic pairs (notes that work well together)
    - Tension pairs (notes that clash)
    
    Args:
        personal: User's natal chart Sound Signature
        daily: Today's transit Sound Signature
        
    Returns:
        AlignmentAnalysis with comparison results
    """
    # Extract note names from signatures
    personal_notes = {normalize_note(n.note) for n in personal.sound_signature}
    daily_notes = {normalize_note(n.note) for n in daily.sound_signature}
    
    # Find shared and unique notes
    shared = personal_notes & daily_notes
    personal_unique = personal_notes - daily_notes
    daily_unique = daily_notes - personal_notes
    
    # Analyze intervals between personal-unique and daily-unique notes
    harmonic_pairs = []
    tension_pairs = []
    
    for p_note in personal_unique:
        for d_note in daily_unique:
            interval = calculate_interval(p_note, d_note)
            interval_name = INTERVAL_NAMES.get(interval, f"{interval} semitones")
            quality = get_interval_quality(interval)
            
            pair = NotePair(
                note_a=p_note,
                note_b=d_note,
                interval=interval_name,
                quality=quality
            )
            
            if quality == "consonant":
                harmonic_pairs.append(pair)
            elif quality == "dissonant":
                tension_pairs.append(pair)
    
    # Calculate alignment score
    score = calculate_alignment_score(
        shared_count=len(shared),
        harmonic_count=len(harmonic_pairs),
        tension_count=len(tension_pairs),
        total_notes=len(personal_notes | daily_notes)
    )
    
    return AlignmentAnalysis(
        shared_notes=list(shared),
        personal_unique=list(personal_unique),
        daily_unique=list(daily_unique),
        harmonic_pairs=harmonic_pairs,
        tension_pairs=tension_pairs,
        alignment_score=score
    )


def calculate_alignment_score(
    shared_count: int,
    harmonic_count: int,
    tension_count: int,
    total_notes: int
) -> int:
    """
    Calculate alignment score (0-100).
    
    Scoring:
    - Base: 50 points
    - +10 per shared note (max 50)
    - +5 per harmonic pair
    - -10 per tension pair
    """
    score = 50
    score += min(shared_count * 10, 50)
    score += harmonic_count * 5
    score -= tension_count * 10
    
    return max(0, min(100, score))


def find_bridge_note(tension_pairs: list[NotePair]) -> Optional[str]:
    """
    Find a bridge note that resolves tensions.
    
    Strategy: Find a note that forms consonant intervals with both
    tension notes (usually a perfect 5th from one or the other).
    """
    if not tension_pairs:
        return None
    
    # Get the most dissonant pair (tritone if exists)
    worst_pair = tension_pairs[0]
    for pair in tension_pairs:
        if pair.interval == "tritone":
            worst_pair = pair
            break
    
    # Find a bridge note that's a perfect 5th from one of the notes
    # This typically creates consonance
    idx_a = get_note_index(worst_pair.note_a)
    bridge_idx = (idx_a + 7) % 12  # Perfect 5th up
    
    # Map index back to note name
    index_to_note = {
        0: "C", 1: "C#", 2: "D", 3: "D#", 4: "E", 5: "F",
        6: "F#", 7: "G", 8: "G#", 9: "A", 10: "A#", 11: "B"
    }
    
    return index_to_note.get(bridge_idx, "C")


def generate_alignment_sound(
    analysis: AlignmentAnalysis,
    personal: ChartSonification,
    daily: ChartSonification
) -> AlignmentSound:
    """
    Generate the alignment meditation sound.
    
    Composition:
    - Anchor notes: Shared notes at full weight (you're already aligned here)
    - Attune notes: Daily-unique notes at lower weight (lean into today's energy)
    - Bridge note: If tensions exist, a resolving note
    """
    # Build anchor notes from shared notes
    anchor_notes = []
    for note_name in analysis.shared_notes:
        freq = note_to_frequency(note_name, octave=4)
        anchor_notes.append(SoundSignatureNote(
            note=note_name,
            frequency=freq,
            octave=4,
            weight=1.0,
            sources=["personal", "daily"]
        ))
    
    # Build attune notes from daily-unique
    attune_notes = []
    for note_name in analysis.daily_unique:
        freq = note_to_frequency(note_name, octave=4)
        attune_notes.append(SoundSignatureNote(
            note=note_name,
            frequency=freq,
            octave=4,
            weight=0.5,  # Lower weight for attunement
            sources=["daily"]
        ))
    
    # Find bridge note if we have tensions
    bridge_note = None
    if analysis.tension_pairs:
        bridge_note_name = find_bridge_note(analysis.tension_pairs)
        if bridge_note_name:
            freq = note_to_frequency(bridge_note_name, octave=3)  # Lower octave for grounding
            bridge_note = SoundSignatureNote(
                note=bridge_note_name,
                frequency=freq,
                octave=3,
                weight=0.7,
                sources=["bridge"]
            )
    
    # Suggested duration based on alignment
    # Lower alignment = longer meditation needed
    if analysis.alignment_score >= 80:
        duration = 120.0  # 2 minutes - already well aligned
    elif analysis.alignment_score >= 50:
        duration = 180.0  # 3 minutes - some adjustment needed
    else:
        duration = 300.0  # 5 minutes - significant realignment needed
    
    return AlignmentSound(
        anchor_notes=anchor_notes,
        attune_notes=attune_notes,
        bridge_note=bridge_note,
        suggested_duration=duration
    )
