import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';

/// Profile screen with user info, stats, and settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _dailyAlignReminder = true;
  bool _shareActivity = false;

  final user = {
    'name': 'Paul',
    'username': '@cosmicpaul',
    'avatarColors': [AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal],
    'birthDate': 'July 15, 1990',
    'birthTime': '3:42 PM',
    'birthLocation': 'Los Angeles, CA',
    'sign': 'Cancer',
    'rising': 'Libra',
    'moon': 'Scorpio',
    'dominantFrequency': '528 Hz',
    'element': 'Water',
    'joinedDate': 'November 2024',
  };

  final stats = [
    {'label': 'Total Alignments', 'value': '247', 'icon': '⟳'},
    {'label': 'Streak', 'value': '12 days', 'icon': '🔥'},
    {'label': 'Connections', 'value': '23', 'icon': '✦'},
    {'label': 'Saved Moments', 'value': '89', 'icon': '💾'},
  ];

  final achievements = [
    {'name': 'Early Riser', 'description': 'Aligned before 7 AM', 'icon': '🌅', 'color': AppColors.electricYellow},
    {'name': 'Social Butterfly', 'description': 'Aligned with 10 friends', 'icon': '🦋', 'color': AppColors.hotPink},
    {'name': 'Full Moon Master', 'description': 'Aligned during 5 full moons', 'icon': '🌕', 'color': AppColors.cosmicPurple},
  ];

  final menuItems = [
    {'id': 'edit-birth', 'label': 'Edit Birth Data', 'icon': Icons.edit_rounded},
    {'id': 'sound-settings', 'label': 'Sound Preferences', 'icon': Icons.volume_up_rounded},
    {'id': 'connected-apps', 'label': 'Connected Apps', 'icon': Icons.link_rounded},
    {'id': 'privacy', 'label': 'Privacy & Security', 'icon': Icons.lock_rounded},
    {'id': 'help', 'label': 'Help & Support', 'icon': Icons.help_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppHeader(
              showBackButton: true,
              showMenuButton: false,
              title: 'Profile',
              showSettingsButton: true,
            ),
            const SizedBox(height: 16),

            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 20),

            // Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 20),

            // Achievements
            _buildAchievements(),
            const SizedBox(height: 20),

            // Settings Toggles
            _buildSettingsToggles(),
            const SizedBox(height: 20),

            // Menu Items
            _buildMenuItems(),
            const SizedBox(height: 20),

            // Sign Out
            _buildSignOutButton(),
            const SizedBox(height: 12),

            // App Version
            Center(
              child: Text(
                'ASTRO.FM v1.0.0 • Member since ${user['joinedDate']}',
                style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(77)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GlassCard(
      child: Column(
        children: [
          // Profile Orb
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: user['avatarColors'] as List<Color>),
              boxShadow: [BoxShadow(color: AppColors.hotPink.withAlpha(102), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Center(
              child: Text(
                (user['name'] as String)[0],
                style: GoogleFonts.syne(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Name & Username
          Text(user['name'] as String, style: GoogleFonts.syne(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(user['username'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(128))),
          const SizedBox(height: 16),

          // Sign Tags
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSignTag('☉', user['sign'] as String, AppColors.electricYellow),
              _buildSignTag('☽', user['moon'] as String, AppColors.hotPink),
              _buildSignTag('↑', user['rising'] as String, AppColors.cosmicPurple),
            ],
          ),
          const SizedBox(height: 16),

          // Birth Info
          Text(
            '${user['birthDate']} • ${user['birthTime']} • ${user['birthLocation']}',
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(102)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignTag(String symbol, String sign, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(symbol, style: TextStyle(fontSize: 14, color: color)),
          const SizedBox(width: 6),
          Text(sign, style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: stats.map((stat) => GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stat['icon'] as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.electricYellow, AppColors.hotPink]).createShader(bounds),
              child: Text(stat['value'] as String, style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            Text(
              (stat['label'] as String).toUpperCase(),
              style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white.withAlpha(128), letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Achievements', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.cosmicPurple)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 140,
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 32, offset: const Offset(0, 8))],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: achievement['color'] as Color, width: 3)),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(achievement['icon'] as String, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 10),
                      Text(achievement['name'] as String, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
                      Text(achievement['description'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white.withAlpha(128)), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsToggles() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildToggleItem('Notifications', 'Push notifications', Icons.notifications_rounded, AppColors.electricYellow, _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
          const Divider(color: Colors.white12, height: 1),
          _buildToggleItem('Daily Align Reminder', '9:00 AM every day', Icons.access_time_rounded, AppColors.cosmicPurple, _dailyAlignReminder, (v) => setState(() => _dailyAlignReminder = v)),
          const Divider(color: Colors.white12, height: 1),
          _buildToggleItem('Share Activity', 'Let friends see your alignments', Icons.people_rounded, AppColors.hotPink, _shareActivity, (v) => setState(() => _shareActivity = v)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, IconData icon, Color color, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.cosmicPurple : Colors.white),
            trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.hotPink.withAlpha(128) : Colors.white.withAlpha(26)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == menuItems.length - 1;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: Colors.white.withAlpha(13), borderRadius: BorderRadius.circular(12)),
                          child: Icon(item['icon'] as IconData, color: Colors.white.withAlpha(153), size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Text(item['label'] as String, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                        Icon(Icons.chevron_right_rounded, color: Colors.white.withAlpha(77), size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast) const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.red.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withAlpha(51)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
                const SizedBox(width: 10),
                Text('Sign Out', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
