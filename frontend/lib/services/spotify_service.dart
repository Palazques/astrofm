import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Model for Spotify connection status.
class SpotifyConnectionStatus {
  final bool connected;
  final String? userId;
  final String? displayName;
  final String? product;

  SpotifyConnectionStatus({
    required this.connected,
    this.userId,
    this.displayName,
    this.product,
  });

  factory SpotifyConnectionStatus.fromJson(Map<String, dynamic> json) {
    return SpotifyConnectionStatus(
      connected: json['connected'] ?? false,
      userId: json['user_id'],
      displayName: json['display_name'],
      product: json['product'],
    );
  }
}

/// Model for playlist creation result.
class SpotifyPlaylistResult {
  final bool success;
  final String? playlistId;
  final String? playlistUrl;
  final String? playlistUri;
  final int tracksAdded;
  final List<String> tracksNotFound;
  final List<SpotifyTrack> tracks;
  final double? avgEnergy;
  final double? avgValence;

  SpotifyPlaylistResult({
    required this.success,
    this.playlistId,
    this.playlistUrl,
    this.playlistUri,
    this.tracksAdded = 0,
    this.tracksNotFound = const [],
    this.tracks = const [],
    this.avgEnergy,
    this.avgValence,
  });

  factory SpotifyPlaylistResult.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylistResult(
      success: json['success'] ?? false,
      playlistId: json['playlist_id'],
      playlistUrl: json['playlist_url'],
      playlistUri: json['playlist_uri'],
      tracksAdded: json['tracks_added'] ?? 0,
      tracksNotFound: List<String>.from(json['tracks_not_found'] ?? []),
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((t) => SpotifyTrack.fromJson(t))
          .toList() ?? [],
      avgEnergy: json['avg_energy']?.toDouble(),
      avgValence: json['avg_valence']?.toDouble(),
    );
  }
}

/// Model for a track from Spotify library.
class SpotifyTrack {
  final String id;
  final String name;
  final List<String> artists;
  final String uri;
  final String url;
  final double? energy;
  final double? valence;
  final double? tempo;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artists,
    required this.uri,
    required this.url,
    this.energy,
    this.valence,
    this.tempo,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artists: List<String>.from(json['artists'] ?? []),
      uri: json['uri'] ?? '',
      url: json['url'] ?? '',
      energy: json['energy']?.toDouble(),
      valence: json['valence']?.toDouble(),
      tempo: json['tempo']?.toDouble(),
    );
  }
  
  /// Get artist name as a single string
  String get artistName => artists.isNotEmpty ? artists.first : 'Unknown Artist';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artists': artists,
      'uri': uri,
      'url': url,
      'energy': energy,
      'valence': valence,
      'tempo': tempo,
    };
  }
}


/// Service for Spotify integration.
/// 
/// Handles OAuth flow initiation, connection status, and playlist creation.
class SpotifyService {
  final http.Client _client;
  static const String _sessionIdKey = 'spotify_session_id';
  
  SpotifyService({http.Client? client}) : _client = client ?? http.Client();
  
