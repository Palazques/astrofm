# Home Screen UX Refactor - Implementation Plan

## Overview
Refactor the Home Screen to reduce cognitive overload and create visual consistency.

---

## Phase 1: Design System Foundation

### 1.1 Create Unified Chip/Badge Component
**File:** `lib/widgets/shared/info_chip.dart` (NEW)

Standardized properties:
- Border radius: `16px`
- Padding: `horizontal: 12, vertical: 6`
- Font: `SpaceGrotesk 11px w600`
- Border: `1px solid color.withAlpha(60)`
- Background: `color.withAlpha(25)`

### 1.2 Create Glyph Icon Set
**File:** `lib/config/glyphs.dart` (NEW)

Replace emojis with consistent Unicode glyphs:
| Current | New Glyph | Meaning |
|---------|-----------|---------|
| 💕 Love | ◇ | Partnerships |
| 🎨 Create | ✧ | Creativity |
| ❤️ Health | ◎ | Vitality |
| 📈 Career | △ | Purpose |
| 💬 Express | ◈ | Communication |
| 🔮 Transform | ⬡ | Transformation |

### 1.3 Card Depth Hierarchy
**File:** `lib/widgets/glass_card.dart` (MODIFY)

Add `elevation` parameter: `flat`, `raised`, `glowing`
- `flat`: No shadow, subtle border
- `raised`: Soft shadow, no glow
- `glowing`: Ambient color glow (for primary cards only)

---

## Phase 2: Modularize Home Screen

### 2.1 Extract Components
Create `lib/widgets/home/` directory with:

| File | Purpose |
|------|---------|
| `daily_essence_card.dart` | Compact horoscope (headline + tags only) |
| `full_reading_modal.dart` | Expandable full horoscope |
| `mode_toggle.dart` | My Chart / Sky Mode toggle |
| `cta_button_group.dart` | Align Now / Discover buttons |

### 2.2 Refactor `home_screen.dart`
- Import modular components
- Remove inline widget builders
- Reduce file from ~1000 lines to ~300 lines

---

## Phase 3: Layout Restructure

### 3.1 New Vertical Flow
```
┌─────────────────────────────┐
│ App Header                  │  <- Same
├─────────────────────────────┤
│ Daily Essence (Compact)     │  <- NEW: Collapsed horoscope
│ [Expand to read full →]     │
├─────────────────────────────┤
│ ┌─────────┐ ┌─────────────┐ │
│ │Align Now│ │  Discover   │ │  <- MOVED UP
│ └─────────┘ └─────────────┘ │
├─────────────────────────────┤
│ Mode Toggle                 │  <- Same position
├─────────────────────────────┤
│ Chart Wheel / Sound Orbs    │  <- Same
├─────────────────────────────┤
│ Sound RX (Simplified)       │  <- Simplified
└─────────────────────────────┘
```

### 3.2 Sound RX Simplification
Move detailed Sound RX content to Soundscape tab.
Home shows only: Primary recommendation with single "Tune In" button.

---

## Phase 4: Visual Polish

### 4.1 Consistency Pass
- Apply `InfoChip` everywhere (replace all `_buildBadge`, `_buildLuxuryInfoPill`)
- Apply glyph icons to `SoundRecommendationCard` life area chips
- Apply card depth hierarchy (`glowing` for Daily Essence, `raised` for others)

---

## Files Changed Summary

| File | Action |
|------|--------|
| `lib/config/glyphs.dart` | CREATE |
| `lib/widgets/shared/info_chip.dart` | CREATE |
| `lib/widgets/home/daily_essence_card.dart` | CREATE |
| `lib/widgets/home/full_reading_modal.dart` | CREATE |
| `lib/widgets/home/mode_toggle.dart` | CREATE |
| `lib/widgets/home/cta_button_group.dart` | CREATE |
| `lib/widgets/glass_card.dart` | MODIFY |
| `lib/widgets/sound_recommendation_card.dart` | MODIFY |
| `lib/screens/home_screen.dart` | MAJOR REFACTOR |

---

## Verification
- Run `flutter analyze` after each phase
- Visual review in Chrome after Phase 4
