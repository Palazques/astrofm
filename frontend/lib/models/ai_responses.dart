/// Models for AI-generated responses from the backend.

/// Parameters for generating a mood-matched playlist.
class PlaylistParams {
  final int bpmMin;
  final int bpmMax;
  final double energy;
  final double valence;
  final List<String> genres;
  final String? keyMode;

  PlaylistParams({
    required this.bpmMin,
    required this.bpmMax,
    required this.energy,
    required this.valence,
    required this.genres,
    this.keyMode,
  });

  factory PlaylistParams.fromJson(Map<String, dynamic> json) {
    return PlaylistParams(
      bpmMin: json['bpm_min'] as int? ?? 110,
      bpmMax: json['bpm_max'] as int? ?? 130,
      energy: (json['energy'] as num?)?.toDouble() ?? 0.6,
      valence: (json['valence'] as num?)?.toDouble() ?? 0.5,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['electronic', 'ambient'],
      keyMode: json['key_mode'] as String?,
    );
  }

  /// Format BPM as a range string (e.g., "118-122")
  String get bpmRange => '$bpmMin-$bpmMax';

  /// Format energy as percentage
  int get energyPercent => (energy * 100).round();
}

/// Structured daily signal (Resonance, Feedback, or Dissonance).
/// 
/// Each signal represents one life area with audio engineering metaphors
/// and human-friendly context.
class DailySignal {
  final String signalType;      // "resonance", "feedback", or "dissonance"
  final String category;        // e.g., "Self", "Communication", "Love & Sex"
  final String categoryMeaning; // Human-friendly: "How in sync you are with partners"
  final String message;         // The reading with audio metaphors

  DailySignal({
    required this.signalType,
    required this.category,
    required this.categoryMeaning,
    required this.message,
  });

  factory DailySignal.fromJson(Map<String, dynamic> json) {
    return DailySignal(
      signalType: json['signal_type'] as String? ?? 'resonance',
      category: json['category'] as String? ?? 'Self',
      categoryMeaning: json['category_meaning'] as String? ?? 'Your daily energy',
      message: json['message'] as String? ?? '',
    );
  }

  /// Get icon for signal type
  String get icon {
    switch (signalType) {
      case 'resonance':
        return '✅';
      case 'feedback':
        return '⚠️';
      case 'dissonance':
        return '❌';
      default:
        return '•';
    }
  }
}

/// AI-generated daily reading with playlist parameters.
class DailyReading {
  final String reading;
  final List<DailySignal> signals; // NEW: structured reading signals
  final PlaylistParams playlistParams;
  final String cosmicWeather;
  final String generatedAt;

  DailyReading({
    required this.reading,
    required this.signals,
    required this.playlistParams,
    required this.cosmicWeather,
    required this.generatedAt,
  });

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(
      reading: json['reading'] as String,
      signals: (json['signals'] as List<dynamic>?)
              ?.map((s) => DailySignal.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      playlistParams: PlaylistParams.fromJson(
        json['playlist_params'] as Map<String, dynamic>,
      ),
      cosmicWeather: json['cosmic_weather'] as String,
      generatedAt: json['generated_at'] as String,
    );
  }

  /// Extract mood from reading or playlist params
  String get mood {
    final genres = playlistParams.genres;
    if (genres.isEmpty) return 'Ambient';
    // Format: "Genre1 → Genre2"
    return genres.take(2).join(' → ');
  }

  /// Determine energy label based on energy value
  String get energyLabel {
    if (playlistParams.energy >= 0.8) return 'High Energy';
    if (playlistParams.energy >= 0.6) return 'Energetic';
    if (playlistParams.energy >= 0.4) return 'Balanced';
    if (playlistParams.energy >= 0.2) return 'Chill';
    return 'Ambient';
  }
}

/// AI interpretation of alignment between two charts.
class AlignmentInterpretation {
  final String interpretation;
  final int resonanceScore;
  final List<String> harmoniousAspects;

  AlignmentInterpretation({
    required this.interpretation,
    required this.resonanceScore,
    required this.harmoniousAspects,
  });

  factory AlignmentInterpretation.fromJson(Map<String, dynamic> json) {
    return AlignmentInterpretation(
      interpretation: json['interpretation'] as String,
      resonanceScore: json['resonance_score'] as int,
      harmoniousAspects: (json['harmonious_aspects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  /// Check if alignment is harmonious (score >= 70)
  bool get isHarmonious => resonanceScore >= 70;
}

/// AI-generated compatibility analysis between two people.
class CompatibilityResult {
  final String narrative;
  final int overallScore;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> sharedGenres;

  CompatibilityResult({
    required this.narrative,
    required this.overallScore,
    required this.strengths,
    required this.challenges,
    required this.sharedGenres,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityResult(
      narrative: json['narrative'] as String,
      overallScore: json['overall_score'] as int,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sharedGenres: (json['shared_genres'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

/// AI-generated interpretation of current planetary transits.
class TransitInterpretation {
  final String interpretation;
  final String highlightPlanet;
  final String highlightReason;
  final String energyDescription;
  final String moonPhase;
  final List<String> retrogradePlanets;

  TransitInterpretation({
    required this.interpretation,
    required this.highlightPlanet,
    required this.highlightReason,
    required this.energyDescription,
    required this.moonPhase,
    required this.retrogradePlanets,
  });

  factory TransitInterpretation.fromJson(Map<String, dynamic> json) {
    return TransitInterpretation(
      interpretation: json['interpretation'] as String,
      highlightPlanet: json['highlight_planet'] as String,
      highlightReason: json['highlight_reason'] as String,
      energyDescription: json['energy_description'] as String,
      moonPhase: json['moon_phase'] as String,
      retrogradePlanets: (json['retrograde_planets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

/// AI-generated insight explaining why a playlist was created.
class PlaylistInsight {
  final String insight;
  final int energyPercent;
  final String dominantMood;
  final String astroHighlight;

  PlaylistInsight({
    required this.insight,
    required this.energyPercent,
    required this.dominantMood,
    required this.astroHighlight,
  });

  factory PlaylistInsight.fromJson(Map<String, dynamic> json) {
    return PlaylistInsight(
      insight: json['insight'] as String,
      energyPercent: json['energy_percent'] as int,
      dominantMood: json['dominant_mood'] as String,
      astroHighlight: json['astro_highlight'] as String,
    );
  }
}

/// AI-generated interpretation of user's cosmic sound profile.
class SoundInterpretation {
  final String personality;
  final String todayInfluence;
  final String shift;
  final Map<String, String> planetDescriptions;

  SoundInterpretation({
    required this.personality,
    required this.todayInfluence,
    required this.shift,
    required this.planetDescriptions,
  });

  factory SoundInterpretation.fromJson(Map<String, dynamic> json) {
    return SoundInterpretation(
      personality: json['personality'] as String,
      todayInfluence: json['today_influence'] as String,
      shift: json['shift'] as String,
      planetDescriptions: (json['planet_descriptions'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as String)),
    );
  }
}

/// AI-generated welcome message for new users during onboarding.
class WelcomeMessage {
  final String greeting;
  final String personality;
  final String soundTeaser;

  WelcomeMessage({
    required this.greeting,
    required this.personality,
    required this.soundTeaser,
  });

  factory WelcomeMessage.fromJson(Map<String, dynamic> json) {
    return WelcomeMessage(
      greeting: json['greeting'] as String,
      personality: json['personality'] as String,
      soundTeaser: json['sound_teaser'] as String,
    );
  }
}
