import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

/// A card wrapper that displays a background image with a dark overlay.
/// 
/// Use this to add decorative backgrounds to featured cards while
/// maintaining text readability through a semi-transparent overlay.
/// 
/// Example:
/// ```dart
/// BackgroundImageCard(
///   imagePath: 'assets/images/card_backgrounds/daily_essence_bg.jpg',
///   borderRadius: AppRadius.lg,
///   child: Column(...),
/// )
/// ```
class BackgroundImageCard extends StatelessWidget {
  /// Asset path to the background image. If null, no background is shown.
  final String? imagePath;
  
  /// The card content.
  final Widget child;
  
  /// Opacity of the dark overlay (0.0 to 1.0). Default is 0.5.
  /// Higher values = darker overlay = more readable text.
  final double overlayOpacity;
  
  /// Border radius of the card.
  final double borderRadius;
  
  /// Optional border color.
  final Color? borderColor;
  
  /// Optional padding for the content.
  final EdgeInsetsGeometry? padding;
  
  /// Optional margin around the card.
  final EdgeInsetsGeometry? margin;
  
  /// Gradient colors for the overlay. Defaults to black fade.
  final List<Color>? overlayColors;
  
  /// Direction of the overlay gradient.
  final AlignmentGeometry overlayBegin;
  final AlignmentGeometry overlayEnd;

  const BackgroundImageCard({
    super.key,
    this.imagePath,
    required this.child,
    this.overlayOpacity = 0.5,
    this.borderRadius = AppRadius.lg,
    this.borderColor,
    this.padding,
    this.margin,
    this.overlayColors,
    this.overlayBegin = Alignment.topCenter,
    this.overlayEnd = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    // If no image path, just return child with basic styling
    if (imagePath == null) {
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? AppColors.glassBorder,
          ),
        ),
        child: child,
      );
    }

    // Build overlay gradient
    final overlayGradient = LinearGradient(
      begin: overlayBegin,
      end: overlayEnd,
      colors: overlayColors ?? [
        Colors.black.withAlpha((overlayOpacity * 180).toInt()),
        Colors.black.withAlpha((overlayOpacity * 255).toInt()),
      ],
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: Stack(
          children: [
            // Background image layer
            Positioned.fill(
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to solid color if image fails to load
                  return Container(color: AppColors.glassBackground);
                },
              ),
            ),
            
            // Dark overlay gradient for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: overlayGradient,
                ),
              ),
            ),
            
            // Content layer
            if (padding != null)
              Padding(padding: padding!, child: child)
            else
              child,
          ],
        ),
      ),
    );
  }
}
