import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A text widget with an animated shimmer gradient effect.
/// Used for premium-feeling title animations.
class ShimmerText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final List<Color> colors;
  final Duration duration;

  const ShimmerText({
    super.key,
    required this.text,
    this.fontSize = 32,
    this.fontWeight = FontWeight.w800,
    this.colors = const [
      Color(0xFFFFFFFF),
      Color(0xFFFAFF0E),
      Color(0xFFFF59D0),
    ],
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: widget.colors,
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-2.0 + (_controller.value * 4), 0),
              end: Alignment(0.0 + (_controller.value * 4), 0),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        );
      },
    );
  }
}

/// A waveform visualization widget for use inside orbs.
/// Creates animated vertical bars that oscillate.
class WaveformBars extends StatefulWidget {
  final int barCount;
  final double maxHeight;
  final double barWidth;
  final Color color;

  const WaveformBars({
    super.key,
    this.barCount = 12,
    this.maxHeight = 60,
    this.barWidth = 6,
    this.color = Colors.white,
  });

  @override
  State<WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<WaveformBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Base heights for each bar (normalized 0-1)
  late List<double> _baseHeights;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Generate varied base heights for visual interest
    _baseHeights = List.generate(widget.barCount, (i) {
      return [0.4, 0.7, 0.5, 1.0, 0.8, 0.6, 0.9, 0.5, 0.7, 0.4, 0.8, 0.6][i % 12];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            // Phase-shifted sine wave for each bar
            final phase = index * 0.3;
            final animValue = ((_controller.value * 2 * 3.14159) + phase);
            final scale = 0.5 + (0.5 * ((animValue).abs() % 1.0));
            final height = _baseHeights[index] * widget.maxHeight * scale;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: widget.barWidth,
              height: height.clamp(widget.maxHeight * 0.2, widget.maxHeight),
              decoration: BoxDecoration(
                color: widget.color.withAlpha(230),
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
              ),
            );
          }),
        );
      },
    );
  }
}
