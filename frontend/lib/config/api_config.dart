/// API configuration for backend communication.
class ApiConfig {
  /// Base URL for the backend API.
  /// Change this when deploying to production.
  static const String baseUrl = 'http://localhost:8000';
  
  /// API endpoints
  static const String healthEndpoint = '/health';
  static const String natalChartEndpoint = '/api/charts/natal';
  static const String geocodeSearchEndpoint = '/api/geocode/search';
  static const String userSonificationEndpoint = '/api/sonification/user';
  static const String dailySonificationEndpoint = '/api/sonification/daily';
  
  // AI endpoints
  static const String dailyReadingEndpoint = '/api/ai/daily-reading';
  static const String interpretAlignmentEndpoint = '/api/ai/interpret-alignment';
  static const String compatibilityEndpoint = '/api/ai/compatibility';
  static const String transitInterpretationEndpoint = '/api/ai/transit-interpretation';
  static const String playlistInsightEndpoint = '/api/ai/playlist-insight';
  static const String soundInterpretationEndpoint = '/api/ai/sound-interpretation';
  static const String welcomeEndpoint = '/api/ai/welcome';
  
  // Alignment endpoints
  static const String dailyAlignmentEndpoint = '/api/alignment/daily';
  static const String friendAlignmentEndpoint = '/api/alignment/friend';
  static const String transitsEndpoint = '/api/alignment/transits';
  
  // Attunement endpoints
  static const String attunementAnalyzeEndpoint = '/api/attunement/analyze';
  static const String attunementWeeklyDigestEndpoint = '/api/attunement/weekly-digest';
  
  // Spotify endpoints
  static const String spotifyAuthUrlEndpoint = '/api/spotify/auth-url';
  static const String spotifyStatusEndpoint = '/api/spotify/status';
  static const String spotifyCreatePlaylistEndpoint = '/api/spotify/create-playlist';
  static const String spotifyGenerateFromLibraryEndpoint = '/api/spotify/generate-from-library';
  static const String spotifyMonthlyZodiacEndpoint = '/api/spotify/monthly-zodiac';
  
  // Cosmic playlist endpoints (no user Spotify auth required)
  static const String cosmicGenerateEndpoint = '/api/cosmic/generate';
  static const String zodiacSeasonEndpoint = '/api/cosmic/zodiac-season';
  
  /// Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 30);
}
