import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/onboarding/gradient_toggle.dart';

/// Settings screen with subscription, notifications, account, and app preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock subscription state - in real app this would come from backend
  bool _isPremium = false;
  
  // Notification settings
  final Map<String, bool> _notifications = {
    'daily': true,
    'moon': true,
    'transit': false,
    'friend': true,
  };

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

  int get _enabledNotificationCount => _notifications.values.where((v) => v).length;

  void _enableAllNotifications() {
    setState(() {
      for (var key in _notifications.keys) {
        _notifications[key] = true;
      }
    });
  }

  void _disableAllNotifications() {
    setState(() {
      for (var key in _notifications.keys) {
        _notifications[key] = false;
      }
    });
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded, color: AppColors.electricYellow, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$feature coming soon!',
                style: GoogleFonts.spaceGrotesk(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        title: Text(
          'Delete Account?',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data, including your birth chart, alignments, and connections will be permanently deleted.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: Colors.white.withAlpha(179),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(128),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.red.withAlpha(51)),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showComingSoon('Account deletion');
              },
              child: Text(
                'Delete Account',
                style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        title: Text(
          'Cancel Subscription?',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'You will lose access to premium features at the end of your billing period. You can resubscribe anytime.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: Colors.white.withAlpha(179),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Premium',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.electricYellow,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isPremium = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Subscription cancelled', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
                  backgroundColor: AppColors.backgroundMid,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text(
              'Cancel Subscription',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(128),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  showBackButton: true,
                  showMenuButton: false,
                  title: 'Settings',
                  onBackPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),

                // Subscription Section
                _buildSubscriptionSection(),
                const SizedBox(height: 24),

                // Notifications Section
                _buildNotificationsSection(),
                const SizedBox(height: 24),

                // Account Section
                _buildAccountSection(),
                const SizedBox(height: 24),

                // App Preferences Section
                _buildAppPreferencesSection(),
                const SizedBox(height: 24),

                // About & Legal Section
                _buildAboutLegalSection(),
                const SizedBox(height: 24),

                // App Version Footer
                _buildAppVersionFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          color: Colors.white.withAlpha(128),
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Subscription'),
        GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _isPremium
                          ? const LinearGradient(colors: [AppColors.electricYellow, AppColors.hotPink])
                          : null,
                      color: _isPremium ? null : Colors.white.withAlpha(13),
                    ),
                    child: Icon(
                      _isPremium ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _isPremium ? AppColors.background : Colors.white.withAlpha(128),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _isPremium ? 'Premium Plan' : 'Free Plan',
                              style: GoogleFonts.syne(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isPremium
                                    ? AppColors.electricYellow.withAlpha(38)
                                    : Colors.white.withAlpha(13),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isPremium
                                      ? AppColors.electricYellow.withAlpha(77)
                                      : Colors.white.withAlpha(26),
                                ),
                              ),
                              child: Text(
                                _isPremium ? 'ACTIVE' : 'BASIC',
                                style: GoogleFonts.syne(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _isPremium ? AppColors.electricYellow : Colors.white.withAlpha(128),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isPremium
                              ? 'Unlimited alignments & premium features'
                              : 'Basic features with limited alignments',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: Colors.white.withAlpha(128),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isPremium)
                _buildActionButton(
                  label: 'Cancel Subscription',
                  icon: Icons.cancel_outlined,
                  color: Colors.white.withAlpha(26),
                  textColor: Colors.white.withAlpha(179),
                  onPressed: _showCancelSubscriptionDialog,
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cosmicPurple, AppColors.hotPink],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.hotPink.withAlpha(77),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _isPremium = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.electricYellow, size: 20),
                                const SizedBox(width: 12),
                                Text('Welcome to Premium! ✨', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
                              ],
                            ),
                            backgroundColor: AppColors.backgroundMid,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Upgrade to Premium',
                              style: GoogleFonts.syne(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Notifications'),
            Row(
              children: [
                GestureDetector(
                  onTap: _enableAllNotifications,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withAlpha(26)),
                    ),
                    child: Text(
                      'All',
                      style: GoogleFonts.syne(fontSize: 11, color: AppColors.electricYellow),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _disableAllNotifications,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withAlpha(26)),
                    ),
                    child: Text(
                      'None',
                      style: GoogleFonts.syne(fontSize: 11, color: Colors.white.withAlpha(128)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: _notificationTypes.asMap().entries.map((entry) {
              final type = entry.value;
              final isLast = entry.key == _notificationTypes.length - 1;
              final id = type['id'] as String;
              final isEnabled = _notifications[id] ?? false;
              final color = type['color'] as Color;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withAlpha(isEnabled ? 38 : 20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            type['icon'] as IconData,
                            color: color.withAlpha(isEnabled ? 255 : 128),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type['title'] as String,
                                style: GoogleFonts.syne(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                type['time'] as String,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  color: color.withAlpha(isEnabled ? 255 : 128),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GradientToggle(
                          value: isEnabled,
                          activeGradient: const [AppColors.cosmicPurple, AppColors.hotPink],
                          onChanged: (value) {
                            setState(() => _notifications[id] = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '$_enabledNotificationCount of ${_notifications.length} notifications enabled',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.white.withAlpha(102),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Account'),
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.email_outlined,
                label: 'Change Email',
                color: AppColors.cosmicPurple,
                onTap: () => _showComingSoon('Change email'),
              ),
              const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
              _buildMenuItem(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                color: AppColors.hotPink,
                onTap: () => _showComingSoon('Change password'),
              ),
              const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
              _buildMenuItem(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Account',
                color: AppColors.red,
                onTap: _showDeleteAccountDialog,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('App Preferences'),
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.language_rounded,
                label: 'Language & Region',
                color: AppColors.electricYellow,
                onTap: () => _showComingSoon('Language settings'),
                trailing: Text(
                  'English',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(102)),
                ),
              ),
              const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
              _buildMenuItem(
                icon: Icons.music_note_rounded,
                label: 'Connected Music Services',
                color: AppColors.teal,
                onTap: () => _showComingSoon('Music connections'),
              ),
              const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
              _buildMenuItem(
                icon: Icons.shield_outlined,
                label: 'Data & Privacy',
                color: AppColors.cosmicPurple,
                onTap: () => _showComingSoon('Data & privacy settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('About & Legal'),
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                color: Colors.white.withAlpha(153),
                onTap: () => _showComingSoon('Terms of Service'),
              ),
              const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                color: Colors.white.withAlpha(153),
                onTap: () => _showComingSoon('Privacy Policy'),
              ),
              const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
              _buildMenuItem(
                icon: Icons.code_rounded,
                label: 'Open Source Licenses',
                color: Colors.white.withAlpha(153),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'ASTRO.FM',
                  applicationVersion: '1.0.0',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppVersionFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Saturn-like icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.electricYellow.withAlpha(128), width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: -0.3,
                      child: Container(
                        width: 40,
                        height: 6,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.hotPink.withAlpha(128), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ASTRO.FM',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Version 1.0.0 • Build 2024.12.18',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(102),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ✦ cosmic energy',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: Colors.white.withAlpha(77),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(isDestructive ? 26 : 26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? AppColors.red : Colors.white,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withAlpha(77),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
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
