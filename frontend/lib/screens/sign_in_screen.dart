import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/sound_orb.dart';
import '../widgets/glass_card.dart';

/// Sign In screen for returning users.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual authentication with Firebase
      // For now, simulate a sign in delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // Navigate to main app on success
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign in failed. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToOnboarding() {
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Animated Orb
                  FadeTransition(
                    opacity: _fadeIn,
                    child: const SoundOrb(
                      size: 140,
                      colors: [
                        AppColors.hotPink,
                        AppColors.cosmicPurple,
                        AppColors.teal,
                      ],
                      animate: true,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  SlideTransition(
                    position: _slideUp,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppColors.electricYellow,
                                AppColors.hotPink,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'Welcome Back',
                              style: GoogleFonts.syne(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue your cosmic journey',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Colors.white.withAlpha(128),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Sign In Form
                  SlideTransition(
                    position: _slideUp,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'your@email.com',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.white.withAlpha(128),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(
                                      () => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: AppColors.cosmicPurple,
                                  ),
                                ),
                              ),
                            ),

                            // Error Message
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.red.withAlpha(26),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.red.withAlpha(51)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        color: AppColors.red, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          color: AppColors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Sign In Button
                            _buildSignInButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Social Sign In Options
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.white.withAlpha(51))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or continue with',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(102),
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.white.withAlpha(51))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              onPressed: () {
                                // TODO: Implement Google sign in
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildSocialButton(
                              icon: Icons.apple_rounded,
                              label: 'Apple',
                              onPressed: () {
                                // TODO: Implement Apple sign in
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Account Link
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Colors.white.withAlpha(128),
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToOnboarding,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppColors.electricYellow,
                                AppColors.hotPink,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'Create one',
                              style: GoogleFonts.syne(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: Colors.white.withAlpha(128),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(26)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: Colors.white.withAlpha(51),
              ),
              prefixIcon: Icon(icon, color: Colors.white.withAlpha(77), size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cosmicPurple, AppColors.hotPink],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cosmicPurple.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _signIn,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  _isLoading ? 'Signing In...' : 'Sign In',
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

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
}
