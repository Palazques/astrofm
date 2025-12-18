# ASTRO.FM Development Roadmap

**Created**: December 17, 2025  
**Last Updated**: December 18, 2025 (10:30 AM)  
**Status**: Active Development — Phase 1.2 in Progress (4/5)

---

## Overview

This document outlines the phased development approach for ASTRO.FM, balancing feature development with strategic Firebase integration. The goal is to maximize productive work while delaying complex infrastructure until essential.

---

## Current State Summary

### ✅ What's Working
| Component | Status | Notes |
|-----------|--------|-------|
| FastAPI Backend | ✅ Operational | Running on localhost:8000 |
| Alignment Engine | ✅ Integrated | Swiss Ephemeris calculations working |
| Sonification API | ✅ Functional | Audio generation complete |
| Playlist Matching | ✅ Functional | Algorithm implemented |
| AI Daily Reading | ✅ Functional | Gemini integration working |
| Flutter App | ✅ Running | Basic navigation and screens |
| Onboarding Flow | ⚠️ Partial | UI complete, data not persisted |

### ❌ Known Gaps (from QA Audit)
- 28 non-functional UI elements (empty button handlers)
- 18 missing backend connections
- No user authentication
- No persistent user data
- Social features mocked (friends, connections)

---

## Development Phases

### 📌 PHASE 1: UI Wiring & Polish (No Firebase Required)
**Estimated Time**: 1-2 weeks  
**Goal**: Make the app feel complete with existing backend

#### 1.1 Navigation Wiring ✅ COMPLETE
- [x] Wire all empty button handlers to appropriate screens
- [x] Make "See All" links tappable
- [x] Connect menu items to destination screens
- [x] Implement proper back navigation throughout

#### 1.2 Backend API Integration
| Task | Screen(s) | API Endpoint | Priority |
|------|-----------|--------------|----------|
| Daily alignment score | Home, Align | `/api/alignment/daily` | 🔴 High |
| Friend synastry | Friend Profile | `/api/alignment/friend` | 🔴 High |
| User sonification | Sound | `/api/sonification/user` | 🟡 Medium |
| Playlist generation | Home | `/api/playlist/generate` | 🟡 Medium |
| Transit positions | Align, Home | `/api/alignment/transits` | 🟢 Low |

#### 1.3 Local Storage (SharedPreferences)
- [x] Persist notification toggle settings → **Deferred to Settings page (Phase 2)**
- [x] Save user's birth data locally for testing
- [x] Remember last-used friend selection
- [x] Store onboarding completion state

#### 1.4 Loading & Error States
- [x] Add skeleton loaders to all data-dependent screens
- [x] Implement error message displays
- [x] Add retry buttons for failed requests
- [x] Disable buttons during in-flight requests (already done for playlist)

#### 1.5 Onboarding Completion
- [x] Validate all form inputs
- [x] Add smooth transitions between screens
- [x] Implement progress indicator
- [x] Store onboarding data locally
- [x] Expand genre selection (15 main + 30 subgenres)
- [x] Add premium subscription screen (3 pricing tiers)
- [x] Update referral screen (3-month discount instead of lifetime)
- [x] Firebase-ready data models (UserProfile, Membership, Referral)

---

### 📌 PHASE 2: Firebase Auth (Minimal Integration)
**Estimated Time**: 2-3 days  
**Goal**: Real user accounts without full Firestore complexity

#### 2.1 Firebase Project Setup
- [ ] Create Firebase project
- [ ] Add Flutter app to Firebase
- [ ] Configure Android/iOS/Web credentials
- [ ] Add `firebase_core` and `firebase_auth` packages

#### 2.2 Authentication Flow
- [ ] Implement sign-up screen (email/password)
- [ ] Implement sign-in screen
- [ ] Add password reset flow
- [ ] Create auth state listener
- [ ] Redirect unauthenticated users to login

#### 2.3 User ID Integration
- [ ] Pass Firebase `uid` to all API calls
- [ ] Update FastAPI endpoints to accept `userId` parameter
- [ ] Create user profile table in backend database (SQLite/PostgreSQL)

#### 2.4 Birth Data Storage (Backend, Not Firestore)
- [ ] Create `/api/users/profile` endpoint
- [ ] Store birth data in backend database
- [ ] Load user profile on app launch
- [ ] Update from onboarding flow

#### 2.5 Usage Tracking & Limits
- [ ] Track friend alignments used per week
- [ ] Track personal alignments used per week
- [ ] Track playlist songs generated per day
- [ ] Implement weekly reset logic
- [ ] Enforce free tier limits based on membership status
- [ ] Show usage indicators in UI

---

### 📌 PHASE 3: Social Features (Firestore Integration)
**Estimated Time**: 1-2 weeks  
**Goal**: Real friends, connections, and social interactions

#### 3.1 Firestore Data Model
```
users/
  {uid}/
    profile: { name, birthData, settings }
    connections/
      {friendId}: { status, createdAt }
    
friendRequests/
  {requestId}: { from, to, status, createdAt }
```

#### 3.2 Friends Management
- [ ] Send friend request
- [ ] Accept/decline friend request
- [ ] Remove friend
- [ ] Block user
- [ ] Real-time connection list updates

#### 3.3 Connections Screen
- [ ] Load real friends list from Firestore
- [ ] Load pending requests
- [ ] Implement search (by username or email)
- [ ] Show real compatibility scores for each friend

#### 3.4 Friend Profile Screen
- [ ] Load friend data from Firestore + backend
- [ ] Calculate real compatibility via API
- [ ] Show friend's real sign/chart data
- [ ] Enable real playlist sharing

