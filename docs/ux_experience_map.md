# AstroFM: User Experience Map & Audit

## I. Core Experience Flow
The user journey in AstroFM is designed as a transition from "Data" (Birth) to "Sensory" (Sound) to "Connection" (Alignment).

### 1. Onboarding: The Creation of the Soul Signature
*   **Step 1: Birth Information** (Stress Peak: Detail Accuracy)
    *   User provides: Name, Date, Time, Location.
    *   *System Action*: Runs Swiss Ephemeris calculations.
*   **Step 2: Genre Preference** (Quiet Inbetween)
    *   User selects primary and sub-genres.
    *   *System Action*: Stores music preferences for playlist generation.

### 2. The Radar (Home Tab): Daily Cosmic Pulse
*   **Layout Detail**:
    *   **Header**: Quick access to Settings.
    *   **Sound Wheel**: Interactive daily transit positions.
    *   **CTA Buttons**: "Align Now" (Shortcuts to Align Tab) & "Generate" (Triggers Playlist logic).
    *   **Horoscope Card**: AI-generated "Today's Reading".
    *   **Zodiac Season**: Seasonal focus and curated playlist.
*   **Interaction Flow**: Landing -> Quick Sound Check -> Reading the Daily Vibe -> Optional Alignment session.

### 3. The Soul (Sound Tab): Personal Sonification
*   **Layout Detail**:
    *   **Main Orb**: Visual representation of the Natal Chart sound.
    *   **Play/Pause**: The primary sensory engagement.
    *   **Birth Chart Wheel**: Astronomical view of planetary house positions.
*   **Interaction Flow**: Discover Personal Frequency -> Explore Planet Details via Chart Wheel -> Share Sonic Identity.

### 4. The Sync (Align Tab): Active Tuning
*   **Layout Detail**:
    *   **Dual Orbs**: "Your Sound" vs "Target Sound".
    *   **Target Selector**: Today, Friend, or Transit.
    *   **Alignment Button**: Triggers the calculation simulation.
    *   **Resonance Score**: The output of the synastry/transit calculation.
*   **Interaction Flow**: Select Target -> Start Alignment (Stress Peak) -> Result Reveal (Magical Moment) -> Interpret & Share.

---

## II. UX Audit: Redundancies & Confusions

### 🔴 Redundancies
1.  **Multiple "Primary" Sounds**: The user has a "Daily Sound" on Home and "Your Sound" on Sound screen. Without clear labeling, the user may ask "Which one am I hearing right now?".
2.  **Shortcut Redundancy**: The "Align Now" button on the Home screen is a large CTA that only serves as a tab switcher. It adds visual weight to the Home tab without providing a unique function.
3.  **Dual Reading Sources**: The Home screen has a daily reading, and the Align screen has an interpretation. If these don't match or reference different data points, it causes fatigue.

### 🟡 Possible Confusions
1.  **Target: "Today" vs "Transit"**: In the Align tab, "Today" and "Transit" likely refer to the same planetary positions. Having both as separate options is confusing.
2.  **Navigation Paradox**: Some buttons (like "See All") navigate deep, while the bottom bar handles top-level. Users might get "lost" in deep detail screens (like Friend Profile) and forget how to return to the global constellation map.
3.  **Spotify Integration Status**: It is not always clear if the app is currently linked to Spotify or if "Generate" will open an external app or play internally.

---

## III. Sensory Map (Speed & Stress)

| Stage | Speed | Stress/Energy | Duration | Context |
| :--- | :--- | :--- | :--- | :--- |
| **Onboarding** | Slow | High (Peak) | 2 min | Technical data entry. |
| **Landing (Home)** | Fast | Medium | 10 sec | Sensory greeting. |
| **Alignment** | Medium | High (Peak) | 15 sec | Anticipation for the score. |
| **Sound Exploration** | Slow | Low (Quiet Inbetween)| Unlimited | Meditative listening. |
| **Reading Horoscope**| Medium | Low (Quiet Inbetween)| 45 sec | Cognitive reflection. |

---

## IV. The Magical Moment & Well-Timed Peak

### ✨ The Reveal (The Magical Moment)
The **Alignment Score Reveal** is the ultimate peak. The moment the progress bar fills, the colors of the two orbs blend into a new "Harmony Color," and the score drops. It transforms abstract data into a binary "connection" that feels personal and meaningful.

### 🌊 The Quiet Inbetween
The **Sound Tab** is the "Cool Down" zone. After the social stress of the Connections tab or the technical stress of Alignment, the Sound tab allows the user to simply exist with their own chart, spinning the wheel to hear individual planets.

---

## V. Strategic Recommendations
1.  **Merge Today/Transit targets**: Consolidate into a single "Current Sky" target to reduce cognitive load.
2.  **Differentiate Orbs**: Use distinct visual motifs for "Today's Sound" (Home) vs "My Sound" (Sound Tab) to emphasize the difference between internal and external energy.
3.  **Enhance the "Align Now" shortcut**: Instead of just switching tabs, the Home shortcut should immediately trigger a "Quick Alignment" for Today.
