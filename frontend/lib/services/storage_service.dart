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
}

/// Global instance for easy access.
final storageService = StorageService();
