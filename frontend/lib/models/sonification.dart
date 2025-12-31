import 'dart:convert';

// =============================================================================
// STEINER SOUND SIGNATURE MODELS
// =============================================================================

/// A single note in the Sound Signature chord.
class SoundSignatureNote {
  final String note;
  final double frequency;
  final int octave;
  final double weight;
  final List<String> sources;

  SoundSignatureNote({
    required this.note,
    required this.frequency,
    required this.octave,
    required this.weight,
    required this.sources,
  });

  factory SoundSignatureNote.fromJson(Map<String, dynamic> json) {
    return SoundSignatureNote(
      note: json['note'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      octave: json['octave'] as int,
      weight: (json['weight'] as num).toDouble(),
      sources: (json['sources'] as List).map((s) => s as String).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'note': note,
    'frequency': frequency,
    'octave': octave,
    'weight': weight,
    'sources': sources,
  };
}

/// Sound modulation based on aspect between Big Four.
class AspectModulation {
  final String aspectType;
  final String planetA;
  final String planetB;
  final double orb;
  final String effect;
  final double intensity;

  AspectModulation({
    required this.aspectType,
    required this.planetA,
    required this.planetB,
    required this.orb,
    required this.effect,
    required this.intensity,
  });

  factory AspectModulation.fromJson(Map<String, dynamic> json) {
    return AspectModulation(
      aspectType: json['aspect_type'] as String,
      planetA: json['planet_a'] as String,
      planetB: json['planet_b'] as String,
      orb: (json['orb'] as num).toDouble(),
      effect: json['effect'] as String,
      intensity: (json['intensity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'aspect_type': aspectType,
    'planet_a': planetA,
    'planet_b': planetB,
    'orb': orb,
    'effect': effect,
    'intensity': intensity,
  };
}

/// Background texture note from non-Big-Four planets.
class TextureNote {
  final String planet;
  final String note;
  final double frequency;

  TextureNote({
    required this.planet,
    required this.note,
    required this.frequency,
  });

  factory TextureNote.fromJson(Map<String, dynamic> json) {
    return TextureNote(
      planet: json['planet'] as String,
      note: json['note'] as String,
      frequency: (json['frequency'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'planet': planet,
    'note': note,
    'frequency': frequency,
  };
}

/// Chord-based planet sound using Steiner Zodiac Tone Circle.
/// Each planet plays its sign's major triad (root, third, fifth).
class PlanetChord {
  final String planet;
  final String sign;
  final int house;
  final double houseDegree;

  // The 3-note chord (triad)
  final String rootNote;
  final String thirdNote;
  final String fifthNote;

  // Frequencies
  final double rootFrequency;
  final double thirdFrequency;
  final double fifthFrequency;

  // Audio params
  final double intensity;
  final double pan;

  PlanetChord({
    required this.planet,
    required this.sign,
    required this.house,
    required this.houseDegree,
    required this.rootNote,
    required this.thirdNote,
    required this.fifthNote,
    required this.rootFrequency,
    required this.thirdFrequency,
    required this.fifthFrequency,
    required this.intensity,
    required this.pan,
  });

  factory PlanetChord.fromJson(Map<String, dynamic> json) {
    return PlanetChord(
      planet: json['planet'] as String,
      sign: json['sign'] as String,
      house: json['house'] as int,
      houseDegree: (json['house_degree'] as num).toDouble(),
      rootNote: json['root_note'] as String,
      thirdNote: json['third_note'] as String,
      fifthNote: json['fifth_note'] as String,
      rootFrequency: (json['root_frequency'] as num).toDouble(),
      thirdFrequency: (json['third_frequency'] as num).toDouble(),
      fifthFrequency: (json['fifth_frequency'] as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble(),
      pan: (json['pan'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'planet': planet,
    'sign': sign,
    'house': house,
    'house_degree': houseDegree,
    'root_note': rootNote,
    'third_note': thirdNote,
    'fifth_note': fifthNote,
    'root_frequency': rootFrequency,
    'third_frequency': thirdFrequency,
    'fifth_frequency': fifthFrequency,
    'intensity': intensity,
    'pan': pan,
  };

  /// Get all 3 frequencies as a list for playback.
  List<double> get frequencies => [rootFrequency, thirdFrequency, fifthFrequency];
}

/// Big Four point data (Sun, Moon, Rising, ChartRuler).
class BigFourPoint {
  final String sign;
  final double signDegree;
  final double longitude;
  final int house;
  final double houseDegree;
  final String? planet; // Only for ChartRuler

  BigFourPoint({
    required this.sign,
    required this.signDegree,
    required this.longitude,
    required this.house,
    required this.houseDegree,
    this.planet,
  });

  factory BigFourPoint.fromJson(Map<String, dynamic> json) {
    return BigFourPoint(
      sign: json['sign'] as String,
      signDegree: (json['sign_degree'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      house: json['house'] as int,
      houseDegree: (json['house_degree'] as num).toDouble(),
      planet: json['planet'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'sign': sign,
    'sign_degree': signDegree,
    'longitude': longitude,
    'house': house,
    'house_degree': houseDegree,
    if (planet != null) 'planet': planet,
  };
}

/// Complete Sound Signature data for an astrological chart.
/// Uses Steiner Zodiac Tone Circle method.
class ChartSonification {
  final List<SoundSignatureNote> soundSignature;
  final List<AspectModulation> aspects;
  final List<TextureNote> textureLayer;
  final String ascendantSign;
  final String chartRuler;
  final Map<String, BigFourPoint> bigFour;
  final List<PlanetSound> storedPlanets;
  final List<PlanetChord> planetChords;

  ChartSonification({
    required this.soundSignature,
    required this.aspects,
    required this.textureLayer,
    required this.ascendantSign,
    required this.chartRuler,
    required this.bigFour,
    this.storedPlanets = const [],
    this.planetChords = const [],
  });

  factory ChartSonification.fromJson(Map<String, dynamic> json) {
    return ChartSonification(
      soundSignature: (json['sound_signature'] as List)
          .map((n) => SoundSignatureNote.fromJson(n as Map<String, dynamic>))
          .toList(),
      aspects: (json['aspects'] as List? ?? [])
          .map((a) => AspectModulation.fromJson(a as Map<String, dynamic>))
          .toList(),
      textureLayer: (json['texture_layer'] as List? ?? [])
          .map((t) => TextureNote.fromJson(t as Map<String, dynamic>))
          .toList(),
      ascendantSign: json['ascendant_sign'] as String,
      chartRuler: json['chart_ruler'] as String,
      bigFour: (json['big_four'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          BigFourPoint.fromJson(value as Map<String, dynamic>),
        ),
      ),
      storedPlanets: (json['planets'] as List? ?? [])
          .map((p) => PlanetSound.fromJson(p as Map<String, dynamic>))
          .toList(),
      planetChords: (json['planet_chords'] as List? ?? [])
          .map((c) => PlanetChord.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sound_signature': soundSignature.map((n) => n.toJson()).toList(),
    'aspects': aspects.map((a) => a.toJson()).toList(),
    'texture_layer': textureLayer.map((t) => t.toJson()).toList(),
    'ascendant_sign': ascendantSign,
    'chart_ruler': chartRuler,
    'big_four': bigFour.map((key, value) => MapEntry(key, value.toJson())),
    'planets': storedPlanets.map((p) => p.toJson()).toList(),
    'planet_chords': planetChords.map((c) => c.toJson()).toList(),
  };

  /// Get all frequencies from the sound signature for playback.
  List<double> get allFrequencies =>
      soundSignature.map((n) => n.frequency).toList();

  /// Get the dominant (highest weighted) note.
  SoundSignatureNote get dominantNote =>
      soundSignature.reduce((a, b) => a.weight > b.weight ? a : b);

  /// Backward-compatible dominantFrequency getter.
  @Deprecated('Use dominantNote.frequency instead')
  double get dominantFrequency => dominantNote.frequency;

  /// Backward-compatible planets getter.
  /// Generates PlanetSound list from Big Four data for legacy code.
  @Deprecated('Use bigFour or soundSignature instead')
  List<PlanetSound> get planets {
    if (storedPlanets.isNotEmpty) {
      return storedPlanets;
    }
    final result = <PlanetSound>[];
    
    // Convert Big Four to PlanetSound for backward compatibility
    bigFour.forEach((name, point) {
      // Find matching note from sound signature for frequency
      final matchingNote = soundSignature
          .where((n) => n.sources.contains(name))
          .firstOrNull;
      
      result.add(PlanetSound(
        planet: name == 'rising' ? 'Ascendant' : name.substring(0, 1).toUpperCase() + name.substring(1),
        frequency: matchingNote?.frequency ?? 440.0,
        intensity: matchingNote?.weight ?? 0.5,
        role: name == 'sun' ? 'carrier' : 'modulator',
        filterType: 'lowpass',
        filterCutoff: 2000.0,
        attack: 0.3,
        decay: 0.5,
        reverb: 0.4,
        pan: 0.0,
        house: point.house,
        houseDegree: point.houseDegree,
        sign: point.sign,
      ));
    });
    
    return result;
  }
}


// =============================================================================
// ALIGNMENT SOUND MODELS
// Compare personal and daily signatures for meditation alignment
// =============================================================================

/// A pair of notes for harmonic/tension analysis.
class NotePair {
  final String noteA;
  final String noteB;
  final String interval;
  final String quality;

  NotePair({
    required this.noteA,
    required this.noteB,
    required this.interval,
    required this.quality,
  });

  factory NotePair.fromJson(Map<String, dynamic> json) {
    return NotePair(
      noteA: json['note_a'] as String,
      noteB: json['note_b'] as String,
      interval: json['interval'] as String,
      quality: json['quality'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'note_a': noteA,
    'note_b': noteB,
    'interval': interval,
    'quality': quality,
  };
}

/// Analysis of alignment between personal and daily Sound Signatures.
class AlignmentAnalysis {
  final List<String> sharedNotes;
  final List<String> personalUnique;
  final List<String> dailyUnique;
  final List<NotePair> harmonicPairs;
  final List<NotePair> tensionPairs;
  final int alignmentScore;

  AlignmentAnalysis({
    required this.sharedNotes,
    required this.personalUnique,
    required this.dailyUnique,
    required this.harmonicPairs,
    required this.tensionPairs,
    required this.alignmentScore,
  });

  factory AlignmentAnalysis.fromJson(Map<String, dynamic> json) {
    return AlignmentAnalysis(
      sharedNotes: (json['shared_notes'] as List? ?? []).map((n) => n as String).toList(),
      personalUnique: (json['personal_unique'] as List? ?? []).map((n) => n as String).toList(),
      dailyUnique: (json['daily_unique'] as List? ?? []).map((n) => n as String).toList(),
      harmonicPairs: (json['harmonic_pairs'] as List? ?? [])
          .map((p) => NotePair.fromJson(p as Map<String, dynamic>))
          .toList(),
      tensionPairs: (json['tension_pairs'] as List? ?? [])
          .map((p) => NotePair.fromJson(p as Map<String, dynamic>))
          .toList(),
      alignmentScore: json['alignment_score'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'shared_notes': sharedNotes,
    'personal_unique': personalUnique,
    'daily_unique': dailyUnique,
    'harmonic_pairs': harmonicPairs.map((p) => p.toJson()).toList(),
    'tension_pairs': tensionPairs.map((p) => p.toJson()).toList(),
    'alignment_score': alignmentScore,
  };
}

/// The alignment meditation sound composition.
class AlignmentSound {
  final List<SoundSignatureNote> anchorNotes;
  final List<SoundSignatureNote> attuneNotes;
  final SoundSignatureNote? bridgeNote;
  final double suggestedDuration;

  AlignmentSound({
    required this.anchorNotes,
    required this.attuneNotes,
    this.bridgeNote,
    required this.suggestedDuration,
  });

  factory AlignmentSound.fromJson(Map<String, dynamic> json) {
    return AlignmentSound(
      anchorNotes: (json['anchor_notes'] as List)
          .map((n) => SoundSignatureNote.fromJson(n as Map<String, dynamic>))
          .toList(),
      attuneNotes: (json['attune_notes'] as List)
          .map((n) => SoundSignatureNote.fromJson(n as Map<String, dynamic>))
          .toList(),
      bridgeNote: json['bridge_note'] != null
          ? SoundSignatureNote.fromJson(json['bridge_note'] as Map<String, dynamic>)
          : null,
      suggestedDuration: (json['suggested_duration'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'anchor_notes': anchorNotes.map((n) => n.toJson()).toList(),
    'attune_notes': attuneNotes.map((n) => n.toJson()).toList(),
    if (bridgeNote != null) 'bridge_note': bridgeNote!.toJson(),
    'suggested_duration': suggestedDuration,
  };

  /// Get all frequencies for playback.
  List<double> get allFrequencies => [
    ...anchorNotes.map((n) => n.frequency),
    ...attuneNotes.map((n) => n.frequency),
    if (bridgeNote != null) bridgeNote!.frequency,
  ];
}

/// Complete response for alignment sound request.
class AlignmentResponse {
  final AlignmentAnalysis analysis;
  final AlignmentSound sound;
  final ChartSonification personalSignature;
  final ChartSonification dailySignature;
  final String explanation;

  AlignmentResponse({
    required this.analysis,
    required this.sound,
    required this.personalSignature,
    required this.dailySignature,
    required this.explanation,
  });

  factory AlignmentResponse.fromJson(Map<String, dynamic> json) {
    return AlignmentResponse(
      analysis: AlignmentAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
      sound: AlignmentSound.fromJson(json['sound'] as Map<String, dynamic>),
      personalSignature: ChartSonification.fromJson(json['personal_signature'] as Map<String, dynamic>),
      dailySignature: ChartSonification.fromJson(json['daily_signature'] as Map<String, dynamic>),
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'analysis': analysis.toJson(),
    'sound': sound.toJson(),
    'personal_signature': personalSignature.toJson(),
    'daily_signature': dailySignature.toJson(),
    'explanation': explanation,
  };
}


// =============================================================================
// LEGACY MODELS (kept for backward compatibility during migration)
// TODO: Remove after audio_service.dart migration
// =============================================================================

/// Legacy model for planet sound synthesis parameters.
@Deprecated('Use SoundSignatureNote instead')
class PlanetSound {
  final String planet;
  final double frequency;
  final double intensity;
  final String role;
  final String filterType;
  final double filterCutoff;
  final double attack;
  final double decay;
  final double reverb;
  final double pan;
  final int house;
  final double houseDegree;
  final String sign;

  PlanetSound({
    required this.planet,
    required this.frequency,
    required this.intensity,
    required this.role,
    required this.filterType,
    required this.filterCutoff,
    required this.attack,
    required this.decay,
    required this.reverb,
    required this.pan,
    required this.house,
    required this.houseDegree,
    required this.sign,
  });

  factory PlanetSound.fromJson(Map<String, dynamic> json) {
    return PlanetSound(
      planet: json['planet'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble(),
      role: json['role'] as String,
      filterType: json['filter_type'] as String,
      filterCutoff: (json['filter_cutoff'] as num).toDouble(),
      attack: (json['attack'] as num).toDouble(),
      decay: (json['decay'] as num).toDouble(),
      reverb: (json['reverb'] as num).toDouble(),
      pan: (json['pan'] as num).toDouble(),
      house: json['house'] as int,
      houseDegree: (json['house_degree'] as num).toDouble(),
      sign: json['sign'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'planet': planet,
    'frequency': frequency,
    'intensity': intensity,
    'role': role,
    'filter_type': filterType,
    'filter_cutoff': filterCutoff,
    'attack': attack,
    'decay': decay,
    'reverb': reverb,
    'pan': pan,
    'house': house,
    'house_degree': houseDegree,
    'sign': sign,
  };
}
