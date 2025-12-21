# Data Sonification Feature Expansion Roadmap

> **Document Purpose**: Comprehensive guide for expanding ASTRO.FM's data sonification capabilities beyond the current implementation.

---

## Current Implementation Summary

### Backend (`services/sonification.py`)
- **Planet-to-Frequency Mapping**: Uses Cosmic Octave method with exact Hz values per planet
- **House-to-Timbre Mapping**: Defines filter types, cutoffs, attack/decay, reverb, and stereo width per house
- **Intensity Calculation**: Bell curve based on degree position within house (max at 15°, fades at cusps)
- **Pan Positioning**: Stereo distribution based on house placement

### Frontend (`services/audio_service.dart`)
- **Web Audio API**: Basic sine wave oscillators
- **Gain Envelopes**: Fade in/out for seamless looping
- **Stereo Panning**: Per-planet spatial positioning
- **Individual Planet Toggles**: Mute/unmute per planet during playback
- **Looped Playback**: 30-second loops with crossfade

### API Endpoints
| Endpoint | Purpose |
|----------|---------|
| `POST /api/sonification/user` | Generate natal chart sonification |
| `GET /api/sonification/daily` | Generate current transit sonification |
| `POST /api/sonification/daily` | Same as above, with JSON body |

---

## Expansion Categories

## I. Enhanced Audio Synthesis

### 1.1 Multiple Waveforms

Currently all planets use sine waves. Map waveform types to planet roles:

| Planet Role | Current | Proposed Waveform | Rationale |
|-------------|---------|-------------------|-----------|
| `carrier` (Sun) | sine | sine | Pure foundation tone |
| `modulator` (Moon) | sine | triangle | Softer, rhythmic quality |
| `detail` (Mercury) | sine | sine | Clean, high-frequency detail |
| `harmonic` (Venus, Jupiter) | sine | sine | Pure harmonic overtones |
| `percussive` (Mars) | sine | sawtooth | Sharp, aggressive attack |
| `drone` (Saturn) | sine | triangle | Warm, grounding low end |
| `glitch` (Uranus) | sine | square | Harsh, digital disruption |
| `ambient` (Neptune) | sine | sine | Smooth, ethereal wash |
| `subbass` (Pluto) | sine | sine | Pure sub-bass frequencies |

**Implementation**: Modify `audio_service.dart` oscillator creation:
```dart
oscillator.type = _getWaveformForRole(planet.role);
```

### 1.2 Filter Implementation

The backend already calculates `filter_type` and `filter_cutoff` per house, but these aren't used in the frontend.

**House Filter Mapping** (from `HOUSE_TIMBRES`):
| House | Filter Type | Cutoff (Hz) |
|-------|-------------|-------------|
| 1st | high_pass | 800 |
| 2nd | low_pass | 1200 |
| 3rd | band_pass | 2000 |
| 4th | low_pass | 400 |
| 5th | high_pass | 600 |
| 6th | band_pass | 1000 |
| 7th | none | - |
| 8th | low_pass | 300 |
| 9th | high_pass | 500 |
| 10th | none | - |
| 11th | band_pass | 1500 |
| 12th | low_pass | 600 |

**Implementation**: Add `BiquadFilterNode` to the audio chain:
```dart
final filter = ctx.createBiquadFilter();
filter.type = planet.filterType; // 'lowpass', 'highpass', 'bandpass'
filter.frequency.value = planet.filterCutoff;
filter.Q.value = 1.0; // Resonance

// New chain: Osc -> Filter -> Envelope -> Mute -> Panner -> Destination
oscillator.connect(filter);
filter.connect(envelopeGain);
```

### 1.3 LFO Modulation

Add Low-Frequency Oscillators to create movement and "shimmer":

| Planet | Modulation Target | LFO Rate | Depth |
|--------|-------------------|----------|-------|
| Moon | Volume | 0.5 Hz | 20% |
| Mercury | Frequency | 2.0 Hz | 5 cents |
| Venus | Filter Cutoff | 0.3 Hz | 15% |
| Neptune | Volume + Pan | 0.1 Hz | 30% |

