import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Primary CTA button group for the home screen.
class CtaButtonGroup extends StatelessWidget {
  final VoidCallback? onAlignTap;
  final VoidCallback? onDiscoverTap;

  const CtaButtonGroup({
    super.key,
    this.onAlignTap,
    this.onDiscoverTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CtaButton(
            label: 'Align Now',
            icon: Icons.access_time_rounded,
            gradient: const LinearGradient(
              colors: [AppColors.cosmicPurple, AppColors.hotPink],
            ),
            onPressed: onAlignTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CtaButton(
            label: 'Discover',
            icon: Icons.music_note_rounded,
            gradient: const LinearGradient(
              colors: [AppColors.electricYellow, Color(0xFFE5EB0D)],
            ),
            textColor: AppColors.background,
            onPressed: onDiscoverTap,
          ),
        ),
      ],
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback? onPressed;

  const _CtaButton({
    required this.label,
    required this.icon,
    required this.gradient,
    this.textColor = Colors.white,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
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
