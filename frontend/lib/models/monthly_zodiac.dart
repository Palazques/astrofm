import '../services/spotify_service.dart';

/// Monthly zodiac playlist response from the API.
class MonthlyZodiacPlaylist {
  final bool success;
  final String zodiacSign;
  final String symbol;
  final String element;
  final String dateRange;
  final String elementQualities;  // New: Element quality description
  final String horoscope;
  final String vibeSummary;
  final int energyLevel;
  final String? playlistId;
  final String? playlistUrl;
  final List<SpotifyTrack> tracks;
  final String zodiacSeasonKey;  // New: Cache key like "Capricorn_2024"
  final DateTime cachedUntil;

  MonthlyZodiacPlaylist({
    required this.success,
    required this.zodiacSign,
    required this.symbol,
    required this.element,
    required this.dateRange,
    required this.elementQualities,
    required this.horoscope,
    required this.vibeSummary,
    required this.energyLevel,
    this.playlistId,
    this.playlistUrl,
    required this.tracks,
    required this.zodiacSeasonKey,
    required this.cachedUntil,
  });

  factory MonthlyZodiacPlaylist.fromJson(Map<String, dynamic> json) {
    return MonthlyZodiacPlaylist(
      success: json['success'] as bool? ?? false,
      zodiacSign: json['zodiac_sign'] as String? ?? 'Unknown',
      symbol: json['symbol'] as String? ?? '♈',
      element: json['element'] as String? ?? 'Fire',
      dateRange: json['date_range'] as String? ?? '',
      elementQualities: json['element_qualities'] as String? ?? '',
      horoscope: json['horoscope'] as String? ?? '',
      vibeSummary: json['vibe_summary'] as String? ?? '',
      energyLevel: json['energy_level'] as int? ?? 50,
      playlistId: json['playlist_id'] as String?,
      playlistUrl: json['playlist_url'] as String?,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      zodiacSeasonKey: json['zodiac_season_key'] as String? ?? '',
      cachedUntil: DateTime.tryParse(json['cached_until'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'zodiac_sign': zodiacSign,
      'symbol': symbol,
      'element': element,
      'date_range': dateRange,
      'element_qualities': elementQualities,
      'horoscope': horoscope,
      'vibe_summary': vibeSummary,
      'energy_level': energyLevel,
      'playlist_id': playlistId,
      'playlist_url': playlistUrl,
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'zodiac_season_key': zodiacSeasonKey,
      'cached_until': cachedUntil.toIso8601String(),
    };
  }

  /// Get element color for theming.
  /// Fire=orange/red, Earth=green/brown, Air=light blue, Water=blue/teal
  static List<int> getElementColors(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
        return [0xFFFF6B35, 0xFFFF4444]; // Orange to red
      case 'earth':
        return [0xFF8BC34A, 0xFF795548]; // Green to brown
      case 'air':
        return [0xFF64B5F6, 0xFFE1BEE7]; // Light blue to lavender
      case 'water':
        return [0xFF00BCD4, 0xFF1565C0]; // Teal to deep blue
      default:
        return [0xFFE91E63, 0xFF9C27B0]; // Pink to purple fallback
    }
  }
}