**Implementation**: Create LFO oscillator connected to parameter:
```dart
final lfo = ctx.createOscillator();
lfo.type = 'sine';
lfo.frequency.value = 0.5; // 0.5 Hz

final lfoGain = ctx.createGain();
lfoGain.gain.value = 0.2; // 20% depth

lfo.connect(lfoGain);
lfoGain.connect(envelopeGain.gain); // Modulate volume
lfo.start(now);
```

### 1.4 Reverb & Delay

Implement the `reverb` parameter from house timbres:

| Reverb Level | Impulse Response | Wet/Dry Mix |
|--------------|------------------|-------------|
| 0.0 - 0.2 | Small room | 10-20% wet |
| 0.3 - 0.5 | Medium hall | 30-50% wet |
| 0.6 - 0.8 | Large cathedral | 60-80% wet |
| 0.9 - 1.0 | Infinite space | 90-100% wet |

**Implementation Options**:
1. **ConvolverNode**: Load impulse response audio files for realistic reverb
2. **Simple Delay Network**: Use `DelayNode` with feedback for basic reverb effect

```dart
final convolver = ctx.createConvolver();
// Load impulse response buffer
convolver.buffer = impulseResponseBuffer;

final dryGain = ctx.createGain();
final wetGain = ctx.createGain();
dryGain.gain.value = 1.0 - planet.reverb;
wetGain.gain.value = planet.reverb;
```

---

## II. Binaural Beat Integration

> Per `product_vision.md`: "Binaural Beat Integration" listed as key Audio Generation feature.

### 2.1 Brainwave States

| Mode | Frequency Range | State | Use Case |
|------|-----------------|-------|----------|
| **Delta** | 0.5 - 4 Hz | Deep sleep | Sleep journey, deep rest |
| **Theta** | 4 - 7 Hz | Deep meditation | Creativity, intuition |
| **Alpha** | 8 - 13 Hz | Relaxation | Light meditation, calm |
| **Beta** | 14 - 30 Hz | Focus | Concentration, alertness |
| **Gamma** | 30 - 100 Hz | Peak awareness | Higher consciousness |

### 2.2 Implementation Approach

Binaural beats require a base frequency in one ear and base + offset in the other:

```dart
// Example: 10 Hz Alpha beat using 200 Hz carrier
final leftOsc = ctx.createOscillator();
leftOsc.frequency.value = 200.0;

final rightOsc = ctx.createOscillator();
rightOsc.frequency.value = 210.0; // +10 Hz offset

// Hard pan to respective ears
final leftPanner = ctx.createStereoPanner();
leftPanner.pan.value = -1.0;

final rightPanner = ctx.createStereoPanner();
rightPanner.pan.value = 1.0;
```

### 2.3 Astrological Mapping

Map planet energies to brainwave states:

| Planet Dominance | Suggested Binaural | Reasoning |
|------------------|-------------------|-----------|
| Saturn dominant | Theta (5 Hz) | Deep introspection |
| Mercury dominant | Beta (18 Hz) | Mental clarity |
| Neptune dominant | Theta (6 Hz) | Dreamlike, spiritual |
| Mars dominant | Beta (25 Hz) | Action, energy |
| Moon dominant | Alpha (10 Hz) | Emotional processing |

### 2.4 UI Integration

Add binaural mode selector to Sound Screen:

```
┌─────────────────────────────────────┐
│  🧠 BRAINWAVE MODE                  │
├─────────────────────────────────────┤
│  [ OFF ] [ FOCUS ] [ CALM ] [ DEEP ]│
│                                     │
│  Current: Alpha (10 Hz)             │
│  Carrier Frequency: 200 Hz          │
└─────────────────────────────────────┘
```

---

## III. Meditation Sound Modes

> Per `product_vision.md`: "Meditation Sound Modes" listed as key feature.

### 3.1 Mode Definitions

#### Birth Chart Meditation
| Parameter | Value |
|-----------|-------|
| Duration | 10-30 minutes |
| Planet Cycling | Slow fade between planets (90s each) |
| Intensity | Lower overall volume (0.15 max) |
| Binaural | Optional theta layer |

