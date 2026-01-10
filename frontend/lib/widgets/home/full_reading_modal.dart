import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../config/glyphs.dart';
import '../../models/ai_responses.dart';
import '../shared/info_chip.dart';

/// Full reading modal that expands from the DailyEssenceCard.
/// Shows complete horoscope, advice, and cosmic weather.
class FullReadingModal extends StatelessWidget {
  final DailyReading reading;
  final VoidCallback? onClose;
  final VoidCallback? onShare;

  const FullReadingModal({
    super.key,
    required this.reading,
    this.onClose,
    this.onShare,
  });

  static void show(BuildContext context, DailyReading reading, {VoidCallback? onShare}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => FullReadingModal(
          reading: reading,
          onClose: () => Navigator.pop(context),
          onShare: onShare,
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.electricYellow,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatCurrentDate().toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: Colors.white.withAlpha(128),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (onShare != null)
                            GestureDetector(
                              onTap: onShare,
                              child: Icon(
                                Icons.share_outlined,
                                size: 18,
                                color: Colors.white.withAlpha(150),
                              ),
                            ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: onClose,
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.white.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Headline
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, AppColors.electricYellow, AppColors.hotPink],
                      stops: [0.0, 0.4, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      reading.headline.toUpperCase(),
                      style: GoogleFonts.syne(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subheadline
                  Text(
                    reading.subheadline,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      color: Colors.white.withAlpha(180),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoChip(
                        glyph: AppGlyphs.moon,
                        label: reading.moonPhase,
                        color: AppColors.electricYellow,
                      ),
                      if (reading.houseContext.isNotEmpty)
                        InfoChip(
                          glyph: '⬡',
                          label: reading.houseContext.split(' ').last,
                          color: AppColors.cosmicPurple,
                        ),
                      InfoChip(
                        glyph: '◈',
                        label: reading.dominantElement,
                        color: const Color(0xFF00B4D8),
                      ),
                      InfoChip(
                        glyph: AppGlyphs.star,
                        label: reading.focusArea,
                        color: AppColors.hotPink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // The Message
                  _buildSection(
                    glyph: '✦',
                    title: 'THE MESSAGE',
                    color: AppColors.cosmicPurple,
                    content: reading.horoscope,
                  ),
                  const SizedBox(height: 20),

                  // Today's Move
                  _buildSection(
                    glyph: '→',
                    title: 'TODAY\'S MOVE',
                    color: AppColors.electricYellow,
                    content: '"${reading.actionableAdvice}"',
                    isAdvice: true,
                  ),
                  const SizedBox(height: 24),

                  // Cosmic Weather
                  Text(
                    reading.cosmicWeather,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(100),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String glyph,
    required String title,
    required Color color,
    required String content,
    bool isAdvice = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                glyph,
                style: TextStyle(color: color, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white.withAlpha(isAdvice ? 230 : 200),
              fontStyle: isAdvice ? FontStyle.italic : FontStyle.normal,
              fontWeight: isAdvice ? FontWeight.w500 : FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
