/// Data model for user birth information.
/// Used for storing and loading birth data from local storage.

import 'dart:convert';

class BirthData {
  final String name;
  final String datetime;      // ISO format: YYYY-MM-DDTHH:MM:SS
  final double latitude;
  final double longitude;
  final String timezone;
  final String locationName;  // Display name (e.g., "Los Angeles, CA")

  const BirthData({
    required this.name,
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.locationName,
  });

  /// Create BirthData from JSON map.
  factory BirthData.fromJson(Map<String, dynamic> json) {
    return BirthData(
      name: json['name'] as String,
      datetime: json['datetime'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      locationName: json['locationName'] as String,
    );
  }

  /// Convert BirthData to JSON map.
  Map<String, dynamic> toJson() => {
    'name': name,
    'datetime': datetime,
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
    'locationName': locationName,
  };

  /// Convert to JSON string for storage.
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string.
  factory BirthData.fromJsonString(String jsonString) {
    return BirthData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Get formatted birth date for display.
  String get formattedDate {
    try {
      final date = DateTime.parse(datetime);
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return datetime;
    }
  }

  /// Get formatted birth time for display.
  String get formattedTime {
    try {
      final date = DateTime.parse(datetime);
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  /// Create a copy with some fields updated.
  BirthData copyWith({
    String? name,
    String? datetime,
    double? latitude,
    double? longitude,
    String? timezone,
    String? locationName,
  }) {
    return BirthData(
      name: name ?? this.name,
      datetime: datetime ?? this.datetime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  String toString() => 'BirthData(name: $name, datetime: $datetime, location: $locationName)';
}