#### Chakra Alignment
| Chakra | Frequency | Associated Planet |
|--------|-----------|-------------------|
| Root | 256 Hz (C) | Saturn |
| Sacral | 288 Hz (D) | Mars |
| Solar Plexus | 320 Hz (E) | Sun |
| Heart | 341 Hz (F) | Venus |
| Throat | 384 Hz (G) | Mercury |
| Third Eye | 426 Hz (A) | Moon |
| Crown | 480 Hz (B) | Neptune |

#### Breath Sync
| Phase | Duration | Audio Behavior |
|-------|----------|----------------|
| Inhale | 4 seconds | Volume ramp up |
| Hold | 7 seconds | Sustained peak |
| Exhale | 8 seconds | Volume ramp down |
| Pause | 2 seconds | Near silence |

**Implementation**: Timer-based gain automation synced to breathing pattern.

#### Sleep Journey
| Phase | Duration | Frequency Shift |
|-------|----------|-----------------|
| Entry | 5 min | Maintain natal frequencies |
| Transition | 10 min | Gradual descent to lower octaves |
| Deep | 15 min | Sub-bass emphasis, delta binaural |
| Fade Out | 5 min | Slow volume decrease to silence |

### 3.2 Backend Endpoint Addition

```python
@router.post("/meditation")
async def get_meditation_sonification(
    request: MeditationRequest
) -> MeditationSonification:
    """
    Generate extended meditation session parameters.
    
    Args:
        request: Birth data + meditation mode + duration
        
    Returns:
        Extended sonification with phase timings
    """
```

---

## IV. Aspect Sonification

> Currently unused from `astrology_vibe_logic.md` Section I orb definitions.

### 4.1 Aspect Types & Audio Treatment

| Aspect | Orb | Harmonic Relationship | Audio Effect |
|--------|-----|----------------------|--------------|
| **Conjunction** (0°) | 8° | Unison/beating | Slight frequency detuning creates "beating" pattern |
| **Sextile** (60°) | 3° | Minor 3rd interval | Pleasing harmonic overlay |
| **Square** (90°) | 8° | Tritone/dissonance | Tension through dissonant interval |
| **Trine** (120°) | 8° | Perfect 5th | Consonant, flowing harmony |
| **Opposition** (180°) | 8° | Octave separation | Hard stereo pan to opposite channels |

### 4.2 Implementation

```python
def calculate_aspect_effects(chart_data: dict) -> list[AspectEffect]:
    """
    Analyze aspects between planets and generate audio effects.
    
    Returns list of AspectEffect objects defining:
    - planet_a, planet_b
    - aspect_type (conjunction, square, trine, etc.)
    - orb (exact degree)
    - audio_modification (detuning, panning, filtering, etc.)
    """
```

### 4.3 Audio Modifications

**Conjunction Beating**:
```dart
// Slightly detune the two conjunct planets to create beating
final beatFrequency = 2.0; // 2 Hz beat rate
planetA.frequency.value = baseFreq - (beatFrequency / 2);
planetB.frequency.value = baseFreq + (beatFrequency / 2);
```

**Square Dissonance**:
```dart
// Add tritone overlay
final dissonantOsc = ctx.createOscillator();
dissonantOsc.frequency.value = planet.frequency * 1.414; // Tritone ratio
dissonantOsc.type = 'square';
// Mix at low volume for subtle tension
```

**Opposition Stereo Split**:
```dart
pannerA.pan.value = -0.9; // Hard left
pannerB.pan.value = 0.9;  // Hard right
```

---

## V. Dynamic Transit Layers

### 5.1 Layer Architecture

```
┌─────────────────────────────────────────┐
│           AUDIO MIX STRUCTURE           │
├─────────────────────────────────────────┤
│                                         │
│  Layer 3: TRANSIT PULSES                │
│  └─ Momentary spikes when transit       │
│     aspects natal position              │
│                                         │
│  Layer 2: TRANSIT OVERLAY               │
│  └─ Current sky positions               │
│  └─ Volume: 40% of natal                │
│                                         │
│  Layer 1: NATAL FOUNDATION              │
│  └─ User's birth chart                  │
│  └─ Always playing (quiet drone)        │
│                                         │
└─────────────────────────────────────────┘
```

### 5.2 Transit-to-Natal Interaction

