import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/orbital_ring.dart';

/// Screen 2: Name input screen with dynamic gradient orb.
class NameScreen extends StatefulWidget {
  final String? initialName;
  final Function(String name) onNext;
  final VoidCallback onBack;

  const NameScreen({
    super.key,
    this.initialName,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  late TextEditingController _controller;
  String? _errorText;
  bool _hasInteracted = false;

  // Gradient cycles based on name length (matching mockup)
  static const _gradients = [
    [AppColors.hotPink, AppColors.cosmicPurple],
    [AppColors.cosmicPurple, AppColors.teal],
    [AppColors.teal, AppColors.electricYellow],
    [AppColors.electricYellow, AppColors.hotPink],
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _currentGradient {
    final index = _controller.text.length % 4;
    return _gradients[index];
  }

  void _validateAndProceed() {
    setState(() => _hasInteracted = true);

    final name = _controller.text.trim();

    if (name.length < 2) {
      setState(() => _errorText = 'Please enter at least 2 characters');
      return;
    }

    if (name.length > 20) {
      setState(() => _errorText = 'Name is too long');
      return;
    }

    setState(() => _errorText = null);
    widget.onNext(name);
  }

  void _onNameChanged(String value) {
    setState(() {
      if (_hasInteracted) {
        final name = value.trim();
        if (name.length < 2) {
          _errorText = 'Please enter at least 2 characters';
        } else if (name.length > 20) {
          _errorText = 'Name is too long';
        } else {
          _errorText = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _controller.text.trim();
    final isValid = name.length >= 2;

    return OnboardingScaffold(
      step: 2,
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Dynamic gradient orb with orbital ring
            OrbitalRing(
              size: 140,
              ringOffset: 15,
              dotColor: AppColors.electricYellow,
              duration: const Duration(seconds: 15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _currentGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _currentGradient.first.withAlpha(77),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: name.isNotEmpty
                      ? Text(
                          name[0].toUpperCase(),
                          style: GoogleFonts.syne(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(77),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 56,
                          color: Colors.white.withAlpha(204),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Title
            Text(
              "What's your name?",
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "This is how you'll appear to friends",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: Colors.white.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Name input field
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _errorText != null 
                      ? AppColors.red 
                      : Colors.white.withAlpha(26),
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onNameChanged,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.syne(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(77),
                  ),
                  counterStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(77),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),
            
            // Error text
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorText!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppColors.red,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Preview card (shows when name is valid)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isValid ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isValid ? null : 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your cosmic profile: ',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                    Text(
                      "$name's Sound",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.electricYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),

            // Continue button
            OnboardingCta(
              label: 'Continue',
              onPressed: _validateAndProceed,
              isDisabled: !isValid,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
