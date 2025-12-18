import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Primary CTA button for onboarding screens.
class OnboardingCta extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in loading state.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Optional icon to show before the label.
  final IconData? icon;

  /// Gradient colors for the button.
  final List<Color> gradientColors;

  /// Text color.
  final Color textColor;

  const OnboardingCta({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.gradientColors = const [
      AppColors.electricYellow,
      Color(0xFFE5EB0D),
    ],
    this.textColor = const Color(0xFF0A0A0F),
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !isDisabled && !isLoading && onPressed != null;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.6,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? gradientColors
                : [Colors.grey.shade700, Colors.grey.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: gradientColors.first.withAlpha(77),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.syne(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary/outline CTA button for onboarding screens.
class OnboardingSecondaryButton extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Optional icon to show before the label.
  final IconData? icon;

  /// Border color.
  final Color borderColor;

  const OnboardingSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.borderColor = AppColors.hotPink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: borderColor.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withAlpha(128),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: borderColor, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: borderColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
