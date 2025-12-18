import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

/// A skeleton loader with pulse animation for loading states.
/// Uses simple opacity animation (0.3 → 0.7) with ease-in-out curve.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.color ?? Colors.white).withOpacity(_animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

/// Skeleton text placeholder with multiple lines.
class SkeletonText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final double? lastLineWidth;

  const SkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 8,
    this.lastLineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: SkeletonLoader(
            width: isLast && lastLineWidth != null
                ? lastLineWidth!
                : double.infinity,
            height: lineHeight,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.1),
          ),
        );
      }),
    );
  }
}

/// Circular skeleton for orbs and avatars.
class SkeletonOrb extends StatefulWidget {
  final double size;
  final Color? color;

  const SkeletonOrb({
    super.key,
    required this.size,
    this.color,
  });

  @override
  State<SkeletonOrb> createState() => _SkeletonOrbState();
}

class _SkeletonOrbState extends State<SkeletonOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (widget.color ?? Colors.white).withOpacity(_animation.value * 0.15),
            border: Border.all(
              color: Colors.white.withOpacity(_animation.value * 0.2),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card placeholder for list items.
class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const SkeletonCard({
    super.key,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLoader(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withOpacity(0.05),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
