/// A track in a seasonal themed playlist.
class SeasonalTrack {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final int energy;
  final String? url;

  SeasonalTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.energy,
    this.url,
  });

  factory SeasonalTrack.fromJson(Map<String, dynamic> json) {
    return SeasonalTrack(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      duration: json['duration'] ?? '3:30',
      energy: json['energy'] ?? 70,
      url: json['url'],
    );
  }
}
