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

/// AI-generated daily reading with playlist parameters.
class DailyReading {
  final String reading;
  final PlaylistParams playlistParams;
  final String cosmicWeather;
  final String generatedAt;

  DailyReading({
    required this.reading,
    required this.playlistParams,
    required this.cosmicWeather,
    required this.generatedAt,
  });

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(
      reading: json['reading'] as String,
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
