import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

/// An animated gradient orb with glow effect.
class SoundOrb extends StatefulWidget {
  final double size;
  final List<Color> colors;
  final bool animate;
  final bool showWaveform;
  final Widget? child;

  const SoundOrb({
    super.key,
    this.size = 100,
    this.colors = const [
      AppColors.hotPink,
      AppColors.cosmicPurple,
      AppColors.teal,
    ],
    this.animate = true,
    this.showWaveform = true,
    this.child,
  });

  @override
  State<SoundOrb> createState() => _SoundOrbState();
}

class _SoundOrbState extends State<SoundOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? -_floatAnimation.value : 0),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.colors,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.colors.first.withAlpha(128),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: widget.child ??
            (widget.showWaveform ? _buildWaveform() : null),
      ),
    );
  }

  Widget _buildWaveform() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(9, (index) {
          final heights = [0.4, 0.7, 1.0, 0.8, 0.5, 0.9, 0.6, 0.7, 0.4];
          return _WaveformBar(
            height: heights[index] * 30,
            delay: Duration(milliseconds: index * 50),
            animate: widget.animate,
          );
        }),
      ),
    );
  }
}

class _WaveformBar extends StatefulWidget {
  final double height;
  final Duration delay;
  final bool animate;

  const _WaveformBar({
    required this.height,
    required this.delay,
    required this.animate,
  });

  @override
  State<_WaveformBar> createState() => _WaveformBarState();
}

class _WaveformBarState extends State<_WaveformBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          width: 3,
          height: widget.height * (widget.animate ? _scaleAnimation.value : 1.0),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(204),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
