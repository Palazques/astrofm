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
  Timer? _singlePlayTimer; // Timer for single planet playback cleanup

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

      // 2. Filter (Tonal Character) - NEW for unique sounds
      web.BiquadFilterNode? filterNode;
      if (planet.filterType != 'none' && planet.filterCutoff > 0) {
        filterNode = ctx.createBiquadFilter();
        // Map backend filter types to Web Audio filter types
        switch (planet.filterType) {
          case 'low_pass':
            filterNode.type = 'lowpass';
            break;
          case 'high_pass':
            filterNode.type = 'highpass';
            break;
          case 'band_pass':
            filterNode.type = 'bandpass';
            break;
          default:
            filterNode.type = 'lowpass';
        }
        filterNode.frequency.value = planet.filterCutoff;
        filterNode.Q.value = 1.5; // Moderate resonance for tonal color
      }

      // 3. Envelope Gain (Dynamics) - seamless looping envelope
      final envelopeGain = ctx.createGain();
      final baseVolume = planet.intensity * 0.25;

      // Smooth fade in, sustain, smooth fade out for seamless loop
      envelopeGain.gain.setValueAtTime(0.0, now);
      envelopeGain.gain.linearRampToValueAtTime(baseVolume, now + 2.0); // 2s fade in
      envelopeGain.gain.setValueAtTime(baseVolume, now + loopDuration - 2.0);
      envelopeGain.gain.linearRampToValueAtTime(0.0, now + loopDuration); // 2s fade out
      
      // 4. Mute Gain (Toggling)
      final muteGain = ctx.createGain();
      final initialMuteGain = currentlyActive.contains(planetName) ? 1.0 : 0.0;
      muteGain.gain.setValueAtTime(initialMuteGain, now);

      // 5. Panner (Space)
      final panner = ctx.createStereoPanner();
      panner.pan.value = planet.pan;

      // Connect Chain: Osc -> [Filter] -> Envelope -> Mute -> Panner -> Destination
      if (filterNode != null) {
        oscillator.connect(filterNode);
        filterNode.connect(envelopeGain);
      } else {
        oscillator.connect(envelopeGain);
      }
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
    
    // Schedule cleanup after duration using cancellable Timer
    _singlePlayTimer?.cancel();
    _singlePlayTimer = Timer(Duration(milliseconds: (duration * 1000).toInt()), () {
      if (_isPlaying) {
        _cleanup();
        _isPlaying = false;
        _playingController.add(false);
      }
    });
  }

  /// Play two frequencies simultaneously as a chord.
  /// 
  /// Creates two oscillators at [freq1] and [freq2] Hz, useful for
  /// playing aspect connections between planets.
  /// 
  /// [freq1] - First frequency in Hz
  /// [freq2] - Second frequency in Hz
  /// [duration] - Playback duration in seconds
  Future<void> playFrequencyChord(int freq1, int freq2, {double duration = 5.0}) async {
    stop();
    
    _ensureContext();
    final ctx = _audioContext!;
    
    if (ctx.state == 'suspended') ctx.resume();
    _isPlaying = true;
    _playingController.add(true);
    
    final now = ctx.currentTime;
    
    // First frequency oscillator
    final osc1 = ctx.createOscillator();
    osc1.type = 'sine';
    osc1.frequency.value = freq1.toDouble();
    
    // Second frequency oscillator
    final osc2 = ctx.createOscillator();
    osc2.type = 'sine';
    osc2.frequency.value = freq2.toDouble();
    
    // Gain nodes with envelope
    final gain1 = ctx.createGain();
    gain1.gain.setValueAtTime(0.0, now);
    gain1.gain.linearRampToValueAtTime(0.2, now + 0.15);
    gain1.gain.setValueAtTime(0.2, now + duration - 0.5);
    gain1.gain.linearRampToValueAtTime(0.0, now + duration);
    
    final gain2 = ctx.createGain();
    gain2.gain.setValueAtTime(0.0, now);
    gain2.gain.linearRampToValueAtTime(0.2, now + 0.15);
    gain2.gain.setValueAtTime(0.2, now + duration - 0.5);
    gain2.gain.linearRampToValueAtTime(0.0, now + duration);
    
    // Pan slightly left and right for stereo separation
    final panner1 = ctx.createStereoPanner();
    panner1.pan.value = -0.3;
    
    final panner2 = ctx.createStereoPanner();
    panner2.pan.value = 0.3;
    
    // Connect chains
    osc1.connect(gain1);
    gain1.connect(panner1);
    panner1.connect(ctx.destination);
    
    osc2.connect(gain2);
    gain2.connect(panner2);
    panner2.connect(ctx.destination);
    
    // Start oscillators
    osc1.start(now);
    osc2.start(now);
    osc1.stop(now + duration);
    osc2.stop(now + duration);
    
    // Store references
    _activeOscillators['chord_1'] = osc1;
    _activeOscillators['chord_2'] = osc2;
    _activeGains['chord_1'] = gain1;
    _activeGains['chord_2'] = gain2;
    
    // Schedule cleanup
    _singlePlayTimer?.cancel();
    _singlePlayTimer = Timer(Duration(milliseconds: (duration * 1000).toInt()), () {
      if (_isPlaying) {
        _cleanup();
        _isPlaying = false;
        _playingController.add(false);
      }
    });
  }

  /// Play a binaural beat for brainwave entrainment.
  /// 
  /// Creates a stereo effect where the left ear receives [carrierHz] and
  /// the right ear receives [carrierHz] + [binauralHz]. The brain perceives
  /// a "beat" at the [binauralHz] frequency, inducing the corresponding
  /// brainwave state.
  /// 
  /// [carrierHz] - Base frequency (planet's Cosmic Octave, e.g., 141.27 Hz for Mercury)
  /// [binauralHz] - Brainwave offset (2-40 Hz depending on mode)
  /// [duration] - Playback duration in seconds
  Future<void> playBinauralBeat({
    required double carrierHz,
    required double binauralHz,
    double duration = 180.0, // Default 3 minutes
  }) async {
    stop();
    
    _ensureContext();
    final ctx = _audioContext!;
    
    if (ctx.state == 'suspended') ctx.resume();
    _isPlaying = true;
    _playingController.add(true);
    
    final now = ctx.currentTime;
    
    // Left ear oscillator (carrier frequency)
    final leftOsc = ctx.createOscillator();
    leftOsc.type = 'sine';
    leftOsc.frequency.value = carrierHz;
    
    // Right ear oscillator (carrier + binaural offset)
    final rightOsc = ctx.createOscillator();
    rightOsc.type = 'sine';
    rightOsc.frequency.value = carrierHz + binauralHz;
    
    // Left channel gain with envelope
    final leftGain = ctx.createGain();
    leftGain.gain.setValueAtTime(0.0, now);
    leftGain.gain.linearRampToValueAtTime(0.25, now + 3.0); // 3s fade in
    leftGain.gain.setValueAtTime(0.25, now + duration - 5.0);
    leftGain.gain.linearRampToValueAtTime(0.0, now + duration); // 5s fade out
    
    // Right channel gain with envelope
    final rightGain = ctx.createGain();
    rightGain.gain.setValueAtTime(0.0, now);
    rightGain.gain.linearRampToValueAtTime(0.25, now + 3.0);
    rightGain.gain.setValueAtTime(0.25, now + duration - 5.0);
    rightGain.gain.linearRampToValueAtTime(0.0, now + duration);
    
    // Hard pan: left ear gets left panner, right ear gets right panner
    final leftPanner = ctx.createStereoPanner();
    leftPanner.pan.value = -1.0; // Full left
    
    final rightPanner = ctx.createStereoPanner();
    rightPanner.pan.value = 1.0; // Full right
    
    // Connect chains
    leftOsc.connect(leftGain);
    leftGain.connect(leftPanner);
    leftPanner.connect(ctx.destination);
    
    rightOsc.connect(rightGain);
    rightGain.connect(rightPanner);
    rightPanner.connect(ctx.destination);
    
    // Start oscillators
    leftOsc.start(now);
    rightOsc.start(now);
    leftOsc.stop(now + duration);
    rightOsc.stop(now + duration);
    
    // Store references for cleanup
    _activeOscillators['binaural_left'] = leftOsc;
    _activeOscillators['binaural_right'] = rightOsc;
    _activeGains['binaural_left'] = leftGain;
    _activeGains['binaural_right'] = rightGain;
    
    // Schedule cleanup after duration
    _singlePlayTimer?.cancel();
    _singlePlayTimer = Timer(Duration(milliseconds: (duration * 1000).toInt()), () {
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

    // Cancel all timers to prevent re-triggering or delayed cleanup
    _loopTimer?.cancel();
    _loopTimer = null;
    _singlePlayTimer?.cancel();
    _singlePlayTimer = null;
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
