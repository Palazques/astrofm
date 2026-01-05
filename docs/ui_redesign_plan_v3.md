# Astro.fm UI/UX Redesign: Home & Soundscape V3

This refined plan prioritizes the **Daily Reading** as the entryway to the app and consolidates all personal astronomical data into a scrollable Home experience.

---

## 🏗️ 1. The REFINED Home Screen: "The Living Chart"

### Scrollable Layout (Top to Bottom)
1.  **THE MESSAGE (Top Hook)**: 
    *   The **Horoscope/Daily Reading Card** is now the very first thing the user sees below the header.
    *   *Rationale*: Provides immediate cognitive value and "vibe" setting for the day.
2.  **THE MODE SELECTOR**:
    *   A sleek toggle: `[ MY CHART | SKY MODE ]`.
3.  **THE ORB & WHEEL (Heart of the App)**:
    *   **MY CHART Mode**: Shows the high-fidelity Natal Orb and the full **Birth Chart Wheel**. This is where users hear their soul's frequency.
    *   **SKY Mode**: Overlays current planetary transits. The wheel updates to show where today's planets are sitting in your natal houses.
4.  **THE BREAKDOWN (Deep Data)**:
    *   Detailed **Frequency Breakdown** (Hz per planet).
    *   **Planet Insight Pills**: The interactive buttons from the Sound page that explain each planet's current influence.
5.  **THE CTAs (Utility)**:
    *   "Align Now" (Shortcut to the Circle/Friends).

---

## 🎵 2. The NEW Soundscape Tab: "Music & Curation"

### Purpose
To separate the *Calculations* (Home) from the *Consumption* (Playlist Hub).

### Layout
1.  **ZODIAC SEASON CARD**: The luxury, curated playlist card for the current season.
2.  **THE COSMIC MIXER**: The "Generate" engine button lives here now. 
3.  **PLAYLIST STACK**: A vertical list of currently active or past cosmic playlists.
4.  **STREAMING STATUS**: Integration status with Spotify/Apple Music.

---

## 📑 3. Component Migration Check-list

| Original Component | New Location |
| :--- | :--- |
| Daily Reading Card | **Home (Fixed Top)** |
| Birth Chart Wheel | **Home (Below Toggle)** |
| Natal Orb | **Home ("My Chart" Mode)** |
| Frequency Breakdown | **Home (Bottom Scroll)** |
| Planet Detailed Pills | **Home (Bottom Scroll)** |
| Zodiac Season Card | **Soundscape Tab** |
| Playlist Generation | **Soundscape Tab** |
| Cosmic Queue | **Soundscape Tab** |

---

## 🎨 4. Visual Language & Flow
*   **The Transition**: When scrolling past the Reading Card, the background stars should become more vibrant as the **Chart Wheel** comes into focus.
*   **The Toggle Logic**:
    *   Choosing **"My Chart"** uses the user's signature color palette (e.g., Pink/Purple).
    *   Choosing **"Sky Mode"** introduces a second ring to the wheel and shifts the background aura to match the current Zodiac Season's energy.
