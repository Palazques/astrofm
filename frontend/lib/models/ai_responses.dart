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
/// Each signal contains 3 message parts for visual hierarchy:
/// - audioMessage: Music/audio engineering metaphor (prominent)
/// - cosmicMessage: Light technical astrology (subtle)
/// - adviceMessage: Relatable, actionable wisdom (bold)
class DailySignal {
  final String signalType;      // "resonance", "feedback", or "dissonance"
  final String category;        // e.g., "Self", "Communication", "Love & Sex"
  final String categoryMeaning; // Human-friendly meaning
  final String message;         // Legacy - backward compat
  final String audioMessage;    // Music/engineering metaphor
  final String cosmicMessage;   // Light technical astrology
  final String adviceMessage;   // Relatable advice

  DailySignal({
    required this.signalType,
    required this.category,
    required this.categoryMeaning,
    required this.message,
    this.audioMessage = '',
    this.cosmicMessage = '',
    this.adviceMessage = '',
  });

  factory DailySignal.fromJson(Map<String, dynamic> json) {
    return DailySignal(
      signalType: json['signal_type'] as String? ?? 'resonance',
      category: json['category'] as String? ?? 'Self',
      categoryMeaning: json['category_meaning'] as String? ?? 'Your daily energy',
      message: json['message'] as String? ?? '',
      audioMessage: json['audio_message'] as String? ?? '',
      cosmicMessage: json['cosmic_message'] as String? ?? '',
      adviceMessage: json['advice_message'] as String? ?? '',
    );
  }

  /// Get icon for signal type
  String get icon {
    switch (signalType) {
      case 'resonance':
        return '✓';
      case 'feedback':
        return '⚠';
      case 'dissonance':
        return '✕';
      default:
        return '•';
    }
  }
}

/// AI-generated daily horoscope with transit-focused content.
/// 
/// Now uses real astronomical data (Moon phase, planetary aspects, dominant element)
/// to create a unique horoscope based on the user's Sun sign.
class DailyReading {
  final String headline;         // NEW: Short punchy headline (3-5 words)
  final String horoscope;        // NEW: 2-3 sentence daily horoscope
  final String cosmicWeather;    // Real-time cosmic weather from transits
  final int energyLevel;         // NEW: Day's energy level 0-100
  final String focusArea;        // NEW: Life area to focus on today
  final String moonPhase;        // NEW: Current moon phase
  final String dominantElement;  // NEW: Dominant element today
  final PlaylistParams playlistParams;
  final String generatedAt;
  
  // Legacy fields for backward compatibility
  final String reading;
  final List<DailySignal> signals;

  DailyReading({
    required this.headline,
    required this.horoscope,
    required this.cosmicWeather,
    required this.energyLevel,
    required this.focusArea,
    required this.moonPhase,
    required this.dominantElement,
    required this.playlistParams,
    required this.generatedAt,
    this.reading = '',
    this.signals = const [],
  });

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(
      headline: json['headline'] as String? ?? 'Your Daily Horoscope',
      horoscope: json['horoscope'] as String? ?? json['reading'] as String? ?? '',
      cosmicWeather: json['cosmic_weather'] as String? ?? '',
      energyLevel: json['energy_level'] as int? ?? 65,
      focusArea: json['focus_area'] as String? ?? 'Self-Expression',
      moonPhase: json['moon_phase'] as String? ?? 'Unknown',
      dominantElement: json['dominant_element'] as String? ?? 'Unknown',
      playlistParams: PlaylistParams.fromJson(
        json['playlist_params'] as Map<String, dynamic>? ?? {},
      ),
      generatedAt: json['generated_at'] as String? ?? '',
      // Legacy fields
      reading: json['reading'] as String? ?? json['horoscope'] as String? ?? '',
      signals: (json['signals'] as List<dynamic>?)
              ?.map((s) => DailySignal.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Extract mood from reading or playlist params
  String get mood {
    final genres = playlistParams.genres;
    if (genres.isEmpty) return 'Ambient';
    // Format: "Genre1 → Genre2"
    return genres.take(2).join(' → ');
  }

  /// Determine energy label based on energy level
  String get energyLabel {
    if (energyLevel >= 80) return 'High Energy';
    if (energyLevel >= 60) return 'Energetic';
    if (energyLevel >= 40) return 'Balanced';
    if (energyLevel >= 20) return 'Chill';
    return 'Ambient';
  }
  
  /// Get emoji for moon phase
  String get moonPhaseEmoji {
    switch (moonPhase) {
      case 'New Moon':
        return '🌑';
      case 'Waxing Crescent':
        return '🌒';
      case 'First Quarter':
        return '🌓';
      case 'Waxing Gibbous':
        return '🌔';
      case 'Full Moon':
        return '🌕';
      case 'Waning Gibbous':
        return '🌖';
      case 'Third Quarter':
        return '🌗';
      case 'Waning Crescent':
        return '🌘';
      default:
        return '🌙';
    }
  }
  
  /// Get emoji for dominant element
  String get elementEmoji {
    switch (dominantElement) {
      case 'Fire':
        return '🔥';
      case 'Earth':
        return '🌍';
      case 'Air':
        return '💨';
      case 'Water':
        return '💧';
      default:
        return '✨';
    }
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
