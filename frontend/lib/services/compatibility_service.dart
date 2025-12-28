import 'dart:math' as math;
import '../models/friend_data.dart';
import '../models/constellation_connection.dart';

/// Service for calculating zodiac sign compatibility between friends.
/// Uses element-based compatibility matrix per astrology logic.
class CompatibilityService {
  /// Singleton instance
  static final CompatibilityService _instance = CompatibilityService._internal();
  factory CompatibilityService() => _instance;
  CompatibilityService._internal();

  /// Maps zodiac signs to their elements
  static const Map<String, String> signElements = {
    'Aries': 'fire',
    'Leo': 'fire',
    'Sagittarius': 'fire',
    'Taurus': 'earth',
    'Virgo': 'earth',
    'Capricorn': 'earth',
    'Gemini': 'air',
    'Libra': 'air',
    'Aquarius': 'air',
    'Cancer': 'water',
    'Scorpio': 'water',
    'Pisces': 'water',
  };

  /// Element compatibility matrix
  /// Same element = 90%, Complementary = 80%, Neutral = 50%, Opposing = 40%
  static const Map<String, Map<String, int>> elementCompatibility = {
    'fire': {'fire': 90, 'air': 80, 'earth': 50, 'water': 40},
    'earth': {'earth': 90, 'water': 80, 'fire': 50, 'air': 40},
    'air': {'air': 90, 'fire': 80, 'water': 50, 'earth': 40},
    'water': {'water': 90, 'earth': 80, 'air': 50, 'fire': 40},
  };

  /// Seeded random for deterministic variance
  double _seededRandom(int seed) {
    final x = math.sin(seed * 9999) * 10000;
    return x - x.floor();
  }

  /// Get element for a zodiac sign
  String? getElement(String sign) => signElements[sign];

  /// Calculate compatibility between two friends based on their signs
  int getFriendCompatibility(FriendData friend1, FriendData friend2) {
    final element1 = signElements[friend1.sunSign];
    final element2 = signElements[friend2.sunSign];

    if (element1 == null || element2 == null) return 50;

    final baseCompat = elementCompatibility[element1]![element2] ?? 50;

    // Add variance based on ID combination for uniqueness (-10 to +10)
    final variance = (_seededRandom(friend1.id * friend2.id) - 0.5) * 20;

    return (baseCompat + variance).round().clamp(0, 100);
  }

  /// Build list of connections between friends above compatibility threshold
  List<ConstellationConnection> buildConnections(
    List<FriendData> friends, {
    int threshold = 70,
  }) {
    final connections = <ConstellationConnection>[];

    for (int i = 0; i < friends.length; i++) {
      for (int j = i + 1; j < friends.length; j++) {
        final compat = getFriendCompatibility(friends[i], friends[j]);

        if (compat >= threshold) {
          connections.add(ConstellationConnection(
            from: friends[i],
            to: friends[j],
            compatibility: compat,
          ));
        }
      }
    }

    return connections;
  }

  /// Get all friends connected to a specific friend
  List<FriendData> getConnectedFriends(
    FriendData friend,
    List<ConstellationConnection> connections,
  ) {
    final connected = <FriendData>[];

    for (final conn in connections) {
      if (conn.from.id == friend.id) {
        connected.add(conn.to);
      } else if (conn.to.id == friend.id) {
        connected.add(conn.from);
      }
    }

    return connected;
  }

  /// Get color based on compatibility score
  static int getCompatibilityColorValue(int score) {
    if (score >= 85) return 0xFF00D4AA; // Teal/green - high
    if (score >= 70) return 0xFFFAFF0E; // Yellow - good
    if (score >= 50) return 0xFFFF8C42; // Orange - medium
    return 0xFFE84855; // Red - low
  }
}
