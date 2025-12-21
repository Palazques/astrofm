/// App startup service for coordinated background loading.
/// Preloads essential data during the welcome back screen.

import '../models/birth_data.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';
import 'spotify_service.dart';
import 'api_service.dart';

/// Result of the startup preloading process.
class StartupResult {
  final UserProfile? userProfile;
  final BirthData? birthData;
  final bool spotifyConnected;
  final bool hasCachedPlaylist;
  final Map<String, dynamic>? cachedHoroscope;
  final Map<String, String> errors;

  StartupResult({
    this.userProfile,
    this.birthData,
    this.spotifyConnected = false,
    this.hasCachedPlaylist = false,
    this.cachedHoroscope,
    this.errors = const {},
  });

  /// Check if essential data is loaded.
  bool get hasEssentials => userProfile != null || birthData != null;
}

/// Service that coordinates background loading during app startup.
class AppStartupService {
  final StorageService _storage;
  final SpotifyService _spotify;
  final ApiService _api;

  AppStartupService({
    StorageService? storage,
    SpotifyService? spotify,
    ApiService? api,
  })  : _storage = storage ?? storageService,
        _spotify = spotify ?? SpotifyService(),
        _api = api ?? ApiService();

  /// Preload all app data in parallel with error isolation.
  /// Each operation runs independently - failures don't block others.
  Future<StartupResult> preloadAppData() async {
    final errors = <String, String>{};
    
    // Run all preloading tasks in parallel
    final results = await Future.wait([
      _loadUserProfile().catchError((e) {
        errors['userProfile'] = e.toString();
        return null;
      }),
      _loadBirthData().catchError((e) {
        errors['birthData'] = e.toString();
        return null;
      }),
      _checkSpotifyConnection().catchError((e) {
        errors['spotify'] = e.toString();
        return false;
      }),
      _checkDailyPlaylist().catchError((e) {
        errors['playlist'] = e.toString();
        return false;
      }),
      _prefetchHoroscope().catchError((e) {
        errors['horoscope'] = e.toString();
        return null;
      }),
    ]);

    return StartupResult(
      userProfile: results[0] as UserProfile?,
      birthData: results[1] as BirthData?,
      spotifyConnected: results[2] as bool? ?? false,
      hasCachedPlaylist: results[3] as bool? ?? false,
      cachedHoroscope: results[4] as Map<String, dynamic>?,
      errors: errors,
    );
  }

  /// Load user profile from local storage.
  Future<UserProfile?> _loadUserProfile() async {
    await _storage.init();
    return await _storage.loadUserProfile();
  }

  /// Load birth data from local storage.
  Future<BirthData?> _loadBirthData() async {
    await _storage.init();
    return await _storage.loadBirthData();
  }

  /// Check if Spotify is connected.
  Future<bool> _checkSpotifyConnection() async {
    try {
      final status = await _spotify.getConnectionStatus();
      return status.connected;
    } catch (e) {
      return false;
    }
  }

  /// Check if we have a cached daily playlist for today.
  Future<bool> _checkDailyPlaylist() async {
    await _storage.init();
    return await _storage.hasTodaysPlaylist();
  }

  /// Prefetch horoscope data (fire-and-forget, results cached by API).
  Future<Map<String, dynamic>?> _prefetchHoroscope() async {
    final birthData = await _storage.loadBirthData();
    if (birthData == null) return null;

    try {
      // Try to get daily alignment which includes horoscope
      final alignment = await _api.getDailyAlignment(
        datetime: birthData.datetime,
        latitude: birthData.latitude,
        longitude: birthData.longitude,
        timezone: birthData.timezone,
      );
      return alignment.toJson();
    } catch (e) {
      // Non-critical, can fail silently
      return null;
    }
  }
}

/// Global instance for easy access.
final appStartupService = AppStartupService();
