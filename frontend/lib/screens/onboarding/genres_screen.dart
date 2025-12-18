import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../config/onboarding_options.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_heading.dart';
import '../../widgets/onboarding/onboarding_cta.dart';

/// Screen 5: Genre preferences selection with solar system layout.
/// Main genres are "suns" with orbiting subgenre "planets".
class GenresScreen extends StatefulWidget {
  final List<String> initialGenres;
  final List<String> initialSubgenres;
  final Function(List<String> genres, List<String> subgenres) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const GenresScreen({
    super.key,
    this.initialGenres = const [],
    this.initialSubgenres = const [],
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  late List<String> _selectedGenres;
  late List<String> _selectedSubgenres;

  @override
  void initState() {
    super.initState();
    _selectedGenres = List.from(widget.initialGenres);
    _selectedSubgenres = List.from(widget.initialSubgenres);
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
        // Also remove subgenres of this genre
        final subs = getSubgenresFor(genre);
        _selectedSubgenres.removeWhere((s) => subs.contains(s));
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _toggleSubgenre(String subgenre) {
    setState(() {
      if (_selectedSubgenres.contains(subgenre)) {
        _selectedSubgenres.remove(subgenre);
      } else {
        _selectedSubgenres.add(subgenre);
      }
    });
  }

  int get _totalSelected => _selectedGenres.length + _selectedSubgenres.length;

  // Get alignment for alternating pattern: Left, Center, Right, Center
  CrossAxisAlignment _getAlignment(int index) {
    final pattern = index % 4;
    switch (pattern) {
      case 0:
        return CrossAxisAlignment.start; // Left
      case 1:
        return CrossAxisAlignment.center; // Center
      case 2:
        return CrossAxisAlignment.end; // Right
      case 3:
        return CrossAxisAlignment.center; // Center
      default:
        return CrossAxisAlignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 5,
      onBack: widget.onBack,
      showSkip: true,
      onSkip: widget.onSkip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Heading
            const OnboardingHeading(
              title: 'What sounds\nresonate with you?',
              subtitle: 'Select genres you love. This helps us tune your cosmic playlists.',
            ),
            const SizedBox(height: 24),

            // Genre solar systems
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...genreData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final genre = entry.value;
                      final isSelected = _selectedGenres.contains(genre.name);
                      return _SolarSystemGenre(
                        genre: genre,
                        isSelected: isSelected,
                        alignment: _getAlignment(index),
                        selectedSubgenres: _selectedSubgenres,
                        onGenreTap: () => _toggleGenre(genre.name),
                        onSubgenreTap: _toggleSubgenre,
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selection count hint
            if (_totalSelected > 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.hotPink.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_totalSelected selected',
                    style: const TextStyle(
                      color: AppColors.hotPink,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Continue button
            OnboardingCta(
              label: _selectedGenres.isEmpty ? 'Skip' : 'Continue',
              onPressed: () {
                if (_selectedGenres.isEmpty) {
                  widget.onSkip();
                } else {
                  widget.onNext(_selectedGenres, _selectedSubgenres);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// A single genre "solar system" with orbiting subgenres.
class _SolarSystemGenre extends StatefulWidget {
  final GenreData genre;
  final bool isSelected;
  final CrossAxisAlignment alignment;
  final List<String> selectedSubgenres;
  final VoidCallback onGenreTap;
  final Function(String) onSubgenreTap;

  const _SolarSystemGenre({
    required this.genre,
    required this.isSelected,
    required this.alignment,
    required this.selectedSubgenres,
    required this.onGenreTap,
    required this.onSubgenreTap,
  });

  @override
  State<_SolarSystemGenre> createState() => _SolarSystemGenreState();
}

class _SolarSystemGenreState extends State<_SolarSystemGenre>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;

  // Size constants
  static const double sunSize = 80.0;
  static const double planetSize = 40.0;
  static const double orbitRadius = 70.0;
  static const double containerSize = sunSize + (orbitRadius * 2) + planetSize;

  @override
  void initState() {
    super.initState();
    // 12 second rotation for moderate orbital speed
    _orbitController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate container height based on selection state
    final containerHeight = widget.isSelected ? containerSize : sunSize + 32;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: containerHeight,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: widget.alignment,
        children: [
          SizedBox(
            width: widget.isSelected ? containerSize : sunSize,
            height: widget.isSelected ? containerSize : sunSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orbiting subgenres (planets)
                if (widget.isSelected)
                  ...widget.genre.subgenres.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subgenre = entry.value;
                    final isSubSelected = widget.selectedSubgenres.contains(subgenre);
                    return _OrbitingPlanet(
                      controller: _orbitController,
                      index: index,
                      totalPlanets: widget.genre.subgenres.length,
                      orbitRadius: orbitRadius,
                      planetSize: planetSize,
                      label: subgenre,
                      isSelected: isSubSelected,
                      onTap: () => widget.onSubgenreTap(subgenre),
                    );
                  }),
                // Main genre (sun)
                _GenreSun(
                  name: widget.genre.name,
                  isSelected: widget.isSelected,
                  size: sunSize,
                  onTap: widget.onGenreTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The main genre "sun" circle.
class _GenreSun extends StatelessWidget {
  final String name;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  const _GenreSun({
    required this.name,
    required this.isSelected,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.hotPink,
                    AppColors.cosmicPurple,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(26),
                    Colors.white.withAlpha(13),
                  ],
                ),
          border: Border.all(
            color: isSelected ? AppColors.hotPink : Colors.white.withAlpha(51),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.hotPink.withAlpha(77),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An orbiting subgenre "planet".
class _OrbitingPlanet extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int totalPlanets;
  final double orbitRadius;
  final double planetSize;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrbitingPlanet({
    required this.controller,
    required this.index,
    required this.totalPlanets,
    required this.orbitRadius,
    required this.planetSize,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate starting angle for this planet (evenly distributed)
    final startAngle = (2 * math.pi * index) / totalPlanets;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate current position on orbit
        final angle = startAngle + (controller.value * 2 * math.pi);
        final x = math.cos(angle) * orbitRadius;
        final y = math.sin(angle) * orbitRadius;

        return Transform.translate(
          offset: Offset(x, y),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: planetSize,
          height: planetSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? AppColors.cosmicPurple.withAlpha(77)
                : Colors.white.withAlpha(13),
            border: Border.all(
              color: isSelected
                  ? AppColors.cosmicPurple
                  : Colors.white.withAlpha(38),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.cosmicPurple.withAlpha(51),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                _abbreviate(label),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 7,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.cosmicPurple
                      : Colors.white.withAlpha(179),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Abbreviate long subgenre names to fit in small circles.
  String _abbreviate(String name) {
    // Already short enough
    if (name.length <= 10) return name;
    
    // Common abbreviations
    final abbreviations = {
      'Contemporary R&B': 'Contemp\nR&B',
      'Alternative R&B': 'Alt\nR&B',
      'Quiet Storm': 'Quiet\nStorm',
      'New Jack Swing': 'New Jack',
      'Lo-Fi Hip-Hop': 'Lo-Fi\nHip-Hop',
      'Conscious': 'Conscious',
      'Drum & Bass': 'D&B',
      'Psychedelic': 'Psych',
      'Singer-Songwriter': 'Singer\nS/W',
      'Appalachian': 'Appalach',
      'Space Ambient': 'Space\nAmb',
      'Dark Ambient': 'Dark\nAmb',
      'Progressive': 'Prog',
      'Northern Soul': 'Northern',
      'Philly Soul': 'Philly',
    };
    
    if (abbreviations.containsKey(name)) {
      return abbreviations[name]!;
    }
    
    // Split long names
    if (name.contains(' ')) {
      final parts = name.split(' ');
      if (parts.length == 2) {
        return '${parts[0]}\n${parts[1]}';
      }
    }
    
    return name;
  }
}
