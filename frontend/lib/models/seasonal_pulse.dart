import 'seasonal_track.dart';

/// Response from the /api/cosmic/seasonal-pulse endpoint.
/// Contains information about the current zodiac season and themed playlists.
class SeasonalPulseResponse {
  final String activeSign;
  final String symbol;
  final String element;
  final String modality;
  final String dateRange;
  final String rulingPlanet;
  final String rulingSymbol;
  final String color1;
  final String color2;
  final String cachedUntil;
  final List<SeasonalTheme> themes;

  SeasonalPulseResponse({
    required this.activeSign,
    required this.symbol,
    required this.element,
    required this.modality,
    required this.dateRange,
    required this.rulingPlanet,
    required this.rulingSymbol,
    required this.color1,
    required this.color2,
    required this.cachedUntil,
    required this.themes,
  });

  factory SeasonalPulseResponse.fromJson(Map<String, dynamic> json) {
    return SeasonalPulseResponse(
      activeSign: json['active_sign'] ?? '',
      symbol: json['symbol'] ?? '',
      element: json['element'] ?? '',
      modality: json['modality'] ?? '',
      dateRange: json['date_range'] ?? '',
      rulingPlanet: json['ruling_planet'] ?? '',
      rulingSymbol: json['ruling_symbol'] ?? '',
      color1: json['color1'] ?? '#7D67FE',
      color2: json['color2'] ?? '#00D4AA',
      cachedUntil: json['cached_until'] ?? '',
      themes: (json['themes'] as List<dynamic>?)
              ?.map((t) => SeasonalTheme.fromJson(t))
              .toList() ??
          [],
    );
  }
}

/// A themed playlist for a specific life area during the current season.
class SeasonalTheme {
  final String id;
  final String title;
  final String glyph;
  final String vibeDescription;
  final String monthlyMessage;
  final String? playlistUrl;
  final int trackCount;
  final String totalDuration;
  final List<SeasonalTrack> tracks;

  SeasonalTheme({
    required this.id,
    required this.title,
    required this.glyph,
    required this.vibeDescription,
    required this.monthlyMessage,
    this.playlistUrl,
    required this.trackCount,
    required this.totalDuration,
    required this.tracks,
  });

  factory SeasonalTheme.fromJson(Map<String, dynamic> json) {
    return SeasonalTheme(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      glyph: json['glyph'] ?? '◆',
      vibeDescription: json['vibe_description'] ?? '',
      monthlyMessage: json['monthly_message'] ?? '',
      playlistUrl: json['playlist_url'],
      trackCount: json['track_count'] ?? 0,
      totalDuration: json['total_duration'] ?? '0 min',
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => SeasonalTrack.fromJson(t))
              .toList() ??
          [],
    );
  }
}
