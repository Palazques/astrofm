# 🔬 ASTRO.FM Codebase Audit

> **Date:** December 31, 2025 | **Status:** 🔴 Action Required | **Issues Found:** 65+

---

## 📊 Dashboard

```
┌─────────────────────────────────────────────────────────────────┐
│  🔴 CRITICAL    │  🟡 MEDIUM    │  🟢 LOW       │  ✅ CLEAN     │
│      14         │      11       │      8        │     32        │
│  Auth, Mocks    │  TODOs        │  Cleanup      │  Widgets      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚨 Critical Issues

### 1. Authentication Not Implemented

> **Impact:** Users cannot create accounts or sign in

```dart
// 📁 lib/screens/sign_in_screen.dart

Line 78   → // TODO: Implement actual authentication with Firebase
Line 222  → // TODO: Implement forgot password  
Line 308  → // TODO: Implement Google sign in
Line 316  → // TODO: Implement Apple sign in
```

**Fix:** Implement Firebase Auth (Phase 2 of roadmap)

---

### 2. Hardcoded Localhost

> **Impact:** App will break when deployed

```dart
// � lib/config/api_config.dart (Line 5)

static const String baseUrl = 'http://localhost:8000';  // ❌ BREAKS IN PROD
```

**Fix:** Use environment variables or platform-specific config

---

### 3. Mock Friends System

> **Impact:** Connections screen shows fake data

| File | What's Mocked |
|:-----|:--------------|
| `add_friend_sheet.dart:21` | Search results (`_mockUsers` array) |
| `test_users.dart` | Entire file is test data |
| `connections_screen.dart:128` | Sorting uses mock data assumptions |

---

### 4. Fake Birth Data Generation

> **Impact:** Compatibility calculations are unreliable for friends

```dart
// 📁 lib/screens/friend_profile_screen.dart

Line 79-93   → Generates mock birth data from sun sign
Line 132-146 → Duplicated mock data generation  
Line 174-175 → _getMockBirthDataForSign() function
```

---

## 🟡 TODO Items

| # | Location | Description |
|:--|:---------|:------------|
| 1 | `home_screen.dart:536` | Open horoscope bottom sheet |
| 2 | `sonification.dart:493` | Remove after audio_service migration |
| 3 | `sonification_schemas.py:11` | Remove after Steiner system migration |
| 4 | `sonification.py:209` | Integrate with AI service |

---

## 🧹 Cleanup Required

### ⚠️ Deprecated Code — MIGRATION REQUIRED

These items are marked `@Deprecated` but **still have active usages** that must be migrated first:

| Deprecated Item | Location | Usages Found | Status |
|:----------------|:---------|:-------------|:-------|
| `dominantFrequency` | Line 291 | **6+ files** | ⏸️ Keep — used in sound_screen, profile_screen, friend_profile_screen |
| `planets` getter | Line 296 | **10+ files** | ⏸️ Keep — used in birth_chart_wheel, audio_service, chart_screen |
| `PlanetSound` class | Line 497 | **5+ files** | ⏸️ Keep — used in audio_service, align_screen, birth_chart_wheel_data |

**Next Steps:** Create a migration task to update all usages to new APIs before removing these.

### ✅ Debug Statements — FIXED

All `debugPrint()` calls now wrapped in `kDebugMode` in `lib/services/playlist_service.dart`:

| Line | Statement | Status |
|:-----|:----------|:-------|
| 93 | `Error loading cached playlist` | ✅ Wrapped |
| 137 | `Playlist generation error` | ✅ Wrapped |
| 194 | `Error loading playlist insight` | ✅ Wrapped |
| 244 | `Error creating Spotify playlist` | ✅ Wrapped |
| 293 | `Error creating Spotify playlist from library` | ✅ Wrapped |

### ✅ Unused Code — FIXED

| File | Line | Issue | Status |
|:-----|:-----|:------|:-------|
| `playlist_service.dart` | 23 | ~~`// ignore: unused_field`~~ | ✅ Removed — field IS used |
| `home_screen.dart` | 53 | ~~Dead comment about removed alignment data~~ | ✅ Removed |

---

## ✅ Silent Failures (Backend) — FIXED

These catch blocks ~~swallow errors without logging~~ now have proper logging:

| File | Line | Status |
|:-----|:-----|:-------|
| `spotify_sessions_db.py` | 238, 245 | ✅ Fixed — `logger.warning()` |
| `ai_service.py` | 291, 1065 | ✅ Fixed — `logger.debug()` |
| `user_library.py` | 114, 118 | ⏸️ Skipped — commented placeholder code |

---

##  Mock Data Inventory

### Frontend

| Component | Mock Location | Real Data Source |
|:----------|:--------------|:-----------------|
| User Auth | `auth_service.dart:60` | Firebase Auth |
| Friend Search | `add_friend_sheet.dart:22` | Backend API |
| Friend List | `test_users.dart` | Firestore |
| Subscription | `settings_screen.dart:20` | Payment backend |
| Referral Count | `referral_screen.dart:33` | Backend API |
| Spotify OAuth | `connect_music_screen.dart:203` | Real OAuth flow |
| Sound Data | `sound_screen.dart:83` | Already has real fallback |

### Backend

| Component | Mock Location | Notes |
|:----------|:--------------|:------|
| Song Library | `data/mock_library.json` | Replace with Spotify API |

---

## ✅ Action Plan

### This Week
- [ ] Replace localhost with env variable in `api_config.dart`
- [ ] Add logging to silent exception handlers
- [ ] Remove 3 deprecated items from `sonification.dart`

### Phase 2 (Firebase)
- [ ] Implement Firebase Auth (4 sign-in TODOs)
- [ ] Replace `AuthService` mock with real Firebase
- [ ] Add user profile storage in backend

### Phase 3 (Social)
- [ ] Connect friends to Firestore
- [ ] Replace `_mockUsers` with API search
- [ ] Implement friend request system

---

## 📈 Progress Tracker

```
Authentication    [░░░░░░░░░░] 0%   ← Phase 2
Social Features   [░░░░░░░░░░] 0%   ← Phase 3
Mock Removal      [██░░░░░░░░] 20%  ← In progress
Code Cleanup      [████░░░░░░] 40%  ← In progress
Core Features     [████████░░] 80%  ← Mostly done
```

---

<details>
<summary><b>📁 Files Scanned (click to expand)</b></summary>

### Frontend
- **Screens:** 13 files
- **Widgets:** 18+ files  
- **Services:** 10 files
- **Models:** 15 files

### Backend
- **Routes:** All API endpoints
- **Services:** 10+ modules
- **Tests:** Full coverage
</details>

---

*Last scanned: Dec 31, 2025 • Re-run audit after major changes*
