import 'package:flutter/material.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/location.dart';
import 'welcome_screen.dart';
import 'name_screen.dart';
import 'birth_data_screen.dart';
import 'how_found_screen.dart';
import 'genres_screen.dart';
import 'connect_music_screen.dart';
import 'how_it_works_screen.dart';
import 'referral_screen.dart';
import 'notifications_screen.dart';
import 'sound_ready_screen.dart';

/// Main container for the onboarding flow.
/// Manages navigation between screens and collects data.
class OnboardingFlow extends StatefulWidget {
  /// Callback when onboarding is complete.
  final VoidCallback onComplete;

  const OnboardingFlow({super.key, required this.onComplete});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = OnboardingController();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    // Sync page view with controller
    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage != _controller.currentStep) {
        _pageController.animateToPage(
          _controller.currentStep,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  void _goToStep(int step) {
    _controller.goToStep(step);
  }

  void _nextStep() {
    _controller.nextStep();
  }

  void _previousStep() {
    _controller.previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Screen 1: Welcome
            WelcomeScreen(
              onNext: _nextStep,
            ),

            // Screen 2: Name
            NameScreen(
              initialName: _controller.data.displayName,
              onNext: (name) {
                _controller.updateName(name);
                _nextStep();
              },
              onBack: _previousStep,
            ),

            // Screen 3: Birth Data
            BirthDataScreen(
              initialDate: _controller.data.birthDate,
              initialTime: _controller.data.birthTime,
              initialLocation: _controller.data.birthLocation,
              initialTimeUnknown: _controller.data.birthTimeUnknown,
              onNext: ({
                required DateTime date,
                TimeOfDay? time,
                required Location location,
                required bool timeUnknown,
              }) {
                _controller.updateBirthData(
                  date: date,
                  time: time,
                  location: location,
                  timeUnknown: timeUnknown,
                );
                _nextStep();
              },
              onBack: _previousStep,
            ),

            // Screen 4: How Found
            HowFoundScreen(
              initialSelections: _controller.data.howFoundUs,
              onNext: (selections) {
                _controller.updateHowFoundUs(selections);
                _nextStep();
              },
              onBack: _previousStep,
              onSkip: _nextStep,
            ),

            // Screen 5: Genres
            GenresScreen(
              initialGenres: _controller.data.favoriteGenres,
              onNext: (genres) {
                _controller.updateGenres(genres);
                _nextStep();
              },
              onBack: _previousStep,
              onSkip: _nextStep,
            ),

            // Screen 6: Connect Music
            ConnectMusicScreen(
              initialSpotifyConnected: _controller.data.spotifyConnected,
              initialAppleMusicConnected: _controller.data.appleMusicConnected,
              onNext: ({
                required bool spotifyConnected,
                required bool appleMusicConnected,
              }) {
                _controller.updateMusicConnection(
                  spotifyConnected: spotifyConnected,
                  appleMusicConnected: appleMusicConnected,
                );
                _nextStep();
              },
              onBack: _previousStep,
              onSkip: _nextStep,
            ),

            // Screen 7: How It Works
            HowItWorksScreen(
              onNext: _nextStep,
              onBack: _previousStep,
            ),

            // Screen 8: Referral
            ReferralScreen(
              initialCode: _controller.data.referralCode,
              onNext: (code) {
                _controller.updateReferralCode(code);
                _nextStep();
              },
              onBack: _previousStep,
              onSkip: _nextStep,
            ),

            // Screen 9: Notifications
            NotificationsScreen(
              initialEnabled: _controller.data.notificationsEnabled,
              onNext: (enabled) {
                _controller.updateNotifications(enabled);
                _nextStep();
              },
              onBack: _previousStep,
              onSkip: _nextStep,
            ),

            // Screen 10: Sound Ready
            SoundReadyScreen(
              data: _controller.data,
              onComplete: () async {
                await _controller.completeOnboarding();
                widget.onComplete();
              },
            ),
          ],
        );
      },
    );
  }
}
