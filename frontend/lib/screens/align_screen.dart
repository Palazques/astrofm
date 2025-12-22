import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/inline_error.dart';
import '../widgets/attunement_widgets.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../models/alignment.dart';
import '../models/ai_responses.dart';
import '../models/birth_data.dart';
import '../models/attunement.dart';
import '../models/sonification.dart';
import '../models/prescription.dart';
import '../widgets/prescribe_tab.dart';
import '../data/test_users.dart';

/// Align screen for frequency alignment.
class AlignScreen extends StatefulWidget {
  const AlignScreen({super.key});

  @override
  State<AlignScreen> createState() => _AlignScreenState();
}

class _AlignScreenState extends State<AlignScreen> {
  final ApiService _apiService = ApiService();
  
  String _alignTarget = 'today';
  bool _isAligning = false;
  double _alignmentProgress = 0;
  int _resonanceScore = 0;
  int? _selectedFriendId;
  String? _dominantEnergy;
  String? _alignmentDescription;
  
  // AI Interpretation data
  AlignmentInterpretation? _aiInterpretation;
  List<String> _harmoniousAspects = [];
  
  // Transit data from API
  TransitsResult? _transitsData;
  bool _isLoadingTransits = false;
  String? _transitsError;
  
  // Transit AI interpretation
  TransitInterpretation? _transitInterpretation;
  bool _isLoadingTransitInterpretation = false;
  String? _transitInterpretationError;
  
  // Attunement data
  final AudioService _audioService = AudioService();
  AttunementAnalysis? _attunementData;
  bool _isLoadingAttunement = false;
  String? _attunementError;
  String _attunementMode = 'attune'; // 'attune' or 'amplify'
  String _attunementDuration = 'standard'; // 'quick', 'standard', 'meditate'
  Set<String> _selectedAttunementPlanets = {};
  bool _isPlayingAttunement = false;
  
  // Prescription data
  CosmicPrescription? _prescriptionData;
  bool _isLoadingPrescription = false;
  String? _prescriptionError;
  
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

  final friends = [
    {'id': 1, 'name': 'Maya', 'color1': AppColors.hotPink, 'color2': AppColors.cosmicPurple, 'compatibility': 87},
    {'id': 2, 'name': 'Jordan', 'color1': AppColors.electricYellow, 'color2': AppColors.hotPink, 'compatibility': 72},
    {'id': 3, 'name': 'Alex', 'color1': AppColors.cosmicPurple, 'color2': AppColors.teal, 'compatibility': 91},
    {'id': 4, 'name': 'Sam', 'color1': AppColors.teal, 'color2': AppColors.electricYellow, 'compatibility': 65},
  ];

  @override
  void initState() {
    super.initState();
    _loadBirthDataAndInit();
  }
  
  Future<void> _loadBirthDataAndInit() async {
    final stored = await storageService.loadBirthData();
    if (mounted) {
      setState(() => _birthData = stored);
    }
    
    // Also restore last selected friend
    final lastFriendId = await storageService.getLastSelectedFriendId();
    if (mounted && lastFriendId != null) {
      setState(() => _selectedFriendId = lastFriendId);
    }
    
    _loadTransits();
  }

