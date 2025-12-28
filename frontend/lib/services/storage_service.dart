/// Storage service for persisting user data locally.
/// Uses SharedPreferences for simple key-value storage.
/// Designed for easy migration to Firebase.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/birth_data.dart';
import '../models/user_profile.dart';

/// Keys for SharedPreferences storage.
class StorageKeys {
  // User profile (Firebase-ready)
  static const String userProfile = 'user_profile';
  
  // Legacy keys (for backward compatibility)
  static const String birthData = 'user_birth_data';
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastSelectedFriendId = 'last_selected_friend_id';
  static const String userName = 'user_name';
  
  // Genres
  static const String genres = 'user_genres';
  static const String subgenres = 'user_subgenres';
  
  // Membership
  static const String membership = 'user_membership';
  
  // Referral
  static const String referral = 'user_referral';
  
  // Daily Playlist Cache
  static const String dailyPlaylistTracks = 'daily_playlist_tracks';
  static const String dailyPlaylistUrl = 'daily_playlist_url';
  static const String dailyPlaylistDate = 'daily_playlist_date';
  static const String dailyDatasetPlaylist = 'daily_dataset_playlist'; // Full dataset playlist result
  static const String dailyCosmicPlaylist = 'daily_cosmic_playlist'; // Cosmic (AI + Spotify) playlist
  
  // Monthly Zodiac Playlist Cache
  static const String monthlyZodiacPlaylist = 'monthly_zodiac_playlist';
  static const String monthlyZodiacMonth = 'monthly_zodiac_month'; // Format: "YYYY-MM"
  
  // Notification Preferences
  static const String notifDaily = 'notif_daily';
  static const String notifMoon = 'notif_moon';
  static const String notifTransit = 'notif_transit';
  static const String notifFriend = 'notif_friend';
}

/// Service for managing local storage operations.
class StorageService {
  SharedPreferences? _prefs;

  /// Initialize the storage service.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized before use.
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ================================
  // User Profile (Firebase-ready)
  // ================================

  /// Save complete user profile.
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(StorageKeys.userProfile, jsonEncode(profile.toJson()));
    
