import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/inline_error.dart';
import '../widgets/attunement_widgets.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../models/birth_data.dart';
import '../models/attunement.dart';
import '../models/prescription.dart';
import '../models/sonification.dart';
import '../widgets/prescribe_tab.dart';
import '../data/test_users.dart';

/// Align screen for frequency attunement.
class AlignScreen extends StatefulWidget {
  const AlignScreen({super.key});

  @override
  State<AlignScreen> createState() => _AlignScreenState();
}

class _AlignScreenState extends State<AlignScreen> {
  final ApiService _apiService = ApiService();
  final AudioService _audioService = AudioService();
  
  // Attunement data
  AttunementAnalysis? _attunementData;
  bool _isLoadingAttunement = false;
  String? _attunementError;
  String _attunementMode = 'attune'; // 'attune', 'amplify', or 'prescribe'
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
    
    // Auto-load attunement data on page load
    _loadAttunementData();
  }

  Future<void> _loadAttunementData() async {
    if (_isLoadingAttunement) return;
    
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
      
      // Start playing
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
                color.withAlpha(38),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withAlpha(77)),
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
                    gradient: LinearGradient(colors: [color, color.withAlpha(179)]),
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
              showBackButton: false,
              showMenuButton: false,
              showSettingsButton: true,
              title: 'Align',
            ),
            const SizedBox(height: 16),

            // Alignment Dashboard Card at the top
            _buildAlignmentDashboard(),
            const SizedBox(height: 24),

            // Attunement Content
            _buildAttuneContent(),
          ],
        ),
      ),
    );
  }

  /// Build the cosmic alignment dashboard card at the top of the page.
  Widget _buildAlignmentDashboard() {
    // Loading state
    if (_isLoadingAttunement) {
      return SkeletonCard(height: 180);
    }
    
    // Error state
    if (_attunementError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.red.withAlpha(77)),
        ),
        child: InlineError(
          message: 'Could not load alignment data',
          onRetry: _loadAttunementData,
        ),
      );
    }
    
    // No data yet
    if (_attunementData == null) {
      return SkeletonCard(height: 180);
    }
    
    // Show the dashboard card
    return AlignmentDashboardCard(
      alignmentScore: _attunementData!.alignmentScore,
      gapCount: _attunementData!.gaps.length,
      resonanceCount: _attunementData!.resonances.length,
      dominantEnergy: _attunementData!.dominantGapEnergy,
      backgroundImage: 'assets/images/card_backgrounds/alignment_dashboard_bg.png',
    );
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
      return const SizedBox.shrink(); // Error shown in dashboard
    }
    
    // Not loaded yet
    if (_attunementData == null) {
      return const SizedBox.shrink();
    }
    
    // Attunement content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Selector (Attune vs Amplify vs Prescribe)
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(16),
              ),
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
}
