/// Playlist models for Astro.FM.
/// Represents songs and playlist results from the backend API.

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationSeconds;
  final int bpm;
  final int energy;
  final int valence;
  final int danceability;
  final int acousticness;
  final int instrumentalness;
  final List<String> genres;
  final List<String> moods;
  final List<String> elements;
  final List<String> planetaryEnergy;
  final int intensity;
  final String? modality;
  final List<String>? timeOfDay;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationSeconds,
    required this.bpm,
    required this.energy,
    required this.valence,
    required this.danceability,
    required this.acousticness,
    required this.instrumentalness,
    required this.genres,
    required this.moods,
    required this.elements,
    required this.planetaryEnergy,
    required this.intensity,
    this.modality,
    this.timeOfDay,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      durationSeconds: json['duration_seconds'] as int,
      bpm: json['bpm'] as int,
      energy: json['energy'] as int,
      valence: json['valence'] as int,
      danceability: json['danceability'] as int,
      acousticness: json['acousticness'] as int,
      instrumentalness: json['instrumentalness'] as int,
      genres: List<String>.from(json['genres'] as List),
      moods: List<String>.from(json['moods'] as List),
      elements: List<String>.from(json['elements'] as List),
      planetaryEnergy: List<String>.from(json['planetary_energy'] as List),
      intensity: json['intensity'] as int,
      modality: json['modality'] as String?,
      timeOfDay: json['time_of_day'] != null 
          ? List<String>.from(json['time_of_day'] as List)
          : null,
    );
  }

  /// Get formatted duration string (MM:SS)
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class PlaylistResult {
  final List<Song> songs;
  final int totalDurationSeconds;
  final double vibeMatchScore;
  final List<int> energyArc;
  final Map<String, int> elementDistribution;
  final Map<String, int> moodDistribution;
  final Map<String, dynamic> generationMetadata;
  final double durationMinutes;
  final int songCount;

  PlaylistResult({
    required this.songs,
    required this.totalDurationSeconds,
    required this.vibeMatchScore,
    required this.energyArc,
    required this.elementDistribution,
    required this.moodDistribution,
    required this.generationMetadata,
    required this.durationMinutes,
    required this.songCount,
  });

  factory PlaylistResult.fromJson(Map<String, dynamic> json) {
    return PlaylistResult(
      songs: (json['songs'] as List)
          .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
          .toList(),
      totalDurationSeconds: json['total_duration_seconds'] as int,
      vibeMatchScore: (json['vibe_match_score'] as num).toDouble(),
      energyArc: List<int>.from(json['energy_arc'] as List),
      elementDistribution: Map<String, int>.from(
        (json['element_distribution'] as Map).map(
          (key, value) => MapEntry(key as String, value as int),
        ),
      ),
      moodDistribution: Map<String, int>.from(
        (json['mood_distribution'] as Map).map(
          (key, value) => MapEntry(key as String, value as int),
        ),
      ),
      generationMetadata: json['generation_metadata'] as Map<String, dynamic>,
      durationMinutes: (json['duration_minutes'] as num).toDouble(),
      songCount: json['song_count'] as int,
    );
  }

  /// Get formatted total duration (e.g., "1h 10m" or "45m")
  String get formattedDuration {
    final hours = (durationMinutes / 60).floor();
    final minutes = (durationMinutes % 60).round();
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
