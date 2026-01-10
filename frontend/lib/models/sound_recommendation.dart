/// Sound Recommendation models for personalized sound prescriptions.
/// Based on natal chart gaps and resonances mapped to life areas.

/// Frequency blend from an aspect between planets.
class AspectBlend {
  final String planets;
  final String aspect;
  final double frequency;
  final String effect;

  AspectBlend({
    required this.planets,
    required this.aspect,
    required this.frequency,
    required this.effect,
  });

  factory AspectBlend.fromJson(Map<String, dynamic> json) {
    return AspectBlend(
      planets: json['planets'] as String,
      aspect: json['aspect'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      effect: json['effect'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'planets': planets,
    'aspect': aspect,
    'frequency': frequency,
    'effect': effect,
  };
}

/// A single sound recommendation for a life area.
class SoundRecommendation {
  final String planet;
  final String lifeArea;
  final String lifeAreaKey;
  final int house;
  final String sign;
  final String status; // "gap", "resonance", or "neutral"
  final String explanation;
  final double frequency;
  final List<AspectBlend> aspectBlends;
  final double intensityGap;
  final int priority;

  SoundRecommendation({
    required this.planet,
    required this.lifeArea,
    required this.lifeAreaKey,
    required this.house,
    required this.sign,
    required this.status,
    required this.explanation,
    required this.frequency,
    required this.aspectBlends,
    required this.intensityGap,
    required this.priority,
  });

  factory SoundRecommendation.fromJson(Map<String, dynamic> json) {
    return SoundRecommendation(
      planet: json['planet'] as String,
      lifeArea: json['life_area'] as String,
      lifeAreaKey: json['life_area_key'] as String,
      house: json['house'] as int,
      sign: json['sign'] as String,
      status: json['status'] as String,
      explanation: json['explanation'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      aspectBlends: (json['aspect_blends'] as List<dynamic>? ?? [])
          .map((e) => AspectBlend.fromJson(e as Map<String, dynamic>))
          .toList(),
      intensityGap: (json['intensity_gap'] as num).toDouble(),
      priority: json['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'planet': planet,
    'life_area': lifeArea,
    'life_area_key': lifeAreaKey,
    'house': house,
    'sign': sign,
    'status': status,
    'explanation': explanation,
    'frequency': frequency,
    'aspect_blends': aspectBlends.map((e) => e.toJson()).toList(),
    'intensity_gap': intensityGap,
    'priority': priority,
  };

  /// Returns true if this is a gap (needs attunement).
  bool get isGap => status == 'gap';

  /// Returns true if this is a resonance (can be amplified).
  bool get isResonance => status == 'resonance';

  /// Get all frequencies including aspects for playback.
  List<double> get allFrequencies => [
    frequency,
    ...aspectBlends.map((b) => b.frequency),
  ];

  /// Get planet symbol for display.
  String get planetSymbol => _planetSymbols[planet] ?? '⊕';

  static const _planetSymbols = {
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
}

/// Complete response with all sound recommendations.
class SoundRecommendationsResponse {
  final SoundRecommendation? primaryRecommendation;
  final List<SoundRecommendation> allRecommendations;
  final List<SoundRecommendation> gaps;
  final List<SoundRecommendation> resonances;
  final int gapsCount;
  final int resonancesCount;
  final int alignmentScore;

  SoundRecommendationsResponse({
    this.primaryRecommendation,
    required this.allRecommendations,
    required this.gaps,
    required this.resonances,
    required this.gapsCount,
    required this.resonancesCount,
    required this.alignmentScore,
  });

  factory SoundRecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return SoundRecommendationsResponse(
      primaryRecommendation: json['primary_recommendation'] != null
          ? SoundRecommendation.fromJson(
              json['primary_recommendation'] as Map<String, dynamic>)
          : null,
      allRecommendations: (json['all_recommendations'] as List<dynamic>)
          .map((e) => SoundRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      gaps: (json['gaps'] as List<dynamic>)
          .map((e) => SoundRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      resonances: (json['resonances'] as List<dynamic>)
          .map((e) => SoundRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      gapsCount: json['gaps_count'] as int,
      resonancesCount: json['resonances_count'] as int,
      alignmentScore: json['alignment_score'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'primary_recommendation': primaryRecommendation?.toJson(),
    'all_recommendations': allRecommendations.map((e) => e.toJson()).toList(),
    'gaps': gaps.map((e) => e.toJson()).toList(),
    'resonances': resonances.map((e) => e.toJson()).toList(),
    'gaps_count': gapsCount,
    'resonances_count': resonancesCount,
    'alignment_score': alignmentScore,
  };

  /// Returns true if there are any gaps.
  bool get hasGaps => gaps.isNotEmpty;

  /// Returns true if there are any resonances.
  bool get hasResonances => resonances.isNotEmpty;

  /// Get gap planets for chart highlighting.
  Set<String> get gapPlanets => gaps.map((g) => g.planet).toSet();

  /// Get resonance planets for chart highlighting.
  Set<String> get resonancePlanets => resonances.map((r) => r.planet).toSet();
}

/// Life area constants for filtering and display.
class LifeAreas {
  static const Map<int, String> byHouse = {
    1: 'self_expression',
    2: 'resources_values',
    3: 'communication',
    4: 'home_foundations',
    5: 'creativity_joy',
    6: 'health_service',
    7: 'partnerships',
    8: 'transformation',
    9: 'expansion_beliefs',
    10: 'career_purpose',
    11: 'community_hopes',
    12: 'spirituality_release',
  };

  static const Map<String, String> labels = {
    'self_expression': 'Self-Expression',
    'resources_values': 'Resources & Values',
    'communication': 'Communication',
    'home_foundations': 'Home & Foundations',
    'creativity_joy': 'Creativity & Joy',
    'health_service': 'Health & Service',
    'partnerships': 'Partnerships',
    'transformation': 'Transformation',
    'expansion_beliefs': 'Expansion & Beliefs',
    'career_purpose': 'Career & Purpose',
    'community_hopes': 'Community & Hopes',
    'spirituality_release': 'Spirituality & Release',
  };

  static const Map<String, String> icons = {
    'self_expression': '🪞',
    'resources_values': '💎',
    'communication': '💬',
    'home_foundations': '🏠',
    'creativity_joy': '🎨',
    'health_service': '❤️',
    'partnerships': '🤝',
    'transformation': '🔮',
    'expansion_beliefs': '🌍',
    'career_purpose': '📈',
    'community_hopes': '👥',
    'spirituality_release': '✨',
  };
}
