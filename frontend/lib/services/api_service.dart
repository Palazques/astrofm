import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/natal_chart.dart';
import '../models/location.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/playlist.dart';
import '../models/alignment.dart';
import '../models/attunement.dart';
import '../models/prescription.dart';

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

  /// Get Sound Signature alignment between personal and daily charts.
  /// 
  /// Compares user's natal Sound Signature with today's transit Sound Signature,
  /// identifies alignments/tensions, and returns an alignment meditation sound.
  Future<AlignmentResponse> getSoundSignatureAlignment({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/sonification/alignment'),
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
      return AlignmentResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get Sound Signature alignment',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get Sound Signature alignment between user and friend.
  /// 
  /// Compares user's natal Sound Signature with friend's natal Sound Signature,
  /// identifies alignments/tensions, and returns an alignment meditation sound.
  Future<AlignmentResponse> getFriendSoundSignatureAlignment({
    required String userDatetime,
    required double userLatitude,
    required double userLongitude,
    String userTimezone = 'UTC',
    required String friendDatetime,
    required double friendLatitude,
    required double friendLongitude,
    String friendTimezone = 'UTC',
    String? friendName,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/sonification/friend-alignment'),
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
            if (friendName != null) 'friend_name': friendName,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return AlignmentResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get friend Sound Signature alignment',
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

  /// Get attunement analysis comparing natal chart to current transits.
  /// Identifies gaps (where user needs to attune) and resonances (natural alignment).
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  Future<AttunementAnalysis> getAttunementAnalysis({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.attunementAnalyzeEndpoint}'),
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
      return AttunementAnalysis.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get attunement analysis',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get weekly digest of attunement patterns.
  /// Shows trends, best/worst days, and common gaps for the past week.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  Future<WeeklyDigest> getWeeklyDigest({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.attunementWeeklyDigestEndpoint}'),
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
      return WeeklyDigest.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get weekly digest',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get cosmic prescription based on transit-to-natal aspects.
  /// Returns personalized brainwave recommendations with AI-generated text.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  Future<CosmicPrescription> getCosmicPrescription({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/prescription/cosmic'),
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
      return CosmicPrescription.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get cosmic prescription',
        statusCode: response.statusCode,
      );
    }
  }

  /// Generate a playlist from the 114K track music dataset with genre preferences.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  /// [playlistSize] - Number of tracks to generate (default: 20)
  /// [mainGenres] - User's selected main genres (e.g., ["Electronic", "Latin"])
  /// [subgenres] - User's explicitly selected subgenres (e.g., ["Trance", "Reggaeton"])
  /// [includeRelated] - Include related genres at 0.3x weight (default: true)
  Future<DatasetPlaylistResult> generateFromDataset({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
    int playlistSize = 20,
    List<String> mainGenres = const [],
    List<String> subgenres = const [],
    bool includeRelated = true,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/playlist/generate-from-dataset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'birth_datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
            'playlist_size': playlistSize,
            'main_genres': mainGenres,
            'subgenres': subgenres,
            'include_related': includeRelated,
          }),
        )
        .timeout(const Duration(seconds: 120)); // Longer timeout for dataset loading

    if (response.statusCode == 200) {
      return DatasetPlaylistResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to generate playlist from dataset',
        statusCode: response.statusCode,
      );
    }
  }

  /// Generate a cosmic playlist using AI + app's Spotify account.
  /// No user Spotify auth required.
  ///
  /// [sunSign] - User's Sun sign (e.g., "Capricorn")
  /// [moonSign] - User's Moon sign
  /// [risingSign] - User's Rising/Ascendant sign
  /// [genrePreferences] - User's preferred genres
  Future<CosmicPlaylistResult> generateCosmicPlaylist({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required List<String> genrePreferences,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/cosmic/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sun_sign': sunSign,
            'moon_sign': moonSign,
            'rising_sign': risingSign,
            'genre_preferences': genrePreferences,
          }),
        )
        .timeout(const Duration(seconds: 120)); // AI + Spotify takes time

    if (response.statusCode == 200) {
      return CosmicPlaylistResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to generate cosmic playlist',
        statusCode: response.statusCode,
      );
    }
  }

  /// Generate a zodiac season playlist using AI + app's Spotify account.
  /// No user Spotify auth required. Cached per zodiac season (~30 days).
  ///
  /// [sunSign] - User's Sun sign (e.g., "Capricorn")
  /// [moonSign] - User's Moon sign
  /// [risingSign] - User's Rising/Ascendant sign
  /// [genrePreferences] - User's preferred genres
  Future<ZodiacSeasonPlaylistResult> getZodiacSeasonPlaylist({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required List<String> genrePreferences,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.zodiacSeasonEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sun_sign': sunSign,
            'moon_sign': moonSign,
            'rising_sign': risingSign,
            'genre_preferences': genrePreferences,
          }),
        )
        .timeout(const Duration(seconds: 120)); // AI + Spotify takes time

    if (response.statusCode == 200) {
      return ZodiacSeasonPlaylistResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to generate zodiac season playlist',
        statusCode: response.statusCode,
      );
    }
  }

  /// Export a playlist as formatted text.
  Future<String> exportPlaylistAsText({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
    int playlistSize = 20,
    List<String> mainGenres = const [],
    List<String> subgenres = const [],
    bool includeRelated = true,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/playlist/export/text'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'birth_datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
            'playlist_size': playlistSize,
            'main_genres': mainGenres,
            'subgenres': subgenres,
            'include_related': includeRelated,
          }),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['formatted_text'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to export playlist',
        statusCode: response.statusCode,
      );
    }
  }

  // =========================================================================
  // USER LIBRARY INTEGRATION
  // =========================================================================

  /// Sync Spotify library to the app's shared music pool.
  ///
  /// Call this after Spotify OAuth completes to import user's saved tracks.
  /// Tracks are deduplicated using hybrid matching (provider ID + name+artist).
  ///
  /// [accessToken] - Valid Spotify access token
  /// [maxTracks] - Maximum tracks to sync (default: 500)
  Future<UserLibrarySyncResult> syncSpotifyLibrary({
    required String accessToken,
    int maxTracks = 500,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/user-library/sync/spotify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'access_token': accessToken,
            'max_tracks': maxTracks,
          }),
        )
        .timeout(const Duration(seconds: 120)); // Long timeout for library sync

    if (response.statusCode == 200) {
      return UserLibrarySyncResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to sync Spotify library',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get library statistics (total tracks, features status, etc).
  Future<UserLibraryStats> getUserLibraryStats() async {
    final response = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}/api/user-library/stats'))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return UserLibraryStats.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to get library stats',
        statusCode: response.statusCode,
      );
    }
  }

  /// Generate a blended playlist from user library + app dataset.
  ///
  /// If user has synced their Spotify library, this will blend their tracks
  /// with the app's dataset based on the day's astrology.
  /// Falls back to dataset-only if no user library exists.
  ///
  /// [datetime] - Birth date and time in ISO format
  /// [latitude] - Birth location latitude
  /// [longitude] - Birth location longitude
  /// [timezone] - Timezone name (default: UTC)
  /// [playlistSize] - Number of tracks to generate (default: 20)
  /// [mainGenres] - User's selected main genres
  /// [subgenres] - User's explicitly selected subgenres
  /// [includeRelated] - Include related genres at 0.3x weight
  Future<BlendedPlaylistResult> generateBlendedPlaylist({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = 'UTC',
    int playlistSize = 20,
    List<String> mainGenres = const [],
    List<String> subgenres = const [],
    bool includeRelated = true,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/playlist/generate-blended'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'birth_datetime': datetime,
            'latitude': latitude,
            'longitude': longitude,
            'timezone': timezone,
            'playlist_size': playlistSize,
            'main_genres': mainGenres,
            'subgenres': subgenres,
            'include_related': includeRelated,
          }),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      return BlendedPlaylistResult.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        message: error['detail'] ?? 'Failed to generate blended playlist',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

