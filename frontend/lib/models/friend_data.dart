/// Model representing friend profile data.
class FriendData {
  final int id;
  final String name;
  final String username;
  final List<int> avatarColors; // Hex color values for gradient
  final String sunSign;
  final String moonSign;
  final String risingSign;
  final String dominantFrequency;
  final String element;
  final String modality;
  final int compatibilityScore;
  final String status; // 'online' or 'offline'
  final String? lastAligned;
  final List<String>? mutualPlanets;

  const FriendData({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarColors,
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
    required this.dominantFrequency,
    required this.element,
    required this.modality,
    required this.compatibilityScore,
    required this.status,
    this.lastAligned,
    this.mutualPlanets,
  });

  /// Get Color objects from hex values
  List<dynamic> get gradientColors {
    return avatarColors.map((hex) => hex).toList();
  }

  /// Create from JSON (for future API integration)
  factory FriendData.fromJson(Map<String, dynamic> json) {
    return FriendData(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String? ?? '@${(json['name'] as String).toLowerCase().replaceAll(' ', '')}',
      avatarColors: (json['avatar_colors'] as List?)?.cast<int>() ?? 
                    [0xFFFF59D0, 0xFF7D67FE],
      sunSign: json['sun_sign'] as String? ?? json['sign'] as String? ?? 'Unknown',
      moonSign: json['moon_sign'] as String? ?? 'Unknown',
      risingSign: json['rising_sign'] as String? ?? 'Unknown',
      dominantFrequency: json['dominant_frequency'] as String? ?? '432 Hz',
      element: json['element'] as String? ?? 'Unknown',
      modality: json['modality'] as String? ?? 'Unknown',
      compatibilityScore: json['compatibility'] as int? ?? 0,
      status: json['status'] as String? ?? 'offline',
      lastAligned: json['last_aligned'] as String?,
      mutualPlanets: (json['mutual_planets'] as List?)?.cast<String>(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'avatar_colors': avatarColors,
    'sun_sign': sunSign,
    'moon_sign': moonSign,
    'rising_sign': risingSign,
    'dominant_frequency': dominantFrequency,
    'element': element,
    'modality': modality,
    'compatibility': compatibilityScore,
    'status': status,
    'last_aligned': lastAligned,
    'mutual_planets': mutualPlanets,
  };

  /// Create mock data for testing (temporary until backend is ready)
  static FriendData createMock({
    required int id,
    required String name,
    required String sign,
    required int color1,
    required int color2,
    int compatibility = 80,
    String status = 'online',
  }) {
    return FriendData(
      id: id,
      name: name,
      username: '@${name.toLowerCase().replaceAll(' ', '')}',
      avatarColors: [color1, color2],
      sunSign: sign,
      moonSign: 'Cancer',
      risingSign: 'Scorpio',
      dominantFrequency: '432 Hz',
      element: 'Water',
      modality: 'Mutable',
      compatibilityScore: compatibility,
      status: status,
    );
  }
}
