import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/progress_widgets.dart';

/// Screen 8: Referral - invite friends for premium rewards.
class ReferralScreen extends StatefulWidget {
  final String? initialCode;
  final Function(String? code) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const ReferralScreen({
    super.key,
    this.initialCode,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _codeController;
  late AnimationController _giftController;
  bool _copied = false;
  final int _invitedFriends = 0; // Mock count
  
  final String _myReferralLink = 'astro.fm/invite/cosmicpaul';

  final _premiumFeatures = [
    {'icon': Icons.layers_outlined, 'label': 'Unlimited Alignments', 'color': AppColors.cosmicPurple},
    {'icon': Icons.wb_sunny_outlined, 'label': 'Advanced Transits', 'color': AppColors.electricYellow},
    {'icon': Icons.radio_button_checked, 'label': 'Custom Frequencies', 'color': AppColors.hotPink},
    {'icon': Icons.check_box_outlined, 'label': 'Priority Support', 'color': AppColors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');
    
    _giftController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _giftController.dispose();
    super.dispose();
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _myReferralLink));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _showShareModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildShareModal(),
    );
  }

  Widget _buildShareModal() {
    final shareOptions = [
      {'id': 'messages', 'label': 'Messages', 'icon': Icons.message_outlined, 'color': AppColors.teal},
      {'id': 'whatsapp', 'label': 'WhatsApp', 'icon': Icons.chat_bubble_outline, 'color': const Color(0xFF25D366)},
      {'id': 'twitter', 'label': 'Twitter', 'icon': Icons.alternate_email, 'color': const Color(0xFF1DA1F2)},
      {'id': 'copy', 'label': 'Copy Link', 'icon': Icons.copy, 'color': AppColors.hotPink},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share with friends',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: shareOptions.map((opt) {
              return GestureDetector(
                onTap: () {
                  if (opt['id'] == 'copy') _copyLink();
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(13),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(26)),
                      ),
                      child: Icon(
                        opt['icon'] as IconData,
                        color: opt['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      opt['label'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _myReferralLink,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.white.withAlpha(153),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _copyLink,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _copied ? AppColors.teal : AppColors.electricYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _copied ? 'Copied!' : 'Copy',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 8,
      onBack: widget.onBack,
      showSkip: true,
      onSkip: widget.onSkip,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Animated gift icon
            AnimatedBuilder(
              animation: _giftController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -8 * _giftController.value),
                  child: Transform.rotate(
                    angle: 0.1 * (0.5 - _giftController.value),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [AppColors.cosmicPurple, AppColors.hotPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cosmicPurple.withAlpha(102),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Lifetime discount badge with shine
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.electricYellow, AppColors.hotPink],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'LIFETIME 50% OFF',
                style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A0A0F),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Invite 3 friends',
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unlock Premium features forever',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: Colors.white.withAlpha(128),
              ),
            ),
            const SizedBox(height: 24),

            // Progress bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                    Text(
                      '$_invitedFriends/3 friends',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.electricYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GradientProgressBar(
                  progress: _invitedFriends / 3,
                  height: 8,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Friend slots
            FriendSlotRow(
              totalSlots: 3,
              filledCount: _invitedFriends,
            ),
            const SizedBox(height: 24),

            // Premium features grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Column(
                children: [
                  Text(
                    'PREMIUM INCLUDES',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white.withAlpha(102),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _premiumFeatures.map((f) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 100) / 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(f['icon'] as IconData, color: f['color'] as Color, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                f['label'] as String,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(179),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Invite button
            OnboardingCta(
              label: 'Invite Friends',
              icon: Icons.share,
              onPressed: _showShareModal,
              gradientColors: const [AppColors.cosmicPurple, AppColors.hotPink],
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),

            // Maybe later
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Maybe later',
                style: GoogleFonts.syne(
                  fontSize: 14,
                  color: Colors.white.withAlpha(128),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