| Transit Aspect | Natal Planet | Audio Effect |
|----------------|--------------|--------------|
| Conjunction | Any | Intensity spike + frequency lock |
| Square | Any | Filter resonance increase |
| Trine | Any | Reverb swell |
| Opposition | Any | Stereo width expansion |

### 5.3 Real-Time Updates

Update transit layer periodically (hourly or with Moon changes):

```python
@router.get("/transit-overlay")
async def get_transit_overlay(
    birth_datetime: str,
    latitude: float,
    longitude: float
) -> TransitOverlay:
    """
    Returns current transits relative to natal chart
    with audio modification instructions.
    """
```

---

## VI. Compatibility Sonification

> Per `product_vision.md`: "Frequency Matching" and "Harmonic Compatibility Analysis"

### 6.1 Dual Chart Blending

Play two users' charts simultaneously:

| Parameter | Behavior |
|-----------|----------|
| Shared planets | Average frequencies, combine in center |
| Aspects between charts | Apply aspect audio effects |
| Elemental harmony | Boost/reduce based on element compatibility |

### 6.2 Synastry Highlights

When charting compatibility:
1. Find all aspects between Chart A and Chart B
2. Rank by closeness of orb
3. Highlight top 5 with increased volume/brightness

### 6.3 Vibe Match Score

Audio-based compatibility metric:

```python
def calculate_sonic_compatibility(chart_a: dict, chart_b: dict) -> float:
    """
    Returns 0.0-1.0 score based on:
    - Harmonic ratios between dominant frequencies
    - Number of consonant vs dissonant aspects
    - Elemental compatibility
    """
```

**UI Display**:
```
┌─────────────────────────────────────┐
│  🎵 HARMONIC RESONANCE: 78%         │
│  ═══════════════════░░░░            │
│                                     │
│  Your frequencies blend naturally!  │
│  Strong Venus-Moon connection.      │
└─────────────────────────────────────┘
```

---

## VII. Exportable Sound Files

### 7.1 Export Options

| Format | Quality | Size (1 min) | Use Case |
|--------|---------|--------------|----------|
| MP3 | 128 kbps | ~1 MB | Social sharing |
| MP3 | 320 kbps | ~2.5 MB | High quality sharing |
| WAV | 16-bit/44.1 kHz | ~10 MB | Lossless archive |
| FLAC | Lossless | ~5 MB | Audiophile quality |

### 7.2 Backend Audio Rendering

Requires server-side audio generation:

```python
from pydub import AudioSegment
from pydub.generators import Sine

def render_sonification_audio(
    sonification: ChartSonification,
    duration_seconds: int = 60,
    format: str = "mp3"
) -> bytes:
    """
    Generate audio file from sonification data.
    
    Returns binary audio data for download.
    """
    combined = AudioSegment.silent(duration=duration_seconds * 1000)
    
    for planet in sonification.planets:
        tone = Sine(planet.frequency).to_audio_segment(
            duration=duration_seconds * 1000
        )
        tone = tone - (30 - planet.intensity * 30)  # Volume adjust
        tone = tone.pan(planet.pan)
        combined = combined.overlay(tone)
    
    return combined.export(format=format).read()
```

### 7.3 API Endpoint

```python
@router.get("/export/{format}")
async def export_sonification(
    birth_datetime: str,
    latitude: float,
    longitude: float,
    duration: int = 60,
    format: str = "mp3"
) -> Response:
    """
    Generate and download audio file of user's sound signature.
    """
    sonification = calculate_user_sonification(...)
    audio_bytes = render_sonification_audio(sonification, duration, format)
    
    return Response(
        content=audio_bytes,
        media_type=f"audio/{format}",
        headers={"Content-Disposition": f"attachment; filename=cosmic_signature.{format}"}
    )
```

### 7.4 Social Sharing

"Share Your Cosmic Frequency" feature:
- Generate 15-second audio clip
- Create shareable link with embedded player
- Generate visual waveform preview image

---

## VIII. Visualization Sync

### 8.1 Real-Time FFT Visualization

```dart
final analyser = ctx.createAnalyser();
analyser.fftSize = 2048;

// Connect master output to analyser
masterGain.connect(analyser);
analyser.connect(ctx.destination);

// Get frequency data for visualization
final frequencyData = Uint8List(analyser.frequencyBinCount);
analyser.getByteFrequencyData(frequencyData);
```

