/// API configuration for backend communication.
class ApiConfig {
  /// Base URL for the backend API.
  /// Change this when deploying to production.
  static const String baseUrl = 'http://localhost:8000';
  
  /// API endpoints
  static const String healthEndpoint = '/health';
  static const String natalChartEndpoint = '/api/charts/natal';
  static const String geocodeSearchEndpoint = '/api/geocode/search';
  
  /// Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 30);
}
