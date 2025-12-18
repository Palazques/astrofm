import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Gradient heading component for onboarding screens.
class OnboardingHeading extends StatelessWidget {
  /// Main title text.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Gradient colors for the title.
  final List<Color> gradientColors;

  /// Text alignment.
  final TextAlign textAlign;

  const OnboardingHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.gradientColors = const [
      AppColors.electricYellow,
      AppColors.hotPink,
    ],
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            title,
            textAlign: textAlign,
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: textAlign,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: Colors.white.withAlpha(128),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
