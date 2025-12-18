import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/design_tokens.dart';
import 'screens/main_shell.dart';
import 'screens/birth_input_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/friend_profile_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/align_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'models/friend_data.dart';

void main() {
  runApp(const AstroFmApp());
}

class AstroFmApp extends StatelessWidget {
  const AstroFmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astro.FM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.electricYellow,
          secondary: AppColors.hotPink,
          tertiary: AppColors.cosmicPurple,
          surface: AppColors.backgroundMid,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.syneTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          bodyMedium: GoogleFonts.spaceGrotesk(
            color: Colors.white,
          ),
          bodySmall: GoogleFonts.spaceGrotesk(
            color: Colors.white.withAlpha(179),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: AppColors.electricYellow,
            textStyle: GoogleFonts.syne(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/': (context) => const MainShell(),
        '/birth-input': (context) => const BirthInputScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/align': (context) => const _AlignScreenWrapper(),
        '/onboarding': (context) => OnboardingFlow(
          onComplete: () => Navigator.pushReplacementNamed(context, '/'),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chart') {
          final chart = settings.arguments;
          if (chart != null) {
            return MaterialPageRoute(
              builder: (context) => ChartScreen(chart: chart as dynamic),
            );
          }
        }
        if (settings.name == '/friend-profile') {
          final friendData = settings.arguments as FriendData;
          return MaterialPageRoute(
            builder: (context) => FriendProfileScreen(friend: friendData),
          );
        }
        return null;
      },
    );
  }
}

/// Wrapper for AlignScreen when accessed via direct navigation (not through MainShell).
class _AlignScreenWrapper extends StatelessWidget {
  const _AlignScreenWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: const AlignScreen(),
      ),
    );
  }
}
