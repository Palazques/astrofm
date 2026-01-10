import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/design_tokens.dart';

/// Card elevation levels for consistent depth hierarchy.
enum CardElevation {
  /// No shadow, subtle border - for nested/secondary content
  flat,
  /// Soft shadow, no glow - standard cards
  raised,
  /// Ambient color glow - for primary/featured cards
  glowing,
}

/// A glassmorphism card widget used throughout the app.
/// 
/// Use [elevation] to control the visual depth:
/// - [CardElevation.flat]: Minimal, for nested content
/// - [CardElevation.raised]: Standard shadow (default)
/// - [CardElevation.glowing]: Ambient glow for featured content
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final CardElevation elevation;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.lg,
    this.borderColor,
    this.backgroundColor,
    this.elevation = CardElevation.raised,
    this.glowColor,
  });

  List<BoxShadow> _buildShadows() {
    switch (elevation) {
      case CardElevation.flat:
        return []; // No shadow
      case CardElevation.raised:
        return [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ];
      case CardElevation.glowing:
        final glow = glowColor ?? AppColors.cosmicPurple;
        return [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: glow.withAlpha(30),
            blurRadius: 60,
            spreadRadius: -10,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.glassBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
        ),
        boxShadow: _buildShadows(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