  Future<void> _loadTransits() async {
    setState(() {
      _isLoadingTransits = true;
      _transitsError = null;
    });
    
    try {
      final result = await _apiService.getTransits();
      if (mounted) {
        setState(() {
          _transitsData = result;
          _isLoadingTransits = false;
        });
        // Load AI interpretation after transits are loaded
        _loadTransitInterpretation();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _transitsError = e.toString();
          _isLoadingTransits = false;
        });
      }
    }
  }

  Future<void> _loadTransitInterpretation() async {
    setState(() {
      _isLoadingTransitInterpretation = true;
      _transitInterpretationError = null;
    });
    
    try {
      final result = await _apiService.getTransitInterpretation();
      if (mounted) {
        setState(() {
          _transitInterpretation = result;
          _isLoadingTransitInterpretation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _transitInterpretationError = e.toString();
          _isLoadingTransitInterpretation = false;
        });
      }
    }
  }

  Future<void> _loadPrescription() async {
    setState(() {
      _isLoadingPrescription = true;
      _prescriptionError = null;
    });
    
    try {
      final result = await _apiService.getCosmicPrescription(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String,
      );
      if (mounted) {
        setState(() {
          _prescriptionData = result;
          _isLoadingPrescription = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _prescriptionError = e.toString();
          _isLoadingPrescription = false;
        });
      }
    }
  }

  void _startAlignment() {
    setState(() {
      _isAligning = true;
      _alignmentProgress = 0;
      _resonanceScore = 0;
    });

    _runAlignment();
  }

  Future<void> _runAlignment() async {
    // Start cosmetic progress animation
    _animateProgress();
    
    try {
      if (_alignTarget == 'today') {
        // Make parallel API calls for alignment score AND AI interpretation
        final results = await Future.wait([
          _apiService.getDailyAlignment(
            datetime: _birthDataMap['datetime'] as String,
            latitude: _birthDataMap['latitude'] as double,
            longitude: _birthDataMap['longitude'] as double,
            timezone: _birthDataMap['timezone'] as String,
          ),
          _apiService.getAlignmentInterpretation(
            userDatetime: _birthDataMap['datetime'] as String,
            userLatitude: _birthDataMap['latitude'] as double,
            userLongitude: _birthDataMap['longitude'] as double,
            // No target params = align with today's transits
          ),
        ]);
        
        final alignResult = results[0] as AlignmentResult;
        final aiResult = results[1] as AlignmentInterpretation;
        
        if (mounted) {
          setState(() {
            _alignmentProgress = 1.0;
            _resonanceScore = alignResult.score;
            _dominantEnergy = alignResult.dominantEnergy;
            // Use AI-generated interpretation instead of basic description
            _alignmentDescription = aiResult.interpretation;
            _aiInterpretation = aiResult;
            _harmoniousAspects = aiResult.harmoniousAspects;
          });
        }
      } else if (_alignTarget == 'friend' && _selectedFriendId != null) {
        // Get friend data for API call
        final friend = testFriends.firstWhere(
          (f) => f.id == _selectedFriendId,
          orElse: () => testFriends.first,
        );
        
        // Call AI interpretation with friend's birth data
        final aiResult = await _apiService.getAlignmentInterpretation(
          userDatetime: _birthDataMap['datetime'] as String,
          userLatitude: _birthDataMap['latitude'] as double,
          userLongitude: _birthDataMap['longitude'] as double,
          targetDatetime: friend.birthDatetime ?? '1992-03-21T14:30:00',
          targetLatitude: friend.birthLatitude ?? 40.7128,
          targetLongitude: friend.birthLongitude ?? -74.0060,
        );
        
        if (mounted) {
          setState(() {
            _alignmentProgress = 1.0;
            _resonanceScore = aiResult.resonanceScore;
            _dominantEnergy = aiResult.isHarmonious ? 'Harmonious' : 'Dynamic';
            _alignmentDescription = aiResult.interpretation;
            _aiInterpretation = aiResult;
            _harmoniousAspects = aiResult.harmoniousAspects;
          });
        }
      } else {
        // Transit alignment - call AI with no target (uses today's transits)
        final aiResult = await _apiService.getAlignmentInterpretation(
          userDatetime: _birthDataMap['datetime'] as String,
          userLatitude: _birthDataMap['latitude'] as double,
          userLongitude: _birthDataMap['longitude'] as double,
        );
        
        if (mounted) {
          setState(() {
            _alignmentProgress = 1.0;
            _resonanceScore = aiResult.resonanceScore;
            _dominantEnergy = 'Cosmic';
            _alignmentDescription = aiResult.interpretation;
            _aiInterpretation = aiResult;
            _harmoniousAspects = aiResult.harmoniousAspects;
          });
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alignment failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade900,
          ),
        );
        setState(() {
          _alignmentProgress = 0;
          _resonanceScore = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAligning = false);
      }
    }
  }

  Future<void> _animateProgress() async {
    // Cosmetic animation while API loads
    for (int i = 0; i <= 85; i += 3) {
      if (!_isAligning || !mounted) break;
      await Future.delayed(const Duration(milliseconds: 40));
      setState(() => _alignmentProgress = i / 100);
    }
  }

  void _resetAlignment() {
    setState(() {
      _alignmentProgress = 0;
      _resonanceScore = 0;
      _isAligning = false;
      _dominantEnergy = null;
      _alignmentDescription = null;
      _aiInterpretation = null;
      _harmoniousAspects = [];
    });
  }

  void _playBlend() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎵 Audio blend coming soon!'),
        backgroundColor: AppColors.cosmicPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveMoment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMoments = prefs.getStringList('saved_moments') ?? [];
      savedMoments.add(jsonEncode({
        'date': DateTime.now().toIso8601String(),
        'score': _resonanceScore,
        'target': _alignTarget,
        'targetName': _getTargetLabel(),
        'dominantEnergy': _dominantEnergy,
      }));
      await prefs.setStringList('saved_moments', savedMoments);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Moment saved!'),
            backgroundColor: AppColors.electricYellow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadAttunementData() async {
    if (_attunementData != null || _isLoadingAttunement) return;
    
    setState(() {
      _isLoadingAttunement = true;
      _attunementError = null;
    });
    
    try {
      final result = await _apiService.getAttunementAnalysis(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String? ?? 'UTC',
      );
      if (mounted) {
        setState(() {
          _attunementData = result;
          _isLoadingAttunement = false;
          // Auto-select the primary gap or resonance
          if (result.hasGaps) {
            _selectedAttunementPlanets = {result.primaryGap!.planet};
            _attunementMode = 'attune';
          } else if (result.hasResonances) {
            _selectedAttunementPlanets = {result.primaryResonance!.planet};
            _attunementMode = 'amplify';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _attunementError = e.toString();
          _isLoadingAttunement = false;
        });
      }
    }
  }

  void _togglePlanetSelection(String planet) {
    setState(() {
      if (_selectedAttunementPlanets.contains(planet)) {
        _selectedAttunementPlanets.remove(planet);
      } else {
        _selectedAttunementPlanets.add(planet);
      }
    });
  }

  Future<void> _playAttunement() async {
    if (_selectedAttunementPlanets.isEmpty || _attunementData == null) return;
    
    // If already playing, stop instead
    if (_isPlayingAttunement) {
      _stopAttunement();
      return;
    }
    
    setState(() => _isPlayingAttunement = true);
    
    // Determine duration in seconds
    final durationSeconds = switch (_attunementDuration) {
      'quick' => 60.0,    // 1 minute
      'standard' => 180.0, // 3 minutes
      'meditate' => 600.0, // 10 minutes for meditate
      _ => 180.0,
    };
    
    // Get the selected planet data
    final selectedPlanets = _attunementData!.planets
        .where((p) => _selectedAttunementPlanets.contains(p.planet))
        .toList();
    
    if (selectedPlanets.isNotEmpty) {
      final attunementPlanet = selectedPlanets.first;
      
      // Choose frequency based on mode
      final frequency = _attunementMode == 'attune' 
          ? attunementPlanet.transitFrequency 
          : attunementPlanet.natalFrequency;
      
      // Choose intensity based on mode
      final intensity = _attunementMode == 'attune'
          ? attunementPlanet.transitIntensity
          : attunementPlanet.natalIntensity;
      
      // Create a PlanetSound from the attunement data
      final planetSound = PlanetSound(
        planet: attunementPlanet.planet,
        frequency: frequency,
        intensity: intensity,
        role: 'carrier', // Default role for attunement
        filterType: 'lowpass',
        filterCutoff: 2000.0,
        attack: 0.5,
        decay: 0.3,
        reverb: 0.5,
        pan: 0.0, // Center
        house: _attunementMode == 'attune' 
            ? attunementPlanet.transitHouse 
            : attunementPlanet.natalHouse,
        houseDegree: 15.0, // Middle of house
        sign: _attunementMode == 'attune'
            ? attunementPlanet.transitSign
            : attunementPlanet.natalSign,
      );
      
      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔊 Playing ${attunementPlanet.planet} at ${frequency.toStringAsFixed(1)} Hz'),
            backgroundColor: _attunementMode == 'attune' 
                ? const Color(0xFFFF6B6B) 
                : const Color(0xFF4ECDC4),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Start playing (don't await - it will set up timer and return immediately)
      // We leave _isPlayingAttunement = true until user stops or audio finishes
      _audioService.playSinglePlanet(planetSound, duration: durationSeconds);
      
      // Listen for audio completion to reset state
      _audioService.playingStream.listen((isPlaying) {
        if (!isPlaying && mounted && _isPlayingAttunement) {
          setState(() => _isPlayingAttunement = false);
        }
      });
    }
  }

  void _stopAttunement() {
    _audioService.stop();
    setState(() => _isPlayingAttunement = false);
  }

  void _showModeUnavailableDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E),
                color.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: Colors.white.withAlpha(179),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Got it!',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _apiService.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppHeader(
              showBackButton: true,
              showMenuButton: false,
              showSettingsButton: true,
              title: 'Align',
            ),
            const SizedBox(height: 16),

            // Alignment Visualization
            _buildAlignmentVisualization(),
            const SizedBox(height: 24),

            // Resonance Result
            if (_resonanceScore > 0) ...[
              _buildResonanceResult(),
              const SizedBox(height: 24),
            ],

            // Target Selection Tabs
            _buildTargetTabs(),
            const SizedBox(height: 16),

            // Target Content
            _buildTargetContent(),
            const SizedBox(height: 24),

            // Align Button
            _buildAlignButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignmentVisualization() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Your Sound Orb
        Column(
          children: [
            SoundOrb(
              size: 120,
              colors: const [AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal],
              animate: _isAligning,
            ),
            const SizedBox(height: 12),
            Text(
              'YOUR SOUND',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
          ],
        ),

        const SizedBox(width: 20),

        // Connection Indicator
        _resonanceScore > 0
            ? _buildCircularScore(_resonanceScore)
            : SizedBox(
                width: 80,
                height: 4,
                child: LinearProgressIndicator(
                  value: _alignmentProgress,
                  backgroundColor: Colors.white.withAlpha(26),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

        const SizedBox(width: 20),

        // Target Sound Orb
        Column(
          children: [
            SoundOrb(
              size: 120,
              colors: _getTargetColors(),
              animate: _isAligning,
            ),
            const SizedBox(height: 12),
            Text(
              _getTargetLabel().toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularScore(int score) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white.withAlpha(26),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
            strokeWidth: 4,
          ),
          Center(
            child: Text(
              '$score%',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.electricYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getTargetColors() {
    if (_alignTarget == 'today') {
      return [AppColors.electricYellow, AppColors.hotPink, AppColors.cosmicPurple];
    } else if (_alignTarget == 'friend' && _selectedFriendId != null) {
      final friend = friends.firstWhere((f) => f['id'] == _selectedFriendId);
      return [friend['color1'] as Color, friend['color2'] as Color];
    }
    return [AppColors.cosmicPurple, AppColors.hotPink, AppColors.electricYellow];
  }

  String _getTargetLabel() {
    if (_alignTarget == 'today') return "Today's Sound";
    if (_alignTarget == 'friend' && _selectedFriendId != null) {
      final friend = friends.firstWhere((f) => f['id'] == _selectedFriendId);
      return friend['name'] as String;
    }
    return 'Select Target';
  }

  Widget _buildResonanceResult() {
    return GlassCard(
      child: Column(
        children: [
          // AI Badge
          if (_aiInterpretation != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.cosmicPurple, AppColors.hotPink],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'AI ANALYSIS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          Text(
            'Your frequencies are',
            style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(153)),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.electricYellow, AppColors.hotPink],
            ).createShader(bounds),
            child: Text(
              '$_resonanceScore% Aligned',
              style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          if (_dominantEnergy != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.electricYellow.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.electricYellow.withAlpha(51)),
              ),
              child: Text(
                _dominantEnergy!,
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricYellow,
                ),
              ),
            ),
          ],
          
          // Harmonious Aspects Pills
          if (_harmoniousAspects.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _harmoniousAspects.map((aspect) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cosmicPurple.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cosmicPurple.withAlpha(51)),
                ),
                child: Text(
                  aspect,
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.cosmicPurple),
                ),
              )).toList(),
            ),
          ],
          
          if (_alignmentDescription != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.hotPink, width: 3),
                ),
              ),
              child: Text(
                _alignmentDescription!,
                textAlign: TextAlign.left,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.white.withAlpha(179),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ResultButton(
                  label: 'Play Blend',
                  icon: Icons.play_arrow_rounded,
                  outlined: true,
                  onPressed: _playBlend,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultButton(
                  label: 'Save Moment',
                  icon: Icons.save_rounded,
                  onPressed: _saveMoment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetTabs() {
    return GlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _TabButton(label: 'Today', isActive: _alignTarget == 'today', onPressed: () {
            setState(() { _alignTarget = 'today'; _resetAlignment(); });
          }),
          _TabButton(label: 'Friend', isActive: _alignTarget == 'friend', onPressed: () {
            setState(() { _alignTarget = 'friend'; _resetAlignment(); });
          }),
          _TabButton(label: 'Transit', isActive: _alignTarget == 'transit', onPressed: () {
            setState(() { _alignTarget = 'transit'; _resetAlignment(); });
          }),
          _TabButton(label: 'Attune', isActive: _alignTarget == 'attune', onPressed: () {
            setState(() { _alignTarget = 'attune'; _resetAlignment(); });
            _loadAttunementData();
          }),
        ],
      ),
    );
  }

  Widget _buildTargetContent() {
    if (_alignTarget == 'today') return _buildTodayContent();
    if (_alignTarget == 'friend') return _buildFriendContent();
    if (_alignTarget == 'attune') return _buildAttuneContent();
    return _buildTransitContent();
  }

  Widget _buildTodayContent() {
    // Calculate current date and zodiac season
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    final formattedDate = '${months[now.month - 1]} ${now.day}, ${now.year}';
    final zodiacSeason = _getCurrentZodiacSeason();
    
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.electricYellow, AppColors.hotPink]),
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: AppColors.background, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Cosmic Sound", style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('$formattedDate • $zodiacSeason Season', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(128))),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Get the current zodiac season name based on today's date
  String _getCurrentZodiacSeason() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces'; // Feb 19 - Mar 20
  }

  Widget _buildFriendContent() {
    return Column(
      children: friends.map((friend) => _buildFriendItem(friend)).toList(),
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend) {
    final isSelected = _selectedFriendId == friend['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderColor: isSelected ? AppColors.electricYellow.withAlpha(77) : null,
        backgroundColor: isSelected ? AppColors.electricYellow.withAlpha(26) : null,
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => setState(() { _selectedFriendId = friend['id'] as int; _resetAlignment(); }),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [friend['color1'] as Color, friend['color2'] as Color]),
                ),
                child: Center(child: Text((friend['name'] as String)[0], style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend['name'] as String, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('${friend['compatibility']}% compatible', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(128))),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.electricYellow : Colors.white.withAlpha(26),
                ),
                child: Icon(Icons.check_rounded, size: 16, color: isSelected ? AppColors.background : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransitContent() {
    // Show skeleton while loading
    if (_isLoadingTransits) {
      return Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SkeletonCard(height: 70),
        )),
      );
    }
    
    // Show error state
    if (_transitsError != null) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: InlineError(
          message: 'Could not load transits',
          onRetry: _loadTransits,
        ),
      );
    }
    
    // Show transit data
    if (_transitsData == null || _transitsData!.planets.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Text('No transit data available', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(128))),
      );
    }
    
    // Build transit list from real API data
    return Column(
      children: [
        // AI Cosmic Weather Insight
        _buildTransitInsightCard(),
        const SizedBox(height: 12),
        
        // Moon phase card
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.electricYellow.withAlpha(51),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [AppColors.electricYellow, AppColors.hotPink]),
                  ),
                  child: const Icon(Icons.nights_stay_rounded, color: AppColors.background, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Moon Phase', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128), letterSpacing: 1)),
                      Text(_transitsData!.moonPhase, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Planet positions
        ...(_transitsData!.planets.take(6).map((planet) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]),
                  ),
                  child: Center(
                    child: Text(
                      _getPlanetSymbol(planet.name),
                      style: const TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planet.name, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('${planet.sign} ${planet.degree.toStringAsFixed(1)}°', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(128))),
                    ],
                  ),
                ),
                if (_transitsData!.isRetrograde(planet.name))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.hotPink.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('℞ Rx', style: GoogleFonts.syne(fontSize: 11, color: AppColors.hotPink)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Direct', style: GoogleFonts.syne(fontSize: 11, color: AppColors.teal)),
                  ),
              ],
            ),
          ),
        ))),
      ],
    );
  }
  
  String _getPlanetSymbol(String name) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mercury': '☿',
      'Venus': '♀',
      'Mars': '♂',
      'Jupiter': '♃',
      'Saturn': '♄',
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
    };
    return symbols[name] ?? '✦';
  }

  Widget _buildAttuneContent() {
    // Loading state
    if (_isLoadingAttunement) {
      return Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SkeletonCard(height: 100),
        )),
      );
    }
    
    // Error state
    if (_attunementError != null) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: InlineError(
          message: 'Could not load attunement data',
          onRetry: _loadAttunementData,
        ),
      );
    }
    
    // Not loaded yet
    if (_attunementData == null) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.tune, size: 48, color: Colors.white.withAlpha(128)),
            const SizedBox(height: 12),
            Text(
              'Tap above to analyze your cosmic attunement',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.white.withAlpha(153),
              ),
            ),
          ],
        ),
      );
    }
    
    // Attunement content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Alignment Dashboard
        AlignmentDashboardCard(
          alignmentScore: _attunementData!.alignmentScore,
          gapCount: _attunementData!.gaps.length,
          resonanceCount: _attunementData!.resonances.length,
          dominantEnergy: _attunementData!.dominantGapEnergy,
        ),
        const SizedBox(height: 16),
        
        // Mode Selector (Attune vs Amplify)
        AttunementModeSelector(
          selectedMode: _attunementMode,
          onModeChanged: (mode) {
            setState(() => _attunementMode = mode);
            // Load prescription when switching to prescribe mode
            if (mode == 'prescribe' && _prescriptionData == null && !_isLoadingPrescription) {
              _loadPrescription();
            }
          },
          hasGaps: _attunementData!.hasGaps,
          hasResonances: _attunementData!.hasResonances,
          onAttuneUnavailable: () => _showModeUnavailableDialog(
            title: 'Perfect Harmony! ✨',
            message: "You're in perfect cosmic alignment today! "
                "There are no gaps between your natal energy and today's transits. "
                "This means your natural frequencies are already flowing smoothly with the universe. "
                "No attunement needed — just enjoy the harmony!",
            icon: Icons.check_circle,
            color: const Color(0xFF4ECDC4),
          ),
          onAmplifyUnavailable: () => _showModeUnavailableDialog(
            title: 'Cosmic Alignment Mode 🌟',
            message: "Today your natal chart and cosmic transits are working independently. "
                "There are gaps to bridge, but no strong resonances to amplify yet. "
                "Focus on \"Attune\" mode to balance your energy with today's cosmos. "
                "Resonances appear when your natal placements naturally align with current transits!",
            icon: Icons.auto_awesome,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 16),
        
        // Show different content based on mode
        if (_attunementMode == 'prescribe') ...[  
          // Prescribe Tab Content
          PrescribeTab(
            prescription: _prescriptionData,
            isLoading: _isLoadingPrescription,
            error: _prescriptionError,
            audioService: _audioService,
            onRetry: _loadPrescription,
          ),
        ] else ...[
          // Duration Selector (for Attune/Amplify only)
          AttunementDurationSelector(
            selectedDuration: _attunementDuration,
            onDurationChanged: (duration) => setState(() => _attunementDuration = duration),
          ),
          const SizedBox(height: 16),
          
          // Planet Cards
          if (_attunementMode == 'attune' && _attunementData!.hasGaps) ...[
            Text(
              'GAPS TO ATTUNE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            ...(_attunementData!.gaps.map((planet) => AttunementPlanetCard(
              planet: planet,
              isSelected: _selectedAttunementPlanets.contains(planet.planet),
              onTap: () => _togglePlanetSelection(planet.planet),
            ))),
          ],
          
          if (_attunementMode == 'amplify' && _attunementData!.hasResonances) ...[
            Text(
              'RESONANCES TO AMPLIFY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            ...(_attunementData!.resonances.map((planet) => AttunementPlanetCard(
              planet: planet,
              isSelected: _selectedAttunementPlanets.contains(planet.planet),
              onTap: () => _togglePlanetSelection(planet.planet),
            ))),
          ],
          
          // No gaps/resonances message
          if ((_attunementMode == 'attune' && !_attunementData!.hasGaps) ||
              (_attunementMode == 'amplify' && !_attunementData!.hasResonances))
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _attunementMode == 'attune' ? Icons.check_circle : Icons.star,
                    size: 36,
                    color: const Color(0xFF4ECDC4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _attunementMode == 'attune'
                        ? "You're in perfect alignment today!"
                        : "No strong resonances detected today",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Play/Stop Button
          if (_selectedAttunementPlanets.isNotEmpty)
            GestureDetector(
              onTap: _isPlayingAttunement ? _stopAttunement : _playAttunement,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _attunementMode == 'attune'
                        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                        : [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPlayingAttunement ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPlayingAttunement
                          ? 'Stop'
                          : '${_attunementMode == 'attune' ? 'Attune' : 'Amplify'} Now',
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
        ], // End of Attune/Amplify content (else block)
      ],
    );
  }

  /// Build the AI cosmic weather insight card for transits
  Widget _buildTransitInsightCard() {
    // Loading state
    if (_isLoadingTransitInterpretation) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.cosmicPurple.withAlpha(51),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'INSIGHT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Shimmer lines
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_transitInterpretationError != null) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: _loadTransitInterpretation,
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Could not load cosmic weather. Tap to retry.',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(179)),
                ),
              ),
              const Icon(Icons.refresh, color: AppColors.red, size: 20),
            ],
          ),
        ),
      );
    }

    // Success state
    if (_transitInterpretation == null) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.cosmicPurple.withAlpha(51),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with AI badge and energy tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      'COSMIC WEATHER',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.electricYellow.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.electricYellow.withAlpha(51)),
                ),
                child: Text(
                  _transitInterpretation!.energyDescription,
                  style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.electricYellow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Interpretation text
          Text(
            _transitInterpretation!.interpretation,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              height: 1.6,
              color: Colors.white.withAlpha(230),
            ),
          ),
          const SizedBox(height: 12),
          
          // Highlight planet
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(color: AppColors.hotPink, width: 3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _getPlanetSymbol(_transitInterpretation!.highlightPlanet),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_transitInterpretation!.highlightPlanet} Highlight',
                        style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.hotPink),
                      ),
                      Text(
                        _transitInterpretation!.highlightReason,
                        style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(153)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Retrograde warning if any
          if (_transitInterpretation!.retrogradePlanets.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _transitInterpretation!.retrogradePlanets.map((planet) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.hotPink.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '℞ $planet Rx',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.hotPink),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlignButton() {
    final canAlign = !_isAligning && (_alignTarget != 'friend' || _selectedFriendId != null);
    return Container(
      decoration: BoxDecoration(
        gradient: canAlign ? const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]) : null,
        color: canAlign ? null : Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        boxShadow: canAlign ? [BoxShadow(color: AppColors.cosmicPurple.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAlign ? _startAlignment : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isAligning)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                else
                  Icon(_resonanceScore > 0 ? Icons.refresh_rounded : Icons.access_time_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  _isAligning ? 'Aligning Frequencies...' : (_resonanceScore > 0 ? 'Align Again' : 'Begin Alignment'),
                  style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _TabButton({required this.label, required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isActive ? Colors.white.withAlpha(26) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppColors.electricYellow : Colors.white.withAlpha(128)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback onPressed;

  const _ResultButton({required this.label, required this.icon, this.outlined = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: outlined ? null : const LinearGradient(colors: [AppColors.electricYellow, Color(0xFFE5EB0D)]),
        color: outlined ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(12),
        border: outlined ? Border.all(color: Colors.white.withAlpha(51)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: outlined ? Colors.white : AppColors.background),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: outlined ? Colors.white : AppColors.background)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
