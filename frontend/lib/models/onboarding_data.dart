import 'package:flutter/material.dart';
import 'location.dart';

/// Data collected during the onboarding flow.
///
/// All user inputs from onboarding are captured here.
/// JSON serializable for Firebase storage.
class OnboardingData {
  // Screen 2: Name
  String? displayName;

  // Screen 3: Birth Data
  DateTime? birthDate;
  TimeOfDay? birthTime;
  Location? birthLocation;
  bool birthTimeUnknown;

  // Screen 4: How Found
  List<String> howFoundUs;

  // Screen 5: Genres
  List<String> favoriteGenres;
  List<String> favoriteSubgenres;

  // Screen 6: Music Services
  bool spotifyConnected;
  bool appleMusicConnected;
  String? spotifyUserId;
  String? appleMusicUserId;

  // Screen 8: Referral
  String? referralCode;

  // Screen 9: Premium/Membership
  String? selectedPlan; // monthly, sixMonth, annual, or null for free

  // Screen 10: Notifications
  bool notificationsEnabled;

  // Completion tracking
  int lastCompletedStep;
  DateTime? completedAt;

  // Future Firebase fields (prepared but not used yet)
  String? email;
  String? userId;

  OnboardingData({
    this.displayName,
    this.birthDate,
    this.birthTime,
    this.birthLocation,
    this.birthTimeUnknown = false,
    this.howFoundUs = const [],
    this.favoriteGenres = const [],
    this.favoriteSubgenres = const [],
    this.spotifyConnected = false,
    this.appleMusicConnected = false,
    this.spotifyUserId,
    this.appleMusicUserId,
    this.referralCode,
    this.selectedPlan,
    this.notificationsEnabled = false,
    this.lastCompletedStep = 0,
    this.completedAt,
    this.email,
    this.userId,
  });

  /// Check if minimum required data is complete.
  bool get isMinimumComplete =>
      displayName != null &&
      displayName!.isNotEmpty &&
      birthDate != null &&
      birthLocation != null;

  /// Get formatted datetime string for API calls.
  /// Returns ISO format: YYYY-MM-DDTHH:MM:SS
  String? get formattedBirthDatetime {
    if (birthDate == null) return null;

    final date = birthDate!;
    final time = birthTimeUnknown
        ? const TimeOfDay(hour: 12, minute: 0) // Noon default
        : birthTime ?? const TimeOfDay(hour: 12, minute: 0);

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}T'
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }

  /// Serialize to JSON for Firebase storage.
  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'birthDate': birthDate?.toIso8601String(),
      'birthTime':
          birthTime != null ? '${birthTime!.hour}:${birthTime!.minute}' : null,
      'birthLocation': birthLocation?.toJson(),
      'birthTimeUnknown': birthTimeUnknown,
      'howFoundUs': howFoundUs,
      'favoriteGenres': favoriteGenres,
      'favoriteSubgenres': favoriteSubgenres,
      'spotifyConnected': spotifyConnected,
      'appleMusicConnected': appleMusicConnected,
      'spotifyUserId': spotifyUserId,
      'appleMusicUserId': appleMusicUserId,
      'referralCode': referralCode,
      'selectedPlan': selectedPlan,
      'notificationsEnabled': notificationsEnabled,
      'lastCompletedStep': lastCompletedStep,
      'completedAt': completedAt?.toIso8601String(),
      'email': email,
      'userId': userId,
    };
  }

  /// Deserialize from JSON (Firebase).
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return OnboardingData(
      displayName: json['displayName'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      birthTime: parseTime(json['birthTime']),
      birthLocation: json['birthLocation'] != null
          ? Location.fromJson(json['birthLocation'])
          : null,
      birthTimeUnknown: json['birthTimeUnknown'] ?? false,
      howFoundUs: List<String>.from(json['howFoundUs'] ?? []),
      favoriteGenres: List<String>.from(json['favoriteGenres'] ?? []),
      favoriteSubgenres: List<String>.from(json['favoriteSubgenres'] ?? []),
      spotifyConnected: json['spotifyConnected'] ?? false,
      appleMusicConnected: json['appleMusicConnected'] ?? false,
      spotifyUserId: json['spotifyUserId'],
      appleMusicUserId: json['appleMusicUserId'],
      referralCode: json['referralCode'],
      selectedPlan: json['selectedPlan'],
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      lastCompletedStep: json['lastCompletedStep'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      email: json['email'],
      userId: json['userId'],
    );
  }

  /// Copy with modifications.
  OnboardingData copyWith({
    String? displayName,
    DateTime? birthDate,
    TimeOfDay? birthTime,
    Location? birthLocation,
    bool? birthTimeUnknown,
    List<String>? howFoundUs,
    List<String>? favoriteGenres,
    List<String>? favoriteSubgenres,
    bool? spotifyConnected,
    bool? appleMusicConnected,
    String? spotifyUserId,
    String? appleMusicUserId,
    String? referralCode,
    String? selectedPlan,
    bool? notificationsEnabled,
    int? lastCompletedStep,
    DateTime? completedAt,
    String? email,
    String? userId,
  }) {
    return OnboardingData(
      displayName: displayName ?? this.displayName,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthLocation: birthLocation ?? this.birthLocation,
      birthTimeUnknown: birthTimeUnknown ?? this.birthTimeUnknown,
      howFoundUs: howFoundUs ?? this.howFoundUs,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      favoriteSubgenres: favoriteSubgenres ?? this.favoriteSubgenres,
      spotifyConnected: spotifyConnected ?? this.spotifyConnected,
      appleMusicConnected: appleMusicConnected ?? this.appleMusicConnected,
      spotifyUserId: spotifyUserId ?? this.spotifyUserId,
      appleMusicUserId: appleMusicUserId ?? this.appleMusicUserId,
      referralCode: referralCode ?? this.referralCode,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastCompletedStep: lastCompletedStep ?? this.lastCompletedStep,
      completedAt: completedAt ?? this.completedAt,
      email: email ?? this.email,
      userId: userId ?? this.userId,
    );
  }
}
