import 'package:flutter/material.dart';
import '../config/design_tokens.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'soundscape_screen.dart';
import 'align_screen.dart';
import 'connections_screen.dart';
import 'discover_screen.dart';

/// Controller to switch tabs from child screens.
class MainShellController extends InheritedWidget {
  final void Function(String tab) switchTab;
  final String activeTab;

  const MainShellController({
    super.key,
    required this.switchTab,
    required this.activeTab,
    required super.child,
  });

  static MainShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellController>();
  }

  @override
  bool updateShouldNotify(MainShellController oldWidget) => 
      activeTab != oldWidget.activeTab;
}

/// Main app shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  String _activeTab = 'home';

  void _switchTab(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  int _getTabIndex(String tab) {
    switch (tab) {
      case 'home':
        return 0;
      case 'discover':
        return 1;
      case 'soundscape':
        return 2;
      case 'align':
        return 3;
      case 'friends':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainShellController(
      switchTab: _switchTab,
      activeTab: _activeTab,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Stack(
            children: [
              // Main content with state persistence
              Positioned.fill(
                child: IndexedStack(
                  index: _getTabIndex(_activeTab),
                  children: const [
                    HomeScreen(),
                    DiscoverScreen(), // New Discover Tab at index 1
                    SoundscapeScreen(),
                    AlignScreen(),
                    ConnectionsScreen(),
                  ],
                ),
              ),

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
      ),
    );
  }
}
