import 'dart:ui';

/// Personal insight about how the zodiac season affects the user.
class PersonalInsight {
  final String headline;
  final String subtext;
  final String meaning;
  final List<String> focusAreas;

  const PersonalInsight({
    required this.headline,
    required this.subtext,
    required this.meaning,
    required this.focusAreas,
  });

  factory PersonalInsight.fromJson(Map<String, dynamic> json) {
    return PersonalInsight(
      headline: json['headline'] as String? ?? 'Season Insight',
      subtext: json['subtext'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      focusAreas: (json['focus_areas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

/// Track info with energy level for seasonal playlist display.
class SeasonTrack {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final int energy;
  final String? url;

  const SeasonTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.energy,
    this.url,
  });

  factory SeasonTrack.fromJson(Map<String, dynamic> json) {
    return SeasonTrack(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Track',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      duration: json['duration'] as String? ?? '0:00',
      energy: json['energy'] as int? ?? 70,
      url: json['url'] as String?,
    );
  }
}

/// Complete zodiac season card data from the API.
class ZodiacSeasonCardData {
  final bool success;
  // Season info
  final String sign;
  final String symbol;
  final String element;
  final String modality;
  final String dateRange;
  final String rulingPlanet;
  final String rulingSymbol;
  final Color color1;
  final Color color2;
  // Personal insight
  final PersonalInsight personalInsight;
  // Playlist
  final String playlistName;
  final String playlistDescription;
  final String totalDuration;
  final int trackCount;
  final List<String> vibeTags;
  final List<SeasonTrack> tracks;
  final String? playlistUrl;
  // Cache metadata
  final String seasonKey;
  final DateTime cachedUntil;

  const ZodiacSeasonCardData({
    required this.success,
    required this.sign,
    required this.symbol,
    required this.element,
    required this.modality,
    required this.dateRange,
    required this.rulingPlanet,
    required this.rulingSymbol,
    required this.color1,
    required this.color2,
    required this.personalInsight,
    required this.playlistName,
    required this.playlistDescription,
    required this.totalDuration,
    required this.trackCount,
    required this.vibeTags,
    required this.tracks,
    this.playlistUrl,
    required this.seasonKey,
    required this.cachedUntil,
  });

  factory ZodiacSeasonCardData.fromJson(Map<String, dynamic> json) {
    return ZodiacSeasonCardData(
      success: json['success'] as bool? ?? false,
      sign: json['zodiac_sign'] as String? ?? 'Unknown',
      symbol: json['symbol'] as String? ?? '♈',
      element: json['element'] as String? ?? 'Fire',
      modality: json['modality'] as String? ?? 'Cardinal',
      dateRange: json['date_range'] as String? ?? '',
      rulingPlanet: json['ruling_planet'] as String? ?? 'Sun',
      rulingSymbol: json['ruling_symbol'] as String? ?? '☉',
      color1: _parseColor(json['color1'] as String?),
      color2: _parseColor(json['color2'] as String?),
      personalInsight: PersonalInsight.fromJson(
        json['personal_insight'] as Map<String, dynamic>? ?? {},
      ),
      playlistName: json['playlist_name'] as String? ?? 'Seasonal Playlist',
      playlistDescription: json['playlist_description'] as String? ?? '',
      totalDuration: json['total_duration'] as String? ?? '0 min',
      trackCount: (json['tracks'] as List<dynamic>?)?.length ?? 0,
      vibeTags: (json['vibe_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => SeasonTrack.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      playlistUrl: json['playlist_url'] as String?,
      seasonKey: json['zodiac_season_key'] as String? ?? '',
      cachedUntil: DateTime.tryParse(json['cached_until'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Parse hex color string to Color.
  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF7D67FE);
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  /// Get element color based on element type.
  Color get elementColor {
    switch (element.toLowerCase()) {
      case 'fire':
        return const Color(0xFFE84855);
      case 'earth':
        return const Color(0xFF00D4AA);
      case 'air':
        return const Color(0xFF64B5F6);
      case 'water':
        return const Color(0xFF00B4D8);
      default:
        return color1;
    }
  }
}
