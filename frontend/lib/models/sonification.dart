import 'dart:convert';

/// Model for planet sound synthesis parameters.
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

/// Model for complete chart sonification data.
class ChartSonification {
  final List<PlanetSound> planets;
  final String ascendantSign;
  final double dominantFrequency;
  final double totalDuration;

  ChartSonification({
    required this.planets,
    required this.ascendantSign,
    required this.dominantFrequency,
    required this.totalDuration,
  });

  factory ChartSonification.fromJson(Map<String, dynamic> json) {
    return ChartSonification(
      planets: (json['planets'] as List)
          .map((p) => PlanetSound.fromJson(p as Map<String, dynamic>))
          .toList(),
      ascendantSign: json['ascendant_sign'] as String,
      dominantFrequency: (json['dominant_frequency'] as num).toDouble(),
      totalDuration: (json['total_duration'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'planets': planets.map((p) => p.toJson()).toList(),
    'ascendant_sign': ascendantSign,
    'dominant_frequency': dominantFrequency,
    'total_duration': totalDuration,
  };
}
