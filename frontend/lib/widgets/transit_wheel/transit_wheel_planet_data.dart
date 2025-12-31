import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/alignment.dart';
import 'transit_planet_orb.dart';

/// Transit-specific planet data for positioning on the transit wheel.
/// 
/// Contains transit position info, retrograde status, and personal impact data
/// derived from comparing transit positions to the user's natal chart.
class TransitWheelPlanetData {
  final String name;
  final String symbol;
  final String sign;
  final double degree;
  final int? natalHouse; // Which house the transit activates in natal chart
  final bool isRetrograde;
  final DateTime? retrogradeStart;
  final DateTime? retrogradeEnd;
  final bool isHighlight; // "Today's Highlight Planet"
  final double angle; // Position on wheel (0-360 degrees)
  final Color color;

  const TransitWheelPlanetData({
    required this.name,
    required this.symbol,
    required this.sign,
    required this.degree,
    this.natalHouse,
    required this.isRetrograde,
    this.retrogradeStart,
    this.retrogradeEnd,
    this.isHighlight = false,
    required this.angle,
    required this.color,
  });

  /// Create from TransitPosition API model.
  factory TransitWheelPlanetData.fromTransitPosition(
    TransitPosition transit, {
    bool isHighlight = false,
  }) {
    // Parse retrograde dates if available
    DateTime? retrogradeStartDate;
    DateTime? retrogradeEndDate;
    if (transit.retrogradeStart != null) {
      retrogradeStartDate = DateTime.tryParse(transit.retrogradeStart!);
    }
    if (transit.retrogradeEnd != null) {
      retrogradeEndDate = DateTime.tryParse(transit.retrogradeEnd!);
    }

    return TransitWheelPlanetData(
      name: transit.name,
      symbol: getPlanetSymbol(transit.name),
      sign: transit.sign,
      degree: transit.degree,
      natalHouse: transit.house,
      isRetrograde: transit.retrograde,
      retrogradeStart: retrogradeStartDate,
      retrogradeEnd: retrogradeEndDate,
      isHighlight: isHighlight,
      angle: _calculateAngleFromSign(transit.sign, transit.degree),
      color: getPlanetColor(transit.name),
    );
  }

  /// Calculate wheel angle from zodiac sign and degree within the sign.
  /// 
  /// The wheel displays zodiac signs in order starting with Aries at 0°.
  /// Each sign occupies 30 degrees of the wheel.
  static double _calculateAngleFromSign(String sign, double degreeInSign) {
    const signOrder = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    
    final signIndex = signOrder.indexOf(sign);
    if (signIndex == -1) return 0;
    
    // Each sign is 30 degrees, starting from Aries at index 0
    final clampedDegree = degreeInSign.clamp(0.0, 30.0);
    return (signIndex * 30.0) + clampedDegree;
  }

  /// Returns a formatted position string like "Mercury in Capricorn 14.3°"
  String get formattedPosition => '$name in $sign ${degree.toStringAsFixed(1)}°';

  /// Returns formatted retrograde date range if retrograde
  String? get retrogradeTimeline {
    if (!isRetrograde || retrogradeStart == null || retrogradeEnd == null) {
      return null;
    }
    final startStr = _formatDate(retrogradeStart!);
    final endStr = _formatDate(retrogradeEnd!);
    return '$startStr – $endStr';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Get x,y position on transit wheel from angle and radius.
Offset getTransitPositionOnWheel(double angleDegrees, double radius) {
  final radians = (angleDegrees - 90) * (pi / 180);
  return Offset(
    cos(radians) * radius,
    sin(radians) * radius,
  );
}

/// General transit meaning descriptions for each planet.
const Map<String, String> planetTransitMeanings = {
  'Sun': 'Illuminates themes of identity, vitality, and self-expression. Focus on personal goals and leadership.',
  'Moon': 'Highlights emotional needs, instincts, and domestic matters. A day for nurturing and intuition.',
  'Mercury': 'Activates communication, thinking, and short travels. Good for learning and connecting.',
  'Venus': 'Brings focus to love, beauty, values, and finances. Favorable for relationships and pleasures.',
  'Mars': 'Energizes action, drive, and assertiveness. Channel this energy into physical activities or projects.',
  'Jupiter': 'Expands opportunities, optimism, and growth. Look for luck and learning experiences.',
  'Saturn': 'Calls for discipline, responsibility, and structure. Time to work on long-term foundations.',
  'Uranus': 'Sparks innovation, change, and unexpected events. Embrace originality and freedom.',
  'Neptune': 'Heightens intuition, creativity, and spiritual awareness. Be mindful of illusions.',
  'Pluto': 'Intensifies transformation, power dynamics, and deep psychological processes.',
};

/// House activation meanings for personal transit impact.
const Map<int, String> houseActivationMeanings = {
  1: 'Self, appearance, new beginnings',
  2: 'Finances, values, self-worth',
  3: 'Communication, siblings, short trips',
  4: 'Home, family, emotional foundations',
  5: 'Creativity, romance, children, fun',
  6: 'Health, daily routines, service',
  7: 'Partnerships, relationships, contracts',
  8: 'Transformation, shared resources, intimacy',
  9: 'Higher learning, travel, philosophy',
  10: 'Career, public image, authority',
  11: 'Friends, groups, hopes, wishes',
  12: 'Spirituality, subconscious, solitude',
};
