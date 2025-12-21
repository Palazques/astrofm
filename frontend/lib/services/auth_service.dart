/// Authentication service for user login/signup.
/// Uses mock local storage for development, structured for Firebase migration.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/birth_data.dart';
import '../models/location.dart';
import 'storage_service.dart';

/// Keys for auth storage.
class AuthStorageKeys {
  static const String credentials = 'auth_credentials';
  static const String rememberMe = 'auth_remember_me';
  static const String currentUserEmail = 'auth_current_user';
  static const String testAccountSeeded = 'auth_test_seeded';
}

/// User credentials model.
class AuthCredentials {
  final String email;
  final String password;
  final String? displayName;
  final DateTime createdAt;

  AuthCredentials({
    required this.email,
    required this.password,
    this.displayName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'displayName': displayName,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AuthCredentials.fromJson(Map<String, dynamic> json) => AuthCredentials(
    email: json['email'] as String,
    password: json['password'] as String,
    displayName: json['displayName'] as String?,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}

/// Authentication result.
class AuthResult {
  final bool success;
  final String? error;
  final AuthCredentials? user;

  AuthResult.success(this.user) : success = true, error = null;
  AuthResult.failure(this.error) : success = false, user = null;
}

/// Mock authentication service (Firebase-ready structure).
class AuthService extends ChangeNotifier {
  SharedPreferences? _prefs;
  AuthCredentials? _currentUser;
  bool _isInitialized = false;

  /// Current logged-in user.
  AuthCredentials? get currentUser => _currentUser;

  /// Whether a user is logged in.
  bool get isLoggedIn => _currentUser != null;

  /// Whether service is initialized.
  bool get isInitialized => _isInitialized;

  /// Initialize the auth service and seed test account.
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs ??= await SharedPreferences.getInstance();
    
    // Seed test account on first run
    await _seedTestAccount();
    
    // Check for remembered user
    await _loadRememberedUser();
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Seed the test account if not already done.
  Future<void> _seedTestAccount() async {
    final seeded = _prefs!.getBool(AuthStorageKeys.testAccountSeeded) ?? false;
    if (seeded) return;

    // Test account credentials
    const testEmail = 'palazques@gmail.com';
    const testPassword = 'Trust8787';
    const testName = 'Paul';

    // Create test credentials
    final testCreds = AuthCredentials(
      email: testEmail,
      password: testPassword,
      displayName: testName,
    );

    // Save to credentials store
    await _saveCredentials(testCreds);

    // Create and save test birth data
    final testBirthData = BirthData(
      name: testName,
      datetime: '1989-03-30T00:52:00', // 12:52 AM on March 30, 1989
      latitude: 37.8044, // Oakland, California
      longitude: -122.2712,
      timezone: 'America/Los_Angeles',
      locationName: 'Oakland, California',
    );
    await storageService.saveBirthData(testBirthData);

    // Mark onboarding as complete for test account
    await storageService.setOnboardingComplete(true);

    // Mark test account as seeded
    await _prefs!.setBool(AuthStorageKeys.testAccountSeeded, true);
  }

  /// Load remembered user on startup.
  Future<void> _loadRememberedUser() async {
    final rememberMe = _prefs!.getBool(AuthStorageKeys.rememberMe) ?? false;
    if (!rememberMe) return;

    final email = _prefs!.getString(AuthStorageKeys.currentUserEmail);
    if (email == null) return;

    final allCreds = await _loadAllCredentials();
    _currentUser = allCreds.firstWhere(
      (c) => c.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );
  }

  /// Login with email and password.
  Future<AuthResult> login(String email, String password, {bool rememberMe = true}) async {
    await init();

    final allCreds = await _loadAllCredentials();
    
    // Find matching credentials
    final match = allCreds.where(
      (c) => c.email.toLowerCase() == email.toLowerCase() && c.password == password,
    ).toList();

    if (match.isEmpty) {
      return AuthResult.failure('Invalid email or password');
    }

    _currentUser = match.first;

    // Save remember me preference
    await _prefs!.setBool(AuthStorageKeys.rememberMe, rememberMe);
    if (rememberMe) {
      await _prefs!.setString(AuthStorageKeys.currentUserEmail, email);
    } else {
      await _prefs!.remove(AuthStorageKeys.currentUserEmail);
    }

    notifyListeners();
    return AuthResult.success(_currentUser);
  }

  /// Register a new account.
  Future<AuthResult> register(String email, String password, {String? displayName}) async {
    await init();

    // Validate email format
    if (!_isValidEmail(email)) {
      return AuthResult.failure('Please enter a valid email address');
    }

    // Check minimum password length
    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters');
    }

    final allCreds = await _loadAllCredentials();
    
    // Check if email already exists
    final exists = allCreds.any(
      (c) => c.email.toLowerCase() == email.toLowerCase(),
    );

    if (exists) {
      return AuthResult.failure('An account with this email already exists');
    }

    // Create new credentials
    final newCreds = AuthCredentials(
      email: email,
      password: password,
      displayName: displayName,
    );

    await _saveCredentials(newCreds);
    _currentUser = newCreds;

    // Auto-enable remember me for new accounts
    await _prefs!.setBool(AuthStorageKeys.rememberMe, true);
    await _prefs!.setString(AuthStorageKeys.currentUserEmail, email);

    notifyListeners();
    return AuthResult.success(_currentUser);
  }

  /// Logout current user.
  Future<void> logout() async {
    await init();

    _currentUser = null;
    await _prefs!.remove(AuthStorageKeys.rememberMe);
    await _prefs!.remove(AuthStorageKeys.currentUserEmail);

    notifyListeners();
  }

  /// Check if user should see welcome back screen.
  Future<bool> hasRememberedUser() async {
    await init();
    return _currentUser != null;
  }

  /// Get display name for current user.
  String? get currentUserDisplayName => _currentUser?.displayName;

  // ================================
  // Private Helper Methods
  // ================================

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<List<AuthCredentials>> _loadAllCredentials() async {
    final jsonString = _prefs!.getString(AuthStorageKeys.credentials);
    if (jsonString == null) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((j) => AuthCredentials.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveCredentials(AuthCredentials creds) async {
    final allCreds = await _loadAllCredentials();
    
    // Update existing or add new
    final index = allCreds.indexWhere(
      (c) => c.email.toLowerCase() == creds.email.toLowerCase(),
    );
    
    if (index >= 0) {
      allCreds[index] = creds;
    } else {
      allCreds.add(creds);
    }

    await _prefs!.setString(
      AuthStorageKeys.credentials,
      jsonEncode(allCreds.map((c) => c.toJson()).toList()),
    );
  }
}

/// Global instance for easy access.
final authService = AuthService();
