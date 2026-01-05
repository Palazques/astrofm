import 'package:flutter/material.dart';
import '../config/design_tokens.dart';
import 'glass_card.dart';

/// Navigation item definition.
class NavItem {
  final String id;
  final String label;
  final IconData icon;

  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Bottom navigation bar for the app.
class BottomNavBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  static const List<NavItem> items = [
    NavItem(id: 'home', label: 'Home', icon: Icons.home_rounded),
    NavItem(id: 'discover', label: 'Discover', icon: Icons.explore_rounded),
    NavItem(id: 'soundscape', label: 'Soundscape', icon: Icons.queue_music_rounded),
    NavItem(id: 'align', label: 'Align', icon: Icons.layers_rounded),
    NavItem(id: 'friends', label: 'Friends', icon: Icons.people_rounded),
  ];

  const BottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) => _buildNavItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final isActive = activeTab == item.id;

    return GestureDetector(
      onTap: () => onTabChanged(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isActive
                  ? AppColors.electricYellow
                  : Colors.white.withAlpha(128),
            ),
            const SizedBox(height: 4),
            Text(
              item.label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.electricYellow
                    : Colors.white.withAlpha(128),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
