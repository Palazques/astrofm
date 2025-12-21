import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/orbital_ring.dart';

/// Screen 2: Name input screen with dynamic gradient orb.
class NameScreen extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final Function(String name, String email) onNext;
  final VoidCallback onBack;

  const NameScreen({
    super.key,
    this.initialName,
    this.initialEmail,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _nameError;
  String? _emailError;
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
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  List<Color> get _currentGradient {
    final index = _nameController.text.length % 4;
    return _gradients[index];
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateAndProceed() {
    setState(() => _hasInteracted = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    bool hasError = false;

    // Validate name
    if (name.length < 2) {
      setState(() => _nameError = 'Please enter at least 2 characters');
      hasError = true;
    } else if (name.length > 20) {
      setState(() => _nameError = 'Name is too long');
      hasError = true;
    } else {
      setState(() => _nameError = null);
    }

    // Validate email
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      hasError = true;
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email');
      hasError = true;
    } else {
      setState(() => _emailError = null);
    }

    if (hasError) return;

    widget.onNext(name, email);
  }

  void _onNameChanged(String value) {
    setState(() {
      if (_hasInteracted) {
        final name = value.trim();
        if (name.length < 2) {
          _nameError = 'Please enter at least 2 characters';
        } else if (name.length > 20) {
          _nameError = 'Name is too long';
        } else {
          _nameError = null;
        }
      }
    });
  }

  void _onEmailChanged(String value) {
    setState(() {
      if (_hasInteracted) {
        final email = value.trim();
        if (email.isEmpty) {
          _emailError = 'Please enter your email';
        } else if (!_isValidEmail(email)) {
          _emailError = 'Please enter a valid email';
        } else {
          _emailError = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final isValid = name.length >= 2 && email.isNotEmpty && _isValidEmail(email);

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
                  color: _nameError != null 
                      ? AppColors.red 
                      : Colors.white.withAlpha(26),
                ),
              ),
              child: TextField(
                controller: _nameController,
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
            
            // Name error text
            if (_nameError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _nameError!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppColors.red,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Email input field
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _emailError != null 
                      ? AppColors.red 
                      : Colors.white.withAlpha(26),
                ),
              ),
              child: TextField(
                controller: _emailController,
                onChanged: _onEmailChanged,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.syne(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
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
            
            // Email error text
            if (_emailError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _emailError!,
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
