import 'dart:math' as math;
import '../data/synastry_data.dart';
import '../models/friend_connection.dart';
import '../models/friend_data.dart';

/// Service for calculating synastry compatibility between users.
class SynastryService {
  /// Singleton instance.
  static final SynastryService _instance = SynastryService._internal();
  factory SynastryService() => _instance;
  SynastryService._internal();

  final _random = math.Random();

  /// Calculate the connection data between user and friend.
  /// Uses mock data when full natal charts aren't available.
  FriendConnection calculateConnection({
    required String userElement,
    required String friendElement,
    required String friendSunSign,
    List<String>? mutualPlanets,
    List<MutualFriend>? mutualFriends,
  }) {
    // Get element match
    final elementMatch = _getElementMatch(userElement, friendElement);
    
    // Generate primary aspect (mock for now)
    final primaryAspect = _generateMockAspect(userElement, friendElement);
    
    // Calculate shared frequency
    final sharedFrequency = _calculateSharedFrequency(primaryAspect);
    
    // Get shared planets
    final sharedPlanets = _getSharedPlanets(mutualPlanets);
    
    // Get song recommendations
    final sharedVibes = _getSharedVibes(userElement, friendElement);
    
    // Generate insight
    final insight = _generateInsight(elementMatch, primaryAspect);
    
    // Get cosmic genre
    final genreKey = '$userElement-$friendElement';
    final sharedGenre = cosmicGenreMapping[genreKey] ?? defaultGenre;
    
    return FriendConnection(
      primaryAspect: primaryAspect,
      sharedPlanets: sharedPlanets,
      sharedFrequency: sharedFrequency,
      elementMatch: elementMatch,
      sharedVibes: sharedVibes,
      insight: insight,
      mutuals: mutualFriends ?? [],
      sharedGenre: sharedGenre,
    );
  }

  /// Get element match data.
  ElementMatch _getElementMatch(String userElement, String friendElement) {
    final key = '$userElement-$friendElement';
    final compatData = elementCompatibility[key] ?? 
        const ElementCompatibility(compatibility: 'neutral', meaning: 'A unique cosmic connection');
    
    final theirElementData = elements[friendElement];
    
    return ElementMatch(
      yours: userElement,
      theirs: friendElement,
      symbol: theirElementData?.symbol ?? '✦',
      compatibility: compatData.compatibility,
      meaning: compatData.meaning,
    );
  }

  /// Generate a mock aspect (when real chart data isn't available).
  PrimaryAspect _generateMockAspect(String userElement, String friendElement) {
    // Select aspects based on compatibility
    final key = '$userElement-$friendElement';
    final compat = elementCompatibility[key];
    
    String aspect;
    String quality;
    
    if (compat?.compatibility == 'same' || compat?.compatibility == 'compatible') {
      // Harmonious aspects for compatible elements
      aspect = _random.nextBool() ? 'Trine' : 'Sextile';
      quality = 'harmonious';
    } else if (compat?.compatibility == 'challenging') {
      // Tense aspects for challenging elements
      aspect = _random.nextBool() ? 'Square' : 'Opposition';
      quality = 'tense';
    } else {
      // Mix for neutral
      aspect = 'Conjunction';
      quality = 'intense';
    }
    
    final aspectData = aspects[aspect]!;
    
    // Select planets based on elements
    final yourPlanet = _selectPlanetForElement(userElement);
    final theirPlanet = _selectPlanetForElement(friendElement);
    
    final yourPlanetData = planets[yourPlanet]!;
    final theirPlanetData = planets[theirPlanet]!;
    
    // Get meaning
    final meaning = _getAspectMeaning(yourPlanet, theirPlanet, quality);
    
    return PrimaryAspect(
      yourPlanet: yourPlanet,
      yourSymbol: yourPlanetData.symbol,
      theirPlanet: theirPlanet,
      theirSymbol: theirPlanetData.symbol,
      aspect: aspect,
      aspectSymbol: aspectData.symbol,
      quality: quality,
      orb: 1.0 + _random.nextDouble() * 4, // 1-5 degree orb
      meaning: meaning,
    );
  }

  /// Select a planet associated with an element.
  String _selectPlanetForElement(String element) {
    switch (element) {
      case 'Fire':
        return ['Sun', 'Mars', 'Jupiter'][_random.nextInt(3)];
      case 'Earth':
        return ['Venus', 'Saturn', 'Mercury'][_random.nextInt(3)];
      case 'Air':
        return ['Mercury', 'Venus', 'Uranus'][_random.nextInt(3)];
      case 'Water':
        return ['Moon', 'Neptune', 'Pluto'][_random.nextInt(3)];
      default:
        return 'Moon';
    }
  }

