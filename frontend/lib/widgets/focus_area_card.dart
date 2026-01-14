import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/seasonal_pulse.dart';
import '../config/design_tokens.dart';
import 'background_image_card.dart';

/// Compact glassmorphic card for seasonal focus areas.
/// Used in a side-by-side grid layout on the Soundscape screen.
class FocusAreaCard extends StatelessWidget {
  final SeasonalTheme theme;
  final Color elementColor;
  final VoidCallback onTap;
  /// Optional background image asset path.
  final String? backgroundImage;

  const FocusAreaCard({
    super.key,
    required this.theme,
    required this.elementColor,
    required this.onTap,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    // Card content
    final content = Stack(
      children: [
        // Background glow (only when no image)
        if (backgroundImage == null)
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    elementColor.withAlpha(40),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        
        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Glyph symbol
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      elementColor.withAlpha(30),
                      elementColor.withAlpha(15),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: elementColor.withAlpha(128)),
                ),
                child: Center(
                  child: Text(
                    theme.glyph,
                    style: TextStyle(
                      fontSize: 24,
                      color: elementColor,
                    ),
                  ),
                ),
              ),
              
              // Theme info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.title,
                    style: GoogleFonts.syne(
                      fontSize:14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.queue_music_rounded,
                        size: 12,
                        color: Colors.white.withAlpha(128),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${theme.trackCount} tracks • ${theme.totalDuration}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: Colors.white.withAlpha(128),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    // Choose wrapper based on background image
    Widget card;
    if (backgroundImage != null) {
      card = BackgroundImageCard(
        imagePath: backgroundImage,
        borderRadius: 20,
        borderColor: elementColor.withAlpha(102),
        overlayOpacity: 0.45,
        child: SizedBox(height: 140, child: content),
      );
    } else {
      card = Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              elementColor.withAlpha(30),
              elementColor.withAlpha(15),
              Colors.white.withAlpha(5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: elementColor.withAlpha(102)),
          boxShadow: [
            BoxShadow(
              color: elementColor.withAlpha(25),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}
