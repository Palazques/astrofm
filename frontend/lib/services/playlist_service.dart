import 'dart:async';
import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/ai_responses.dart';
import '../models/sonification.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/spotify_service.dart';

/// Service to handle playlist generation in the background.
/// Maintains state across screen navigation.
class PlaylistService extends ChangeNotifier {
  static final PlaylistService _instance = PlaylistService._internal();

  factory PlaylistService() {
    return _instance;
  }

  PlaylistService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  // ignore: unused_field
  final SpotifyService _spotifyService = SpotifyService();

  // State variables
  bool _isGenerating = false;
  String? _error;
  
  // Playlist data
  CosmicPlaylistResult? _cosmicPlaylist;
  DatasetPlaylistResult? _datasetPlaylist;
  List<SpotifyTrack> _spotifyLibraryTracks = [];
  PlaylistResult? _generatedPlaylist; // Legacy format
  String? _spotifyPlaylistUrl;
  
  // Playlist Insight
  PlaylistInsight? _playlistInsight;
  bool _isLoadingInsight = false;

  // Getters
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  CosmicPlaylistResult? get cosmicPlaylist => _cosmicPlaylist;
  DatasetPlaylistResult? get datasetPlaylist => _datasetPlaylist;
  List<SpotifyTrack> get spotifyLibraryTracks => _spotifyLibraryTracks;
  PlaylistResult? get generatedPlaylist => _generatedPlaylist;
  String? get spotifyPlaylistUrl => _spotifyPlaylistUrl;
  PlaylistInsight? get playlistInsight => _playlistInsight;
  bool get isLoadingInsight => _isLoadingInsight;

  // Check if we have any valid playlist data
  bool get hasPlaylist => 
      _cosmicPlaylist != null || 
      _datasetPlaylist != null || 
      _spotifyLibraryTracks.isNotEmpty || 
      _generatedPlaylist != null;

  /// Initialize and load cached data
  Future<void> init() async {
    await _loadCachedPlaylist();
  }

