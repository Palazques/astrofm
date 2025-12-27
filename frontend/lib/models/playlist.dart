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

/// Track from the 114K music dataset.
class DatasetTrack {
  final String trackId;
  final String trackName;
  final String artists;
  final String albumName;
  final int durationMs;
  final int popularity;
  final double energy;
  final double valence;
  final double danceability;
  final String? mainGenre;
  final String? subgenre;
  final String? element;

  DatasetTrack({
    required this.trackId,
    required this.trackName,
    required this.artists,
    required this.albumName,
    required this.durationMs,
    required this.popularity,
    required this.energy,
    required this.valence,
    required this.danceability,
    this.mainGenre,
    this.subgenre,
    this.element,
  });

  factory DatasetTrack.fromJson(Map<String, dynamic> json) {
    return DatasetTrack(
      trackId: json['track_id'] as String,
      trackName: json['track_name'] as String,
      artists: json['artists'] as String,
      albumName: json['album_name'] as String,
      durationMs: json['duration_ms'] as int,
      popularity: json['popularity'] as int,
      energy: (json['energy'] as num).toDouble(),
      valence: (json['valence'] as num).toDouble(),
      danceability: (json['danceability'] as num).toDouble(),
      mainGenre: json['main_genre'] as String?,
      subgenre: json['subgenre'] as String?,
      element: json['element'] as String?,
    );
  }

  /// Get formatted duration string (MM:SS)
  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Serialize to JSON for storage.
  Map<String, dynamic> toJson() => {
    'track_id': trackId,
    'track_name': trackName,
    'artists': artists,
    'album_name': albumName,
    'duration_ms': durationMs,
    'popularity': popularity,
    'energy': energy,
    'valence': valence,
    'danceability': danceability,
    'main_genre': mainGenre,
    'subgenre': subgenre,
    'element': element,
  };
}

/// Playlist result from the 114K music dataset.
class DatasetPlaylistResult {
  final List<DatasetTrack> tracks;
  final int totalDurationMs;
  final double vibeMatchScore;
  final List<double> energyArc;
  final Map<String, int> elementDistribution;
  final Map<String, int> genreDistribution;
  final Map<String, dynamic> generationMetadata;

  DatasetPlaylistResult({
    required this.tracks,
    required this.totalDurationMs,
    required this.vibeMatchScore,
    required this.energyArc,
    required this.elementDistribution,
    required this.genreDistribution,
    required this.generationMetadata,
  });

  factory DatasetPlaylistResult.fromJson(Map<String, dynamic> json) {
    return DatasetPlaylistResult(
      tracks: (json['tracks'] as List)
          .map((t) => DatasetTrack.fromJson(t as Map<String, dynamic>))
          .toList(),
      totalDurationMs: json['total_duration_ms'] as int,
      vibeMatchScore: (json['vibe_match_score'] as num).toDouble(),
      energyArc: (json['energy_arc'] as List).map((e) => (e as num).toDouble()).toList(),
      elementDistribution: Map<String, int>.from(
        (json['element_distribution'] as Map).map(
          (key, value) => MapEntry(key as String, value as int),
        ),
      ),
      genreDistribution: Map<String, int>.from(
        (json['genre_distribution'] as Map).map(
          (key, value) => MapEntry(key as String, value as int),
        ),
      ),
      generationMetadata: json['generation_metadata'] as Map<String, dynamic>,
    );
  }

  /// Serialize to JSON for storage.
  Map<String, dynamic> toJson() => {
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'total_duration_ms': totalDurationMs,
    'vibe_match_score': vibeMatchScore,
    'energy_arc': energyArc,
    'element_distribution': elementDistribution,
    'genre_distribution': genreDistribution,
    'generation_metadata': generationMetadata,
  };

  /// Get formatted total duration (e.g., "1h 10m" or "45m")
  String get formattedDuration {
    final totalMinutes = totalDurationMs ~/ 60000;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int get trackCount => tracks.length;
}
