# Astrology Vibe Logic: Steiner Zodiac Tone Circle Sound Signature

## I. Astrological Calculation Directives
* **Engine Source:** Swiss Ephemeris data must be used for planetary positions.
* **House System:** **Whole Sign Houses** must be used (each house is a full 30 degrees).
* **Orb of Influence:** 8° for major aspects (Conjunction, Opposition, Square, Trine), 3° for minor aspects.

---

## II. Sound Signature Architecture

The Sound Signature is a **5-note chord** built from the **Big Four** astrological points:
1. **Sun** - Core identity
2. **Moon** - Emotional self  
3. **Rising (Ascendant)** - Outer appearance (always 100% weight)
4. **Chart Ruler** - Planet ruling the Rising sign

---

## III. Layer 1: Planet Root Notes

Each planet has a fixed root note derived from its ruling sign's position on the Circle of Fifths.

| Planet | Rules | Root Note | Frequency (A=440) |
| :--- | :--- | :--- | :--- |
| Sun | Leo | E | 329.63 Hz |
| Moon | Cancer | A | 440.00 Hz |
| Mercury | Gemini | D | 293.66 Hz |
| Venus | Taurus | G | 392.00 Hz |
| Mars | Aries | C | 261.63 Hz |
| Jupiter | Sagittarius | A♭ | 415.30 Hz |
| Saturn | Capricorn | E♭ | 311.13 Hz |
| Uranus | Aquarius | B♭ | 466.16 Hz |
| Neptune | Pisces | F | 349.23 Hz |
| Pluto | Scorpio | D♭ | 277.18 Hz |

---

## IV. Layer 2: Sign Chords

The sign a planet occupies determines the harmonic chord (major triad).

| Sign | Major Chord | Notes |
| :--- | :--- | :--- |
| Aries | C Major | C - E - G |
| Taurus | G Major | G - B - D |
| Gemini | D Major | D - F# - A |
| Cancer | A Major | A - C# - E |
| Leo | E Major | E - G# - B |
| Virgo | B Major | B - D# - F# |
| Libra | F# Major | F# - A# - C# |
| Scorpio | D♭ Major | D♭ - F - A♭ |
| Sagittarius | A♭ Major | A♭ - C - E♭ |
| Capricorn | E♭ Major | E♭ - G - B♭ |
| Aquarius | B♭ Major | B♭ - D - F |
| Pisces | F Major | F - A - C |

---

## V. Layer 3: House Degree (Weight & Inversion)

### Weight Calculation (Bell Curve)
```
weight = sin(degree_in_house / 30 × π)
```

| Degree | Weight |
| :--- | :--- |
| 0° | 0% |
| 5° | 50% |
| 10° | 87% |
| 15° | 100% |
| 20° | 87% |
| 25° | 50% |
| 30° | 0% |

### Chord Inversion by Degree
| Degree Range | Inversion | Structure |
| :--- | :--- | :--- |
| 0° - 10° | Root position | 1 - 3 - 5 |
| 10° - 20° | First inversion | 3 - 5 - 1 |
| 20° - 30° | Second inversion | 5 - 1 - 3 |

---

## VI. Layer 4: Aspect Interactions

### Interval Relationships
| Aspect | Degrees | Musical Interval | Quality |
| :--- | :--- | :--- | :--- |
| Conjunction | 0° | Unison | Reinforced, powerful |
| Semi-sextile | 30° | Perfect 5th | Stable |
| Sextile | 60° | Major 2nd | Bright, open |
| Square | 90° | Minor 3rd | Tension, friction |
| Trine | 120° | Major 3rd | Harmony, ease |
| Quincunx | 150° | Perfect 4th | Awkward, suspended |
| Opposition | 180° | Tritone | Maximum tension |

### Aspect Sound Modulation
| Aspect | Sound Effect |
| :--- | :--- |
| Conjunction | Unison, slightly detuned, thick |
| Sextile | Gentle LFO cross-modulation, shimmer |
| Square | Ring modulation, harsh, metallic |
| Trine | Chorus, warm blend |
| Opposition | Phase cancellation, push-pull |

### Orb Intensity
| Orb | Effect Strength |
| :--- | :--- |
| 0° (exact) | 100% |
| 1-3° | 75% |
| 4-6° | 50% |
| 7-8° | 25% |
| 9°+ | 0% (no aspect) |

---

## VII. Chart Ruler Table

| Rising Sign | Chart Ruler |
| :--- | :--- |
| Aries | Mars |
| Taurus | Venus |
| Gemini | Mercury |
| Cancer | Moon |
| Leo | Sun |
| Virgo | Mercury |
| Libra | Venus |
| Scorpio | Pluto |
| Sagittarius | Jupiter |
| Capricorn | Saturn |
| Aquarius | Uranus |
| Pisces | Neptune |

**Special Case:** If Chart Ruler is Sun or Moon, that planet is counted twice (extra weight).

---

## VIII. Building the Sound Signature

### Step 1: Collect Notes from Big Four
For each source, collect:
- Planet root note (1 note)
- Sign chord notes (3 notes)

Total: Up to 16 notes (4 sources × 4 notes each)

### Step 2: Calculate Weighted Contribution
| Source | Weight Calculation |
| :--- | :--- |
| Sun | sin(sun_degree / 30 × π) |
| Moon | sin(moon_degree / 30 × π) |
| Rising | 1.0 (fixed 100%) |
| Chart Ruler | sin(chart_ruler_degree / 30 × π) |

### Step 3: Count Weighted Notes
Multiply each note's occurrence by its source's weight.

### Step 4: Select Top 5 Notes
Take the 5 notes with highest weighted count.

### Step 5: Tie-Breaker Rules
| Priority | Rule |
| :--- | :--- |
| 1st | Sun's notes win |
| 2nd | Moon's notes win |
| 3rd | Rising's notes win |
| 4th | Chart Ruler's notes win |

---

## IX. Sound Signature Voicing (Octave Spread)

| Position | Note | Octave |
| :--- | :--- | :--- |
| 1st (root) | Most common | Octave 3 (low) |
| 2nd | Second most | Octave 3 (low) |
| 3rd | Third most | Octave 4 (middle) |
| 4th | Fourth most | Octave 4 (middle) |
| 5th | Fifth most | Octave 5 (high) |

---

## X. Texture Layer (Other Planets)

Planets not in the Big Four become background texture:
- Play root notes only (not full chords)
- Arpeggiate slowly (one note every 1-2 seconds)
- Volume: 20%
- Adds movement without clutter
