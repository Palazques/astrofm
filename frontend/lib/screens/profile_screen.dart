import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../config/onboarding_options.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/genre_preferences_modal.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/birth_data.dart';
import '../models/sonification.dart';
import 'package:url_launcher/url_launcher.dart';

/// Profile screen with user info, preferences, and settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  
  // Birth data from storage
  BirthData? _birthData;
  
  // Chart sonification data (contains zodiac signs)
  ChartSonification? _chartData;
  bool _isLoadingChart = true;
  
  // Genre preferences
  List<String> _selectedGenres = [];
  List<String> _selectedSubgenres = [];
  
  // Extract zodiac signs from chart data
  String get _sunSign {
    if (_chartData == null) return 'Loading...';
    final sun = _chartData!.planets.where((p) => p.planet == 'Sun').firstOrNull;
    return sun?.sign ?? 'Unknown';
  }
  
  String get _moonSign {
    if (_chartData == null) return 'Loading...';
    final moon = _chartData!.planets.where((p) => p.planet == 'Moon').firstOrNull;
    return moon?.sign ?? 'Unknown';
  }
  
  String get _risingSign {
    if (_chartData == null) return 'Loading...';
    return _chartData!.ascendantSign;
  }
  
  Map<String, dynamic> get user => {
    'name': _birthData?.name ?? 'Paul',
    'username': '@cosmic${(_birthData?.name ?? 'paul').toLowerCase()}',
    'avatarColors': [AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal],
    'birthDate': _birthData?.formattedDate ?? 'July 15, 1990',
    'birthTime': _birthData?.formattedTime ?? '3:42 PM',
    'birthLocation': _birthData?.locationName ?? 'Los Angeles, CA',
    'sign': _sunSign,
    'rising': _risingSign,
    'moon': _moonSign,
    'dominantFrequency': _chartData != null 
        ? '${_chartData!.dominantFrequency.toStringAsFixed(0)} Hz' 
        : '--- Hz',
    'joinedDate': 'November 2024',
  };

  final menuItems = [
    {'id': 'edit-birth', 'label': 'Edit Birth Data', 'icon': Icons.edit_rounded},
    {'id': 'sound-settings', 'label': 'Sound Preferences', 'icon': Icons.volume_up_rounded},
    {'id': 'music-services', 'label': 'Music Services', 'icon': Icons.music_note_rounded},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadBirthData();
    _loadGenrePreferences();
  }
  
  Future<void> _loadBirthData() async {
    final stored = await storageService.loadBirthData();
    if (mounted && stored != null) {
      setState(() => _birthData = stored);
      // After loading birth data, fetch the chart
      _loadChartData(stored);
    } else {
      setState(() => _isLoadingChart = false);
    }
  }
  
  Future<void> _loadChartData(BirthData birthData) async {
    try {
      final chart = await _apiService.getUserSonification(
        datetime: birthData.datetime,
        latitude: birthData.latitude,
        longitude: birthData.longitude,
        timezone: birthData.timezone,
      );
      if (mounted) {
        setState(() {
          _chartData = chart;
          _isLoadingChart = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingChart = false);
      }
    }
  }
  
  Future<void> _loadGenrePreferences() async {
    final prefs = await storageService.loadGenres();
    if (mounted) {
      setState(() {
        _selectedGenres = prefs.genres;
        _selectedSubgenres = prefs.subgenres;
      });
    }
  }
  
  void _openGenreEditor() {
    GenrePreferencesModal.show(
      context,
      initialGenres: _selectedGenres,
      initialSubgenres: _selectedSubgenres,
      onSaved: _loadGenrePreferences,
    );
  }

  void _handleMenuTap(String menuId) {
    switch (menuId) {
      case 'edit-birth':
        Navigator.pushNamed(context, '/birth-input').then((_) {
          // Reload birth data after returning from edit screen
          _loadBirthData();
        });
        break;
      case 'sound-settings':
        // Navigate to main shell with sound tab selected
        Navigator.pushNamed(context, '/sound');
        break;
      case 'music-services':
        // Open Spotify app directly
        _openSpotify();
        break;
    }
  }

  Future<void> _openSpotify() async {
    // Try to open Spotify app first, fall back to web
    final spotifyAppUri = Uri.parse('spotify://');
    final spotifyWebUri = Uri.parse('https://open.spotify.com');
    
    if (await canLaunchUrl(spotifyAppUri)) {
      await launchUrl(spotifyAppUri);
    } else {
      await launchUrl(spotifyWebUri, mode: LaunchMode.externalApplication);
    }
  }

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

            // Genre Preferences
            _buildGenrePreferences(),
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

  Widget _buildGenrePreferences() {
    final hasGenres = _selectedGenres.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Music Preferences',
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: _openGenreEditor,
              child: Text(
                'Edit Genres',
                style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cosmicPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: hasGenres
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected genres as chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedGenres.map((genre) {
                        // Get subgenres for this genre
                        final subgenres = _selectedSubgenres
                            .where((s) => getSubgenresFor(genre).contains(s))
                            .toList();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Genre chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cosmicPurple.withAlpha(51),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.cosmicPurple.withAlpha(77),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.music_note_rounded,
                                    size: 14,
                                    color: AppColors.cosmicPurple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    genre,
                                    style: GoogleFonts.syne(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Subgenres underneath
                            if (subgenres.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  top: 4,
                                ),
                                child: Text(
                                  subgenres.join(', '),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    color: Colors.white.withAlpha(128),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      Icons.library_music_rounded,
                      size: 40,
                      color: Colors.white.withAlpha(51),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No genres selected',
                      style: GoogleFonts.syne(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Edit Genres" to set your preferences',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withAlpha(77),
                      ),
                    ),
                  ],
                ),
        ),
      ],
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
                  onTap: () => _handleMenuTap(item['id'] as String),
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

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        title: Text(
          'Sign Out?',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
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
                Navigator.pop(context); // Close dialog
                // Navigate to sign-in screen, clearing all routes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/sign-in',
                  (route) => false,
                );
              },
              child: Text(
                'Sign Out',
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
          onTap: _showSignOutDialog,
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
