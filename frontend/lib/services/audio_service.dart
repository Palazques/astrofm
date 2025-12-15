import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../models/sonification.dart';

/// Service for playing sonification audio using Web Audio API.
/// Generates synthesized tones from astrological chart data.
class AudioService {
  web.AudioContext? _audioContext;
  final List<web.OscillatorNode> _activeOscillators = [];
  final List<web.GainNode> _activeGains = [];
  bool _isPlaying = false;

  /// Stream controller for playback state
  final StreamController<bool> _playingController = StreamController<bool>.broadcast();

  /// Whether audio is currently playing.
  bool get isPlaying => _isPlaying;

  /// Stream of playback state changes.
  Stream<bool> get playingStream => _playingController.stream;

  /// Initialize the audio context.
  void _ensureContext() {
    _audioContext ??= web.AudioContext();
  }

  /// Play a chart sonification.
  ///
  /// Creates layered oscillators for each planet and plays them
  /// with the calculated frequencies, intensities, and panning.
  Future<void> playChartSound(ChartSonification sonification) async {
    // Stop any existing playback
    stop();

    _ensureContext();
    final ctx = _audioContext!;

    // Resume context if suspended (browser autoplay policy)
    if (ctx.state == 'suspended') {
      ctx.resume();
    }

    _isPlaying = true;
    _playingController.add(true);

    final now = ctx.currentTime;

    // Create an oscillator for each planet
    for (final planet in sonification.planets) {
      if (planet.intensity < 0.05) continue; // Skip very quiet planets

      // Create oscillator for pure sine wave
      final oscillator = ctx.createOscillator();
      oscillator.type = 'sine';
      oscillator.frequency.value = planet.frequency;

      // Create gain node for volume control
      final gainNode = ctx.createGain();

      // Apply intensity as base volume (0.0-0.3 range to avoid clipping)
      final baseVolume = planet.intensity * 0.25;

      // Create envelope: attack -> sustain -> decay
      gainNode.gain.setValueAtTime(0.0, now);
      gainNode.gain.linearRampToValueAtTime(
        baseVolume,
        now + planet.attack,
      );
      gainNode.gain.setValueAtTime(
        baseVolume,
        now + sonification.totalDuration - planet.decay,
      );
      gainNode.gain.linearRampToValueAtTime(
        0.0,
        now + sonification.totalDuration,
      );

      // Create stereo panner for positioning
      final panner = ctx.createStereoPanner();
      panner.pan.value = planet.pan;

      // Connect: oscillator -> gain -> panner -> destination
      oscillator.connect(gainNode);
      gainNode.connect(panner);
      panner.connect(ctx.destination);

      // Start and schedule stop
      oscillator.start(now);
      oscillator.stop(now + sonification.totalDuration);

      _activeOscillators.add(oscillator);
      _activeGains.add(gainNode);
    }

    // Schedule cleanup after playback completes
    Future.delayed(
      Duration(milliseconds: (sonification.totalDuration * 1000).toInt()),
      () {
        if (_isPlaying) {
          _cleanup();
          _isPlaying = false;
          _playingController.add(false);
        }
      },
    );
  }

  /// Play a single planet's frequency.
  Future<void> playSinglePlanet(PlanetSound planet, {double duration = 3.0}) async {
    stop();
    
    _ensureContext();
    final ctx = _audioContext!;

    if (ctx.state == 'suspended') {
      ctx.resume();
    }

    _isPlaying = true;
    _playingController.add(true);

    final now = ctx.currentTime;

    final oscillator = ctx.createOscillator();
    oscillator.type = 'sine';
    oscillator.frequency.value = planet.frequency;

    final gainNode = ctx.createGain();
    final volume = planet.intensity * 0.3;

    // Envelope
    gainNode.gain.setValueAtTime(0.0, now);
    gainNode.gain.linearRampToValueAtTime(volume, now + 0.1);
    gainNode.gain.setValueAtTime(volume, now + duration - 0.3);
    gainNode.gain.linearRampToValueAtTime(0.0, now + duration);

    final panner = ctx.createStereoPanner();
    panner.pan.value = planet.pan;

    oscillator.connect(gainNode);
    gainNode.connect(panner);
    panner.connect(ctx.destination);

    oscillator.start(now);
    oscillator.stop(now + duration);

    _activeOscillators.add(oscillator);
    _activeGains.add(gainNode);

    Future.delayed(Duration(milliseconds: (duration * 1000).toInt()), () {
      if (_isPlaying) {
        _cleanup();
        _isPlaying = false;
        _playingController.add(false);
      }
    });
  }

  /// Stop all playback immediately.
  void stop() {
    if (!_isPlaying) return;

    final ctx = _audioContext;
    if (ctx != null) {
      final now = ctx.currentTime;

      // Fade out quickly to avoid clicks
      for (final gain in _activeGains) {
        try {
          gain.gain.linearRampToValueAtTime(0.0, now + 0.05);
        } catch (_) {}
      }

      // Stop oscillators after fade
      Future.delayed(const Duration(milliseconds: 60), () {
        for (final osc in _activeOscillators) {
          try {
            osc.stop();
          } catch (_) {}
        }
        _cleanup();
      });
    } else {
      _cleanup();
    }

    _isPlaying = false;
    _playingController.add(false);
  }

  void _cleanup() {
    _activeOscillators.clear();
    _activeGains.clear();
  }

  /// Dispose the audio service.
  void dispose() {
    stop();
    _audioContext?.close();
    _audioContext = null;
    _playingController.close();
  }
}