  /// Get aspect meaning from synastry data.
  String _getAspectMeaning(String planet1, String planet2, String quality) {
    // Sort planets alphabetically for consistent key
    final sortedPlanets = [planet1, planet2]..sort();
    final key = '${sortedPlanets[0]}-${sortedPlanets[1]}';
    
    final meanings = synastryMeanings[quality];
    if (meanings != null && meanings.containsKey(key)) {
      return meanings[key]!;
    }
    
    // Fallback
    final aspectData = aspects.values.firstWhere(
      (a) => a.quality == quality,
      orElse: () => aspects['Trine']!,
    );
    return 'Your $planet1 ${aspectData.description} their $planet2';
  }

  /// Calculate shared frequency from aspect.
  SharedFrequency _calculateSharedFrequency(PrimaryAspect aspect) {
    final freq1 = planets[aspect.yourPlanet]?.frequency ?? 140;
    final freq2 = planets[aspect.theirPlanet]?.frequency ?? 140;
    
    int blendedHz;
    switch (aspect.aspect) {
      case 'Conjunction':
        // Frequencies merge - average
        blendedHz = ((freq1 + freq2) / 2).round();
        break;
      case 'Trine':
      case 'Sextile':
        // Harmonious - golden ratio blend
        blendedHz = ((freq1 + freq2 * 1.618) / 2.618).round();
        break;
      case 'Square':
      case 'Opposition':
        // Tense - create beating frequency
        blendedHz = ((freq1 - freq2).abs() + math.min(freq1, freq2)).round();
        break;
      default:
        blendedHz = ((freq1 + freq2) / 2).round();
    }
    
    final descriptions = frequencyDescriptions[aspect.quality] ?? 
        frequencyDescriptions['harmonious']!;
    final description = descriptions[blendedHz % descriptions.length];
    
    return SharedFrequency(
      hz: blendedHz,
      description: description,
      waveform: _getWaveformDescription(aspect.yourPlanet, aspect.theirPlanet),
    );
  }

  /// Get waveform description.
  String _getWaveformDescription(String planet1, String planet2) {
    if (['Moon', 'Neptune', 'Pluto'].contains(planet1) || 
        ['Moon', 'Neptune', 'Pluto'].contains(planet2)) {
      return 'Layered sub-bass with fluid modulation';
    }
    if (['Sun', 'Mars', 'Jupiter'].contains(planet1) || 
        ['Sun', 'Mars', 'Jupiter'].contains(planet2)) {
      return 'Bright harmonics with dynamic pulse';
    }
    return 'Balanced mid-range with subtle movement';
  }

  /// Get shared planets from mutual planets list.
  List<SharedPlanet> _getSharedPlanets(List<String>? mutualPlanets) {
    if (mutualPlanets == null || mutualPlanets.isEmpty) {
      return [];
    }
    
    return mutualPlanets.take(3).map((planetName) {
      final planetData = planets[planetName];
      return SharedPlanet(
        name: planetName,
        symbol: planetData?.symbol ?? '★',
        sign: 'Shared sign', // Would be calculated from actual charts
        colorValue: planetData?.colorValue ?? 0xFFC0C0C0,
      );
    }).toList();
  }

  /// Get song recommendations by element combo.
  List<SharedVibe> _getSharedVibes(String userElement, String friendElement) {
    final key = '$userElement-$friendElement';
    return sharedVibesMapping[key] ?? defaultVibes;
  }

  /// Generate connection insight.
  String _generateInsight(ElementMatch elementMatch, PrimaryAspect aspect) {
    // Check if aspect is tight enough to use aspect-based insight
    if (aspect.orb < 3) {
      final aspectKey = '${aspect.yourPlanet}-${aspect.theirPlanet}';
      final reverseKey = '${aspect.theirPlanet}-${aspect.yourPlanet}';
      
      final insights = aspectInsights[aspectKey] ?? aspectInsights[reverseKey];
      if (insights != null && insights.isNotEmpty) {
        return insights[_random.nextInt(insights.length)];
      }
    }
    
    // Fall back to element combination
    final elementKey = '${elementMatch.yours}-${elementMatch.theirs}';
    final insights = elementInsights[elementKey];
    
    if (insights != null && insights.isNotEmpty) {
      return insights[_random.nextInt(insights.length)];
    }
    
    return 'A unique cosmic connection';
  }

  /// Calculate connection for a FriendData object.
  FriendConnection calculateConnectionForFriend({
    required FriendData friend,
    required String userElement,
    List<FriendData>? mutualFriends,
  }) {
    final mutuals = mutualFriends?.map((f) => MutualFriend(
      id: f.id.toString(),
      initials: f.initials,
      colorValue: f.primaryColorValue,
    )).toList() ?? [];
    
    return calculateConnection(
      userElement: userElement,
      friendElement: friend.element,
      friendSunSign: friend.sunSign,
      mutualPlanets: friend.mutualPlanets,
      mutualFriends: mutuals,
    );
  }
}
