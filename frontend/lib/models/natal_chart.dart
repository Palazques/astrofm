// Data models for natal chart data.

/// Represents a single planet's position in the chart.
class PlanetPosition {
  final String name;
  final double longitude;
  final double latitude;
  final double distance;
  final double speed;
  final String sign;
  final double signDegree;
  final int house;
  final double houseDegree;
  final bool retrograde;

  PlanetPosition({
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.speed,
    required this.sign,
    required this.signDegree,
    required this.house,
    required this.houseDegree,
    required this.retrograde,
  });

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      name: json['name'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      sign: json['sign'] as String,
      signDegree: (json['sign_degree'] as num).toDouble(),
      house: json['house'] as int,
      houseDegree: (json['house_degree'] as num).toDouble(),
      retrograde: json['retrograde'] as bool,
    );
  }

  /// Get formatted position string (e.g., "15° Capricorn")
  String get formattedPosition => '${signDegree.toStringAsFixed(1)}° $sign';

  /// Get retrograde symbol if retrograde
  String get retrogradeSymbol => retrograde ? ' ℞' : '';
}

/// Represents a complete natal chart.
class NatalChart {
  final String birthDatetime;
  final double latitude;
  final double longitude;
  final String timezone;
  final double ascendant;
  final String ascendantSign;
  final List<PlanetPosition> planets;
  final List<double> houseCusps;

  NatalChart({
    required this.birthDatetime,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.ascendant,
    required this.ascendantSign,
    required this.planets,
    required this.houseCusps,
  });

  factory NatalChart.fromJson(Map<String, dynamic> json) {
    return NatalChart(
      birthDatetime: json['birth_datetime'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      ascendant: (json['ascendant'] as num).toDouble(),
      ascendantSign: json['ascendant_sign'] as String,
      planets: (json['planets'] as List)
          .map((p) => PlanetPosition.fromJson(p as Map<String, dynamic>))
          .toList(),
      houseCusps: (json['house_cusps'] as List)
          .map((h) => (h as num).toDouble())
          .toList(),
    );
  }

  /// Get formatted ascendant string
  String get formattedAscendant =>
      '${(ascendant % 30).toStringAsFixed(1)}° $ascendantSign Rising';
}
