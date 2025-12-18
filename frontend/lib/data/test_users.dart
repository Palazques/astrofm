/// Test users data for development and testing purposes.
/// These mock friends have complete birth data for API testing.

import '../models/friend_data.dart';
import '../config/design_tokens.dart';

/// Example test users with complete birth data for testing friend alignment.
final List<FriendData> testFriends = [
  FriendData(
    id: 1,
    name: 'Maya Chen',
    username: '@mayavibes',
    sunSign: 'Pisces',
    moonSign: 'Cancer',
    risingSign: 'Scorpio',
    compatibilityScore: 87,
    avatarColors: [AppColors.hotPink.value, AppColors.cosmicPurple.value],
    dominantFrequency: '432 Hz',
    element: 'Water',
    modality: 'Mutable',
    // Birth data for API calls
    birthDatetime: '1992-03-21T14:30:00',
    birthLatitude: 40.7128,
    birthLongitude: -74.0060,
    birthTimezone: 'America/New_York',
  ),
  FriendData(
    id: 2,
    name: 'Jordan Rivers',
    username: '@jordanflow',
    sunSign: 'Sagittarius',
    moonSign: 'Aries',
    risingSign: 'Leo',
    compatibilityScore: 72,
    avatarColors: [AppColors.electricYellow.value, AppColors.hotPink.value],
    dominantFrequency: '528 Hz',
    element: 'Fire',
    modality: 'Mutable',
    birthDatetime: '1994-12-05T08:15:00',
    birthLatitude: 34.0522,
    birthLongitude: -118.2437,
    birthTimezone: 'America/Los_Angeles',
  ),
  FriendData(
    id: 3,
    name: 'Alex Kim',
    username: '@alexcosmic',
    sunSign: 'Aquarius',
    moonSign: 'Libra',
    risingSign: 'Gemini',
    compatibilityScore: 91,
    avatarColors: [AppColors.cosmicPurple.value, AppColors.teal.value],
    dominantFrequency: '639 Hz',
    element: 'Air',
    modality: 'Fixed',
    birthDatetime: '1995-02-14T22:45:00',
    birthLatitude: 37.7749,
    birthLongitude: -122.4194,
    birthTimezone: 'America/Los_Angeles',
  ),
  FriendData(
    id: 4,
    name: 'Sam Taylor',
    username: '@samstars',
    sunSign: 'Taurus',
    moonSign: 'Capricorn',
    risingSign: 'Virgo',
    compatibilityScore: 65,
    avatarColors: [AppColors.teal.value, AppColors.electricYellow.value],
    dominantFrequency: '396 Hz',
    element: 'Earth',
    modality: 'Fixed',
    birthDatetime: '1991-05-10T06:30:00',
    birthLatitude: 41.8781,
    birthLongitude: -87.6298,
    birthTimezone: 'America/Chicago',
  ),
  FriendData(
    id: 5,
    name: 'Riley Moon',
    username: '@rileymoon',
    sunSign: 'Cancer',
    moonSign: 'Pisces',
    risingSign: 'Sagittarius',
    compatibilityScore: 84,
    avatarColors: [AppColors.hotPink.value, AppColors.electricYellow.value],
    dominantFrequency: '741 Hz',
    element: 'Water',
    modality: 'Cardinal',
    birthDatetime: '1993-07-04T12:00:00',
    birthLatitude: 29.7604,
    birthLongitude: -95.3698,
    birthTimezone: 'America/Chicago',
  ),
];

/// Get a test friend by ID.
FriendData? getTestFriendById(int id) {
  try {
    return testFriends.firstWhere((f) => f.id == id);
  } catch (_) {
    return null;
  }
}

/// Default test birth data for the current user (for testing without onboarding).
const defaultTestBirthData = {
  'name': 'Paul',
  'datetime': '1990-07-15T15:42:00',
  'latitude': 34.0522,
  'longitude': -118.2437,
  'timezone': 'America/Los_Angeles',
  'locationName': 'Los Angeles, CA',
};
