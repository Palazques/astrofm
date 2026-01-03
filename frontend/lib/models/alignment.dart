/// Data models for alignment calculations.
/// These models correspond to the backend alignment API responses.

/// Individual aspect data between two planets.
class AspectData {
  final String planet1;
  final String planet2;
  final String aspect;
  final double orb;
  final String nature;

  AspectData({
    required this.planet1,
    required this.planet2,
    required this.aspect,
    required this.orb,
    required this.nature,
  });

  factory AspectData.fromJson(Map<String, dynamic> json) {
    return AspectData(
      planet1: json['planet1'] as String,
      planet2: json['planet2'] as String,
      aspect: json['aspect'] as String,
      orb: (json['orb'] as num).toDouble(),
      nature: json['nature'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'planet1': planet1,
    'planet2': planet2,
    'aspect': aspect,
    'orb': orb,
    'nature': nature,
  };

  /// Returns true if this is a harmonious aspect.
  bool get isHarmonious => nature == 'harmonious';

  /// Returns true if this is a challenging aspect.
  bool get isChallenging => nature == 'challenging';
}

/// Transit position data for a planet.
class TransitPosition {
  final String name;
  final String sign;
  final double degree;
  final int? house;
  final bool retrograde;
  final String? retrogradeStart;
  final String? retrogradeEnd;

  TransitPosition({
    required this.name,
    required this.sign,
    required this.degree,
    this.house,
    required this.retrograde,
    this.retrogradeStart,
    this.retrogradeEnd,
  });

  factory TransitPosition.fromJson(Map<String, dynamic> json) {
    return TransitPosition(
      name: json['name'] as String,
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      house: json['house'] as int?,
      retrograde: json['retrograde'] as bool? ?? false,
      retrogradeStart: json['retrograde_start'] as String?,
      retrogradeEnd: json['retrograde_end'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'sign': sign,
    'degree': degree,
    'house': house,
    'retrograde': retrograde,
    'retrograde_start': retrogradeStart,
    'retrograde_end': retrogradeEnd,
  };

  /// Returns a formatted string like "Sun in Sagittarius 25.4°"
  String get formattedPosition => '$name in $sign ${degree.toStringAsFixed(1)}°';
}

/// Result from the daily alignment calculation.
class AlignmentResult {
  final int score;
  final List<AspectData> aspects;
  final String dominantEnergy;
  final String description;

  AlignmentResult({
    required this.score,
    required this.aspects,
    required this.dominantEnergy,
    required this.description,
  });

  factory AlignmentResult.fromJson(Map<String, dynamic> json) {
    return AlignmentResult(
      score: json['score'] as int,
      aspects: (json['aspects'] as List<dynamic>)
          .map((e) => AspectData.fromJson(e as Map<String, dynamic>))
          .toList(),
      dominantEnergy: json['dominant_energy'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'aspects': aspects.map((e) => e.toJson()).toList(),
    'dominant_energy': dominantEnergy,
    'description': description,
  };

  /// Count of harmonious aspects.
  int get harmoniousCount => aspects.where((a) => a.isHarmonious).length;

  /// Count of challenging aspects.
  int get challengingCount => aspects.where((a) => a.isChallenging).length;
}

/// Result from the friend/synastry alignment calculation.
class FriendAlignmentResult {
  final int score;
  final List<AspectData> aspects;
  final String dominantEnergy;
  final String description;
  final List<String> strengths;
  final List<String> challenges;

  FriendAlignmentResult({
    required this.score,
    required this.aspects,
    required this.dominantEnergy,
    required this.description,
    required this.strengths,
    required this.challenges,
  });

  factory FriendAlignmentResult.fromJson(Map<String, dynamic> json) {
    return FriendAlignmentResult(
      score: json['score'] as int,
      aspects: (json['aspects'] as List<dynamic>)
          .map((e) => AspectData.fromJson(e as Map<String, dynamic>))
          .toList(),
      dominantEnergy: json['dominant_energy'] as String,
      description: json['description'] as String,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'aspects': aspects.map((e) => e.toJson()).toList(),
    'dominant_energy': dominantEnergy,
    'description': description,
    'strengths': strengths,
    'challenges': challenges,
  };
}

/// Result from the transits endpoint.
class TransitsResult {
  final List<TransitPosition> planets;
  final String moonPhase;
  final List<String> retrograde;

  TransitsResult({
    required this.planets,
    required this.moonPhase,
    required this.retrograde,
  });

  factory TransitsResult.fromJson(Map<String, dynamic> json) {
    return TransitsResult(
      planets: (json['planets'] as List<dynamic>)
          .map((e) => TransitPosition.fromJson(e as Map<String, dynamic>))
          .toList(),
      moonPhase: json['moon_phase'] as String,
      retrograde: (json['retrograde'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'planets': planets.map((e) => e.toJson()).toList(),
    'moon_phase': moonPhase,
    'retrograde': retrograde,
  };

  /// Get a planet by name.
  TransitPosition? getPlanet(String name) {
    try {
      return planets.firstWhere((p) => p.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if a planet is currently retrograde.
  bool isRetrograde(String planetName) => retrograde.contains(planetName);
}


// Transit Alignment Models (for comparing natal chart with current transits)

/// Natal planet position data.
class NatalPositionData {
  final String sign;
  final double degree;
  final int house;

  NatalPositionData({
    required this.sign,
    required this.degree,
    required this.house,
  });

  factory NatalPositionData.fromJson(Map<String, dynamic> json) {
    return NatalPositionData(
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      house: json['house'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'sign': sign,
    'degree': degree,
    'house': house,
  };
}

/// Transit planet position data.
class TransitPositionData {
  final String sign;
  final double degree;
  final int house;
  final bool retrograde;

  TransitPositionData({
    required this.sign,
    required this.degree,
    required this.house,
    required this.retrograde,
  });

  factory TransitPositionData.fromJson(Map<String, dynamic> json) {
    return TransitPositionData(
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      house: json['house'] as int,
      retrograde: json['retrograde'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'sign': sign,
    'degree': degree,
    'house': house,
    'retrograde': retrograde,
  };
}

/// Complete alignment data for a single planet.
class TransitAlignmentPlanet {
  final String id;
  final String name;
  final String symbol;
  final String color;
  final NatalPositionData natal;
  final TransitPositionData transit;
  final String status; // 'gap' or 'resonance'
  final String pull;
  final List<String> feelings;
  final String practice;

  TransitAlignmentPlanet({
    required this.id,
    required this.name,
    required this.symbol,
    required this.color,
    required this.natal,
    required this.transit,
    required this.status,
    required this.pull,
    required this.feelings,
    required this.practice,
  });

  factory TransitAlignmentPlanet.fromJson(Map<String, dynamic> json) {
    return TransitAlignmentPlanet(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      color: json['color'] as String,
      natal: NatalPositionData.fromJson(json['natal'] as Map<String, dynamic>),
      transit: TransitPositionData.fromJson(json['transit'] as Map<String, dynamic>),
      status: json['status'] as String,
      pull: json['pull'] as String,
      feelings: (json['feelings'] as List<dynamic>).map((e) => e as String).toList(),
      practice: json['practice'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'symbol': symbol,
    'color': color,
    'natal': natal.toJson(),
    'transit': transit.toJson(),
    'status': status,
    'pull': pull,
    'feelings': feelings,
    'practice': practice,
  };

  /// Returns true if this is a gap (tension).
  bool get isGap => status == 'gap';

  /// Returns true if this is a resonance (harmony).
  bool get isResonance => status == 'resonance';

  /// Get the Color object from hex string.
  int get colorValue => int.parse(color.replaceFirst('#', '0xFF'));
}

/// Result from the transit alignment calculation.
class TransitAlignmentResult {
  final List<TransitAlignmentPlanet> planets;
  final int gapCount;
  final int resonanceCount;

  TransitAlignmentResult({
    required this.planets,
    required this.gapCount,
    required this.resonanceCount,
  });

  factory TransitAlignmentResult.fromJson(Map<String, dynamic> json) {
    return TransitAlignmentResult(
      planets: (json['planets'] as List<dynamic>)
          .map((e) => TransitAlignmentPlanet.fromJson(e as Map<String, dynamic>))
          .toList(),
      gapCount: json['gap_count'] as int,
      resonanceCount: json['resonance_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'planets': planets.map((e) => e.toJson()).toList(),
    'gap_count': gapCount,
    'resonance_count': resonanceCount,
  };

  /// Get a planet by name.
  TransitAlignmentPlanet? getPlanet(String name) {
    try {
      return planets.firstWhere((p) => p.name == name);
    } catch (_) {
      return null;
    }
  }
}
