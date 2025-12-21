import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/sound_orb.dart';
import '../services/auth_service.dart';
import '../services/app_startup_service.dart';

/// Welcome back screen with animated loader and background preloading.
/// Displays for a minimum of 5 seconds while loading app data.
class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<double> _pulse;

  String _statusText = 'Connecting to the cosmos...';
  bool _loadingComplete = false;
  bool _timerComplete = false;
  StartupResult? _startupResult;

  static const Duration _minimumDisplayTime = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startLoading();
  }

  void _setupAnimations() {
    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Pulsing animation for the orb
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  void _startLoading() async {
    // Start timer and loading in parallel
    final timerFuture = Future.delayed(_minimumDisplayTime);
    final loadingFuture = _loadAppData();

    // Both must complete before navigating
    await Future.wait([timerFuture, loadingFuture]);

    // Navigate to home
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _loadAppData() async {
    // Update status as loading progresses
    _updateStatus('Loading your profile...');
    await Future.delayed(const Duration(milliseconds: 800));

    _updateStatus('Checking music connections...');
    await Future.delayed(const Duration(milliseconds: 600));

    // Actually start the background loading
    _startupResult = await appStartupService.preloadAppData();

    _updateStatus('Preparing your cosmic experience...');
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() => _loadingComplete = true);
    _updateStatus('Ready!');
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() => _statusText = status);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = authService.currentUserDisplayName ?? 'Star Child';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated pulsing orb
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulse.value,
                        child: const SoundOrb(
                          size: 160,
                          colors: [
                            AppColors.hotPink,
                            AppColors.cosmicPurple,
                            AppColors.teal,
                            AppColors.electricYellow,
                          ],
                          animate: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Welcome back greeting
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      color: Colors.white.withAlpha(179),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: GoogleFonts.syne(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading indicator
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        // Linear progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withAlpha(26),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _loadingComplete
                                  ? AppColors.teal
                                  : AppColors.electricYellow,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _statusText,
                            key: ValueKey(_statusText),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: Colors.white.withAlpha(128),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
