# Constellation Map - Real Data Integration Notes

> **Created**: 2025-12-28  
> **Status**: Mock Data (awaiting backend integration)  
> **Priority**: Phase 3 (Social Features)

## Current Implementation

The Constellation Map feature is **fully implemented in the frontend** but uses **hardcoded mock data**. It needs to be connected to real user/friends data.

### Files Involved

| File | Purpose |
|------|---------|
| `lib/screens/connections_screen.dart` | Main screen, holds mock `_friends` list |
| `lib/widgets/connections/constellation_map.dart` | Map widget with orbs and lines |
| `lib/widgets/connections/friend_orb.dart` | Individual friend star orb |
| `lib/widgets/connections/friend_detail_card.dart` | Detail card when friend is selected |
| `lib/widgets/connections/background_stars.dart` | Background star field + nebula |
| `lib/services/compatibility_service.dart` | Calculates zodiac compatibility |
| `lib/services/position_service.dart` | Calculates orb positions with collision detection |
| `lib/models/friend_data.dart` | Friend data model |
| `lib/models/constellation_connection.dart` | Connection between two friends |

---

## What Needs to Change for Real Data

### 1. Replace Mock Friends List

**Current** (in `connections_screen.dart`):
```dart
_friends = [
  FriendData(id: 1, name: 'Maya Chen', sunSign: 'Pisces', ...),
  FriendData(id: 2, name: 'Jordan Rivera', sunSign: 'Aries', ...),
  // ... hardcoded
];
```

**Future**: Fetch from API/Firebase:
```dart
@override
void initState() {
  super.initState();
  _loadFriends();
}

Future<void> _loadFriends() async {
  final friends = await _friendsService.getFriends(userId);
  setState(() => _friends = friends);
}
```

### 2. User-Specific Compatibility

**Current**: Compatibility uses friend-to-friend calculation (element matrix + random variance)

**Future**: Should use **logged-in user's signs vs each friend's signs**:
```dart
// In compatibility_service.dart
int getUserFriendCompatibility(UserData user, FriendData friend) {
  // Compare user.sunSign, moonSign, risingSign with friend's
  // Return weighted average of all sign comparisons
}
```

### 3. Real-Time Status

**Current**: Status is hardcoded (`'online'` / `'offline'`)

**Future**: Should reflect actual online status from backend/Firebase presence

### 4. Pending Requests from Backend

**Current**: Mock `_pendingRequests` list

**Future**: Fetch from `/api/friends/pending` endpoint

---

## Uniqueness Per User

The constellation IS DESIGNED to be unique per user:

| Factor | How It Creates Uniqueness |
|--------|---------------------------|
| Friends list | Each user has different friends → different orbs |
| Orb positions | Seeded by `friend.id` → same friend always in same spot, but different friends = different layout |
| Compatibility scores | Based on USER's signs vs friend's signs → same friend has different score for different users |
| Connection lines | Only appear for >60% compat → different users see different networks |
| Orb size/glow | Based on compatibility → varies by user |

---

## API Endpoints Needed

```
GET  /api/friends                    → List user's friends as FriendData[]
GET  /api/friends/pending            → Pending friend requests
POST /api/friends/request/{userId}   → Send friend request
POST /api/friends/accept/{requestId} → Accept friend request
DELETE /api/friends/{friendId}       → Remove friend
GET  /api/compatibility/{friendId}   → Get detailed compatibility with friend
```

---

## Backend Data Requirements

### Friend record should include:
```json
{
  "id": "friend_user_id",
  "name": "Maya Chen",
  "username": "@mayachen",
  "avatarColors": [0xFFFF59AB, 0xFF7D67FE],
  "sunSign": "Pisces",
  "moonSign": "Cancer",
  "risingSign": "Scorpio",
  "element": "Water",
  "modality": "Mutable",
  "status": "online",
  "lastAligned": "2 hours ago",
  "mutualPlanets": ["Moon", "Venus"]
}
```

### User's birth data needed for compatibility:
- Sun sign, Moon sign, Rising sign
- Full birth chart (for detailed synastry later)

---

## Implementation Checklist

- [ ] Create `FriendsService` for API calls
- [ ] Add friends loading to `connections_screen.dart`
- [ ] Update `CompatibilityService` to use logged-in user's signs
- [ ] Connect pending requests to backend
- [ ] Add real-time status updates (Firebase or WebSocket)
- [ ] Handle empty state (no friends yet)
- [ ] Add loading states for async data
- [ ] Error handling for failed API calls

---

## Notes

- The seeded random positioning ensures the map looks consistent across reloads
- Collision detection prevents orbs from overlapping
- Animation timings are also seeded for variety but consistency
