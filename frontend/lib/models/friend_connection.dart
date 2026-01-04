import 'package:flutter/material.dart';
import '../data/synastry_data.dart';

/// Represents the calculated synastry connection between the user and a friend.
class FriendConnection {
  /// The strongest aspect between the charts.
  final PrimaryAspect primaryAspect;
  
  /// Planets in the same sign or element.
  final List<SharedPlanet> sharedPlanets;
  
  /// Combined frequency based on aspect planets.
  final SharedFrequency sharedFrequency;
  
  /// Element compatibility between the two.
  final ElementMatch elementMatch;
  
  /// Song recommendations based on element combo.
  final List<SharedVibe> sharedVibes;
  
  /// One-line connection insight.
  final String insight;
  
  /// Mutual friends in common.
  final List<MutualFriend> mutuals;
  
  /// Cosmic genre based on element combination.
  final CosmicGenre sharedGenre;

  const FriendConnection({
    required this.primaryAspect,
    required this.sharedPlanets,
    required this.sharedFrequency,
    required this.elementMatch,
    required this.sharedVibes,
    required this.insight,
    required this.mutuals,
    required this.sharedGenre,
  });
  
  /// Create a mock connection for display when real data isn't available.
  factory FriendConnection.mock({
    required String friendElement,
    required String userElement,
  }) {
    // Get element match
    final elementKey = '$userElement-$friendElement';
    final compatData = elementCompatibility[elementKey] ?? 
        const ElementCompatibility(compatibility: 'neutral', meaning: 'A unique cosmic connection');
    
    return FriendConnection(
      primaryAspect: PrimaryAspect(
        yourPlanet: 'Moon',
        yourSymbol: '☽',
        theirPlanet: 'Pluto',
        theirSymbol: '♇',
        aspect: 'Trine',
        aspectSymbol: '△',
        quality: 'harmonious',
        orb: 2.5,
        meaning: 'Deep emotional transformation',
      ),
      sharedPlanets: [
        SharedPlanet(name: 'Pluto', symbol: '♇', sign: 'Scorpio', colorValue: 0xFF9D4EDD),
        SharedPlanet(name: 'Moon', symbol: '☽', sign: 'Water signs', colorValue: 0xFFC0C0C0),
      ],
      sharedFrequency: SharedFrequency(
        hz: 176,
        description: 'Transformative Depth',
        waveform: 'Layered sub-bass with fluid modulation',
      ),
      elementMatch: ElementMatch(
        yours: userElement,
        theirs: friendElement,
        symbol: elements[friendElement]?.symbol ?? '✦',
        compatibility: compatData.compatibility,
        meaning: compatData.meaning,
      ),
      sharedVibes: sharedVibesMapping['$userElement-$friendElement'] ?? defaultVibes,
      insight: _getInsight(userElement, friendElement),
      mutuals: [],
      sharedGenre: cosmicGenreMapping['$userElement-$friendElement'] ?? defaultGenre,
    );
  }
  
  static String _getInsight(String userElement, String friendElement) {
    final key = '$userElement-$friendElement';
    final insights = elementInsights[key];
    if (insights != null && insights.isNotEmpty) {
      return insights[0];
    }
    return 'A unique cosmic connection';
  }
}

/// Represents the strongest aspect between two charts.
class PrimaryAspect {
  final String yourPlanet;
  final String yourSymbol;
  final String theirPlanet;
  final String theirSymbol;
  final String aspect;
  final String aspectSymbol;
  final String quality;
  final double orb;
  final String meaning;

  const PrimaryAspect({
    required this.yourPlanet,
    required this.yourSymbol,
    required this.theirPlanet,
    required this.theirSymbol,
    required this.aspect,
    required this.aspectSymbol,
    required this.quality,
    required this.orb,
    required this.meaning,
  });
  
  /// Get the color for this aspect's quality.
  Color get qualityColor => getQualityColor(quality);
}

/// Represents a shared planetary placement.
class SharedPlanet {
  final String name;
  final String symbol;
  final String sign; // Either the sign name or "Element signs"
  final int colorValue;

  const SharedPlanet({
    required this.name,
    required this.symbol,
    required this.sign,
    required this.colorValue,
  });
  
  Color get color => Color(colorValue);
}

/// Represents the shared frequency between two charts.
class SharedFrequency {
  final int hz;
  final String description;
  final String waveform;

  const SharedFrequency({
    required this.hz,
    required this.description,
    required this.waveform,
  });
}

/// Represents the element compatibility match.
class ElementMatch {
  final String yours;
  final String theirs;
  final String symbol;
  final String compatibility; // 'same', 'compatible', 'neutral', 'challenging'
  final String meaning;

  const ElementMatch({
    required this.yours,
    required this.theirs,
    required this.symbol,
    required this.compatibility,
    required this.meaning,
  });
  
  /// Get display string for elements.
  String get displayText => '$symbol $yours × $theirs';
  
  /// Get color based on compatibility.
  Color get compatibilityColor {
    switch (compatibility) {
      case 'same':
      case 'compatible':
        return const Color(0xFF00D4AA); // Teal
      case 'challenging':
        return const Color(0xFFE84855); // Red
      default:
        return const Color(0xFFFAFF0E); // Yellow
    }
  }
}

/// Represents a mutual friend connection.
class MutualFriend {
  final String id;
  final String initials;
  final int colorValue;

  const MutualFriend({
    required this.id,
    required this.initials,
    required this.colorValue,
  });
  
  Color get color => Color(colorValue);
}
