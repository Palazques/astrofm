import 'dart:math';
import 'package:flutter/material.dart';
import '../config/design_tokens.dart';
import 'sonification.dart';

/// Planet data for positioning on the birth chart wheel.
class WheelPlanetData {
  final String name;
  final String symbol;
  final String sign;
  final int house;
  final double angle; // Position on wheel (degrees)
  final int frequency;
  final int intensity; // 0-100%
  final Color color;

  const WheelPlanetData({
    required this.name,
    required this.symbol,
    required this.sign,
    required this.house,
    required this.angle,
    required this.frequency,
    required this.intensity,
    required this.color,
  });

  /// Create from PlanetSound sonification data.
  factory WheelPlanetData.fromPlanetSound(PlanetSound planet) {
    return WheelPlanetData(
      name: planet.planet,
      symbol: _planetSymbols[planet.planet] ?? '★',
      sign: planet.sign,
      house: planet.house,
      angle: _calculateAngle(planet.house, planet.houseDegree),
      frequency: planet.frequency.round(),
      intensity: (planet.intensity * 100).round(),
      color: _planetColors[planet.planet] ?? AppColors.electricYellow,
    );
  }

  /// Calculate wheel angle from house and degree position.
  static double _calculateAngle(int house, double houseDegree) {
    // Each house is 30 degrees, starting from house 1 at the left (180°)
    // Houses go counter-clockwise in traditional charts
    final baseAngle = ((house - 1) * 30.0) + 180.0;
    final degreeOffset = (houseDegree / 30.0) * 30.0;
    return (baseAngle + degreeOffset) % 360;
  }

  static const Map<String, String> _planetSymbols = {
    'Sun': '☉',
    'Moon': '☽',
    'Mercury': '☿',
    'Venus': '♀',
    'Mars': '♂',
    'Jupiter': '♃',
    'Saturn': '♄',
    'Uranus': '♅',
    'Neptune': '♆',
    'Pluto': '♇',
  };

  static const Map<String, Color> _planetColors = {
    'Sun': Color(0xFFFAFF0E),
    'Moon': Color(0xFFC0C0C0),
    'Mercury': Color(0xFF50E3C2),
    'Venus': Color(0xFFFF59D0),
    'Mars': Color(0xFFE84855),
    'Jupiter': Color(0xFFFF8C42),
    'Saturn': Color(0xFF8B7355),
    'Uranus': Color(0xFF00D4AA),
    'Neptune': Color(0xFF7D67FE),
    'Pluto': Color(0xFF9B59B6),
  };
}

/// Aspect type definitions with visual properties.
enum AspectType {
  conjunction(
    name: 'Conjunct',
    symbol: '☌',
    color: Color(0xFFFAFF0E),
    angle: 0,
    orb: 8,
    isDashed: false,
    harmony: 'blend',
  ),
  sextile(
    name: 'Sextile',
    symbol: '⚹',
    color: Color(0xFF7D67FE),
    angle: 60,
    orb: 8,
    isDashed: false,
    harmony: 'harmonious',
  ),
  square(
    name: 'Square',
    symbol: '□',
    color: Color(0xFFE84855),
    angle: 90,
    orb: 8,
    isDashed: true,
    harmony: 'tense',
  ),
  trine(
    name: 'Trine',
    symbol: '△',
    color: Color(0xFF00D4AA),
    angle: 120,
    orb: 8,
    isDashed: false,
    harmony: 'harmonious',
  ),
  opposition(
    name: 'Opposition',
    symbol: '☍',
    color: Color(0xFFFF59D0),
    angle: 180,
    orb: 8,
    isDashed: true,
    harmony: 'tense',
  );

  final String name;
  final String symbol;
  final Color color;
  final double angle;
  final double orb;
  final bool isDashed;
  final String harmony;

  const AspectType({
    required this.name,
    required this.symbol,
    required this.color,
    required this.angle,
    required this.orb,
    required this.isDashed,
    required this.harmony,
  });
}

/// Aspect between two planets.
class WheelAspectData {
  final String planet1;
  final String planet2;
  final AspectType type;
  final double orb;

