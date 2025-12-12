import 'package:flutter/material.dart';

/// Design tokens for the Astro.FM app.
class AppColors {
  // Primary gradient colors
  static const electricYellow = Color(0xFFFAFF0E);
  static const hotPink = Color(0xFFFF59D0);
  static const cosmicPurple = Color(0xFF7D67FE);
  static const teal = Color(0xFF00D4AA);
  static const orange = Color(0xFFFF8C42);
  static const red = Color(0xFFE84855);

  // Background colors
  static const background = Color(0xFF0A0A0F);
  static const backgroundMid = Color(0xFF0D0D15);
  static const backgroundLight = Color(0xFF12101A);

  // Glass effect
  static const glassBackground = Color(0x08FFFFFF);
  static const glassBorder = Color(0x14FFFFFF);

  // Text colors
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0x80FFFFFF);
  static const textTertiary = Color(0x66FFFFFF);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hotPink, cosmicPurple, teal],
  );

  static const yellowPinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricYellow, hotPink, cosmicPurple],
  );

  static const purplePinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cosmicPurple, hotPink],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundMid, backgroundLight],
  );
}

/// Common spacing values.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Common border radius values.
class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 100;
}
