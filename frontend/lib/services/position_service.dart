import 'dart:math' as math;
import 'dart:ui';
import '../models/friend_data.dart';

/// Service for calculating scattered positions of friend orbs on the constellation map.
/// Uses seeded random for deterministic positioning and collision detection.
class PositionService {
  /// Singleton instance
  static final PositionService _instance = PositionService._internal();
  factory PositionService() => _instance;
  PositionService._internal();

  /// Minimum distance between orb centers (prevents overlap)
  static const double minDistance = 55.0;
  
  /// Maximum attempts for collision resolution
  static const int maxAttempts = 50;

  /// Seeded random for consistent positions based on friend ID
  double seededRandom(int seed) {
    final x = math.sin(seed * 9999) * 10000;
    return x - x.floor();
  }

  /// Calculate scattered positions for all friends with collision detection
  /// Returns a Map of friend ID to position Offset
  Map<int, Offset> calculatePositions(
    List<FriendData> friends,
    Size containerSize, {
    double padding = 35.0,
  }) {
    final positions = <int, Offset>{};
    final placedPositions = <Offset>[];

    final availableWidth = containerSize.width - (padding * 2);
    final availableHeight = containerSize.height - (padding * 2);

    for (final friend in friends) {
      // Initial position from seeded random using friend ID
      final seed1 = friend.id * 137;
      final seed2 = friend.id * 251;

      double x = padding + seededRandom(seed1) * availableWidth;
      double y = padding + seededRandom(seed2) * availableHeight;

      // Collision detection and resolution
      int attempts = 0;
      bool hasOverlap = true;

      while (hasOverlap && attempts < maxAttempts) {
        hasOverlap = false;

        for (final placed in placedPositions) {
          final distance = (Offset(x, y) - placed).distance;

          if (distance < minDistance) {
            hasOverlap = true;

            // Nudge away from overlapping orb
            final angle = math.atan2(y - placed.dy, x - placed.dx);
            final nudgeDistance = minDistance - distance + 5;

            x += math.cos(angle) * nudgeDistance;
            y += math.sin(angle) * nudgeDistance;

            // Keep within bounds
            x = x.clamp(padding, containerSize.width - padding);
            y = y.clamp(padding, containerSize.height - padding);

            break;
          }
        }

        attempts++;
      }

      final position = Offset(x, y);
      positions[friend.id] = position;
      placedPositions.add(position);
    }

    return positions;
  }

  /// Calculate orb size based on compatibility score (28-40px range)
  double calculateOrbSize(int compatibilityWithUser) {
    const double baseSize = 28.0;
    const double maxBonus = 12.0;
    
    // Scale from 50-100 compatibility to 0-1 bonus factor
    final factor = ((compatibilityWithUser - 50) / 50).clamp(0.0, 1.0);
    
    return baseSize + (factor * maxBonus);
  }

  /// Calculate glow opacity based on compatibility score (0.2 - 0.6 range)
  double calculateGlowOpacity(int compatibilityWithUser) {
    const double baseOpacity = 0.2;
    const double maxBonus = 0.4;
    
    final factor = ((compatibilityWithUser - 50) / 50).clamp(0.0, 1.0);
    
    return baseOpacity + (factor * maxBonus);
  }
}
