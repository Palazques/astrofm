import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/inline_error.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/birth_data.dart';
import '../data/test_users.dart';

/// Your Sound screen with frequency breakdown.
class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key});

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  
  bool _isPlaying = false;
  bool _isLoading = false;
  ChartSonification? _sonification;
  String? _errorMessage;
  final Set<String> _selectedPlanets = {};
  
  // AI Sound interpretation
  SoundInterpretation? _soundInterpretation;
  bool _isLoadingSoundInterpretation = false;
  
  // Birth data from storage (or fallback to test data)
  BirthData? _birthData;
  
  Map<String, dynamic> get _birthDataMap => _birthData != null 
    ? {
        'datetime': _birthData!.datetime,
        'latitude': _birthData!.latitude,
        'longitude': _birthData!.longitude,
        'timezone': _birthData!.timezone,
      }
    : defaultTestBirthData;
    
  Map<String, dynamic> get soundProfile => {
    'name': _birthData?.name ?? 'Paul',
    'sign': 'Cancer',
    'createdFrom': _birthData != null 
        ? '${_birthData!.formattedDate} • ${_birthData!.formattedTime} • ${_birthData!.locationName}'
        : 'July 15, 1990 • 3:42 PM • Los Angeles, CA',
    'dominantFrequency': '528 Hz',
    'element': 'Water',
  };

  List<Map<String, dynamic>> get frequencyBreakdown {
    if (_sonification == null) {
      // Return mock data while loading
      return [
        {'planet': 'Sun', 'sign': 'Cancer', 'frequency': '126 Hz', 'color': AppColors.electricYellow, 'description': 'Core essence • Nurturing vibration', 'symbol': '☉'},
        {'planet': 'Moon', 'sign': 'Scorpio', 'frequency': '210 Hz', 'color': AppColors.hotPink, 'description': 'Emotional depth • Transformative pulse', 'symbol': '☽'},
        {'planet': 'Mercury', 'sign': 'Leo', 'frequency': '141 Hz', 'color': AppColors.teal, 'description': 'Communication • Creative expression', 'symbol': '☿'},
        {'planet': 'Venus', 'sign': 'Gemini', 'frequency': '221 Hz', 'color': AppColors.orange, 'description': 'Love language • Curious connection', 'symbol': '♀'},
        {'planet': 'Mars', 'sign': 'Taurus', 'frequency': '145 Hz', 'color': AppColors.red, 'description': 'Drive • Steady determination', 'symbol': '♂'},
      ];
    }
    
    // Build from actual sonification data
    final planetColors = {
      'Sun': AppColors.electricYellow,
      'Moon': AppColors.hotPink,
      'Mercury': AppColors.teal,
      'Venus': AppColors.orange,
      'Mars': AppColors.red,
      'Jupiter': AppColors.cosmicPurple,
      'Saturn': AppColors.glassBorder,
      'Uranus': AppColors.teal,
      'Neptune': AppColors.cosmicPurple,
      'Pluto': AppColors.hotPink,
    };
    
    final planetSymbols = {
      'Sun': '☉', 'Moon': '☽', 'Mercury': '☿', 'Venus': '♀',
      'Mars': '♂', 'Jupiter': '♃', 'Saturn': '♄', 'Uranus': '♅',
      'Neptune': '♆', 'Pluto': '♇',
    };
    
    return _sonification!.planets.map((p) {
      // Use AI description if available, otherwise fallback
      String description = 'House ${p.house} • ${(p.intensity * 100).toStringAsFixed(0)}% intensity';
      if (_soundInterpretation != null && _soundInterpretation!.planetDescriptions.containsKey(p.planet)) {
        description = _soundInterpretation!.planetDescriptions[p.planet]!;
      }
      
      return {
        'planet': p.planet,
        'sign': p.sign,
        'frequency': '${p.frequency.toStringAsFixed(0)} Hz',
        'color': planetColors[p.planet] ?? AppColors.electricYellow,
        'description': description,
        'symbol': planetSymbols[p.planet] ?? '★',
      };
    }).toList();
  }

  Map<String, dynamic> get todaysInfluence {
    if (_soundInterpretation != null) {
      return {
        'transit': 'Your Sonic Personality',
        'effect': _soundInterpretation!.todayInfluence,
        'shift': _soundInterpretation!.shift,
        'personality': _soundInterpretation!.personality,
      };
    }
    // Fallback while loading
    return {
      'transit': 'Loading cosmic insights...',
      'effect': 'Connecting to the cosmos...',
      'shift': '...',
      'personality': '',
    };
  }

  @override
  void initState() {
    super.initState();
    _loadBirthDataAndInit();
    _audioService.playingStream.listen((isPlaying) {
      if (mounted) {
        setState(() => _isPlaying = isPlaying);
      }
    });
  }
  
  Future<void> _loadBirthDataAndInit() async {
    final stored = await storageService.loadBirthData();
    if (mounted) {
      setState(() => _birthData = stored);
    }
    _loadSonification();
  }

  @override
  void dispose() {
    _audioService.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadSonification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sonification = await _apiService.getUserSonification(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String,
      );
      
      if (mounted) {
        setState(() {
          _sonification = sonification;
          // Select all planets by default
          _selectedPlanets.clear();
          _selectedPlanets.addAll(sonification.planets.map((p) => p.planet));
          _isLoading = false;
        });
        // Load AI interpretation after sonification loads
        _loadSoundInterpretation();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load sound data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSoundInterpretation() async {
    if (_sonification == null) return;
    
    setState(() => _isLoadingSoundInterpretation = true);
    
    try {
      // Build planet data for API
      final planets = _sonification!.planets.map((p) => {
        'name': p.planet,
        'sign': p.sign,
        'house': p.house,
        'frequency': p.frequency,
      }).toList();
      
      final interpretation = await _apiService.getSoundInterpretation(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        dominantElement: soundProfile['element'] as String,
        planets: planets,
      );
      
      if (mounted) {
        setState(() {
          _soundInterpretation = interpretation;
          _isLoadingSoundInterpretation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSoundInterpretation = false);
      }
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _audioService.stop();
    } else if (_sonification != null) {
      _audioService.playChartSound(
        _sonification!,
        activePlanets: _selectedPlanets,
      );
    }
  }

  void _togglePlanet(String planet) {
    setState(() {
      if (_selectedPlanets.contains(planet)) {
        _selectedPlanets.remove(planet);
      } else {
        _selectedPlanets.add(planet);
      }
    });

    if (_isPlaying) {
      _audioService.updateActivePlanets(_selectedPlanets);
    }
  }

  void _selectAll() {
    if (_sonification == null) return;
    setState(() {
      _selectedPlanets.addAll(_sonification!.planets.map((p) => p.planet));
    });
    if (_isPlaying) {
      _audioService.updateActivePlanets(_selectedPlanets);
    }
  }

  void _deselectAll() {
    setState(() {
      _selectedPlanets.clear();
    });
    if (_isPlaying) {
      _audioService.updateActivePlanets(_selectedPlanets);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              showBackButton: true,
              showMenuButton: false,
              title: 'Your Sound',
              rightAction: IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () async {
                  await Share.share(
                    '🌌 My Cosmic Sound Profile \u2728\n\n'
                    '🎵 Dominant Frequency: ${soundProfile['dominantFrequency']}\n'
                    '⭐ Sign: ${soundProfile['sign']}\n'
                    '💧 Element: ${soundProfile['element']}\n\n'
                    'Created from ${soundProfile['createdFrom']}\n\n'
                    'Discover your cosmic sound at ASTRO.FM!',
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Main Sound Orb
            _buildMainOrb(),
            const SizedBox(height: 32),

            // Play Button
            _buildPlayButton(),
            const SizedBox(height: 24),

            // Today's Influence
            _buildTodaysInfluence(),
            const SizedBox(height: 24),

            // Frequency Breakdown
            _buildFrequencyBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainOrb() {
    // Show error state with retry
    if (_errorMessage != null) {
      return Column(
        children: [
          const SkeletonOrb(size: 180),
          const SizedBox(height: 24),
          InlineError(
            message: _errorMessage!,
            onRetry: _loadSonification,
          ),
        ],
      );
    }
    
    // Show skeleton while loading
    if (_isLoading && _sonification == null) {
      return Column(
        children: [
          const SkeletonOrb(size: 180),
          const SizedBox(height: 24),
          SkeletonLoader(
            width: 200,
            height: 28,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withAlpha(25),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 250,
            height: 13,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withAlpha(15),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonLoader(width: 70, height: 28, borderRadius: BorderRadius.circular(20), color: Colors.white.withAlpha(15)),
              const SizedBox(width: 12),
              SkeletonLoader(width: 60, height: 28, borderRadius: BorderRadius.circular(20), color: Colors.white.withAlpha(15)),
              const SizedBox(width: 12),
              SkeletonLoader(width: 65, height: 28, borderRadius: BorderRadius.circular(20), color: Colors.white.withAlpha(15)),
            ],
          ),
        ],
      );
    }
    
    return Column(
      children: [
        SoundOrb(
          size: 180,
          colors: const [AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal, AppColors.electricYellow],
          animate: _isPlaying,
          showWaveform: true,
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.hotPink, AppColors.electricYellow],
          ).createShader(bounds),
          child: Text(
            "${soundProfile['name']}'s Sound",
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          soundProfile['createdFrom'] as String,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: Colors.white.withAlpha(128),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildTag(soundProfile['dominantFrequency'] as String, AppColors.electricYellow),
            _buildTag(soundProfile['element'] as String, AppColors.cosmicPurple),
            _buildTag(soundProfile['sign'] as String, AppColors.hotPink),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Text(
        text,
        style: GoogleFonts.syne(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    final isDisabled = _isLoading || _sonification == null;
    
    return Container(
      decoration: BoxDecoration(
        gradient: _isPlaying || isDisabled
            ? null
            : const LinearGradient(colors: [AppColors.hotPink, AppColors.cosmicPurple]),
        color: _isPlaying ? AppColors.hotPink.withAlpha(51) : (isDisabled ? Colors.grey.withAlpha(51) : null),
        borderRadius: BorderRadius.circular(16),
        border: _isPlaying ? Border.all(color: AppColors.hotPink, width: 2) : null,
        boxShadow: _isPlaying || isDisabled
            ? null
            : [BoxShadow(color: AppColors.hotPink.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : _togglePlayback,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isLoading 
                      ? 'Loading Sound...' 
                      : (_isPlaying ? 'Pause Your Sound' : 'Play Your Sound'),
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysInfluence() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 32, offset: const Offset(0, 8))],
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.hotPink, width: 3)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cosmicPurple, AppColors.hotPink],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'AI INSIGHT',
                            style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_soundInterpretation != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.hotPink.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      todaysInfluence['shift'] as String,
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hotPink,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Personality section
            if (_isLoadingSoundInterpretation)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 200, decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 12),
                  Container(height: 12, width: 150, decoration: BoxDecoration(color: Colors.white.withAlpha(15), borderRadius: BorderRadius.circular(6))),
                ],
              )
            else if (_soundInterpretation != null) ...[
              Text(
                _soundInterpretation!.personality,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white.withAlpha(230),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.electricYellow.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.electricYellow.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.today_rounded, size: 16, color: AppColors.electricYellow),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _soundInterpretation!.todayInfluence,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppColors.electricYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Text(
                'Connecting to the cosmos...',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.white.withAlpha(128),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frequency Breakdown',
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _sonification == null ? null : _selectAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'All',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.electricYellow,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _sonification == null ? null : _deselectAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'None',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(128),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: frequencyBreakdown.map((item) => _buildFrequencyItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyItem(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final isSelected = _selectedPlanets.contains(item['planet']);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _togglePlanet(item['planet'] as String),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              // Checkbox indicator
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? item['color'] as Color : Colors.white.withAlpha(51),
                    width: 2,
                  ),
                  color: isSelected ? (item['color'] as Color).withAlpha(51) : null,
                ),
                child: isSelected 
                    ? Icon(Icons.check, size: 14, color: item['color'] as Color)
                    : null,
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: (item['color'] as Color).withAlpha(isSelected ? 26 : 10),
                  border: Border.all(color: (item['color'] as Color).withAlpha(isSelected ? 51 : 20)),
                ),
                child: Center(
                  child: Text(
                    item['symbol'] as String,
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w700, 
                      color: (item['color'] as Color).withAlpha(isSelected ? 255 : 128),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['planet'] as String,
                            style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'in ${item['sign']}',
                            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(102)),
                          ),
                        ],
                      ),
                      Text(
                        item['description'] as String,
                        style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128)),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['frequency'] as String,
                    style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: item['color'] as Color),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
