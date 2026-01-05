/// Model for friend alignment suggestions ("Listen to Your Friends Blend").
/// 
/// Represents which friends to align with today based on current planetary transits.

class FriendHarmonySuggestion {
  final int friendId;
  final int score;
  final String glowColor;  // Hex: "#FF59D0"
  final String contextString;
  final String harmonyType;  // "lunar", "transit", "mixed"

  const FriendHarmonySuggestion({
    required this.friendId,
    required this.score,
    required this.glowColor,
    required this.contextString,
    required this.harmonyType,
  });

  factory FriendHarmonySuggestion.fromJson(Map<String, dynamic> json) {
    return FriendHarmonySuggestion(
      friendId: json['friend_id'] as int,
      score: json['score'] as int,
      glowColor: json['glow_color'] as String,
      contextString: json['context_string'] as String,
      harmonyType: json['harmony_type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'friend_id': friendId,
    'score': score,
    'glow_color': glowColor,
    'context_string': contextString,
    'harmony_type': harmonyType,
  };
}

class FriendSuggestionsResponse {
  final List<FriendHarmonySuggestion> suggestions;
  final String currentMoonSign;
  final DateTime refreshAt;
  final bool fromCache;

  const FriendSuggestionsResponse({
    required this.suggestions,
    required this.currentMoonSign,
    required this.refreshAt,
    this.fromCache = false,
  });

  factory FriendSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return FriendSuggestionsResponse(
      suggestions: (json['suggestions'] as List)
          .map((s) => FriendHarmonySuggestion.fromJson(s as Map<String, dynamic>))
          .toList(),
      currentMoonSign: json['current_moon_sign'] as String,
      refreshAt: DateTime.parse(json['refresh_at'] as String),
      fromCache: json['from_cache'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'suggestions': suggestions.map((s) => s.toJson()).toList(),
    'current_moon_sign': currentMoonSign,
    'refresh_at': refreshAt.toIso8601String(),
    'from_cache': fromCache,
  };

  /// Get suggestion for a specific friend ID
  FriendHarmonySuggestion? getSuggestionForFriend(int friendId) {
    try {
      return suggestions.firstWhere((s) => s.friendId == friendId);
    } catch (_) {
      return null;
    }
  }

  /// Check if a friend is in the top 3 suggestions
  bool isSuggestedFriend(int friendId) {
    return suggestions.any((s) => s.friendId == friendId);
  }
}