  /// Get stored Spotify session ID from local storage.
  Future<String?> getStoredSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }
  
  /// Store Spotify session ID to local storage.
  Future<void> storeSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, sessionId);
  }
  
  /// Clear stored Spotify session.
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
  }
  
  /// Get Spotify OAuth URL and open it in browser.
  /// 
  /// Returns the state parameter that should be used to track the session.
  /// After user authorizes, they'll be redirected to the callback URL.
  Future<String?> initiateSpotifyAuth() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.spotifyAuthUrlEndpoint}'))
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authUrl = data['url'] as String;
        final state = data['state'] as String;
        
        // Open Spotify auth URL in browser
        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri, 
            mode: LaunchMode.externalApplication,
          );
        }
        
        return state;
      } else if (response.statusCode == 503) {
        throw SpotifyException(
          message: 'Spotify integration is not configured on the server',
          statusCode: response.statusCode,
        );
      } else {
        final error = jsonDecode(response.body);
        throw SpotifyException(
          message: error['detail'] ?? 'Failed to get auth URL',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is SpotifyException) rethrow;
      throw SpotifyException(
        message: 'Failed to connect to Spotify: $e',
        statusCode: 0,
      );
    }
  }
  
  /// Check if user is connected to Spotify.
  Future<SpotifyConnectionStatus> getConnectionStatus() async {
    final sessionId = await getStoredSessionId();
    
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.spotifyStatusEndpoint}')
          .replace(queryParameters: sessionId != null ? {'session_id': sessionId} : {});
      
      final response = await _client.get(uri).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        return SpotifyConnectionStatus.fromJson(jsonDecode(response.body));
      }
      
      return SpotifyConnectionStatus(connected: false);
    } catch (e) {
      return SpotifyConnectionStatus(connected: false);
    }
  }
  
  /// Create a Spotify playlist from generated songs.
  /// 
  /// [name] - Playlist name
  /// [songs] - List of song objects with 'title' and 'artist' fields
  /// [description] - Optional playlist description
  Future<SpotifyPlaylistResult> createPlaylist({
    required String name,
    required List<Map<String, String>> songs,
    String? description,
  }) async {
    final sessionId = await getStoredSessionId();
    
    if (sessionId == null) {
      throw SpotifyException(
        message: 'Not connected to Spotify. Please connect first.',
        statusCode: 401,
      );
    }
    
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.spotifyCreatePlaylistEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'session_id': sessionId,
              'name': name,
              'description': description ?? 'Created by Astro.FM 🌟',
              'songs': songs,
            }),
          )
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        return SpotifyPlaylistResult.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw SpotifyException(
          message: error['detail'] ?? 'Failed to create playlist',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is SpotifyException) rethrow;
      throw SpotifyException(
        message: 'Failed to create playlist: $e',
        statusCode: 0,
      );
    }
  }
  
  /// Generate a Spotify playlist from user's saved library.
  /// 
  /// Filters user's saved tracks by cosmic energy/mood parameters.
  /// [name] - Playlist name
  /// [energyTarget] - Target energy level 0.0-1.0
  /// [moodTarget] - Target mood/valence level 0.0-1.0 (sad to happy)
  /// [tempoMin] - Minimum BPM
  /// [tempoMax] - Maximum BPM
  /// [playlistSize] - Number of tracks to include
  Future<SpotifyPlaylistResult> generateFromLibrary({
    required String name,
    double energyTarget = 0.5,
    double moodTarget = 0.5,
    int tempoMin = 80,
    int tempoMax = 160,
    int playlistSize = 20,
    String? description,
  }) async {
    final sessionId = await getStoredSessionId();
    
    if (sessionId == null) {
      throw SpotifyException(
        message: 'Not connected to Spotify. Please connect first.',
        statusCode: 401,
      );
    }
    
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.spotifyGenerateFromLibraryEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'session_id': sessionId,
              'name': name,
              'description': description ?? 'Cosmic playlist from your library by Astro.FM 🌟',
              'energy_target': energyTarget,
              'mood_target': moodTarget,
              'tempo_min': tempoMin,
              'tempo_max': tempoMax,
              'playlist_size': playlistSize,
            }),
          )
          .timeout(const Duration(seconds: 60)); // Longer timeout for library fetch
      
      if (response.statusCode == 200) {
        return SpotifyPlaylistResult.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw SpotifyException(
          message: error['detail'] ?? 'Failed to generate playlist from library',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is SpotifyException) rethrow;
      throw SpotifyException(
        message: 'Failed to generate playlist from library: $e',
        statusCode: 0,
      );
    }
  }
  
  /// Open a Spotify playlist URL.
  Future<bool> openPlaylist(String playlistUrl) async {
    final uri = Uri.parse(playlistUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
  
  /// Disconnect from Spotify (clears local session).
  Future<void> disconnect() async {
    await clearSession();
  }
  
  void dispose() {
    _client.close();
  }

  /// Get monthly zodiac playlist generated from user's library.
  /// 
  /// Generates a playlist based on the current zodiac season's element
  /// (Fire/Earth/Air/Water) with an AI-generated horoscope.
  Future<Map<String, dynamic>> getMonthlyZodiacPlaylist() async {
    final sessionId = await getStoredSessionId();
    
    if (sessionId == null) {
      throw SpotifyException(
        message: 'Not connected to Spotify. Please connect first.',
        statusCode: 401,
      );
    }
    
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.spotifyMonthlyZodiacEndpoint}')
          .replace(queryParameters: {'session_id': sessionId});
      
      final response = await _client
          .post(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 90)); // Long timeout for horoscope + playlist generation
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body);
        throw SpotifyException(
          message: error['detail'] ?? 'Failed to generate monthly zodiac playlist',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is SpotifyException) rethrow;
      throw SpotifyException(
        message: 'Failed to generate monthly zodiac playlist: $e',
        statusCode: 0,
      );
    }
  }
}

/// Exception for Spotify-related errors.
class SpotifyException implements Exception {
  final String message;
  final int statusCode;

  SpotifyException({required this.message, required this.statusCode});

  @override
  String toString() => 'SpotifyException: $message (status $statusCode)';
}
