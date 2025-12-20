import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/natal_chart.dart';
import '../models/location.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/playlist.dart';
import '../models/alignment.dart';

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
  /// [subjectName] - Optional name for third-person horoscope (e.g., friend's name)
  Future<DailyReading> getDailyReading({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
    String? subjectName,
  }) async {
    final Map<String, dynamic> body = {
      'datetime': datetime,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
    
    if (subjectName != null) {
      body['subject_name'] = subjectName;
    }
    
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dailyReadingEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
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
    final Map<String, dynamic> body = {
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
    String? friendName,
  }) async {
    final Map<String, dynamic> body = {
      'user_datetime': userDatetime,
      'user_latitude': userLatitude,
      'user_longitude': userLongitude,
      'friend_datetime': friendDatetime,
      'friend_latitude': friendLatitude,
      'friend_longitude': friendLongitude,
    };
    
    if (friendName != null) {
      body['friend_name'] = friendName;
    }
    
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.compatibilityEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
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

  /// Get AI-generated interpretation of current planetary transits.
  Future<TransitInterpretation> getTransitInterpretation() async {
    final response = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transitInterpretationEndpoint}'))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return TransitInterpretation.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get transit interpretation',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get AI-generated insight explaining why a playlist was created.
  Future<PlaylistInsight> getPlaylistInsight({
    required String datetime,
    required double latitude,
    required double longitude,
    required int energyPercent,
    required String dominantMood,
    required String dominantElement,
    required int bpmMin,
    required int bpmMax,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.playlistInsightEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'energy_percent': energyPercent,
            'dominant_mood': dominantMood,
            'dominant_element': dominantElement,
            'bpm_min': bpmMin,
            'bpm_max': bpmMax,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return PlaylistInsight.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get playlist insight',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get AI-generated interpretation of user's cosmic sound profile.
  Future<SoundInterpretation> getSoundInterpretation({
    required String datetime,
    required double latitude,
    required double longitude,
    required String dominantElement,
    required List<Map<String, dynamic>> planets,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.soundInterpretationEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'dominant_element': dominantElement,
            'planets': planets,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return SoundInterpretation.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get sound interpretation',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get AI-generated welcome message for new users during onboarding.
  Future<WelcomeMessage> getWelcomeMessage({
    required String datetime,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.welcomeEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return WelcomeMessage.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get welcome message',
        statusCode: response.statusCode,
      );
    }
  }

  /// Generate a personalized playlist based on birth chart data.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  /// [playlistSize] - Number of songs to generate (default: 20)
  Future<PlaylistResult> generatePlaylist({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
    int playlistSize = 20,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/playlist/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'birth_datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
            'playlist_size': playlistSize,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return PlaylistResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to generate playlist',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get daily alignment score based on natal chart vs current transits.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  Future<AlignmentResult> getDailyAlignment({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dailyAlignmentEndpoint}'),
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
      return AlignmentResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get daily alignment',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get synastry alignment between user and friend natal charts.
  ///
  /// [userDatetime] - User birth datetime ISO format
  /// [userLatitude] - User birth latitude
  /// [userLongitude] - User birth longitude
  /// [userTimezone] - User timezone
  /// [friendDatetime] - Friend birth datetime ISO format
  /// [friendLatitude] - Friend birth latitude
  /// [friendLongitude] - Friend birth longitude
  /// [friendTimezone] - Friend timezone
  Future<FriendAlignmentResult> getFriendAlignment({
    required String userDatetime,
    required double userLatitude,
    required double userLongitude,
    String userTimezone = 'UTC',
    required String friendDatetime,
    required double friendLatitude,
    required double friendLongitude,
    String friendTimezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.friendAlignmentEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_datetime': userDatetime,
            'user_latitude': userLatitude,
            'user_longitude': userLongitude,
            'user_timezone': userTimezone,
            'friend_datetime': friendDatetime,
            'friend_latitude': friendLatitude,
            'friend_longitude': friendLongitude,
            'friend_timezone': friendTimezone,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return FriendAlignmentResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get friend alignment',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get current planetary transit positions.
  Future<TransitsResult> getTransits() async {
    final response = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transitsEndpoint}'))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return TransitsResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get transits',
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
