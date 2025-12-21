/// Data models for attunement analysis.
/// Compares natal chart to daily transits to identify gaps and resonances.

/// Comparison of a single planet between natal and transit.
class PlanetAttunement {
  final String planet;
  
  // Natal chart data
  final double natalIntensity;
  final int natalHouse;
  final String natalSign;
  final double natalFrequency;
  
  // Transit data
  final double transitIntensity;
  final int transitHouse;
  final String transitSign;
  final double transitFrequency;
  
  // Comparison results
  final double intensityGap;
  final String status; // "gap", "resonance", or "neutral"
  final int priority;
  final String explanation;

  PlanetAttunement({
    required this.planet,
    required this.natalIntensity,
    required this.natalHouse,
    required this.natalSign,
    required this.natalFrequency,
    required this.transitIntensity,
    required this.transitHouse,
    required this.transitSign,
    required this.transitFrequency,
    required this.intensityGap,
    required this.status,
    required this.priority,
    required this.explanation,
  });

  factory PlanetAttunement.fromJson(Map<String, dynamic> json) {
    return PlanetAttunement(
      planet: json['planet'] as String,
      natalIntensity: (json['natal_intensity'] as num).toDouble(),
      natalHouse: json['natal_house'] as int,
      natalSign: json['natal_sign'] as String,
      natalFrequency: (json['natal_frequency'] as num).toDouble(),
      transitIntensity: (json['transit_intensity'] as num).toDouble(),
      transitHouse: json['transit_house'] as int,
      transitSign: json['transit_sign'] as String,
      transitFrequency: (json['transit_frequency'] as num).toDouble(),
      intensityGap: (json['intensity_gap'] as num).toDouble(),
      status: json['status'] as String,
      priority: json['priority'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'planet': planet,
    'natal_intensity': natalIntensity,
    'natal_house': natalHouse,
    'natal_sign': natalSign,
    'natal_frequency': natalFrequency,
    'transit_intensity': transitIntensity,
    'transit_house': transitHouse,
    'transit_sign': transitSign,
    'transit_frequency': transitFrequency,
    'intensity_gap': intensityGap,
    'status': status,
    'priority': priority,
    'explanation': explanation,
  };

  /// Returns true if this planet needs attunement.
  bool get isGap => status == 'gap';

  /// Returns true if this planet is naturally resonant today.
  bool get isResonance => status == 'resonance';

  /// Returns the natal intensity as a percentage (0-100).
  int get natalPercent => (natalIntensity * 100).round();

  /// Returns the transit intensity as a percentage (0-100).
  int get transitPercent => (transitIntensity * 100).round();
}


/// Complete attunement analysis comparing natal to daily transits.
class AttunementAnalysis {
  final List<PlanetAttunement> planets;
  final List<PlanetAttunement> gaps;
  final List<PlanetAttunement> resonances;
  final int alignmentScore;
  final bool shouldNotify;
  final String? notificationReason;
  final String analysisDate;
  final String? dominantGapEnergy;

  AttunementAnalysis({
    required this.planets,
    required this.gaps,
    required this.resonances,
    required this.alignmentScore,
    required this.shouldNotify,
    this.notificationReason,
    required this.analysisDate,
    this.dominantGapEnergy,
  });

  factory AttunementAnalysis.fromJson(Map<String, dynamic> json) {
    return AttunementAnalysis(
      planets: (json['planets'] as List<dynamic>)
          .map((e) => PlanetAttunement.fromJson(e as Map<String, dynamic>))
          .toList(),
      gaps: (json['gaps'] as List<dynamic>)
          .map((e) => PlanetAttunement.fromJson(e as Map<String, dynamic>))
          .toList(),
      resonances: (json['resonances'] as List<dynamic>)
          .map((e) => PlanetAttunement.fromJson(e as Map<String, dynamic>))
          .toList(),
      alignmentScore: json['alignment_score'] as int,
      shouldNotify: json['should_notify'] as bool? ?? false,
      notificationReason: json['notification_reason'] as String?,
      analysisDate: json['analysis_date'] as String,
      dominantGapEnergy: json['dominant_gap_energy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'planets': planets.map((e) => e.toJson()).toList(),
    'gaps': gaps.map((e) => e.toJson()).toList(),
    'resonances': resonances.map((e) => e.toJson()).toList(),
    'alignment_score': alignmentScore,
    'should_notify': shouldNotify,
    'notification_reason': notificationReason,
    'analysis_date': analysisDate,
    'dominant_gap_energy': dominantGapEnergy,
  };

  /// Returns true if there are any gaps that need attunement.
  bool get hasGaps => gaps.isNotEmpty;

  /// Returns true if there are any resonances to amplify.
  bool get hasResonances => resonances.isNotEmpty;

  /// Returns the primary gap planet, if any.
  PlanetAttunement? get primaryGap => gaps.isNotEmpty ? gaps.first : null;

  /// Returns the primary resonance planet, if any.
  PlanetAttunement? get primaryResonance => resonances.isNotEmpty ? resonances.first : null;
}


/// Weekly summary of attunement patterns.
class WeeklyDigest {
  final String weekStart;
  final String weekEnd;
  final int averageAlignment;
  final String bestDay;
  final int bestDayScore;
  final String challengingDay;
  final int challengingDayScore;
  final List<String> commonGaps;
  final String summary;

  WeeklyDigest({
    required this.weekStart,
    required this.weekEnd,
    required this.averageAlignment,
    required this.bestDay,
    required this.bestDayScore,
    required this.challengingDay,
    required this.challengingDayScore,
    required this.commonGaps,
    required this.summary,
  });

  factory WeeklyDigest.fromJson(Map<String, dynamic> json) {
    return WeeklyDigest(
      weekStart: json['week_start'] as String,
      weekEnd: json['week_end'] as String,
      averageAlignment: json['average_alignment'] as int,
      bestDay: json['best_day'] as String,
      bestDayScore: json['best_day_score'] as int,
      challengingDay: json['challenging_day'] as String,
      challengingDayScore: json['challenging_day_score'] as int,
      commonGaps: (json['common_gaps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      summary: json['summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'week_start': weekStart,
    'week_end': weekEnd,
    'average_alignment': averageAlignment,
    'best_day': bestDay,
    'best_day_score': bestDayScore,
    'challenging_day': challengingDay,
    'challenging_day_score': challengingDayScore,
    'common_gaps': commonGaps,
    'summary': summary,
  };
}