// =========================================================================
// USER LIBRARY MODELS
// =========================================================================

/// Result of syncing user's Spotify library.
class UserLibrarySyncResult {
  final bool success;
  final int totalProcessed;
  final int inserted;
  final int duplicateId;
  final int duplicateName;
  final int skipped;
  final String message;

  UserLibrarySyncResult({
    required this.success,
    required this.totalProcessed,
    required this.inserted,
    required this.duplicateId,
    required this.duplicateName,
    required this.skipped,
    required this.message,
  });

  factory UserLibrarySyncResult.fromJson(Map<String, dynamic> json) {
    return UserLibrarySyncResult(
      success: json['success'] ?? false,
      totalProcessed: json['total_processed'] ?? 0,
      inserted: json['inserted'] ?? 0,
      duplicateId: json['duplicate_id'] ?? 0,
      duplicateName: json['duplicate_name'] ?? 0,
      skipped: json['skipped'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

/// Statistics about the app's shared user library.
class UserLibraryStats {
  final int totalTracks;
  final int completeFeatures;
  final int pendingFeatures;
  final int failedFeatures;
  final Map<String, int> elementDistribution;

  UserLibraryStats({
    required this.totalTracks,
    required this.completeFeatures,
    required this.pendingFeatures,
    required this.failedFeatures,
    required this.elementDistribution,
  });

  factory UserLibraryStats.fromJson(Map<String, dynamic> json) {
    return UserLibraryStats(
      totalTracks: json['total_tracks'] ?? 0,
      completeFeatures: json['complete_features'] ?? 0,
      pendingFeatures: json['pending_features'] ?? 0,
      failedFeatures: json['failed_features'] ?? 0,
      elementDistribution: Map<String, int>.from(
        (json['element_distribution'] ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
    );
  }

  /// Check if user library has any tracks with complete features.
  bool get hasLibrary => completeFeatures > 0;
}

/// A track in a blended playlist (from user library or app dataset).
class BlendedTrack {
  final String trackId;
  final String trackName;
  final String artists;
  final String? albumName;
  final int durationMs;
  final double? energy;
  final double? valence;
  final double? danceability;
  final String? mainGenre;
  final String? subgenre;
  final String? element;
  final String source; // "user_library" or "app_dataset"
  final double matchScore;

  BlendedTrack({
    required this.trackId,
    required this.trackName,
    required this.artists,
    this.albumName,
    required this.durationMs,
    this.energy,
    this.valence,
    this.danceability,
    this.mainGenre,
    this.subgenre,
    this.element,
    required this.source,
    required this.matchScore,
  });

  factory BlendedTrack.fromJson(Map<String, dynamic> json) {
    return BlendedTrack(
      trackId: json['track_id'] ?? '',
      trackName: json['track_name'] ?? '',
      artists: json['artists'] ?? '',
      albumName: json['album_name'],
      durationMs: json['duration_ms'] ?? 0,
      energy: json['energy']?.toDouble(),
      valence: json['valence']?.toDouble(),
      danceability: json['danceability']?.toDouble(),
      mainGenre: json['main_genre'],
      subgenre: json['subgenre'],
      element: json['element'],
      source: json['source'] ?? 'app_dataset',
      matchScore: (json['match_score'] ?? 0).toDouble(),
    );
  }

  /// Check if this track is from the user's library.
  bool get isFromUserLibrary => source == 'user_library';
}

/// Result of blended playlist generation.
class BlendedPlaylistResult {
  final List<BlendedTrack> tracks;
  final int totalDurationMs;
  final double vibeMatchScore;
  final List<double> energyArc;
  final Map<String, int> elementDistribution;
  final Map<String, int> genreDistribution;
  final BlendedPlaylistMetadata metadata;

  BlendedPlaylistResult({
    required this.tracks,
    required this.totalDurationMs,
    required this.vibeMatchScore,
    required this.energyArc,
    required this.elementDistribution,
    required this.genreDistribution,
    required this.metadata,
  });

  factory BlendedPlaylistResult.fromJson(Map<String, dynamic> json) {
    return BlendedPlaylistResult(
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((t) => BlendedTrack.fromJson(t))
          .toList() ?? [],
      totalDurationMs: json['total_duration_ms'] ?? 0,
      vibeMatchScore: (json['vibe_match_score'] ?? 0).toDouble(),
      energyArc: (json['energy_arc'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
      elementDistribution: Map<String, int>.from(
        (json['element_distribution'] ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      genreDistribution: Map<String, int>.from(
        (json['genre_distribution'] ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ),
      ),
      metadata: BlendedPlaylistMetadata.fromJson(
        json['generation_metadata'] ?? {},
      ),
    );
  }

  /// Number of tracks from user library.
  int get userLibraryCount => tracks.where((t) => t.isFromUserLibrary).length;

  /// Number of tracks from app dataset.
  int get datasetCount => tracks.where((t) => !t.isFromUserLibrary).length;
}

/// Metadata about blended playlist generation.
class BlendedPlaylistMetadata {
  final String source;
  final int userLibraryTracks;
  final int datasetTracks;
  final int playlistSizeRequested;
  final int tracksSelected;
  final List<int>? targetEnergy;
  final List<int>? targetValence;
  final List<String> primaryElements;
  final int? userLibraryPoolSize;

  BlendedPlaylistMetadata({
    required this.source,
    required this.userLibraryTracks,
    required this.datasetTracks,
    required this.playlistSizeRequested,
    required this.tracksSelected,
    this.targetEnergy,
    this.targetValence,
    required this.primaryElements,
    this.userLibraryPoolSize,
  });

  factory BlendedPlaylistMetadata.fromJson(Map<String, dynamic> json) {
    return BlendedPlaylistMetadata(
      source: json['source'] ?? 'dataset_only',
      userLibraryTracks: json['user_library_tracks'] ?? 0,
      datasetTracks: json['dataset_tracks'] ?? 0,
      playlistSizeRequested: json['playlist_size_requested'] ?? 20,
      tracksSelected: json['tracks_selected'] ?? 0,
      targetEnergy: (json['target_energy'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      targetValence: (json['target_valence'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      primaryElements: List<String>.from(json['primary_elements'] ?? []),
      userLibraryPoolSize: json['user_library_pool_size'],
    );
  }

  /// Check if playlist is blended (has tracks from both sources).
  bool get isBlended => source == 'blended';
}

/// Result from zodiac season playlist generation.
/// Contains zodiac info, element qualities, horoscope, and playlist tracks.
class ZodiacSeasonPlaylistResult {
  final bool success;
  final String zodiacSign;
  final String symbol;
  final String element;
  final String dateRange;
  final String elementQualities;
  final String horoscope;
  final String vibeSummary;
  final String? playlistUrl;
  final String? playlistId;
  final int trackCount;
  final List<ZodiacSeasonTrack> tracks;
  final String zodiacSeasonKey;
  final String cachedUntil;
  final String? error;

  ZodiacSeasonPlaylistResult({
    required this.success,
    required this.zodiacSign,
    required this.symbol,
    required this.element,
    required this.dateRange,
    required this.elementQualities,
    required this.horoscope,
    required this.vibeSummary,
    this.playlistUrl,
    this.playlistId,
    required this.trackCount,
    required this.tracks,
    required this.zodiacSeasonKey,
    required this.cachedUntil,
    this.error,
  });

  factory ZodiacSeasonPlaylistResult.fromJson(Map<String, dynamic> json) {
    return ZodiacSeasonPlaylistResult(
      success: json['success'] ?? false,
      zodiacSign: json['zodiac_sign'] ?? '',
      symbol: json['symbol'] ?? '♈',
      element: json['element'] ?? 'Fire',
      dateRange: json['date_range'] ?? '',
      elementQualities: json['element_qualities'] ?? '',
      horoscope: json['horoscope'] ?? '',
      vibeSummary: json['vibe_summary'] ?? '',
      playlistUrl: json['playlist_url'],
      playlistId: json['playlist_id'],
      trackCount: json['track_count'] ?? 0,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => ZodiacSeasonTrack.fromJson(t))
              .toList() ??
          [],
      zodiacSeasonKey: json['zodiac_season_key'] ?? '',
      cachedUntil: json['cached_until'] ?? '',
      error: json['error'],
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
      'playlist_url': playlistUrl,
      'playlist_id': playlistId,
      'track_count': trackCount,
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'zodiac_season_key': zodiacSeasonKey,
      'cached_until': cachedUntil,
      'error': error,
    };
  }
}

/// A track in a zodiac season playlist.
class ZodiacSeasonTrack {
  final String name;
  final String artist;
  final String url;
  final String? albumArt;

  ZodiacSeasonTrack({
    required this.name,
    required this.artist,
    required this.url,
    this.albumArt,
  });

  factory ZodiacSeasonTrack.fromJson(Map<String, dynamic> json) {
    return ZodiacSeasonTrack(
      name: json['name'] ?? '',
      artist: json['artist'] ?? '',
      url: json['url'] ?? '',
      albumArt: json['album_art'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artist': artist,
      'url': url,
      'album_art': albumArt,
    };
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
