/// Discover service for event discovery with astrological alignment.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/event_data.dart';

/// Filter types for event discovery.
enum DiscoverFilter {
  aligned,  // Only events aligned with user's elements
  nearby,   // Sort by distance
  all,      // All events
}

/// Service for Discover page API calls.
class DiscoverService {
  final http.Client _client;

  DiscoverService({http.Client? client}) : _client = client ?? http.Client();

  /// Get seasonal guidance for Discover page header.
  Future<SeasonalGuidance> getSeasonalGuidance() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/discover/seasonal-guidance');
    
    final response = await _client.get(uri).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return SeasonalGuidance.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load seasonal guidance: ${response.statusCode}');
    }
  }

  /// Get events with filtering and scoring.
  /// 
  /// [latitude] - User's current GPS latitude
  /// [longitude] - User's current GPS longitude
  /// [radiusMiles] - Search radius in miles (1-50)
  /// [userElements] - User's dominant elements from Sun/Moon/Rising
  /// [filter] - Filter type (aligned/nearby/all)
  /// [eventTypes] - Filter by specific event types
  Future<List<Event>> getEvents({
    required double latitude,
    required double longitude,
    double radiusMiles = 50.0,
    List<String>? userElements,
    DiscoverFilter filter = DiscoverFilter.all,
    List<EventType>? eventTypes,
  }) async {
    // Build query parameters
    final Map<String, String> queryParams = {
      'lat': latitude.toString(),
      'long': longitude.toString(),
      'radius_miles': radiusMiles.toString(),
    };

    // Add filter type
    if (filter != DiscoverFilter.all) {
      queryParams['filter_type'] = filter.name;
    }

    // Build URI with base params
    var uri = Uri.parse('${ApiConfig.baseUrl}/api/discover/events')
        .replace(queryParameters: queryParams);
    
    // Manually add repeated params for lists
    String uriString = uri.toString();
    
    if (userElements != null && userElements.isNotEmpty) {
      for (final element in userElements) {
        uriString += '&user_elements=$element';
      }
    }
    
    if (eventTypes != null && eventTypes.isNotEmpty) {
      for (final type in eventTypes) {
        uriString += '&event_types=${type.value}';
      }
    }
    
    uri = Uri.parse(uriString);
    
    final response = await _client.get(uri).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
  }

  /// Create a new user event.
  Future<Event> createEvent(CreateEventRequest request) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/discover/events');
    
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create event: ${response.statusCode}');
    }
  }

  /// Get available event types with metadata.
  Future<List<Map<String, dynamic>>> getEventTypes() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/discover/event-types');
    
    final response = await _client.get(uri).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load event types: ${response.statusCode}');
    }
  }
}

/// Global instance for easy access.
final discoverService = DiscoverService();