### 8.2 Planet Pulse Animations

Map oscillator amplitude to visual elements:

| Visual Element | Data Source | Animation |
|----------------|-------------|-----------|
| Planet icon | Planet gain node | Scale/glow pulsing |
| House segment | Combined house planets | Brightness |
| Frequency ring | Individual frequency | Ripple effect |

### 8.3 Implementation Pattern

```dart
class AudioVisualSync {
  final AnimationController _controller;
  late web.AnalyserNode _analyser;
  
  void _updateVisualization() {
    final data = _getFrequencyData();
    
    // Update planet animations based on their frequency bands
    for (final planet in planets) {
      final bandIndex = _frequencyToBand(planet.frequency);
      final amplitude = data[bandIndex] / 255.0;
      planet.animationController.value = amplitude;
    }
  }
}
```

---

## Implementation Priority Matrix

### 🟢 Quick Wins (1-2 days each)

| Feature | Effort | Impact | Dependencies |
|---------|--------|--------|--------------|
| Multiple waveforms | Low | Medium | None |
| Filter implementation | Low | High | None - data exists |
| Attack/decay envelopes | Low | Medium | None - data exists |

### 🟡 Medium Effort (3-5 days each)

| Feature | Effort | Impact | Dependencies |
|---------|--------|--------|--------------|
| Binaural beat mode | Medium | High | UI toggle |
| LFO modulation | Medium | Medium | None |
| Reverb implementation | Medium | High | Impulse response files |
| Aspect sonification | Medium | High | Backend calculation |
| Visualization sync | Medium | High | Canvas/animation setup |

### 🔴 Major Features (1+ weeks each)

| Feature | Effort | Impact | Dependencies |
|---------|--------|--------|--------------|
| Meditation modes | High | High | Timer UI, backend endpoints |
| Transit layers | High | High | Real-time updates |
| Audio export | High | Medium | `pydub`, storage |
| Compatibility sonification | High | High | Friend system |

---

## Technical Considerations

### Web Audio API Limitations
- **iOS Safari**: Requires user gesture to start audio context
- **Polyphony**: Keep oscillator count under 20 for performance
- **Sample Rate**: Default 44.1 kHz, consider 48 kHz for quality

### Backend Performance
- **FFmpeg/pydub**: Heavy for audio rendering - consider async workers
- **Caching**: Cache rendered audio files by birth data hash
- **File Storage**: Use cloud storage (GCS, S3) for exported files

### Mobile Considerations
- **Battery**: Active audio synthesis drains battery
- **Background Audio**: May need native plugins for background playback
- **Headphone Requirement**: Binaural beats require headphones - detect and warn

---

## Appendix: Frequency Reference

### Cosmic Octave Frequencies (Current)

| Planet | Frequency (Hz) | Note |
|--------|---------------|------|
| Sun | 126.22 | B |
| Moon | 210.42 | G# |
| Mercury | 141.27 | C# |
| Venus | 221.23 | A |
| Mars | 144.72 | C# |
| Jupiter | 183.58 | F# |
| Saturn | 147.85 | D |
| Uranus | 207.36 | G# |
| Neptune | 211.44 | G# |
| Pluto | 140.25 | C# |

### Chakra Frequencies (Alternative Mapping)

| Chakra | Frequency (Hz) | Note | Planet Association |
|--------|---------------|------|-------------------|
| Root | 256 | C | Saturn |
| Sacral | 288 | D | Mars |
| Solar Plexus | 320 | E | Sun |
| Heart | 341 | F | Venus |
| Throat | 384 | G | Mercury |
| Third Eye | 426 | A | Moon |
| Crown | 480 | B | Neptune |

### Brainwave Frequencies

| State | Frequency Range | Typical Target |
|-------|-----------------|----------------|
| Delta | 0.5 - 4 Hz | 2 Hz |
| Theta | 4 - 7 Hz | 6 Hz |
| Alpha | 8 - 13 Hz | 10 Hz |
| Beta | 14 - 30 Hz | 18 Hz |
| Gamma | 30 - 100 Hz | 40 Hz |

---

*Document Version: 1.0*  
*Created: December 2024*  
*Last Updated: December 2024*
