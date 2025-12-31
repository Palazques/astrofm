/// Session cache service for in-memory state persistence.
/// Prevents data reloading when navigating between screens.
///
/// This is a singleton that holds cached data during the app session.
/// Data is cleared on logout or app restart.

import '../models/sonification.dart';
import '../models/friend_data.dart';

/// Singleton service for session-based caching.
class SessionCacheService {
  static final SessionCacheService _instance = SessionCacheService._internal();
  factory SessionCacheService() => _instance;
  SessionCacheService._internal();

  // ===== Sonification Cache =====
  ChartSonification? _userSonification;
  ChartSonification? _dailySonification;

  ChartSonification? get userSonification => _userSonification;
  ChartSonification? get dailySonification => _dailySonification;

  void cacheUserSonification(ChartSonification sonification) {
    _userSonification = sonification;
  }

  void cacheDailySonification(ChartSonification sonification) {
    _dailySonification = sonification;
  }

  // ===== AI Readings Cache =====
  final Map<String, dynamic> _aiReadings = {};

  dynamic getAiReading(String key) => _aiReadings[key];

  void cacheAiReading(String key, dynamic reading) {
    _aiReadings[key] = reading;
  }

  bool hasAiReading(String key) => _aiReadings.containsKey(key);

  // ===== Friends Cache =====
  List<FriendData>? _friends;

  List<FriendData>? get friends => _friends;

  void cacheFriends(List<FriendData> friends) {
    _friends = friends;
  }

  // ===== Alignment Cache =====
  Map<String, dynamic>? _alignmentData;

  Map<String, dynamic>? get alignmentData => _alignmentData;

  void cacheAlignmentData(Map<String, dynamic> data) {
    _alignmentData = data;
  }

  // ===== Clear Methods =====
  
  /// Clear all cached data (for logout).
  void clearAll() {
    _userSonification = null;
    _dailySonification = null;
    _aiReadings.clear();
    _friends = null;
    _alignmentData = null;
  }

  /// Clear only sonification data (for refresh).
  void clearSonification() {
    _userSonification = null;
    _dailySonification = null;
  }

  /// Clear AI readings (for refresh).
  void clearAiReadings() {
    _aiReadings.clear();
  }
}
