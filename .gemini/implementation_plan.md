# Implementation Plan: Daily Reading Horoscope Redesign

## Objective
Redesign the Daily Reading to be a **transit-focused general horoscope** that:
1. Reflects what TODAY holds based on current planetary positions
2. Feels **unique every day** with actual astrological data
3. Is **Sun sign based** (like traditional horoscopes)
4. Less focused on individual birth chart details, more on cosmic weather

---

## Current Problems

| Issue | Impact |
|-------|--------|
| Cache key only uses Ascendant sign | All users with same ASC get identical reading |
| Fallback messages are hardcoded | Same text if AI fails |
| Life areas seeded by date only | Everyone sees same 3 categories |
| Limited transit data in prompt | Only Moon sign, season, retrogrades |
| Heavy birth chart focus | Too personalized, not horoscope-style |

---

## Proposed Changes

### 1. **Refactor `get_transit_summary()` in `transits.py`**
Add rich transit data for the AI prompt:
- Major aspects between transiting planets (Sun-Moon, Venus-Mars, etc.)
- Moon phase with exact angle
- Void of Course Moon status
- Dominant element of the day
- Most exact aspect of the day

### 2. **Redesign `generate_daily_reading()` in `ai_service.py`**
- **Cache key**: By Sun sign + date (not Ascendant)
- **Prompt focus**: Today's cosmic weather, then how it affects each Sun sign
- **Response format**: General horoscope style (1 main message, not 3 signals)
- **Add variety**: Include actual transit aspects in the prompt

### 3. **Update Response Model**
New simplified response for general horoscope:
```python
{
    "headline": str,           # Short punchy headline (Co-Star style)
    "horoscope": str,          # 2-3 sentence horoscope text
    "cosmic_weather": str,     # Today's sky summary
    "energy_level": int,       # 0-100 energy for the day
    "focus_area": str,         # Life area to focus on
    "playlist_params": {...}   # Keep for music generation
}
```

### 4. **Add Diverse Fallbacks**
Create a pool of 20+ fallback messages per signal type that rotate

---

## Files to Modify

| File | Change |
|------|--------|
| `backend/services/transits.py` | Add `get_detailed_transit_summary()` with aspects |
| `backend/services/ai_service.py` | Rewrite `generate_daily_reading()` prompt |
| `backend/models/schemas.py` | Update `DailyReadingResponse` model |
| `backend/api/routes/ai.py` | Update daily-reading endpoint |
| `frontend/lib/models/daily_reading.dart` | Update Dart model |
| `frontend/lib/screens/home_screen.dart` | Update UI to match new response |

---

## New Transit Data to Include

```python
get_detailed_transit_summary():
    return {
        "date": "2026-01-02",
        "moon_sign": "Pisces",
        "moon_phase": "Waning Gibbous",
        "moon_phase_percent": 78,
        "sun_sign": "Capricorn",  # Current zodiac season
        "retrograde_planets": ["Mercury"],
        "major_aspects_today": [
            {"planets": "Sun-Moon", "aspect": "Trine", "exact_at": "14:32 UTC"},
            {"planets": "Venus-Mars", "aspect": "Square", "exact_at": "09:15 UTC"},
        ],
        "dominant_element": "Earth",  # Most planets in Earth signs
        "day_energy": "Grounding",
    }
```

---

## New AI Prompt Structure

```
TODAY'S COSMIC WEATHER (January 2, 2026):
- Sun in Capricorn (Season: Capricorn)
- Moon in Pisces (Waning Gibbous, 78%)
- Retrograde: Mercury
- Major Aspects: Sun trine Moon (exact 2:32pm), Venus square Mars (building)
- Dominant Element: Earth (4 planets)
- Overall Energy: Grounding, practical, emotionally intuitive

GENERATE A DAILY HOROSCOPE FOR: Scorpio Sun

Write a 2-3 sentence horoscope that:
1. Reflects TODAY'S specific cosmic energy
2. Speaks directly to Scorpio's nature
3. Gives one actionable insight
4. Uses "you" and "your"
5. Is blunt and direct (Co-Star style)

Also provide:
- HEADLINE: 3-5 word punchy title
- FOCUS_AREA: One life area to prioritize today
- ENERGY_LEVEL: 1-100

Format:
HEADLINE: [title]
HOROSCOPE: [2-3 sentences]
FOCUS_AREA: [area]
ENERGY_LEVEL: [number]
```

---

## Approval Checklist

- [ ] Refactor transit service for detailed data
- [ ] Rewrite AI prompt for horoscope style
- [ ] Update cache key to Sun sign + date
- [ ] Simplify response model
- [ ] Add diverse fallback pool
- [ ] Update frontend models and UI
- [ ] Test with multiple Sun signs on same day

---

**Estimated Impact:** ~300 lines across 6 files
**Risk Level:** Medium (changes API response structure)
**Backward Compatibility:** Frontend update required

---

*Awaiting USER approval before proceeding.*
