import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../config/glyphs.dart';
import '../../models/ai_responses.dart';
import '../glass_card.dart';
import '../shared/info_chip.dart';

/// Compact daily horoscope card showing just the essence.
/// Tapping expands to show the full reading.
class DailyEssenceCard extends StatelessWidget {
  final DailyReading? reading;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onExpand;
  final VoidCallback? onShare;

  const DailyEssenceCard({
    super.key,
    this.reading,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onExpand,
    this.onShare,
  });

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _buildErrorState();
    }

    if (isLoading || reading == null) {
      return _buildLoadingState();
    }

    return GestureDetector(
      onTap: onExpand,
      child: GlassCard(
        elevation: CardElevation.glowing,
        glowColor: AppColors.electricYellow,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.electricYellow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TODAY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        color: Colors.white.withAlpha(128),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrentDate(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
                if (onShare != null)
                  GestureDetector(
                    onTap: onShare,
                    child: Icon(
                      Icons.share_outlined,
                      size: 14,
                      color: Colors.white.withAlpha(150),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Headline with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, AppColors.electricYellow],
                stops: [0.3, 1.0],
              ).createShader(bounds),
              child: Text(
                reading!.headline.toUpperCase(),
                style: GoogleFonts.syne(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Subheadline
            Text(
              reading!.subheadline,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: Colors.white.withAlpha(180),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Info chips row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(
                  glyph: AppGlyphs.moon,
                  label: reading!.moonPhase,
                  color: AppColors.electricYellow,
                ),
                InfoChip(
                  glyph: '◈',
                  label: reading!.dominantElement,
                  color: const Color(0xFF00B4D8),
                ),
                InfoChip(
                  glyph: AppGlyphs.star,
                  label: reading!.focusArea,
                  color: AppColors.hotPink,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expand button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Read full insight',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.electricYellow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  AppGlyphs.expand,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.electricYellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return GlassCard(
      elevation: CardElevation.raised,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 70,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return GlassCard(
      elevation: CardElevation.flat,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: Colors.white.withAlpha(100),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            error ?? 'Could not load reading',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white.withAlpha(150),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Tap to retry',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppColors.electricYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
