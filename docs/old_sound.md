# Original Sound Generation Method (Archived)

> **Archived on:** 2025-12-30  
> **Reason:** Replaced by Steiner Zodiac Tone Circle method

---

## Overview

The original Astro.FM sound generation used the **Cousto Cosmic Octave method**, which derives frequencies from planetary orbital periods. Each planet had a fixed frequency calculated from its orbit time, octaved up into the audible range.

---

## II. Planet-to-Tone Mapping (Cosmic Octave Method)

The core sound signature was a **pure tone** based on the planet's orbital frequency. The output was a raw, filtered sine wave with NO instrumental timbre.

| Planet | Core Energy/Vibe Code | Calculated Frequency (Hz) | Musical Note/Pitch (Fixed) | Tone Output Role |
| :--- | :--- | :--- | :--- | :--- |
| **Sun** | Identity, Vitality | 126.22 Hz | **B** | Carrier/Foundation Tone |
| **Moon** | Emotion, Intuition | 210.42 Hz | **G#** | Rhythmic/Fluid Modulator |
| **Mercury** | Communication, Clarity | 141.27 Hz | **C#** | High-Frequency Detail Tone |
| **Venus** | Harmony, Love | 221.23 Hz | **A** | Harmonic/Melodic Tone |
| **Mars** | Drive, Action | 144.72 Hz | **C#** | Pulsing/Percussive Tone |
| **Jupiter** | Expansion, Optimism | 183.58 Hz | **F#** | Harmonic Layer Tone |
| **Saturn** | Structure, Discipline | 147.85 Hz | **D** | Low-Frequency Grounding Drone |
| **Uranus** | Innovation, Disruption | 207.36 Hz | **G#** | Glitch/Unpredictable Filter Tone |
| **Neptune** | Dreams, Spirituality | 211.44 Hz | **G#** | Reverb/Echo Ambient Tone |
| **Pluto** | Transformation, Intensity | 140.25 Hz | **C#** | Sub-Bass/Intense Filter Tone |

*Directive:* The exact calculated frequency (or its highest octave equivalent) was used as the fundamental tone. The **Tone Output Role** defined how the filter (VCF) and volume envelope (VCA) were applied to the pure sine wave.

---

## III. House-to-Sound/Timbre Mapping (The Context Layer)

Each house represented a life area and was sonified by a unique sound quality (Timbre/Texture). This timbre filtered the planet's base note, providing the context for its energy.

| House | Life Area (Context) | Quality/Modality | Sound Quality / Timbre | Purpose in Mix |
| :--- | :--- | :--- | :--- | :--- |
| **1st** | Self, Appearance | Angular (Action) | **Lead, Focused** | High-pass filter, clear, singular melodic line. |
| **2nd** | Money, Self-Worth | Succedent (Security) | **Warm, Resonant** | Rich mid-bass frequencies, smooth attack. |
| **3rd** | Communication, Mind | Cadent (Learning) | **Fast, Repeating** | Quick arpeggios, staccato notes. |
| **4th** | Home, Roots | Angular (Action) | **Deep, Substantial** | Low-end resonance, steady bass drone. |
| **5th** | Creativity, Pleasure | Succedent (Security) | **Bright, Expansive** | Layered synths, wide stereo field. |
| **6th** | Service, Health | Cadent (Learning) | **Rhythmic, Structured** | Looping percussion, complex time signature. |
| **7th** | Partnership | Angular (Action) | **Layered, Counterpoint** | Two interwoven, harmonizing melodic lines. |
| **8th** | Transformation, Shared Resources | Succedent (Security) | **Deep, Unsettling** | Filtered noise, reversed sounds, sub-bass pulse. |
| **9th** | Philosophy, Travel | Cadent (Learning) | **Ascending, Open** | Rising pitch bends, open fifths, sustained reverb. |
| **10th**| Career, Public Status | Angular (Action) | **Apex, Authoritative** | Sharp attack, high volume, clear structure. |
| **11th**| Groups, Hopes | Succedent (Security) | **Synthetic, Interconnected** | Complex chord clusters, digital timbre. |
| **12th**| Subconscious, Hidden | Cadent (Learning) | **Ambient, Dissolving** | Heavy delay/echo, minimal attack, sustained pads. |

---

## IV. Intensity and Distinctness Dynamic (The Volume Rule)

The distinctness of the planet's sound signature (volume/filter) changed dynamically based on its angular distance within the house.

* **Mid-House Distinctness:** When a planet was near the **center of the house** (around 15° into the 30-degree segment), its sound was at **maximum volume/distinctness**.
* **Cusp Fading:** As a planet approached either cusp (the 0° or 30° mark), its sound **faded out or became heavily filtered** to represent its energy blending with the adjacent house.
* **Rule:** The intensity function was implemented as a **smooth sine curve** from 0° → Max Distinctness → 30°.

### Intensity Formula
```python
intensity = sin(degree_in_house / 30 × π)
```

---

## V. Original Implementation Files

### Backend
- `backend/services/sonification.py` - Main sonification service
- `backend/models/sonification_schemas.py` - Pydantic models
- `backend/api/routes/sonification.py` - API endpoints

### Frontend
- `frontend/lib/models/sonification.dart` - Dart models
- `frontend/lib/services/audio_service.dart` - Web Audio API playback

---

## VI. Key Differences from New System

| Aspect | Old (Cosmic Octave) | New (Steiner Zodiac Tone Circle) |
| :--- | :--- | :--- |
| **Frequency Source** | Planetary orbital period | Planet's ruling sign on Circle of Fifths |
| **Sound Type** | Single frequency per planet | 5-note chord (Sound Signature) |
| **Primary Focus** | All 10 planets equally | Big Four emphasized |
| **Harmonic Structure** | No chord awareness | Sign-based major chords |
| **Aspect Handling** | Not implemented | Full aspect-based modulation |
