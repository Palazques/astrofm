import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';
import '../../config/onboarding_options.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_heading.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/selectable_chip.dart';

/// Screen 5: Genre preferences selection.
class GenresScreen extends StatefulWidget {
  final List<String> initialGenres;
  final Function(List<String>) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const GenresScreen({
    super.key,
    this.initialGenres = const [],
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  late List<String> _selectedGenres;

  @override
  void initState() {
    super.initState();
    _selectedGenres = List.from(widget.initialGenres);
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 5,
      onBack: widget.onBack,
      showSkip: true,
      onSkip: widget.onSkip,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Heading
            const OnboardingHeading(
              title: 'What sounds\nresonate with you?',
              subtitle: 'Select genres you love. This helps us tune your cosmic playlists.',
            ),
            const SizedBox(height: 40),

            // Genre chips
            Expanded(
              child: SingleChildScrollView(
                child: SelectableChipGroup(
                  options: genreOptions,
                  selectedOptions: _selectedGenres,
                  onToggle: _toggleGenre,
                  selectedColor: AppColors.hotPink,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selection count hint
            if (_selectedGenres.isNotEmpty)
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
                    '${_selectedGenres.length} selected',
                    style: TextStyle(
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
                  widget.onNext(_selectedGenres);
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
