import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Base scaffold for all onboarding screens.
/// Provides consistent layout with gradient background, progress indicator, and back button.
class OnboardingScaffold extends StatelessWidget {
  /// Current step (1-based for display).
  final int step;

  /// Total number of steps.
  final int totalSteps;

  /// Whether to show the back button.
  final bool showBack;

  /// Callback when back button is pressed.
  final VoidCallback? onBack;

  /// Whether to show the skip button.
  final bool showSkip;

  /// Callback when skip button is pressed.
  final VoidCallback? onSkip;

  /// Main content of the screen.
  final Widget child;

  const OnboardingScaffold({
    super.key,
    required this.step,
    this.totalSteps = 11,
    this.showBack = true,
    this.onBack,
    this.showSkip = false,
    this.onSkip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button, progress, and skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Back button
                    if (showBack && step > 1)
                      GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),

                    // Progress indicator
                    Expanded(
                      child: Center(
                        child: Text(
                          'Step $step of $totalSteps',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: Colors.white.withAlpha(102),
                          ),
                        ),
                      ),
                    ),

                    // Skip button
                    if (showSkip)
                      GestureDetector(
                        onTap: onSkip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Colors.white.withAlpha(128),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: step / totalSteps,
                    backgroundColor: Colors.white.withAlpha(26),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.electricYellow,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
