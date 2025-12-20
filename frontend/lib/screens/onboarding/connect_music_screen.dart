import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_heading.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/service_connect_card.dart';
import '../../services/spotify_service.dart';

/// Screen 6: Connect music streaming services.
class ConnectMusicScreen extends StatefulWidget {
  final bool initialSpotifyConnected;
  final bool initialAppleMusicConnected;
  final Function({
    required bool spotifyConnected,
    required bool appleMusicConnected,
  }) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const ConnectMusicScreen({
    super.key,
    this.initialSpotifyConnected = false,
    this.initialAppleMusicConnected = false,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<ConnectMusicScreen> createState() => _ConnectMusicScreenState();
}

class _ConnectMusicScreenState extends State<ConnectMusicScreen> {
  late bool _spotifyConnected;
  late bool _appleMusicConnected;
  bool _spotifyLoading = false;
  bool _appleMusicLoading = false;
  String? _spotifyUserName;
  String? _pendingSpotifyState;
  
  final SpotifyService _spotifyService = SpotifyService();

  @override
  void initState() {
    super.initState();
    _spotifyConnected = widget.initialSpotifyConnected;
    _appleMusicConnected = widget.initialAppleMusicConnected;
    
    // Check if already connected to Spotify
    _checkSpotifyConnection();
  }
  
  Future<void> _checkSpotifyConnection() async {
    final status = await _spotifyService.getConnectionStatus();
    if (mounted && status.connected) {
      setState(() {
        _spotifyConnected = true;
        _spotifyUserName = status.displayName;
      });
    }
  }

  Future<void> _connectSpotify() async {
    // If already connected, disconnect
    if (_spotifyConnected) {
      await _spotifyService.disconnect();
      setState(() {
        _spotifyConnected = false;
        _spotifyUserName = null;
      });
      return;
    }

    setState(() => _spotifyLoading = true);

    try {
      // Initiate OAuth flow - this opens Spotify in browser
      final state = await _spotifyService.initiateSpotifyAuth();
      _pendingSpotifyState = state;
      
      // Show dialog explaining next steps
      if (mounted) {
        _showSpotifyAuthDialog();
      }
    } on SpotifyException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _spotifyLoading = false);
      }
    }
  }
  
  void _showSpotifyAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Connecting to Spotify',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A browser window has opened for you to log in to Spotify.\n\nAfter authorizing, copy the session ID shown and paste it below.',
              style: GoogleFonts.spaceGrotesk(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Paste session ID here',
                hintStyle: GoogleFonts.spaceGrotesk(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withAlpha(13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _pendingSpotifyState = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _spotifyLoading = false);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954), // Spotify green
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (_pendingSpotifyState != null && _pendingSpotifyState!.isNotEmpty) {
                // Store the session ID
                await _spotifyService.storeSessionId(_pendingSpotifyState!);
                
                // Check connection status
                final status = await _spotifyService.getConnectionStatus();
                
                if (mounted) {
                  Navigator.pop(context);
                  if (status.connected) {
                    setState(() {
                      _spotifyConnected = true;
                      _spotifyUserName = status.displayName;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Connected as ${status.displayName ?? 'Spotify User'}'),
                        backgroundColor: const Color(0xFF1DB954),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connection failed. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text('Confirm', style: GoogleFonts.spaceGrotesk()),
          ),
        ],
      ),
    );
  }

  Future<void> _connectAppleMusic() async {
    if (_appleMusicConnected) {
      setState(() => _appleMusicConnected = false);
      return;
    }

    setState(() => _appleMusicLoading = true);

    // Simulate OAuth flow (mock for now)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _appleMusicConnected = true;
        _appleMusicLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final anyConnected = _spotifyConnected || _appleMusicConnected;

    return OnboardingScaffold(
      step: 6,
      onBack: widget.onBack,
      showSkip: true,
      onSkip: widget.onSkip,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Heading
            const OnboardingHeading(
              title: 'Connect your\nmusic',
              subtitle: 'Link your streaming service to get personalized cosmic playlists.',
            ),
            const SizedBox(height: 40),

            // Spotify card
            SpotifyConnectCard(
              isConnected: _spotifyConnected,
              isLoading: _spotifyLoading,
              onTap: _connectSpotify,
            ),
            const SizedBox(height: 16),

            // Apple Music card
            AppleMusicConnectCard(
              isConnected: _appleMusicConnected,
              isLoading: _appleMusicLoading,
              onTap: _connectAppleMusic,
            ),

            const SizedBox(height: 24),

            // Info note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAlpha(26),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.white.withAlpha(128),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'We only access your listening history to personalize recommendations. You can disconnect anytime.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withAlpha(128),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Continue button
            OnboardingCta(
              label: anyConnected ? 'Continue' : 'Skip for now',
              onPressed: () {
                if (anyConnected) {
                  widget.onNext(
                    spotifyConnected: _spotifyConnected,
                    appleMusicConnected: _appleMusicConnected,
                  );
                } else {
                  widget.onSkip();
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