---

### 📌 PHASE 4: Advanced Features
**Estimated Time**: 2-4 weeks  
**Goal**: Full-featured production app

#### 4.1 Push Notifications (Firebase Cloud Messaging)
- [ ] Daily alignment reminder
- [ ] Friend request notifications
- [ ] New alignment opportunity alerts
- [ ] Retrograde warnings

#### 4.2 Analytics (Firebase Analytics)
- [ ] Track screen views
- [ ] Track alignment completions
- [ ] Track playlist generations
- [ ] Monitor onboarding drop-off

#### 4.3 Cloud Functions
- [ ] Daily horoscope generation (scheduled)
- [ ] Friend alignment calculations (triggered)
- [ ] Playlist refresh (periodic)

#### 4.4 Additional Features
- [ ] Achievements system
- [ ] Streak tracking
- [ ] Calendar integration
- [ ] Share to social media

---

## Screen-by-Screen Priority

Based on QA audit, prioritized by user impact:

| Priority | Screen | Key Issues | Phase |
|----------|--------|------------|-------|
| 🔴 1 | Home Screen | 7 non-functional elements, 4 missing backend | Phase 1 |
| 🔴 2 | Align Screen | Fake alignment simulation | Phase 1 |
| 🔴 3 | Connections Screen | All mock data | Phase 3 |
| 🔴 4 | Friend Profile Screen | All mock data, no sound | Phase 3 |
| 🟡 5 | Profile Screen | 8 non-functional elements | Phase 2 |
| 🟡 6 | Sound Screen | 2 non-functional, 2 mock | Phase 1 |
| ✅ 7 | Chart Screen | Fully functional | — |
| ✅ 8 | Birth Input Screen | Fully functional | — |

---

## API Endpoints Reference

### Already Implemented (Backend)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/alignment/daily` | POST | Calculate daily alignment |
| `/api/alignment/friend` | POST | Calculate friend synastry |
| `/api/alignment/transits` | GET | Get current transits |
| `/api/sonification/user` | POST | Generate user sound |
| `/api/sonification/daily` | GET | Generate daily sound |
| `/api/playlist/generate` | POST | Personalized playlist |
| `/api/ai/daily-reading` | POST | AI horoscope |
| `/api/ai/compatibility` | POST | AI compatibility analysis |
| `/api/charts` | POST | Calculate natal chart |
| `/api/geocoding/search` | GET | Location search |

### Needs Implementation (Backend)
| Endpoint | Method | Purpose | Phase |
|----------|--------|---------|-------|
| `/api/users/profile` | GET/POST | User profile CRUD | Phase 2 |
| `/api/users/{id}/playlists` | GET | User's saved playlists | Phase 3 |
| `/api/horoscope/{sign}` | GET | Sign-specific horoscope | Phase 3 |

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-12-17 | Delay Firestore, start with Auth only | Avoid complexity, backend already handles astrology |
| 2025-12-17 | Store user data in backend DB, not Firestore | Keeps astrology logic centralized |
| 2025-12-17 | Phase 1 focuses on wiring, not new features | Make existing work functional before adding |

---

## Quick Reference: Next Actions

### If You Have 30 Minutes
- Wire Profile screen menu items to destinations
- Add loading state to one screen
- Make "See All" links tappable

### If You Have 1 Hour
- Connect friend alignment to real API
- Implement local settings persistence
- Add error handling to one screen

### If You Have 1 Day
- Complete Phase 1.1 (all navigation wiring)
- Set up Firebase project (no code yet)
- Implement skeleton loaders for Home screen

---

## Files to Reference

| Document | Location | Purpose |
|----------|----------|---------|
| Product Vision | [product_vision.md](file:///c:/ASTROFM/docs/product_vision.md) | App goals and features |
| Technical Stack | [technical_stack.md](file:///c:/ASTROFM/docs/technical_stack.md) | Architecture decisions |
| Astrology Logic | [astrology_vibe_logic.md](file:///c:/ASTROFM/docs/astrology_vibe_logic.md) | Calculation rules |
| Full Audit | [full_app_audit.md](file:///C:/Users/Paelazques/.gemini/antigravity/brain/2519a42d-ebf6-4f0e-bec0-045b61859a04/full_app_audit.md) | Detailed QA findings |

---

## Progress Tracking

### Phase 1 Progress
- [x] 1.1 Navigation Wiring (4/4) ✅
- [x] 1.2 Backend API Integration (4/5) ✅ — Friend synastry blocked until Phase 3
- [x] 1.3 Local Storage (4/4) ✅ — Notifications deferred to Settings page
- [x] 1.4 Loading & Error States (4/4) ✅
- [x] 1.5 Onboarding Completion (8/8) ✅ — Expanded with premium screen, genres, referral

### Phase 2 Progress
- [ ] 2.1 Firebase Project Setup (0/4)
- [ ] 2.2 Authentication Flow (0/5)
- [ ] 2.3 User ID Integration (0/3)
- [ ] 2.4 Birth Data Storage (0/4)
- [ ] 2.5 Usage Tracking & Limits (0/6)

### Phase 3 Progress
- [ ] 3.1 Firestore Data Model (0/1)
- [ ] 3.2 Friends Management (0/5)
- [ ] 3.3 Connections Screen (0/4)
- [ ] 3.4 Friend Profile Screen (0/4)

---

*This document should be updated as development progresses. Check off items as completed and update the "Last Updated" date.*
