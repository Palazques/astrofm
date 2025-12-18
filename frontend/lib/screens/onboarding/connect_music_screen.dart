import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_heading.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/onboarding/service_connect_card.dart';

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

  @override
  void initState() {
    super.initState();
    _spotifyConnected = widget.initialSpotifyConnected;
    _appleMusicConnected = widget.initialAppleMusicConnected;
  }

  Future<void> _connectSpotify() async {
    if (_spotifyConnected) {
      setState(() => _spotifyConnected = false);
      return;
    }

    setState(() => _spotifyLoading = true);

    // Simulate OAuth flow (mock for now)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _spotifyConnected = true;
        _spotifyLoading = false;
      });
    }
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
