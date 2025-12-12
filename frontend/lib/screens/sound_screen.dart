import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';

/// Your Sound screen with frequency breakdown.
class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key});

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  bool _isPlaying = false;

  final soundProfile = {
    'name': 'Paul',
    'sign': 'Cancer',
    'createdFrom': 'July 15, 1990 • 3:42 PM • Los Angeles, CA',
    'dominantFrequency': '528 Hz',
    'element': 'Water',
  };

  final frequencyBreakdown = [
    {'planet': 'Sun', 'sign': 'Cancer', 'frequency': '528 Hz', 'color': AppColors.electricYellow, 'description': 'Core essence • Nurturing vibration', 'symbol': '☉'},
    {'planet': 'Moon', 'sign': 'Scorpio', 'frequency': '432 Hz', 'color': AppColors.hotPink, 'description': 'Emotional depth • Transformative pulse', 'symbol': '☽'},
    {'planet': 'Rising', 'sign': 'Libra', 'frequency': '396 Hz', 'color': AppColors.cosmicPurple, 'description': 'Outer expression • Harmonic balance', 'symbol': '↑'},
    {'planet': 'Mercury', 'sign': 'Leo', 'frequency': '741 Hz', 'color': AppColors.teal, 'description': 'Communication • Creative expression', 'symbol': '☿'},
    {'planet': 'Venus', 'sign': 'Gemini', 'frequency': '639 Hz', 'color': AppColors.orange, 'description': 'Love language • Curious connection', 'symbol': '♀'},
    {'planet': 'Mars', 'sign': 'Taurus', 'frequency': '417 Hz', 'color': AppColors.red, 'description': 'Drive • Steady determination', 'symbol': '♂'},
  ];

  final todaysInfluence = {
    'transit': 'Moon conjunct your natal Pluto',
    'effect': 'Your sound carries extra intensity today. Deep bass frequencies are amplified.',
    'shift': '+12% depth',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              showBackButton: true,
              showMenuButton: false,
              title: 'Your Sound',
              rightAction: IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 16),

            // Main Sound Orb
            _buildMainOrb(),
            const SizedBox(height: 32),

            // Play Button
            _buildPlayButton(),
            const SizedBox(height: 24),

            // Today's Influence
            _buildTodaysInfluence(),
            const SizedBox(height: 24),

            // Frequency Breakdown
            _buildFrequencyBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainOrb() {
    return Column(
      children: [
        SoundOrb(
          size: 180,
          colors: const [AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal, AppColors.electricYellow],
          animate: _isPlaying,
          showWaveform: true,
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.hotPink, AppColors.electricYellow],
          ).createShader(bounds),
          child: Text(
            "${soundProfile['name']}'s Sound",
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          soundProfile['createdFrom'] as String,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: Colors.white.withAlpha(128),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildTag(soundProfile['dominantFrequency'] as String, AppColors.electricYellow),
            _buildTag(soundProfile['element'] as String, AppColors.cosmicPurple),
            _buildTag(soundProfile['sign'] as String, AppColors.hotPink),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Text(
        text,
        style: GoogleFonts.syne(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: _isPlaying
            ? null
            : const LinearGradient(colors: [AppColors.hotPink, AppColors.cosmicPurple]),
        color: _isPlaying ? AppColors.hotPink.withAlpha(51) : null,
        borderRadius: BorderRadius.circular(16),
        border: _isPlaying ? Border.all(color: AppColors.hotPink, width: 2) : null,
        boxShadow: _isPlaying
            ? null
            : [BoxShadow(color: AppColors.hotPink.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isPlaying = !_isPlaying),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  _isPlaying ? 'Pause Your Sound' : 'Play Your Sound',
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysInfluence() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 32, offset: const Offset(0, 8))],
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.hotPink, width: 3)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S INFLUENCE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(128),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todaysInfluence['transit'] as String,
                      style: GoogleFonts.syne(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.hotPink.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todaysInfluence['shift'] as String,
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hotPink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              todaysInfluence['effect'] as String,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                height: 1.5,
                color: Colors.white.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frequency Breakdown',
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Full Chart',
                style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cosmicPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: frequencyBreakdown.map((item) => _buildFrequencyItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyItem(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withAlpha(26),
              border: Border.all(color: color.withAlpha(51)),
            ),
            child: Center(
              child: Text(
                item['symbol'] as String,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item['planet'] as String,
                      style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'in ${item['sign']}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(102)),
                    ),
                  ],
                ),
                Text(
                  item['description'] as String,
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['frequency'] as String,
              style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
