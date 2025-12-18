import 'package:flutter/material.dart';

/// A gradient progress bar with customizable colors and animation.
/// Used for referral progress and other progress indicators.
class GradientProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final BorderRadius? borderRadius;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.gradientColors = const [Color(0xFF7D67FE), Color(0xFFFF59D0)],
    this.backgroundColor = const Color(0x1AFFFFFF),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: radius,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A friend slot circle for referral progress tracking.
/// Shows empty, pending, or filled states.
class FriendSlot extends StatelessWidget {
  final FriendSlotState state;
  final double size;
  final List<Color> filledGradient;

  const FriendSlot({
    super.key,
    required this.state,
    this.size = 56,
    this.filledGradient = const [Color(0xFF7D67FE), Color(0xFFFF59D0)],
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: state == FriendSlotState.filled
            ? LinearGradient(colors: filledGradient)
            : null,
        border: state == FriendSlotState.empty
            ? Border.all(
                color: Colors.white.withAlpha(51),
                width: 2,
                style: BorderStyle.solid,
              )
            : null,
      ),
      child: Center(
        child: state == FriendSlotState.filled
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : Icon(
                Icons.person_outline,
                color: Colors.white.withAlpha(77),
                size: 24,
              ),
      ),
    );
  }
}

enum FriendSlotState { empty, pending, filled }

/// A row of friend slots for referral tracking.
class FriendSlotRow extends StatelessWidget {
  final int totalSlots;
  final int filledCount;
  final double slotSize;
  final double spacing;

  const FriendSlotRow({
    super.key,
    this.totalSlots = 3,
    required this.filledCount,
    this.slotSize = 56,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSlots, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: FriendSlot(
            state: index < filledCount
                ? FriendSlotState.filled
                : FriendSlotState.empty,
            size: slotSize,
          ),
        );
      }),
    );
  }
}
