/// Models for the Cosmic Prescription feature.
///
/// Represents brainwave recommendations based on transit-to-natal aspects.

/// Brainwave frequency modes for cosmic prescription.
enum BrainwaveMode {
  focus,  // 18-22 Hz Beta - mental clarity
  calm,   // 10 Hz Alpha - relaxation
  deep,   // 5-6 Hz Theta - subconscious processing
  expand, // 40 Hz Gamma - breakthrough integration
  rest,   // 2-3 Hz Delta - deep restoration
  neutral, // User choice - no specific recommendation
}

extension BrainwaveModeExtension on BrainwaveMode {
  String get displayName {
    switch (this) {
      case BrainwaveMode.focus:
        return 'Focus';
      case BrainwaveMode.calm:
        return 'Calm';
      case BrainwaveMode.deep:
        return 'Deep';
      case BrainwaveMode.expand:
        return 'Expand';
      case BrainwaveMode.rest:
        return 'Rest';
      case BrainwaveMode.neutral:
        return 'Neutral';
    }
  }
  
  String get icon {
    switch (this) {
      case BrainwaveMode.focus:
        return '🎯';
      case BrainwaveMode.calm:
        return '🌊';
      case BrainwaveMode.deep:
        return '🌙';
      case BrainwaveMode.expand:
        return '✨';
      case BrainwaveMode.rest:
        return '😴';
      case BrainwaveMode.neutral:
        return '⚖️';
    }
  }
  
  double get hz {
    switch (this) {
      case BrainwaveMode.focus:
        return 18.0;
      case BrainwaveMode.calm:
        return 10.0;
      case BrainwaveMode.deep:
        return 5.0;
      case BrainwaveMode.expand:
        return 40.0;
      case BrainwaveMode.rest:
        return 2.0;
      case BrainwaveMode.neutral:
        return 10.0;
    }
  }
  
  String get description {
    switch (this) {
      case BrainwaveMode.focus:
        return 'Sharpens mental clarity and concentration';
      case BrainwaveMode.calm:
        return 'Creates emotional breathing room and relaxation';
      case BrainwaveMode.deep:
        return 'Opens safe channel to subconscious processing';
      case BrainwaveMode.expand:
        return 'Integrates breakthrough energy and insights';
      case BrainwaveMode.rest:
        return 'Deep restoration and recovery';
      case BrainwaveMode.neutral:
        return 'Choose your own intention';
    }
  }
  
  static BrainwaveMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'focus':
        return BrainwaveMode.focus;
      case 'calm':
        return BrainwaveMode.calm;
      case 'deep':
        return BrainwaveMode.deep;
      case 'expand':
        return BrainwaveMode.expand;
      case 'rest':
        return BrainwaveMode.rest;
      case 'neutral':
      default:
        return BrainwaveMode.neutral;
    }
  }
}

/// A single transit-to-natal aspect for prescription.
class TransitPrescription {
  final String transitPlanet;
  final String natalPlanet;
  final String aspect;
  final double orb;
  final String nature;

  TransitPrescription({
    required this.transitPlanet,
    required this.natalPlanet,
    required this.aspect,
    required this.orb,
    required this.nature,
  });

  factory TransitPrescription.fromJson(Map<String, dynamic> json) {
    return TransitPrescription(
      transitPlanet: json['transit_planet'] as String,
      natalPlanet: json['natal_planet'] as String,
      aspect: json['aspect'] as String,
      orb: (json['orb'] as num).toDouble(),
      nature: json['nature'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'transit_planet': transitPlanet,
    'natal_planet': natalPlanet,
    'aspect': aspect,
    'orb': orb,
    'nature': nature,
  };
  
  /// Returns a human-readable description of this transit.
  String get description {
    final isHarmonious = nature == 'harmonious';
    final qualityWord = isHarmonious ? 'harmonizing with' : 'challenging';
    return '$transitPlanet $qualityWord $natalPlanet ($aspect)';
  }
}

/// Information about a brainwave mode.
class ModeInfo {
  final BrainwaveMode mode;
  final String name;
  final double hz;
  final String description;
  final String icon;

  ModeInfo({
    required this.mode,
    required this.name,
    required this.hz,
    required this.description,
    required this.icon,
  });

  factory ModeInfo.fromJson(Map<String, dynamic> json) {
    return ModeInfo(
      mode: BrainwaveModeExtension.fromString(json['mode'] as String),
      name: json['name'] as String,
      hz: (json['hz'] as num).toDouble(),
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }
}

/// Complete cosmic prescription response.
class CosmicPrescription {
  /// Primary transit (most significant active transit)
  final TransitPrescription? primaryTransit;
  
  /// Additional active transits (up to 2)
  final List<TransitPrescription> secondaryTransits;
  
  /// AI-recommended brainwave mode
  final BrainwaveMode recommendedMode;
  
  /// Brainwave frequency in Hz
  final double brainwaveHz;
  
  /// Carrier frequency (planet's Cosmic Octave)
  final double carrierFrequencyHz;
  
  /// Planet used for carrier frequency
  final String carrierPlanet;
  
  /// Plain language transit explanation
  final String whatsHappening;
  
  /// Human experience of this transit
  final String howItFeels;
  
  /// What the recommended frequency does
  final String whatItDoes;
  
  /// True if no significant transits active
  final bool isQuietDay;
  
  /// Total active transit count
  final int transitCount;
  
  /// All 6 modes with info for mode picker
  final List<ModeInfo> availableModes;

  CosmicPrescription({
    this.primaryTransit,
    required this.secondaryTransits,
    required this.recommendedMode,
    required this.brainwaveHz,
    required this.carrierFrequencyHz,
    required this.carrierPlanet,
    required this.whatsHappening,
    required this.howItFeels,
    required this.whatItDoes,
    required this.isQuietDay,
    required this.transitCount,
    required this.availableModes,
  });

  factory CosmicPrescription.fromJson(Map<String, dynamic> json) {
    return CosmicPrescription(
      primaryTransit: json['primary_transit'] != null
          ? TransitPrescription.fromJson(json['primary_transit'] as Map<String, dynamic>)
          : null,
      secondaryTransits: (json['secondary_transits'] as List<dynamic>?)
          ?.map((e) => TransitPrescription.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      recommendedMode: BrainwaveModeExtension.fromString(json['recommended_mode'] as String),
      brainwaveHz: (json['brainwave_hz'] as num).toDouble(),
      carrierFrequencyHz: (json['carrier_frequency_hz'] as num).toDouble(),
      carrierPlanet: json['carrier_planet'] as String,
      whatsHappening: json['whats_happening'] as String,
      howItFeels: json['how_it_feels'] as String,
      whatItDoes: json['what_it_does'] as String,
      isQuietDay: json['is_quiet_day'] as bool? ?? false,
      transitCount: json['transit_count'] as int? ?? 0,
      availableModes: (json['available_modes'] as List<dynamic>?)
          ?.map((e) => ModeInfo.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'primary_transit': primaryTransit?.toJson(),
    'secondary_transits': secondaryTransits.map((e) => e.toJson()).toList(),
    'recommended_mode': recommendedMode.name,
    'brainwave_hz': brainwaveHz,
    'carrier_frequency_hz': carrierFrequencyHz,
    'carrier_planet': carrierPlanet,
    'whats_happening': whatsHappening,
    'how_it_feels': howItFeels,
    'what_it_does': whatItDoes,
    'is_quiet_day': isQuietDay,
    'transit_count': transitCount,
  };
}
