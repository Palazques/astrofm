import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/natal_chart.dart';
import '../models/location.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';

/// Service for communicating with the backend API.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Check if the backend is healthy.
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.healthEndpoint}'))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Search for locations by name.
  ///
  /// [query] - Search text (city name, address, etc.)
  /// [limit] - Maximum number of results (default: 5)
  Future<List<Location>> searchLocations(String query, {int limit = 5}) async {
    if (query.length < 2) {
      return [];
    }

    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.geocodeSearchEndpoint}',
      ).replace(queryParameters: {
        'query': query,
        'limit': limit.toString(),
      });

      final response = await _client.get(uri).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Location.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Calculate a natal chart from birth data.
  ///
  /// [datetime] - Birth date and time in ISO format (YYYY-MM-DDTHH:MM:SS)
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  Future<NatalChart> calculateNatalChart({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.natalChartEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return NatalChart.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to calculate chart',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get sonification data for a user's birth chart.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  Future<ChartSonification> getUserSonification({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userSonificationEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return ChartSonification.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get sonification',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get sonification data for today's planetary transits.
  ///
  /// [latitude] - Observer latitude (optional, default: 0)
  /// [longitude] - Observer longitude (optional, default: 0)
  Future<ChartSonification> getDailySonification({
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.dailySonificationEndpoint}',
    ).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });

    final response = await _client.get(uri).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return ChartSonification.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get daily sonification',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get AI-generated daily reading with playlist parameters.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  Future<DailyReading> getDailyReading({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dailyReadingEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return DailyReading.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get daily reading',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get AI interpretation of alignment between user and target.
  ///
  /// If target parameters are null, aligns with today's transits.
  Future<AlignmentInterpretation> getAlignmentInterpretation({
    required String userDatetime,
    required double userLatitude,
    required double userLongitude,
    String? targetDatetime,
    double? targetLatitude,
    double? targetLongitude,
  }) async {
    final body = {
      'user_datetime': userDatetime,
      'user_latitude': userLatitude,
      'user_longitude': userLongitude,
    };
    
    if (targetDatetime != null) {
      body['target_datetime'] = targetDatetime;
      body['target_latitude'] = targetLatitude;
      body['target_longitude'] = targetLongitude;
    }

    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.interpretAlignmentEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return AlignmentInterpretation.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get alignment interpretation',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get AI-generated compatibility analysis between two people.
  Future<CompatibilityResult> getCompatibility({
    required String userDatetime,
    required double userLatitude,
    required double userLongitude,
    required String friendDatetime,
    required double friendLatitude,
    required double friendLongitude,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.compatibilityEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_datetime': userDatetime,
            'user_latitude': userLatitude,
            'user_longitude': userLongitude,
            'friend_datetime': friendDatetime,
            'friend_latitude': friendLatitude,
            'friend_longitude': friendLongitude,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return CompatibilityResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get compatibility',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Exception for API errors.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (status $statusCode)';
}
