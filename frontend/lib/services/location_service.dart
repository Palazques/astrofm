/// Location service for GPS access with permission handling.
/// 
/// Provides live location for the Discover page's "Nearby" filter.
/// Falls back to stored location if GPS permission is denied.

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'storage_service.dart';

/// Service for managing device location access.
class LocationService {
  // Default location (Los Angeles) if all else fails
  static const LatLng defaultLocation = LatLng(34.0522, -118.2437);
  
  // Cached current location
  LatLng? _cachedLocation;
  DateTime? _cacheTime;
  
  // Cache duration (5 minutes)
  static const Duration cacheDuration = Duration(minutes: 5);

  /// Check if location services are enabled and permission is granted.
  Future<bool> isLocationAvailable() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permission from user.
  /// 
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied
      return false;
    }
    
    return true;
  }

  /// Get current device location.
  /// 
  /// Returns cached location if available and fresh.
  /// Falls back to default location if permission denied.
  Future<LatLng> getCurrentLocation({bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && 
        _cachedLocation != null && 
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < cacheDuration) {
      return _cachedLocation!;
    }
    
    // Check permission
    bool hasPermission = await isLocationAvailable();
    
    if (!hasPermission) {
      hasPermission = await requestPermission();
    }
    
    if (hasPermission) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
        
        _cachedLocation = LatLng(position.latitude, position.longitude);
        _cacheTime = DateTime.now();
        
        return _cachedLocation!;
      } catch (e) {
        print('Error getting location: $e');
        // Fall through to default
      }
    }
    
    // Try to get stored birth location as fallback
    try {
      final birthData = await storageService.loadBirthData();
      if (birthData != null) {
        return LatLng(birthData.latitude, birthData.longitude);
      }
    } catch (e) {
      print('Error loading birth data for location fallback: $e');
    }
    
    return defaultLocation;
  }

  /// Calculate distance in miles between two points.
  double calculateDistance(LatLng from, LatLng to) {
    final distanceInMeters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    
    // Convert meters to miles
    return distanceInMeters / 1609.344;
  }

  /// Get permission status for UI display.
  Future<LocationPermissionStatus> getPermissionStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.servicesDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      default:
        return LocationPermissionStatus.denied;
    }
  }

  /// Open app settings for user to grant permission manually.
  Future<bool> openSettings() async {
    return await Geolocator.openAppSettings();
  }
}

/// Location permission status for UI.
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  servicesDisabled,
}

/// Global instance for easy access.
final locationService = LocationService();
