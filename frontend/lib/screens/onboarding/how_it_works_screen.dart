import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';

/// Screen 7: How it works - horizontal swipeable cards.
class HowItWorksScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const HowItWorksScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final _cards = [
    {
      'icon': Icons.satellite_alt,
      'title': 'NASA Data',
      'description': 'We use real-time planetary positions from astronomical databases.',
      'gradientStart': AppColors.electricYellow,
      'gradientEnd': AppColors.hotPink,
    },
    {
      'icon': Icons.graphic_eq,
      'title': 'Sound Translation',
      'description': 'Each planet becomes a frequency. Your chart becomes a symphony.',
      'gradientStart': AppColors.hotPink,
      'gradientEnd': AppColors.cosmicPurple,
    },
    {
      'icon': Icons.today,
      'title': 'Daily Alignment',
      'description': 'Transits shift your sound. Each day brings new cosmic harmonies.',
      'gradientStart': AppColors.cosmicPurple,
      'gradientEnd': AppColors.teal,
    },
    {
      'icon': Icons.queue_music,
      'title': 'Cosmic Playlists',
      'description': 'Music matched to your energy. Updated with your transits.',
      'gradientStart': AppColors.teal,
      'gradientEnd': AppColors.electricYellow,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 7,
      onBack: widget.onBack,
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.electricYellow, AppColors.hotPink],
              ).createShader(bounds),
              child: Text(
                'How Astro.FM Works',
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Swipe to explore',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white.withAlpha(128),
            ),
          ),
          const SizedBox(height: 32),

          // Horizontal card carousel
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                final isActive = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: isActive ? 0 : 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (card['gradientStart'] as Color).withAlpha(isActive ? 38 : 20),
                        (card['gradientEnd'] as Color).withAlpha(isActive ? 25 : 13),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (card['gradientStart'] as Color).withAlpha(isActive ? 77 : 38),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Card number badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${_cards.length}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: Colors.white.withAlpha(153),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Icon
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                card['gradientStart'] as Color,
                                card['gradientEnd'] as Color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (card['gradientStart'] as Color).withAlpha(77),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            card['icon'] as IconData,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          card['title'] as String,
                          style: GoogleFonts.syne(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          card['description'] as String,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Colors.white.withAlpha(153),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_cards.length, (index) {
              final isActive = index == _currentPage;
              final card = _cards[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? card['gradientStart'] as Color
                      : Colors.white.withAlpha(51),
                ),
              );
            }),
          ),

          const Spacer(),

          // Continue button
          Padding(
            padding: const EdgeInsets.all(24),
            child: OnboardingCta(
              label: 'Got it!',
              onPressed: widget.onNext,
            ),
          ),
        ],
      ),
    );
  }
}
