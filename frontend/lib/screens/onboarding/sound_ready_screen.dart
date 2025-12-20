import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/onboarding_data.dart';
import '../../models/ai_responses.dart';
import '../../services/api_service.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/shimmer_text.dart';
import '../../widgets/onboarding/orbital_ring.dart';
import '../../widgets/glass_card.dart';

/// Screen 10: Sound ready - completion celebration with waveform orb.
class SoundReadyScreen extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onComplete;

  const SoundReadyScreen({
    super.key,
    required this.data,
    required this.onComplete,
  });

  @override
  State<SoundReadyScreen> createState() => _SoundReadyScreenState();
}

class _SoundReadyScreenState extends State<SoundReadyScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late AnimationController _statsController;
  late AnimationController _waveformController;
  late AnimationController _celebrationController;
  late Animation<double> _fadeIn;

  bool _isCalculating = false;
  String? _error;

  // AI Welcome Message
  WelcomeMessage? _welcomeMessage;
  bool _isLoadingWelcome = false;

  // Natal chart data for dynamic stats
  String _sunSign = '...';
  String _element = '...';
  int _genreCount = 0;
  bool _isLoadingChart = true;

  // Waveform bar heights
  final _barHeights = [0.4, 0.7, 0.5, 1.0, 0.8, 0.6, 0.9, 0.5, 0.7, 0.4, 0.8, 0.6];

  // Dynamic stats based on user data
  List<Map<String, dynamic>> get _soundStats => [
    {'label': 'Sun Sign', 'value': _sunSign, 'color': AppColors.electricYellow, 'icon': Icons.wb_sunny_outlined},
    {'label': 'Element', 'value': _element, 'color': AppColors.hotPink, 'icon': Icons.auto_awesome},
    {'label': 'Genres', 'value': '$_genreCount', 'color': AppColors.teal, 'icon': Icons.library_music_outlined},
  ];

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _contentController.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _statsController.forward());
    
    // Load user-specific data
    _loadUserData();
    _loadWelcomeMessage();
  }

  /// Load natal chart and calculate dynamic stats
  Future<void> _loadUserData() async {
    if (widget.data.formattedBirthDatetime == null || widget.data.birthLocation == null) {
      setState(() => _isLoadingChart = false);
      return;
    }

    try {
      final apiService = ApiService();
      final chart = await apiService.calculateNatalChart(
        datetime: widget.data.formattedBirthDatetime!,
        latitude: widget.data.birthLocation!.latitude,
        longitude: widget.data.birthLocation!.longitude,
        timezone: 'UTC',
      );
      apiService.dispose();

      if (mounted) {
        // Find sun sign from planets
        String sunSign = 'Cosmic';
        for (final planet in chart.planets) {
          if (planet.name == 'Sun') {
            sunSign = planet.sign;
            break;
          }
        }

        // Determine dominant element based on sun sign
        final elementMap = {
          'Aries': 'Fire', 'Leo': 'Fire', 'Sagittarius': 'Fire',
          'Taurus': 'Earth', 'Virgo': 'Earth', 'Capricorn': 'Earth',
          'Gemini': 'Air', 'Libra': 'Air', 'Aquarius': 'Air',
          'Cancer': 'Water', 'Scorpio': 'Water', 'Pisces': 'Water',
        };
        final element = elementMap[sunSign] ?? 'Cosmic';

        // Get genre count from user selections
        final genreCount = widget.data.favoriteGenres.length + widget.data.favoriteSubgenres.length;

        setState(() {
          _sunSign = sunSign;
          _element = element;
          _genreCount = genreCount > 0 ? genreCount : 3;
          _isLoadingChart = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingChart = false);
      }
    }
  }

  Future<void> _loadWelcomeMessage() async {
    if (widget.data.formattedBirthDatetime == null || widget.data.birthLocation == null) return;

    setState(() => _isLoadingWelcome = true);

    try {
      final apiService = ApiService();
      final message = await apiService.getWelcomeMessage(
        datetime: widget.data.formattedBirthDatetime!,
        latitude: widget.data.birthLocation!.latitude,
        longitude: widget.data.birthLocation!.longitude,
      );
      apiService.dispose();

      if (mounted) {
        setState(() {
          _welcomeMessage = message;
          _isLoadingWelcome = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWelcome = false);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _statsController.dispose();
    _waveformController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _calculateAndComplete() async {
    if (!widget.data.isMinimumComplete) {
      setState(() => _error = 'Missing required birth data');
      return;
    }

    setState(() {
      _isCalculating = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      await apiService.calculateNatalChart(
        datetime: widget.data.formattedBirthDatetime!,
        latitude: widget.data.birthLocation!.latitude,
        longitude: widget.data.birthLocation!.longitude,
        timezone: 'UTC',
      );
      apiService.dispose();

      if (mounted) {
        setState(() => _isCalculating = false);
        await Future.delayed(const Duration(milliseconds: 300));
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection error. Please try again.';
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.data.displayName ?? 'Cosmic Being';

    return OnboardingScaffold(
      step: 10,
      showBack: false,
      child: Stack(
        children: [
          // Floating star particles
          ..._buildStarParticles(),

          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Orb with waveform and orbital rings
                FadeTransition(
                  opacity: _fadeIn,
                  child: MultiOrbitalRings(
                    size: 160,
                    child: _buildWaveformOrb(),
                  ),
                ),
                const SizedBox(height: 32),

                // Shimmer title
                FadeTransition(
                  opacity: _fadeIn,
                  child: const ShimmerText(
                    text: 'Your Sound is Ready!',
                    fontSize: 28,
                    colors: [AppColors.teal, AppColors.electricYellow, AppColors.hotPink],
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    'A unique cosmic frequency crafted just for you, $userName',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.white.withAlpha(128),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Stats cards
                _buildStatsRow(),
                const SizedBox(height: 24),

                // Celebration card
                _buildCelebrationCard(),
                const SizedBox(height: 32),

                // Error display
                if (_error != null) _buildErrorCard(),

                // Play button
                FadeTransition(
                  opacity: _fadeIn,
                  child: OnboardingCta(
                    label: 'Play My Sound',
                    icon: Icons.play_circle_filled,
                    isLoading: _isCalculating,
                    onPressed: _calculateAndComplete,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformOrb() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.teal, AppColors.cosmicPurple, AppColors.hotPink, AppColors.electricYellow],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.hotPink.withAlpha(102),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _waveformController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_barHeights.length, (i) {
                final phase = i * 0.3;
                final animValue = math.sin((_waveformController.value * 2 * math.pi) + phase);
                final scale = 0.5 + (0.5 * animValue.abs());
                final height = _barHeights[i] * 50 * scale;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 5,
                  height: height.clamp(10.0, 50.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_soundStats.length, (index) {
        final stat = _soundStats[index];
        final delay = index * 0.15;

        return AnimatedBuilder(
          animation: _statsController,
          builder: (context, child) {
            final progress = ((_statsController.value - delay) / 0.5).clamp(0.0, 1.0);
            return Transform.scale(
              scale: 0.5 + (0.5 * Curves.elasticOut.transform(progress)),
              child: Opacity(
                opacity: progress,
                child: _buildStatCard(stat),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final color = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(stat['icon'] as IconData, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            stat['value'] as String,
            style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            (stat['label'] as String).toUpperCase(),
            style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.white.withAlpha(102), letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationCard() {
    return FadeTransition(
      opacity: _fadeIn,
      child: GlassCard(
        child: Column(
          children: [
            // Animated stars
            AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.9 + (0.1 * _celebrationController.value),
                      child: const Icon(Icons.star, color: AppColors.electricYellow, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Transform.scale(
                      scale: 1.0 + (0.1 * (1 - _celebrationController.value)),
                      child: const Icon(Icons.star, color: AppColors.hotPink, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Transform.scale(
                      scale: 0.9 + (0.1 * _celebrationController.value),
                      child: const Icon(Icons.star, color: AppColors.cosmicPurple, size: 28),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            if (_isLoadingWelcome)
              Column(
                children: [
                  Container(height: 24, width: 200, decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 12),
                  Container(height: 14, width: 280, decoration: BoxDecoration(color: Colors.white.withAlpha(15), borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 200, decoration: BoxDecoration(color: Colors.white.withAlpha(15), borderRadius: BorderRadius.circular(4))),
                ],
              )
            else if (_welcomeMessage != null)
              Column(
                children: [
                  Text(
                    _welcomeMessage!.greeting,
                    style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _welcomeMessage!.personality,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(200), height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.hotPink.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.hotPink.withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.hotPink),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _welcomeMessage!.soundTeaser,
                            style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.hotPink),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    'Welcome to Astro.FM',
                    style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your cosmic journey begins now.\nTap below to hear your unique sound signature.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(128), height: 1.5),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.red.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.red.withAlpha(77)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(_error!, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.red))),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStarParticles() {
    final random = math.Random(42);
    return List.generate(12, (i) {
      final colors = [AppColors.electricYellow, AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal];
      return Positioned(
        top: 50 + random.nextDouble() * 400,
        left: 20 + random.nextDouble() * (MediaQuery.of(context).size.width - 40),
        child: AnimatedBuilder(
          animation: _celebrationController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 + (0.3 * _celebrationController.value),
              child: Container(
                width: 4 + random.nextDouble() * 4,
                height: 4 + random.nextDouble() * 4,
                decoration: BoxDecoration(
                  color: colors[i % 4],
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