  /// Load cached daily playlist if available for today.
  Future<void> _loadCachedPlaylist() async {
    try {
      // Priority: Load cosmic playlist first (new system)
      final cachedCosmic = await _storageService.loadCosmicPlaylist();
      if (cachedCosmic != null) {
        _cosmicPlaylist = CosmicPlaylistResult.fromJson(cachedCosmic);
        _spotifyPlaylistUrl = _cosmicPlaylist?.playlistUrl;
        notifyListeners();
        return; 
      }
      
      // Fallback: Load dataset playlist from cache (legacy)
      final cachedDataset = await _storageService.loadDatasetPlaylist();
      if (cachedDataset != null) {
        _datasetPlaylist = DatasetPlaylistResult.fromJson(cachedDataset);
        notifyListeners();
      }
      
      // Load Spotify library tracks from cache
      final cached = await _storageService.loadDailyPlaylist();
      if (cached != null) {
        _spotifyLibraryTracks = cached.tracks
            .map((t) => SpotifyTrack.fromJson(t))
            .toList();
        _spotifyPlaylistUrl = cached.playlistUrl;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached playlist: $e');
    }
  }

  /// Generate cosmic playlist using AI + app's Spotify account.
  Future<void> generatePlaylist({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required List<String> genrePreferences,
  }) async {
    if (_isGenerating) return;
    
    _isGenerating = true;
    _error = null;
    _datasetPlaylist = null;
    _spotifyPlaylistUrl = null;
    notifyListeners();
    
    try {
      // Combine genres - use main genres, fall back to defaults if empty
      final genres = genrePreferences.isNotEmpty 
          ? genrePreferences 
          : ['indie rock', 'electronic', 'pop'];
      
      // Generate cosmic playlist using AI + app's Spotify account
      final result = await _apiService.generateCosmicPlaylist(
        sunSign: sunSign,
        moonSign: moonSign,
        risingSign: risingSign,
        genrePreferences: genres,
      );
      
      if (result.success) {
        _spotifyPlaylistUrl = result.playlistUrl;
        _cosmicPlaylist = result;
        
        // Save playlist to cache for the rest of the day
        await _storageService.saveCosmicPlaylist(result.toJson());
      } else {
        throw Exception(result.error ?? 'Failed to generate playlist');
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to generate playlist';
      debugPrint('Playlist generation error: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Clear current playlist data (useful for testing or manual reset)
  void clearPlaylist() {
    _cosmicPlaylist = null;
    _datasetPlaylist = null;
    _spotifyLibraryTracks = [];
    _generatedPlaylist = null;
    _spotifyPlaylistUrl = null;
    _error = null;
    notifyListeners();
  }
  
  /// Load playlist insight
  Future<void> loadPlaylistInsight({
    required String datetime,
    required double latitude,
    required double longitude,
    required PlaylistResult playlist,
  }) async {
    if (_isLoadingInsight) return;
    
    _isLoadingInsight = true;
    notifyListeners();
    
    try {
      // Extract dominant mood and element from playlist
      final dominantMood = playlist.moodDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final dominantElement = playlist.elementDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      // Get BPM range from songs
      final bpms = playlist.songs.map((s) => s.bpm).toList();
      final bpmMin = bpms.isNotEmpty ? bpms.reduce((a, b) => a < b ? a : b) : 100;
      final bpmMax = bpms.isNotEmpty ? bpms.reduce((a, b) => a > b ? a : b) : 130;
      
      final insight = await _apiService.getPlaylistInsight(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        energyPercent: playlist.vibeMatchScore.round(),
        dominantMood: dominantMood,
        dominantElement: dominantElement,
        bpmMin: bpmMin,
        bpmMax: bpmMax,
      );
      
      _playlistInsight = insight;
    } catch (e) {
      debugPrint('Error loading playlist insight: $e');
    } finally {
      _isLoadingInsight = false;
      notifyListeners();
    }
  }
  
  // Method to retry generation
  void retryGeneration({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required List<String> genrePreferences,
  }) {
    _error = null;
    generatePlaylist(
      sunSign: sunSign,
      moonSign: moonSign,
      risingSign: risingSign,
      genrePreferences: genrePreferences,
    );
  }

  /// Create Spotify playlist from dataset tracks
  Future<void> createSpotifyFromDataset(DatasetPlaylistResult playlist) async {
    // Determine playlist name
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';
    final playlistName = 'Astro.FM - Cosmic Vibe - $dateStr';

    // Convert DatasetTracks to song list for Spotify search
    final songs = playlist.tracks.map((track) => {
      'title': track.trackName,
      'artist': track.artists.split(',').first.trim(), // Use primary artist
    }).toList();

    try {
      final result = await _spotifyService.createPlaylist(
        name: playlistName,
        songs: songs,
        description: 'Your cosmic vibe for today ✨🌟 Generated by Astro.FM',
      );

      if (result.success && result.playlistUrl != null) {
        _spotifyPlaylistUrl = result.playlistUrl;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error creating Spotify playlist: $e');
      rethrow;
    }
  }

  /// Generate playlist from user's library using cosmic parameters
  Future<void> createSpotifyFromLibrary(PlaylistResult playlist) async {
    try {
      // Extract cosmic parameters from playlist for filtering
      // Energy: use vibe match score (0-100 -> 0-1)
      final energyTarget = (playlist.vibeMatchScore / 100).clamp(0.0, 1.0);
      
      // Mood: map dominant mood to valence (0-1 scale)
      final dominantMood = playlist.moodDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
          
      // Map moods to valence: higher = happier
      final moodToValence = {
        'energetic': 0.8, 'happy': 0.9, 'uplifting': 0.85,
        'calm': 0.5, 'peaceful': 0.6,
        'melancholic': 0.2, 'introspective': 0.4,
        'intense': 0.6, 'mysterious': 0.35,
      };
      
      final moodTarget = moodToValence[dominantMood.toLowerCase()] ?? 0.5;
      
      // Get BPM range from playlist songs
      final bpms = playlist.songs.map((s) => s.bpm).toList();
      final tempoMin = bpms.isNotEmpty ? bpms.reduce((a, b) => a < b ? a : b) : 80;
      final tempoMax = bpms.isNotEmpty ? bpms.reduce((a, b) => a > b ? a : b) : 160;
      
      // Generate playlist from user's library using cosmic parameters
      final result = await _spotifyService.generateFromLibrary(
        name: 'Cosmic Queue - ${DateTime.now().toString().split(' ')[0]}',
        energyTarget: energyTarget,
        moodTarget: moodTarget,
        tempoMin: tempoMin,
        tempoMax: tempoMax,
        playlistSize: 20,
        description: 'Personalized from your library by Astro.FM 🌟✨',
      );
      
      if (result.success && result.playlistUrl != null) {
        _spotifyPlaylistUrl = result.playlistUrl;
        _spotifyLibraryTracks = result.tracks;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error creating Spotify playlist from library: $e');
      rethrow;
    }
  }
}

final playlistService = PlaylistService();
