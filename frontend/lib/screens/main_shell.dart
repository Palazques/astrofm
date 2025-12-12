import 'package:flutter/material.dart';
import '../config/design_tokens.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'sound_screen.dart';
import 'align_screen.dart';
import 'connections_screen.dart';
import 'profile_screen.dart';

/// Main app shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  String _activeTab = 'home';

  Widget _getScreen() {
    switch (_activeTab) {
      case 'home':
        return const HomeScreen();
      case 'sound':
        return const SoundScreen();
      case 'align':
        return const AlignScreen();
      case 'friends':
        return const ConnectionsScreen();
      case 'profile':
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Main content
            _getScreen(),

            // Bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                activeTab: _activeTab,
                onTabChanged: (tab) {
                  setState(() {
                    _activeTab = tab;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