  const WheelAspectData({
    required this.planet1,
    required this.planet2,
    required this.type,
    required this.orb,
  });

  String get name => type.name;
  String get symbol => type.symbol;
  Color get color => type.color;
  bool get isDashed => type.isDashed;
  String get harmony => type.harmony;
}

/// Zodiac sign data with element-based coloring.
class ZodiacSignData {
  final String name;
  final String element;
  final Color color;

  const ZodiacSignData({
    required this.name,
    required this.element,
    required this.color,
  });

  static const List<ZodiacSignData> allSigns = [
    ZodiacSignData(name: 'Aries', element: 'Fire', color: Color(0xFFE84855)),
    ZodiacSignData(name: 'Taurus', element: 'Earth', color: Color(0xFF8B7355)),
    ZodiacSignData(name: 'Gemini', element: 'Air', color: Color(0xFF7D67FE)),
    ZodiacSignData(name: 'Cancer', element: 'Water', color: Color(0xFF00D4AA)),
    ZodiacSignData(name: 'Leo', element: 'Fire', color: Color(0xFFFF8C42)),
    ZodiacSignData(name: 'Virgo', element: 'Earth', color: Color(0xFF8B7355)),
    ZodiacSignData(name: 'Libra', element: 'Air', color: Color(0xFF7D67FE)),
    ZodiacSignData(name: 'Scorpio', element: 'Water', color: Color(0xFF9B59B6)),
    ZodiacSignData(name: 'Sagittarius', element: 'Fire', color: Color(0xFFE84855)),
    ZodiacSignData(name: 'Capricorn', element: 'Earth', color: Color(0xFF8B7355)),
    ZodiacSignData(name: 'Aquarius', element: 'Air', color: Color(0xFF00D4AA)),
    ZodiacSignData(name: 'Pisces', element: 'Water', color: Color(0xFF00D4AA)),
  ];
}

/// Utility class for calculating aspects between planets.
class AspectCalculator {
  /// Calculate all aspects between planets.
  static List<WheelAspectData> calculateAspects(List<WheelPlanetData> planets) {
    final aspects = <WheelAspectData>[];

    for (var i = 0; i < planets.length; i++) {
      for (var j = i + 1; j < planets.length; j++) {
        final aspect = _detectAspect(planets[i], planets[j]);
        if (aspect != null) {
          aspects.add(aspect);
        }
      }
    }

    return aspects;
  }

  /// Detect if an aspect exists between two planets.
  static WheelAspectData? _detectAspect(
    WheelPlanetData planet1,
    WheelPlanetData planet2,
  ) {
    final distance = _angularDistance(planet1.angle, planet2.angle);

    for (final aspectType in AspectType.values) {
      final orb = (distance - aspectType.angle).abs();
      if (orb <= aspectType.orb) {
        return WheelAspectData(
          planet1: planet1.name,
          planet2: planet2.name,
          type: aspectType,
          orb: orb,
        );
      }
    }

    return null;
  }

  /// Calculate shortest angular distance between two angles.
  static double _angularDistance(double angle1, double angle2) {
    var diff = (angle1 - angle2).abs();
    if (diff > 180) {
      diff = 360 - diff;
    }
    return diff;
  }

  /// Get all aspects for a specific planet.
  static List<WheelAspectData> getAspectsForPlanet(
    String planetName,
    List<WheelAspectData> allAspects,
  ) {
    return allAspects
        .where((a) => a.planet1 == planetName || a.planet2 == planetName)
        .toList();
  }

  /// Get the other planet in an aspect.
  static String getOtherPlanet(WheelAspectData aspect, String planetName) {
    return aspect.planet1 == planetName ? aspect.planet2 : aspect.planet1;
  }
}

/// Utility for polar coordinate calculations.
class WheelGeometry {
  /// Get x,y position on wheel from angle and radius.
  static Offset getPositionOnWheel(double angleDegrees, double radius) {
    final radians = (angleDegrees - 90) * (pi / 180);
    return Offset(
      cos(radians) * radius,
      sin(radians) * radius,
    );
  }
}
