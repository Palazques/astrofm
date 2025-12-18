import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../widgets/sound_orb.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/shimmer_text.dart';

/// Screen 1: Welcome screen with animated orb and introduction.
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;

  const WelcomeScreen({super.key, required this.onNext});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 1,
      showBack: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Animated orb
            FadeTransition(
              opacity: _fadeIn,
              child: const SoundOrb(
                size: 180,
                colors: [
                  AppColors.hotPink,
                  AppColors.cosmicPurple,
                  AppColors.teal,
                  AppColors.electricYellow,
                ],
                animate: true,
              ),
            ),
            const SizedBox(height: 48),

            // Title and subtitle
            SlideTransition(
              position: _slideUp,
              child: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    // Animated shimmer title
                    const ShimmerText(
                      text: 'ASTRO.FM',
                      fontSize: 42,
                      colors: [
                        AppColors.electricYellow,
                        Colors.white,
                        AppColors.hotPink,
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Cosmic Sound Profile',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: Colors.white.withAlpha(179),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Discover music that resonates with your unique cosmic signature. We\'ll create a personalized sound profile based on your birth chart.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.white.withAlpha(128),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 2),

            // CTA Button
            FadeTransition(
              opacity: _fadeIn,
              child: OnboardingCta(
                label: 'Get Started',
                icon: Icons.arrow_forward,
                onPressed: widget.onNext,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
