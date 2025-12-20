import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../models/sonification.dart';

/// Service for playing sonification audio using Web Audio API.
/// Generates synthesized tones from astrological chart data.
class AudioService {
  web.AudioContext? _audioContext;
  // Store oscillators and mute nodes keyed by planet name for individual control
  final Map<String, web.OscillatorNode> _activeOscillators = {};
  final Map<String, web.GainNode> _activeGains = {}; // Envelope gains
  final Map<String, web.GainNode> _planetMuteNodes = {}; // Toggle gains

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

  /// Update which planets are audible during playback.
  /// 
  /// [activePlanets] - Set of planet names that should be audible.
  void updateActivePlanets(Set<String> activePlanets) {
    if (!_isPlaying || _audioContext == null) return;
    
    final ctx = _audioContext!;
    final now = ctx.currentTime;
    // fade time for toggle
    const fadeTime = 0.1; 

    // Iterate through all controlled mute nodes
    _planetMuteNodes.forEach((planetName, muteNode) {
      final shouldBeAudible = activePlanets.contains(planetName);
      final targetGain = shouldBeAudible ? 1.0 : 0.0;
      
      // Ramp to target gain
      muteNode.gain.cancelScheduledValues(now);
      muteNode.gain.setTargetAtTime(targetGain, now, fadeTime);
    });
  }

  /// Play a chart sonification.
  ///
  /// Creates layered oscillators for each planet and plays them
  /// with the calculated frequencies, intensities, and panning.
  /// Loops continuously until stop() is called.
  Future<void> playChartSound(ChartSonification sonification, {Set<String>? activePlanets}) async {
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

    // Default to all active if not specified
    final currentlyActive = activePlanets ?? sonification.planets.map((p) => p.planet).toSet();

    // Store the sonification for looping
    _currentSonification = sonification;
    _currentActivePlanets = currentlyActive;

    // Start the looped playback
    _startLoopedPlayback(sonification, currentlyActive);
  }

  ChartSonification? _currentSonification;
  Set<String>? _currentActivePlanets;
  Timer? _loopTimer;

  /// Start looped playback of the sonification
  void _startLoopedPlayback(ChartSonification sonification, Set<String> currentlyActive) {
    if (!_isPlaying || _audioContext == null) return;

    final ctx = _audioContext!;
    final now = ctx.currentTime;
    
    // Use a longer loop duration for smoother ambient playback
    const loopDuration = 30.0; // 30 second loops

    // Create a node chain for each planet
    for (final planet in sonification.planets) {
      if (planet.intensity < 0.05) continue; // Skip very quiet planets

      final planetName = planet.planet;

      // 1. Oscillator (Source)
      final oscillator = ctx.createOscillator();
      oscillator.type = 'sine';
      oscillator.frequency.value = planet.frequency;

      // 2. Envelope Gain (Dynamics) - seamless looping envelope
      final envelopeGain = ctx.createGain();
      final baseVolume = planet.intensity * 0.25;

      // Smooth fade in, sustain, smooth fade out for seamless loop
      envelopeGain.gain.setValueAtTime(0.0, now);
      envelopeGain.gain.linearRampToValueAtTime(baseVolume, now + 2.0); // 2s fade in
      envelopeGain.gain.setValueAtTime(baseVolume, now + loopDuration - 2.0);
      envelopeGain.gain.linearRampToValueAtTime(0.0, now + loopDuration); // 2s fade out
      
      // 3. Mute Gain (Toggling)
      final muteGain = ctx.createGain();
      final initialMuteGain = currentlyActive.contains(planetName) ? 1.0 : 0.0;
      muteGain.gain.setValueAtTime(initialMuteGain, now);

      // 4. Panner (Space)
      final panner = ctx.createStereoPanner();
      panner.pan.value = planet.pan;

      // Connect Chain: Osc -> Envelope -> Mute -> Panner -> Destination
      oscillator.connect(envelopeGain);
      envelopeGain.connect(muteGain);
      muteGain.connect(panner);
      panner.connect(ctx.destination);

      // Start
      oscillator.start(now);
      oscillator.stop(now + loopDuration);

      // Store references
      _activeOscillators[planetName] = oscillator;
      _activeGains[planetName] = envelopeGain;
      _planetMuteNodes[planetName] = muteGain;
    }

    // Schedule the next loop iteration (with crossfade overlap)
    _loopTimer?.cancel();
    _loopTimer = Timer(
      Duration(milliseconds: ((loopDuration - 2.0) * 1000).toInt()), // Start next loop 2s before current ends
      () {
        if (_isPlaying && _currentSonification != null) {
          _cleanup();
          _startLoopedPlayback(_currentSonification!, _currentActivePlanets ?? {});
        }
      },
    );
  }

  /// Play a single planet's frequency.
  Future<void> playSinglePlanet(PlanetSound planet, {double duration = 3.0}) async {
    // For single play, we treat it as a chart sound with just one planet
    stop();
    
    _ensureContext();
    final ctx = _audioContext!;
    
    if (ctx.state == 'suspended') ctx.resume();
    _isPlaying = true;
    _playingController.add(true);
    
    final now = ctx.currentTime;
    
    final oscillator = ctx.createOscillator();
    oscillator.type = 'sine';
    oscillator.frequency.value = planet.frequency;
    
    final gainNode = ctx.createGain();
    final volume = planet.intensity * 0.3;
    
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
    
    // We use a dummy key for single playback since it's transient
    _activeOscillators['single'] = oscillator;
    _activeGains['single'] = gainNode;
    
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

    // Cancel the loop timer to prevent re-triggering
    _loopTimer?.cancel();
    _loopTimer = null;
    _currentSonification = null;
    _currentActivePlanets = null;

    final ctx = _audioContext;
    if (ctx != null) {
      final now = ctx.currentTime;

      // Fade out envelope gains quickly
      _activeGains.values.forEach((gain) {
        try {
          gain.gain.cancelScheduledValues(now);
          gain.gain.linearRampToValueAtTime(0.0, now + 0.05);
        } catch (_) {}
      });

      // Stop oscillators after fade
      Future.delayed(const Duration(milliseconds: 60), () {
        _activeOscillators.values.forEach((osc) {
          try {
            osc.stop();
          } catch (_) {}
        });
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
    _planetMuteNodes.clear();
  }

  /// Dispose the audio service.
  void dispose() {
    stop();
    _audioContext?.close();
    _audioContext = null;
    _playingController.close();
  }
}
