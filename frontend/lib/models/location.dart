// Data model for location geocoding results.

/// Represents a geocoded location with coordinates.
class Location {
  final String displayName;
  final String? city;
  final String? state;
  final String country;
  final String countryCode;
  final double latitude;
  final double longitude;

  Location({
    required this.displayName,
    this.city,
    this.state,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      displayName: json['display_name'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String,
      countryCode: json['country_code'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'city': city,
      'state': state,
      'country': country,
      'country_code': countryCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => displayName;
}
