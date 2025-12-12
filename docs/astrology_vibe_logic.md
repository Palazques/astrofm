# Astrology Vibe Logic and Custom Sound Signature Rules

## I. Astrological Calculation Directives
* **Engine Source:** Swiss Ephemeris data must be used for planetary positions.
* **House System:** **Whole Sign Houses** must be used for all calculations mapping positions to sound parameters (each house is a full 30 degrees).
* **Orb of Influence:** Use a standard orb of $8^\circ$ for major aspects (Conjunction, Opposition, Square, Trine) and $3^\circ$ for minor aspects.

---

## II. Planet-to-Tone Mapping (Sound Signature Foundation)

The core sound signature is a **pure tone** based on the planet's orbital frequency (Cosmic Octave method). The output is a raw, filtered sine wave with NO instrumental timbre. 

| Planet | Core Energy/Vibe Code | Calculated Frequency (Hz) | Musical Note/Pitch (Fixed) | Tone Output Role |
| :--- | :--- | :--- | :--- | :--- |
| **Sun** | Identity, Vitality | $126.22\text{ Hz}$ | **B** | Carrier/Foundation Tone |
| **Moon** | Emotion, Intuition | $210.42\text{ Hz}$ | **G#** | Rhythmic/Fluid Modulator |
| **Mercury** | Communication, Clarity | $141.27\text{ Hz}$ | **C#** | High-Frequency Detail Tone |
| **Mars** | Drive, Action | $144.72\text{ Hz}$ | **C#** | Pulsing/Percussive Tone |
| **Jupiter** | Expansion, Optimism | $183.58\text{ Hz}$ | **F#** | Harmonic Layer Tone |
| **Saturn** | Structure, Discipline | $147.85\text{ Hz}$ | **D** | Low-Frequency Grounding Drone |
| **Uranus** | Innovation, Disruption | $207.36\text{ Hz}$ | **G#** | Glitch/Unpredictable Filter Tone |
| **Neptune** | Dreams, Spirituality | $211.44\text{ Hz}$ | **G#** | Reverb/Echo Ambient Tone |
| **Pluto** | Transformation, Intensity | $140.25\text{ Hz}$ | **C#** | Sub-Bass/Intense Filter Tone |

*Directive:* The Agent must use the **exact calculated frequency** (or its highest octave equivalent) as the fundamental tone. The **Tone Output Role** defines how the filter (VCF) and volume envelope (VCA) are applied to the pure sine wave.

---

## III. House-to-Sound/Timbre Mapping (The Context Layer)

Each house represents a life area and must be sonified by a unique sound quality (Timbre/Texture). This timbre filters the planet's base note, providing the context for its energy.

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

The distinctness of the planet's sound signature (volume/filter) must change dynamically based on its angular distance within the house. 

* **Mid-House Distinctness:** When a planet is near the **center of the house** (around $15^\circ$ into the 30-degree segment), its sound must be at **maximum volume/distinctness**. This is the "most distinct sound."
* **Cusp Fading:** As a planet approaches either cusp (the $0^\circ$ or $30^\circ$ mark), its sound must **fade out or become heavily filtered** (e.g., volume decreases, a low-pass filter is applied) to represent its energy blending with the adjacent house.
* **Rule:** The intensity function must be implemented as a **smooth curve** (e.g., bell curve or sine wave segment) from $0^\circ \rightarrow \text{Max Distinctness} \rightarrow 30^\circ$.

---
