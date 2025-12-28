import 'friend_data.dart';

/// Represents a connection between two friends in the constellation map.
/// Connection exists when their zodiac signs are compatible (threshold 70%+).
class ConstellationConnection {
  final FriendData from;
  final FriendData to;
  final int compatibility;  // Compatibility between the two friends (0-100)

  const ConstellationConnection({
    required this.from,
    required this.to,
    required this.compatibility,
  });
}
