import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/gradient_toggle.dart';

/// Screen 9: Notification preferences with toggle switches.
class NotificationsScreen extends StatefulWidget {
  final bool initialEnabled;
  final Function(bool enabled) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const NotificationsScreen({
    super.key,
    this.initialEnabled = false,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  
  // Individual notification toggles (matching mockup)
  late Map<String, bool> _notifications;

  final _notificationTypes = [
    {
      'id': 'daily',
      'title': 'Daily Alignment',
      'description': 'Start each day tuned to the cosmos',
      'time': '9:00 AM',
      'color': AppColors.electricYellow,
      'icon': Icons.wb_sunny_outlined,
    },
    {
      'id': 'moon',
      'title': 'Moon Phases',
      'description': 'New & full moon energy alerts',
      'time': 'As they occur',
      'color': AppColors.cosmicPurple,
      'icon': Icons.nightlight_round,
    },
    {
      'id': 'transit',
      'title': 'Major Transits',
      'description': 'Important planetary movements',
      'time': 'Weekly digest',
      'color': AppColors.hotPink,
      'icon': Icons.auto_awesome,
    },
    {
      'id': 'friend',
      'title': 'Friend Alignments',
      'description': 'When friends sync with you',
      'time': 'Real-time',
      'color': AppColors.teal,
      'icon': Icons.people_outline,
    },
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Default: daily, moon, and friend enabled
    _notifications = {
      'daily': true,
      'moon': true,
      'transit': false,
      'friend': true,
    };
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  int get _enabledCount => _notifications.values.where((v) => v).length;

  void _enableAll() {
    setState(() {
      for (var key in _notifications.keys) {
        _notifications[key] = true;
      }
    });
  }

  void _disableAll() {
    setState(() {
      for (var key in _notifications.keys) {
        _notifications[key] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 9,
      onBack: widget.onBack,
      showSkip: true,
      onSkip: widget.onSkip,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Animated bell icon
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: (_iconController.value - 0.5) * 0.3,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [AppColors.hotPink, AppColors.electricYellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.hotPink.withAlpha(77),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 36,
                        ),
                        Positioned(
                          top: 14,
                          right: 18,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.electricYellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Stay cosmically tuned',
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose how we keep you aligned',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: Colors.white.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Notification cards with toggles
            ...List.generate(_notificationTypes.length, (index) {
              final type = _notificationTypes[index];
              final id = type['id'] as String;
              final isEnabled = _notifications[id] ?? false;
              final color = type['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isEnabled 
                          ? color.withAlpha(77) 
                          : Colors.white.withAlpha(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withAlpha(38),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          type['icon'] as IconData,
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type['title'] as String,
                              style: GoogleFonts.syne(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type['description'] as String,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: Colors.white.withAlpha(128),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type['time'] as String,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Toggle
                      GradientToggle(
                        value: isEnabled,
                        activeGradient: [AppColors.cosmicPurple, AppColors.hotPink],
                        onChanged: (value) {
                          setState(() => _notifications[id] = value);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Enable All / Disable All buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton('Enable All', _enableAll),
                const SizedBox(width: 16),
                _buildActionButton('Disable All', _disableAll),
              ],
            ),
            const SizedBox(height: 32),

            // Continue button with dynamic text
            OnboardingCta(
              label: _enabledCount > 0
                  ? 'Continue with $_enabledCount notifications'
                  : 'Continue without notifications',
              onPressed: () => widget.onNext(_enabledCount > 0),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Text(
          label,
          style: GoogleFonts.syne(
            fontSize: 13,
            color: Colors.white.withAlpha(153),
          ),
        ),
      ),
    );
  }
}
