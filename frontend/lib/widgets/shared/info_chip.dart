import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Standardized info chip component for consistent badge/tag styling.
/// 
/// Use this for all pill-shaped labels throughout the app:
/// - Horoscope tags (moon phase, element, focus area)
/// - Sound RX life area chips
/// - Status badges
/// 
/// Design specs:
/// - Border radius: 16px
/// - Padding: horizontal 12, vertical 6
/// - Font: SpaceGrotesk 11px w600
/// - Border: 1px solid color.withAlpha(60)
/// - Background: color.withAlpha(25)
class InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final String? glyph;
  final bool isSelected;
  final VoidCallback? onTap;

  const InfoChip({
    super.key,
    required this.label,
    required this.color,
    this.glyph,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgAlpha = isSelected ? 50 : 25;
    final borderAlpha = isSelected ? 100 : 60;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(bgAlpha),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(borderAlpha),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[
              Text(
                glyph!,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
