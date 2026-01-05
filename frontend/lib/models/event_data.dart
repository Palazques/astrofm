/// Data models for Discover page events.

/// Event type categories with icons.
enum EventType {
  soundHealing,
  meditation,
  fitness,
  social,
  workshop,
  nature,
  creative,
}

/// Extension for event type display properties.
extension EventTypeExtension on EventType {
  String get value {
    switch (this) {
      case EventType.soundHealing:
        return 'sound_healing';
      case EventType.meditation:
        return 'meditation';
      case EventType.fitness:
        return 'fitness';
      case EventType.social:
        return 'social';
      case EventType.workshop:
        return 'workshop';
      case EventType.nature:
        return 'nature';
      case EventType.creative:
        return 'creative';
    }
  }

  String get displayName {
    switch (this) {
      case EventType.soundHealing:
        return 'Sound Healing';
      case EventType.meditation:
        return 'Meditation';
      case EventType.fitness:
        return 'Fitness';
      case EventType.social:
        return 'Social';
      case EventType.workshop:
        return 'Workshop';
      case EventType.nature:
        return 'Nature';
      case EventType.creative:
        return 'Creative';
    }
  }

  String get icon {
    switch (this) {
      case EventType.soundHealing:
        return '🎵';
      case EventType.meditation:
        return '🧘';
      case EventType.fitness:
        return '💪';
      case EventType.social:
        return '👥';
      case EventType.workshop:
        return '📚';
      case EventType.nature:
        return '🌲';
      case EventType.creative:
        return '🎨';
    }
  }

  static EventType fromString(String value) {
    switch (value) {
      case 'sound_healing':
        return EventType.soundHealing;
      case 'meditation':
        return EventType.meditation;
      case 'fitness':
        return EventType.fitness;
      case 'social':
        return EventType.social;
      case 'workshop':
        return EventType.workshop;
      case 'nature':
        return EventType.nature;
      case 'creative':
        return EventType.creative;
      default:
        return EventType.social;
    }
  }
}

/// Alignment tier for event scoring.
enum AlignmentTier {
  aligned,  // Gold badge - matches user elements or seasonal
  explore,  // Silver badge - worth exploring
}

extension AlignmentTierExtension on AlignmentTier {
  String get displayName {
    switch (this) {
      case AlignmentTier.aligned:
        return 'Aligned for You';
      case AlignmentTier.explore:
        return 'Worth Exploring';
    }
  }

  static AlignmentTier fromString(String value) {
    switch (value) {
      case 'aligned':
        return AlignmentTier.aligned;
      case 'explore':
        return AlignmentTier.explore;
      default:
        return AlignmentTier.explore;
    }
  }
}

/// Event model with astrological alignment fields.
class Event {
  final String id;
  final String title;
  final String description;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime date;
  final EventType eventType;
  final List<String> vibeTags;
  final double? price;
  final String? imageUrl;
  final AlignmentTier? alignmentTier;
  final String? cosmicReasoning;
  final double? distanceMiles;
  final String? creatorId;
  final String? cosmicIntention;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.eventType,
    required this.vibeTags,
    this.price,
    this.imageUrl,
    this.alignmentTier,
    this.cosmicReasoning,
    this.distanceMiles,
    this.creatorId,
    this.cosmicIntention,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      locationName: json['location_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      eventType: EventTypeExtension.fromString(json['event_type'] as String),
      vibeTags: (json['vibe_tags'] as List<dynamic>).map((e) => e as String).toList(),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      imageUrl: json['image_url'] as String?,
      alignmentTier: json['alignment_tier'] != null 
          ? AlignmentTierExtension.fromString(json['alignment_tier'] as String)
          : null,
      cosmicReasoning: json['cosmic_reasoning'] as String?,
      distanceMiles: json['distance_miles'] != null 
          ? (json['distance_miles'] as num).toDouble() 
          : null,
      creatorId: json['creator_id'] as String?,
      cosmicIntention: json['cosmic_intention'] as String?,
    );
  }

  /// Format price for display.
  String get priceDisplay {
    if (price == null || price == 0) {
      return 'Free';
    }
    return '\$${price!.toStringAsFixed(0)}';
  }

  /// Format distance for display.
  String get distanceDisplay {
    if (distanceMiles == null) {
      return '';
    }
    if (distanceMiles! < 1) {
      return '< 1 mi';
    }
    return '${distanceMiles!.toStringAsFixed(1)} mi';
  }

  /// Format date for display.
  String get dateDisplay {
    final now = DateTime.now();
    final diff = date.difference(now);
    
    if (diff.inDays == 0) {
      return 'Today ${_formatTime()}';
    } else if (diff.inDays == 1) {
      return 'Tomorrow ${_formatTime()}';
    } else if (diff.inDays < 7) {
      return '${_dayName()} ${_formatTime()}';
    } else {
      return '${date.month}/${date.day} ${_formatTime()}';
    }
  }

  String _formatTime() {
    final hour = date.hour;
    final minute = date.minute;
    final isPM = hour >= 12;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
  }

  String _dayName() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

/// Seasonal guidance response model.
class SeasonalGuidance {
  final String zodiacSign;
  final String element;
  final String guidanceText;
  final List<String> recommendedEventTypes;
  final String elementEmoji;

  SeasonalGuidance({
    required this.zodiacSign,
    required this.element,
    required this.guidanceText,
    required this.recommendedEventTypes,
    required this.elementEmoji,
  });

  factory SeasonalGuidance.fromJson(Map<String, dynamic> json) {
    return SeasonalGuidance(
      zodiacSign: json['zodiac_sign'] as String,
      element: json['element'] as String,
      guidanceText: json['guidance_text'] as String,
      recommendedEventTypes: (json['recommended_event_types'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      elementEmoji: json['element_emoji'] as String,
    );
  }
}

/// Request model for creating a new event.
class CreateEventRequest {
  final String title;
  final String description;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime date;
  final EventType eventType;
  final double? price;
  final String? cosmicIntention;

  CreateEventRequest({
    required this.title,
    required this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.eventType,
    this.price,
    this.cosmicIntention,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'event_type': eventType.value,
      if (price != null) 'price': price,
      if (cosmicIntention != null) 'cosmic_intention': cosmicIntention,
    };
  }
}
