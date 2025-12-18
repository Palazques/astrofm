import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../models/location.dart';
import '../models/birth_data.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

/// State management for the onboarding flow.
class OnboardingController extends ChangeNotifier {
  OnboardingData _data = OnboardingData();
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  /// Current onboarding data.
  OnboardingData get data => _data;

  /// Current step index (0-based).
  int get currentStep => _currentStep;

  /// Total number of steps.
  static const int totalSteps = 11;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Error message if any.
  String? get error => _error;

  /// Update display name (Screen 2).
  void updateName(String name) {
    _data = _data.copyWith(displayName: name);
    notifyListeners();
  }

  /// Update birth data (Screen 3).
  void updateBirthData({
    DateTime? date,
    TimeOfDay? time,
    Location? location,
    bool? timeUnknown,
  }) {
    _data = _data.copyWith(
      birthDate: date ?? _data.birthDate,
      birthTime: time ?? _data.birthTime,
      birthLocation: location ?? _data.birthLocation,
      birthTimeUnknown: timeUnknown ?? _data.birthTimeUnknown,
    );
    notifyListeners();
  }

  /// Update how found us selections (Screen 4).
  void updateHowFoundUs(List<String> selections) {
    _data = _data.copyWith(howFoundUs: selections);
    notifyListeners();
  }

  /// Toggle a single "how found" option.
  void toggleHowFoundOption(String option) {
    final current = List<String>.from(_data.howFoundUs);
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    _data = _data.copyWith(howFoundUs: current);
    notifyListeners();
  }

  /// Update favorite genres (Screen 5).
  void updateGenres(List<String> genres, {List<String>? subgenres}) {
    _data = _data.copyWith(
      favoriteGenres: genres,
      favoriteSubgenres: subgenres ?? _data.favoriteSubgenres,
    );
    notifyListeners();
  }

  /// Toggle a single genre option.
  void toggleGenre(String genre) {
    final current = List<String>.from(_data.favoriteGenres);
    if (current.contains(genre)) {
      current.remove(genre);
    } else {
      current.add(genre);
    }
    _data = _data.copyWith(favoriteGenres: current);
    notifyListeners();
  }

  /// Update music service connection (Screen 6).
  void updateMusicConnection({
    bool? spotifyConnected,
    bool? appleMusicConnected,
    String? spotifyUserId,
    String? appleMusicUserId,
  }) {
    _data = _data.copyWith(
      spotifyConnected: spotifyConnected ?? _data.spotifyConnected,
      appleMusicConnected: appleMusicConnected ?? _data.appleMusicConnected,
      spotifyUserId: spotifyUserId ?? _data.spotifyUserId,
      appleMusicUserId: appleMusicUserId ?? _data.appleMusicUserId,
    );
    notifyListeners();
  }

  /// Update referral code (Screen 8).
  void updateReferralCode(String? code) {
    _data = _data.copyWith(referralCode: code);
    notifyListeners();
  }

  /// Update notifications permission (Screen 10).
  void updateNotifications(bool enabled) {
    _data = _data.copyWith(notificationsEnabled: enabled);
    notifyListeners();
  }

  /// Update membership selection (Screen 9).
  void updateMembership(PlanType? plan) {
    _data = _data.copyWith(selectedPlan: plan?.name);
    notifyListeners();
  }

  /// Advance to next step.
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      _data = _data.copyWith(lastCompletedStep: _currentStep);
      notifyListeners();
    }
  }

  /// Go back to previous step.
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Jump to a specific step.
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// Set loading state.
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message.
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Mark onboarding as complete and save data to local storage.
  Future<void> completeOnboarding() async {
    _data = _data.copyWith(completedAt: DateTime.now());
    
    // Save birth data to local storage
    if (_data.birthDate != null && _data.birthLocation != null) {
      // Build datetime string from date and time
      final date = _data.birthDate!;
      final time = _data.birthTime ?? const TimeOfDay(hour: 12, minute: 0);
      final datetime = DateTime(
        date.year, date.month, date.day, 
        time.hour, time.minute,
      );
      
      final birthData = BirthData(
        name: _data.displayName ?? 'User',
        datetime: datetime.toIso8601String(),
        latitude: _data.birthLocation!.latitude,
        longitude: _data.birthLocation!.longitude,
        timezone: _data.birthLocation!.timezone ?? 'UTC',
        locationName: _data.birthLocation!.displayName,
      );
      
      await storageService.saveBirthData(birthData);
    }
    
    // Mark onboarding as complete
    await storageService.setOnboardingComplete(true);
    
    // Save genres
    await storageService.saveGenres(
      _data.favoriteGenres, 
      _data.favoriteSubgenres,
    );
    
    notifyListeners();
  }

  /// Check if current step can proceed (validation).
  bool canProceed() {
    switch (_currentStep) {
      case 0: // Welcome - always can proceed
        return true;
      case 1: // Name - needs name
        return _data.displayName != null && _data.displayName!.trim().length >= 2;
      case 2: // Birth data - needs date and location
        return _data.birthDate != null && _data.birthLocation != null;
      default: // Other screens are optional
        return true;
    }
  }

  /// Reset controller to initial state.
  void reset() {
    _data = OnboardingData();
    _currentStep = 0;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