    // Also update legacy keys for backward compatibility
    if (profile.birthData != null) {
      await prefs.setString(StorageKeys.birthData, profile.birthData!.toJsonString());
    }
    await prefs.setString(StorageKeys.userName, profile.displayName);
    await prefs.setBool(StorageKeys.onboardingComplete, profile.onboarding.completed);
  }

  /// Load complete user profile.
  Future<UserProfile?> loadUserProfile() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(StorageKeys.userProfile);
    if (jsonString == null) return null;
    
    try {
      return UserProfile.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // ================================
  // Birth Data
  // ================================

  /// Save user's birth data.
  Future<void> saveBirthData(BirthData data) async {
    final prefs = await _getPrefs();
    await prefs.setString(StorageKeys.birthData, data.toJsonString());
    await prefs.setString(StorageKeys.userName, data.name);
  }

  /// Load user's birth data.
  Future<BirthData?> loadBirthData() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(StorageKeys.birthData);
    if (jsonString == null) return null;
    
    try {
      return BirthData.fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Check if birth data exists.
  Future<bool> hasBirthData() async {
    final prefs = await _getPrefs();
    return prefs.containsKey(StorageKeys.birthData);
  }

  /// Get user name quickly without parsing full birth data.
  Future<String?> getUserName() async {
    final prefs = await _getPrefs();
    return prefs.getString(StorageKeys.userName);
  }

  // ================================
  // Genres
  // ================================

  /// Save user's genre preferences.
  Future<void> saveGenres(List<String> genres, List<String> subgenres) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(StorageKeys.genres, genres);
    await prefs.setStringList(StorageKeys.subgenres, subgenres);
  }

  /// Load user's genre preferences.
  Future<({List<String> genres, List<String> subgenres})> loadGenres() async {
    final prefs = await _getPrefs();
    final genres = prefs.getStringList(StorageKeys.genres) ?? [];
    final subgenres = prefs.getStringList(StorageKeys.subgenres) ?? [];
    return (genres: genres, subgenres: subgenres);
  }

  // ================================
  // Membership
  // ================================

  /// Save membership status.
  Future<void> saveMembership(Membership membership) async {
    final prefs = await _getPrefs();
    await prefs.setString(StorageKeys.membership, jsonEncode(membership.toJson()));
  }

  /// Load membership status.
  Future<Membership> loadMembership() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(StorageKeys.membership);
    if (jsonString == null) return Membership();
    
    try {
      return Membership.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return Membership();
    }
  }

  // ================================
  // Referral
  // ================================

  /// Save referral data.
  Future<void> saveReferral(Referral referral) async {
    final prefs = await _getPrefs();
    await prefs.setString(StorageKeys.referral, jsonEncode(referral.toJson()));
  }

  /// Load referral data.
  Future<Referral> loadReferral() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(StorageKeys.referral);
    if (jsonString == null) return Referral();
    
    try {
      return Referral.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return Referral();
    }
  }

  /// Mark referral discount as earned (shared with 3 friends).
  Future<void> earnReferralDiscount() async {
    final now = DateTime.now();
    final discountEnds = now.add(const Duration(days: 90)); // 3 months
    
    final referral = Referral(
      sharedWithCount: 3,
      sharedAt: now,
      earnedDiscount: true,
      discountEndsAt: discountEnds,
    );
    await saveReferral(referral);
  }

  /// Check if user has earned referral discount.
  Future<bool> hasReferralDiscount() async {
    final referral = await loadReferral();
    return referral.hasEarnedDiscount;
  }

  // ================================
  // Onboarding State
  // ================================

  /// Mark onboarding as complete.
  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _getPrefs();
    await prefs.setBool(StorageKeys.onboardingComplete, complete);
  }

  /// Check if onboarding is complete.
  Future<bool> isOnboardingComplete() async {
    final prefs = await _getPrefs();
    return prefs.getBool(StorageKeys.onboardingComplete) ?? false;
  }

  // ================================
  // Friend Selection
  // ================================

  /// Save last selected friend ID.
  Future<void> saveLastSelectedFriendId(int id) async {
    final prefs = await _getPrefs();
    await prefs.setInt(StorageKeys.lastSelectedFriendId, id);
  }

  /// Get last selected friend ID.
  Future<int?> getLastSelectedFriendId() async {
    final prefs = await _getPrefs();
    return prefs.getInt(StorageKeys.lastSelectedFriendId);
  }

  // ================================
  // Utility Methods
  // ================================

  /// Clear all stored data (for sign out).
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  /// Clear only user-specific data (keep app settings).
  Future<void> clearUserData() async {
    final prefs = await _getPrefs();
    await prefs.remove(StorageKeys.userProfile);
    await prefs.remove(StorageKeys.birthData);
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.onboardingComplete);
    await prefs.remove(StorageKeys.lastSelectedFriendId);
    await prefs.remove(StorageKeys.genres);
    await prefs.remove(StorageKeys.subgenres);
    await prefs.remove(StorageKeys.membership);
    await prefs.remove(StorageKeys.referral);
  }

  // ================================
  // Daily Playlist Cache
  // ================================

  /// Save daily playlist to cache with today's date.
  Future<void> saveDailyPlaylist({
    required List<Map<String, dynamic>> tracks,
    String? playlistUrl,
  }) async {
    final prefs = await _getPrefs();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    
    await prefs.setString(StorageKeys.dailyPlaylistTracks, jsonEncode(tracks));
    await prefs.setString(StorageKeys.dailyPlaylistDate, today);
    if (playlistUrl != null) {
      await prefs.setString(StorageKeys.dailyPlaylistUrl, playlistUrl);
    }
  }

  /// Load cached daily playlist if it's from today.
  /// Returns null if no cache or cache is from a different day.
  Future<({List<Map<String, dynamic>> tracks, String? playlistUrl})?> loadDailyPlaylist() async {
    final prefs = await _getPrefs();
    
    // Check if cache is from today
    final cachedDate = prefs.getString(StorageKeys.dailyPlaylistDate);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (cachedDate != today) {
      return null; // Cache is stale (different day)
    }
    
    // Load cached tracks
    final tracksJson = prefs.getString(StorageKeys.dailyPlaylistTracks);
    if (tracksJson == null) return null;
    
    try {
      final tracks = (jsonDecode(tracksJson) as List)
          .map((t) => t as Map<String, dynamic>)
          .toList();
      final playlistUrl = prefs.getString(StorageKeys.dailyPlaylistUrl);
      return (tracks: tracks, playlistUrl: playlistUrl);
    } catch (e) {
      return null;
    }
  }

  /// Check if we have a valid playlist cached for today.
  Future<bool> hasTodaysPlaylist() async {
    final prefs = await _getPrefs();
    final cachedDate = prefs.getString(StorageKeys.dailyPlaylistDate);
    final today = DateTime.now().toIso8601String().split('T')[0];
    return cachedDate == today && prefs.containsKey(StorageKeys.dailyPlaylistTracks);
  }

  /// Save the full dataset playlist result to cache with today's date.
  Future<void> saveDatasetPlaylist(Map<String, dynamic> playlistData) async {
    final prefs = await _getPrefs();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    
    await prefs.setString(StorageKeys.dailyDatasetPlaylist, jsonEncode(playlistData));
    await prefs.setString(StorageKeys.dailyPlaylistDate, today);
  }

  /// Load cached dataset playlist if it's from today.
  /// Returns null if no cache or cache is from a different day.
  Future<Map<String, dynamic>?> loadDatasetPlaylist() async {
    final prefs = await _getPrefs();
    
    // Check if cache is from today
    final cachedDate = prefs.getString(StorageKeys.dailyPlaylistDate);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (cachedDate != today) {
      return null; // Cache is stale (different day)
    }
    
    // Load cached dataset playlist
    final playlistJson = prefs.getString(StorageKeys.dailyDatasetPlaylist);
    if (playlistJson == null) return null;
    
    try {
      return jsonDecode(playlistJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save the cosmic playlist result to cache with today's date.
  Future<void> saveCosmicPlaylist(Map<String, dynamic> playlistData) async {
    final prefs = await _getPrefs();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    
    await prefs.setString(StorageKeys.dailyCosmicPlaylist, jsonEncode(playlistData));
    await prefs.setString(StorageKeys.dailyPlaylistDate, today);
  }

  /// Load cached cosmic playlist if it's from today.
  /// Returns null if no cache or cache is from a different day.
  Future<Map<String, dynamic>?> loadCosmicPlaylist() async {
    final prefs = await _getPrefs();
    
    // Check if cache is from today
    final cachedDate = prefs.getString(StorageKeys.dailyPlaylistDate);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (cachedDate != today) {
      return null; // Cache is stale (different day)
    }
    
    // Load cached cosmic playlist
    final playlistJson = prefs.getString(StorageKeys.dailyCosmicPlaylist);
    if (playlistJson == null) return null;
    
    try {
      return jsonDecode(playlistJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ================================
  // Monthly Zodiac Playlist Cache
  // ================================

  /// Save monthly zodiac playlist to cache with current month.
  Future<void> saveMonthlyZodiacPlaylist(Map<String, dynamic> playlistData) async {
    final prefs = await _getPrefs();
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}'; // YYYY-MM
    
    await prefs.setString(StorageKeys.monthlyZodiacPlaylist, jsonEncode(playlistData));
    await prefs.setString(StorageKeys.monthlyZodiacMonth, currentMonth);
  }

  /// Load cached monthly zodiac playlist if it's from the current month.
  /// Returns null if no cache or cache is from a different month.
  Future<Map<String, dynamic>?> loadMonthlyZodiacPlaylist() async {
    final prefs = await _getPrefs();
    
    // Check if cache is from current month
    final cachedMonth = prefs.getString(StorageKeys.monthlyZodiacMonth);
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    if (cachedMonth != currentMonth) {
      return null; // Cache is stale (different month)
    }
    
    // Load cached playlist data
    final playlistJson = prefs.getString(StorageKeys.monthlyZodiacPlaylist);
    if (playlistJson == null) return null;
    
    try {
      return jsonDecode(playlistJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Check if we have a valid monthly zodiac playlist cached for current month.
  Future<bool> hasCurrentMonthPlaylist() async {
    final prefs = await _getPrefs();
    final cachedMonth = prefs.getString(StorageKeys.monthlyZodiacMonth);
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return cachedMonth == currentMonth && prefs.containsKey(StorageKeys.monthlyZodiacPlaylist);
  }

  // ================================
  // Notification Preferences
  // ================================

  /// Save notification preferences.
  Future<void> saveNotificationPreferences(Map<String, bool> prefs) async {
    final storage = await _getPrefs();
    await storage.setBool(StorageKeys.notifDaily, prefs['daily'] ?? true);
    await storage.setBool(StorageKeys.notifMoon, prefs['moon'] ?? true);
    await storage.setBool(StorageKeys.notifTransit, prefs['transit'] ?? false);
    await storage.setBool(StorageKeys.notifFriend, prefs['friend'] ?? true);
  }

  /// Load notification preferences.
  Future<Map<String, bool>> loadNotificationPreferences() async {
    final prefs = await _getPrefs();
    return {
      'daily': prefs.getBool(StorageKeys.notifDaily) ?? true,
      'moon': prefs.getBool(StorageKeys.notifMoon) ?? true,
      'transit': prefs.getBool(StorageKeys.notifTransit) ?? false,
      'friend': prefs.getBool(StorageKeys.notifFriend) ?? true,
    };
  }
}

/// Global instance for easy access.
final storageService = StorageService();
