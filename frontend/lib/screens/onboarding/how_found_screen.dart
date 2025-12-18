import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';
import '../../config/onboarding_options.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_heading.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/selectable_chip.dart';

/// Screen 4: How did you find us (marketing attribution).
class HowFoundScreen extends StatefulWidget {
  final List<String> initialSelections;
  final Function(List<String>) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const HowFoundScreen({
    super.key,
    this.initialSelections = const [],
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<HowFoundScreen> createState() => _HowFoundScreenState();
}

class _HowFoundScreenState extends State<HowFoundScreen> {
  late List<String> _selections;

  @override
  void initState() {
    super.initState();
    _selections = List.from(widget.initialSelections);
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selections.contains(option)) {
        _selections.remove(option);
      } else {
        _selections.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
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
              title: 'How did you\ndiscover us?',
              subtitle: 'Help us understand where our cosmic community is coming from.',
            ),
            const SizedBox(height: 40),

            // Options
            Expanded(
              child: SingleChildScrollView(
                child: SelectableChipGroup(
                  options: howFoundUsOptions,
                  selectedOptions: _selections,
                  onToggle: _toggleOption,
                  selectedColor: AppColors.cosmicPurple,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Continue button
            OnboardingCta(
              label: _selections.isEmpty ? 'Skip' : 'Continue',
              onPressed: () {
                if (_selections.isEmpty) {
                  widget.onSkip();
                } else {
                  widget.onNext(_selections);
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
