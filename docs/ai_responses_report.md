# Astro.FM AI Responses Report

> **Generated:** January 2, 2026  
> **Purpose:** Document all AI interpretation endpoints, their response structures, and sample outputs

---

## Table of Contents

1. [Daily Reading](#1-daily-reading)
2. [Alignment Interpretation](#2-alignment-interpretation)
3. [Compatibility Narrative](#3-compatibility-narrative)
4. [Transit Interpretation](#4-transit-interpretation)
5. [Playlist Insight](#5-playlist-insight)
6. [Sound Interpretation](#6-sound-interpretation)
7. [Welcome Message](#7-welcome-message)
8. [Transit Alignment](#8-transit-alignment)
9. [Monthly Horoscope](#9-monthly-horoscope)
10. [Summary & Caching](#summary--caching)

---

## 1. Daily Reading (REDESIGNED ✅)

**Endpoint:** `POST /api/ai/daily-reading`  
**Used In:** Home Screen (Today's Reading card)  
**Response Model:** `DailyReadingResponse`

### What Changed

| Before | After |
|--------|-------|
| 3 signals (Resonance/Feedback/Dissonance) | 1 headline + 2-3 sentence horoscope |
| Cached by Ascendant sign | Cached by **Sun sign** |
| Birth chart focused | **Transit-focused** (today's sky) |
| Static fallbacks | Dynamic with real planetary data |

### Request Body
```json
{
  "datetime": "1990-07-15T14:30:00",
  "latitude": 34.0522,
  "longitude": -118.2437,
  "timezone": "America/Los_Angeles",
  "subject_name": null
}
```

### Sample Response (NEW FORMAT)
```json
{
  "headline": "Trust Your Gut Today",
  "horoscope": "The Waning Gibbous Moon in Pisces opens a channel to your intuition. With Earth energy dominating today, you're grounded enough to act on what you feel. Don't overthink—your first instinct is right.",
  "cosmic_weather": "Waning Gibbous Moon in Pisces. No planets retrograde. Sun-Moon Trine.",
  "energy_level": 72,
  "focus_area": "Inner World",
  "moon_phase": "Waning Gibbous",
  "dominant_element": "Earth",
  "playlist_params": {
    "bpm_min": 95,
    "bpm_max": 120,
    "energy": 0.55,
    "valence": 0.6,
    "genres": ["ambient", "downtempo"],
    "key_mode": "minor"
  },
  "generated_at": "2026-01-03T03:40:00.000Z",
  "reading": "The Waning Gibbous Moon in Pisces opens a channel...",
  "signals": []
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `headline` | string | **NEW** Short punchy headline (3-5 words) |
| `horoscope` | string | **NEW** 2-3 sentence daily horoscope |
| `cosmic_weather` | string | Real-time cosmic weather with Moon phase, aspects |
| `energy_level` | int (0-100) | **NEW** Day's energy level |
| `focus_area` | string | **NEW** Life area to focus on (e.g., "Inner World") |
| `moon_phase` | string | **NEW** Current moon phase name |
| `dominant_element` | string | **NEW** Dominant element today (Fire/Earth/Air/Water) |
| `playlist_params` | object | AI-generated playlist parameters |
| `generated_at` | string | ISO timestamp |
| `reading` | string | Legacy (same as horoscope, for backward compat) |
| `signals` | array | Legacy (empty array, deprecated) |

### What Makes It Unique Each Day

The response is generated using **real astronomical data**:

| Data Point | Source | Updates |
|------------|--------|---------|
| Moon sign & phase | Swiss Ephemeris | Every few hours |
| Moon phase % | Calculated from Sun-Moon angle | Real-time |
| Major transit aspects | Planet-to-planet aspects | Daily |
| Dominant element | Planet positions by element | Daily |
| Retrograde planets | Planet speed calculations | Real-time |
| Day energy | Derived from aspects + moon phase | Daily |

---


## 2. Alignment Interpretation

**Endpoint:** `POST /api/ai/interpret-alignment`  
**Used In:** Align Screen (friend comparison view)  
**Response Model:** `AlignmentInterpretation`

### Request Body
```json
{
  "user_datetime": "1990-07-15T14:30:00",
  "user_latitude": 34.0522,
  "user_longitude": -118.2437,
  "target_datetime": "1992-03-22T10:15:00",
  "target_latitude": 40.7128,
  "target_longitude": -74.0060
}
```

### Sample Response
```json
{
  "interpretation": "Your Leo warmth harmonizes with today's expansive Sagittarius energy, creating a rich, uplifting resonance. This is the sound of confidence meeting adventure—like a driving synth lead over a warm bass foundation.",
  "resonance_score": 85,
  "harmonious_aspects": [
    "Trine formation",
    "Harmonic resonance",
    "Complementary frequencies"
  ]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `interpretation` | string | AI-generated 2-3 sentence interpretation in sonic terms |
| `resonance_score` | int (0-100) | Calculated resonance percentage |
| `harmonious_aspects` | array[string] | List of harmonious aspect descriptions |

---

## 3. Compatibility Narrative

**Endpoint:** `POST /api/ai/compatibility`  
**Used In:** Friend Profile Screen  
**Response Model:** `CompatibilityResponse`

### Request Body
```json
{
  "user_datetime": "1990-07-15T14:30:00",
  "user_latitude": 34.0522,
  "user_longitude": -118.2437,
  "friend_datetime": "1992-03-22T10:15:00",
  "friend_latitude": 40.7128,
  "friend_longitude": -74.0060,
  "friend_name": "Alex"
}
```

### Sample Response
```json
{
  "narrative": "You and Alex make an interesting sonic pairing. Your deep Scorpio intensity blends with their airy Gemini curiosity—imagine dreamy synths meeting playful melodies. There's depth balanced with lightness here.",
  "overall_score": 75,
  "strengths": [
    "Complementary energies",
    "Shared curiosity",
    "Emotional depth meets playfulness"
  ],
  "challenges": [
    "Different communication rhythms",
    "Intensity vs. lightness tension"
  ],
  "shared_genres": [
    "Electronic",
    "Indie",
    "Dream Pop"
  ]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `narrative` | string | 2-3 sentence compatibility narrative |
| `overall_score` | int (0-100) | Overall compatibility score |
| `strengths` | array[string] | 2-3 relationship strengths |
| `challenges` | array[string] | 1-2 potential challenges |
| `shared_genres` | array[string] | 2-3 shared music genre recommendations |

---

## 4. Transit Interpretation

**Endpoint:** `GET /api/ai/transit-interpretation`  
**Used In:** Align Screen (Transit tab)  
**Response Model:** `TransitInterpretationResponse`

### Sample Response
```json
{
  "interpretation": "Today's Waxing Gibbous Moon brings building momentum as we approach fullness. The cosmic signal is clear with harmonious undertones—a good day for creative output and emotional expression.",
  "highlight_planet": "Venus",
  "highlight_reason": "Venus in Pisces amplifies romantic and creative frequencies today.",
  "energy_description": "Flowing",
  "moon_phase": "Waxing Gibbous",
  "retrograde_planets": ["Mercury"]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `interpretation` | string | AI-generated cosmic weather summary |
| `highlight_planet` | string | Most significant planet to highlight |
| `highlight_reason` | string | Why this planet is significant |
| `energy_description` | string | One-word energy description (e.g., "Flowing", "Dynamic") |
| `moon_phase` | string | Current moon phase name |
| `retrograde_planets` | array[string] | Planets currently in retrograde |

---

## 5. Playlist Insight

**Endpoint:** `POST /api/ai/playlist-insight`  
**Used In:** Home Screen (Cosmic Queue insight card)  
**Response Model:** `PlaylistInsightResponse`

### Request Body
```json
{
  "datetime": "1990-07-15T14:30:00",
  "latitude": 34.0522,
  "longitude": -118.2437,
  "energy_percent": 62,
  "dominant_mood": "Dreamy",
  "dominant_element": "Water",
  "bpm_min": 90,
  "bpm_max": 120
}
```

### Sample Response
```json
{
  "insight": "With your Scorpio intensity meeting today's dreamy Pisces Moon, we're serving deep, emotional tracks that match your introspective vibe—expect layered textures and hypnotic rhythms.",
  "energy_percent": 62,
  "dominant_mood": "Dreamy",
  "astro_highlight": "Scorpio Sun"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `insight` | string | 1-2 sentence relatable playlist explanation |
| `energy_percent` | int (0-100) | Playlist energy level |
| `dominant_mood` | string | Dominant mood in playlist |
| `astro_highlight` | string | Key astrological placement |

---

## 6. Sound Interpretation

**Endpoint:** `POST /api/ai/sound-interpretation`  
**Used In:** Sound Screen  
**Response Model:** `SoundInterpretationResponse`

### Request Body
```json
{
  "datetime": "1990-07-15T14:30:00",
  "latitude": 34.0522,
  "longitude": -118.2437,
  "dominant_element": "Fire",
  "planets": [
    { "name": "Sun", "sign": "Leo", "house": 10, "frequency": 126.22 },
    { "name": "Moon", "sign": "Cancer", "house": 9, "frequency": 210.42 },
    { "name": "Mercury", "sign": "Leo", "house": 10, "frequency": 141.27 },
    { "name": "Venus", "sign": "Virgo", "house": 11, "frequency": 221.23 },
    { "name": "Mars", "sign": "Taurus", "house": 7, "frequency": 144.72 }
  ]
}
```

### Sample Response
```json
{
  "personality": "Your Fire energy creates a sound that's bold, warm, and full of drive. The blend of your Aries Sun and Cancer Moon gives your sound both intensity and emotional depth—like a powerful drumbeat with melodic undertones.",
  "today_influence": "Today's cosmic weather amplifies your natural intensity, adding extra heat to your frequencies.",
  "shift": "+12% warmth",
  "planet_descriptions": {
    "Sun": "Core identity tone • Bold and direct",
    "Moon": "Emotional rhythm • Nurturing undertones",
    "Mercury": "Mental frequency • Quick and sharp",
    "Venus": "Harmony style • Passionate connection",
    "Mars": "Drive energy • Unstoppable force"
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `personality` | string | 2-sentence sonic personality description |
| `today_influence` | string | 1-sentence transit effect on sound |
| `shift` | string | Short label for today's shift (e.g., "+8% warmth") |
| `planet_descriptions` | object | Per-planet 5-8 word sound descriptions |

---

## 7. Welcome Message

**Endpoint:** `POST /api/ai/welcome`  
**Used In:** Onboarding (Sound Ready Screen)  
**Response Model:** `WelcomeMessageResponse`

### Request Body
```json
{
  "datetime": "1990-07-15T14:30:00",
  "latitude": 34.0522,
  "longitude": -118.2437
}
```

### Sample Response
```json
{
  "greeting": "Welcome, adventurous Sagittarius! 🏹",
  "personality": "Your Sagittarius Sun brings bold, expansive energy to everything you do. Combined with your Pisces Moon's dreamy depth, you're someone who thinks big and feels deeply.",
  "sound_teaser": "Your unique sound carries warm, driving tones with moments of dreamy transcendence—tap below to experience your cosmic audio signature."
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `greeting` | string | 1-sentence personalized welcome |
| `personality` | string | 1-2 sentence friendly personality description |
| `sound_teaser` | string | 1-sentence intriguing hint about their sound |

---

## 8. Transit Alignment

**Endpoint:** `POST /api/ai/transit-alignment`  
**Used In:** Align Screen (Transit Wheel)  
**Response Model:** `TransitAlignmentResponse`

### Request Body
```json
{
  "datetime": "1990-07-15T14:30:00",
  "latitude": 34.0522,
  "longitude": -118.2437,
  "timezone": "America/Los_Angeles",
  "target_date": null
}
```

### Sample Response
```json
{
  "planets": [
    {
      "id": "sun",
      "name": "Sun",
      "symbol": "☉",
      "color": "#FFB800",
      "natal": {
        "sign": "Leo",
        "degree": 15.3,
        "house": 10
      },
      "transit": {
        "sign": "Capricorn",
        "degree": 12.8,
        "house": 3,
        "retrograde": false
      },
      "status": "gap",
      "pull": "Your natural self-expression is being channeled into practical matters.",
      "feelings": [
        "A push to be more grounded",
        "Less spontaneous",
        "Career-focused energy"
      ],
      "practice": "Journal about where ambition meets authenticity today."
    },
    {
      "id": "moon",
      "name": "Moon",
      "symbol": "☽",
      "color": "#C9C9C9",
      "natal": {
        "sign": "Pisces",
        "degree": 22.1,
        "house": 5
      },
      "transit": {
        "sign": "Pisces",
        "degree": 19.5,
        "house": 5,
        "retrograde": false
      },
      "status": "resonance",
      "pull": "Emotional alignment—your feelings are flowing naturally.",
      "feelings": [
        "Heightened intuition",
        "Creative inspiration",
        "Emotional clarity"
      ],
      "practice": "Trust your gut instincts today, they're running clear."
    },
    {
      "id": "mercury",
      "name": "Mercury",
      "symbol": "☿",
      "color": "#7D67FE",
      "natal": {
        "sign": "Leo",
        "degree": 8.7,
        "house": 10
      },
      "transit": {
        "sign": "Sagittarius",
        "degree": 24.2,
        "house": 2,
        "retrograde": true
      },
      "status": "gap",
      "pull": "Communication patterns are being reviewed and revised.",
      "feelings": [
        "Thoughts feel scattered",
        "Words not landing right",
        "Re-examining ideas"
      ],
      "practice": "Write before you speak. Edit before you send."
    }
  ],
  "gap_count": 5,
  "resonance_count": 3
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `planets` | array | Alignment data for each planet |
| `planets[].id` | string | Planet identifier (lowercase) |
| `planets[].name` | string | Planet name |
| `planets[].symbol` | string | Unicode planet symbol |
| `planets[].color` | string | Hex color code |
| `planets[].natal` | object | Natal position (sign, degree, house) |
| `planets[].transit` | object | Transit position (sign, degree, house, retrograde) |
| `planets[].status` | string | `"gap"` or `"resonance"` |
| `planets[].pull` | string | Explanation of tension/harmony |
| `planets[].feelings` | array[string] | 3-4 symptom descriptions |
| `planets[].practice` | string | Actionable guidance |
| `gap_count` | int | Number of planets in gap |
| `resonance_count` | int | Number of planets in resonance |

---

## 9. Monthly Horoscope

**Endpoint:** *(Internal service, not exposed via API route)*  
**Used In:** Zodiac Playlist Card  
**Response Model:** `dict`

### Sample Response
```json
{
  "horoscope": "Welcome to Sagittarius season! This month invites you to embrace bold adventures and expansive thinking. Your usual caution can take a backseat as the cosmic energy encourages risk-taking and new experiences. Let your playlist be your soundtrack to exploration—upbeat tempos and anthemic choruses will match your fearless spirit.",
  "vibe_summary": "Expect driving beats, soaring melodies, and the sound of freedom.",
  "energy_level": 85
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `horoscope` | string | ~80-100 word paragraph about the month ahead |
| `vibe_summary` | string | 1-sentence punchy sonic vibe description |
| `energy_level` | int (1-100) | Overall energy intensity |

---

## Summary & Caching

### Response Length Comparison

| Endpoint | Avg Response Size | Primary Text Field |
|----------|-------------------|-------------------|
| Daily Reading | ~1.5 KB | `signals[]` (3 items, ~500 chars) |
| Alignment Interpretation | ~400 bytes | `interpretation` (~150 chars) |
| Compatibility | ~600 bytes | `narrative` (~300 chars) |
| Transit Interpretation | ~500 bytes | `interpretation` (~200 chars) |
| Playlist Insight | ~350 bytes | `insight` (~150 chars) |
| Sound Interpretation | ~800 bytes | `personality` + `planet_descriptions` (~400 chars) |
| Welcome Message | ~500 bytes | `personality` + `sound_teaser` (~250 chars) |
| Transit Alignment | ~2 KB | `planets[]` (8 items, ~800 chars) |
| Monthly Horoscope | ~600 bytes | `horoscope` (~400 chars) |

### Caching Strategy

| Endpoint | Cache Duration | Cache Key |
|----------|---------------|-----------|
| Daily Reading | 24 hours | `daily_v2:{asc_sign}:{date}:{subject}` |
| Alignment Interpretation | None | - |
| Compatibility | Indefinite | `compat:{user_asc}:{friend_asc}:{name}` |
| Transit Interpretation | 3 hours | `transit:{date-hour}` |
| Playlist Insight | None | - |
| Sound Interpretation | None | - |
| Welcome Message | None | - |
| Transit Alignment | None | - |
| Monthly Horoscope | 30 days | `monthly_horoscope:{sign}:{month}` |

### Loading States by Screen

| Screen | AI Response | Current Loading UI |
|--------|-------------|-------------------|
| Home Screen | Daily Reading, Playlist Insight | `SkeletonLoader`, `CosmicWaveLoader` |
| Sound Screen | Sound Interpretation | `_isLoadingSoundInterpretation` → `CircularProgressIndicator` |
| Align Screen | Transit Interpretation, Transit Alignment | `_isLoadingTransitInterpretation` → Shimmer |
| Friend Profile | Compatibility | `_buildShimmerInsight()` |
| Onboarding | Welcome Message | Inline loading |

---

## Frontend Models (Dart)

The frontend models for these responses are located in:
- `frontend/lib/models/daily_reading.dart`
- `frontend/lib/models/alignment.dart`
- `frontend/lib/models/transit.dart`
- `frontend/lib/models/sound.dart`
- `frontend/lib/models/playlist.dart`

Each model includes `fromJson()` factory constructors for parsing API responses.

---

## API Service Methods

All AI endpoints are accessed through `ApiService` (`frontend/lib/services/api_service.dart`):

```dart
// Daily Reading
Future<DailyReadingResponse> getDailyReading({...})

// Alignment Interpretation  
Future<AlignmentInterpretation> getAlignmentInterpretation({...})

// Compatibility
Future<CompatibilityResponse> getCompatibility({...})

// Transit Interpretation
Future<TransitInterpretation> getTransitInterpretation()

// Playlist Insight
Future<PlaylistInsight> getPlaylistInsight({...})

// Sound Interpretation
Future<SoundInterpretation> getSoundInterpretation({...})

// Welcome Message
Future<WelcomeMessage> getWelcomeMessage({...})

// Transit Alignment
Future<TransitAlignmentResponse> getTransitAlignment({...})
```

---

*End of Report*
