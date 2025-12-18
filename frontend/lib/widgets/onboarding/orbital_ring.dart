import 'package:flutter/material.dart';

/// An animated orbital ring that rotates around content.
/// Used for orb decorations matching the design mockups.
class OrbitalRing extends StatefulWidget {
  final double size;
  final double ringOffset;
  final Color ringColor;
  final Color dotColor;
  final double dotSize;
  final Duration duration;
  final bool reverse;
  final Widget? child;

  const OrbitalRing({
    super.key,
    required this.size,
    this.ringOffset = 20,
    this.ringColor = const Color(0x26FFFFFF),
    this.dotColor = const Color(0xFFFAFF0E),
    this.dotSize = 8,
    this.duration = const Duration(seconds: 15),
    this.reverse = false,
    this.child,
  });

  @override
  State<OrbitalRing> createState() => _OrbitalRingState();
}

class _OrbitalRingState extends State<OrbitalRing>
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
    final ringSize = widget.size + (widget.ringOffset * 2);

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating ring with dot
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = widget.reverse
                  ? -_controller.value * 2 * 3.14159
                  : _controller.value * 2 * 3.14159;
              return Transform.rotate(
                angle: angle,
                child: Container(
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.ringColor,
                      width: 1,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: Offset(0, -widget.dotSize / 2),
                      child: Container(
                        width: widget.dotSize,
                        height: widget.dotSize,
                        decoration: BoxDecoration(
                          color: widget.dotColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.dotColor.withAlpha(153),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Child content
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

/// Multiple orbital rings stacked for complex orb effects.
class MultiOrbitalRings extends StatelessWidget {
  final double size;
  final Widget child;
  final List<OrbitalRingConfig> rings;

  const MultiOrbitalRings({
    super.key,
    required this.size,
    required this.child,
    this.rings = const [
      OrbitalRingConfig(offset: 20, dotColor: Color(0xFFFAFF0E), duration: Duration(seconds: 15)),
      OrbitalRingConfig(offset: 40, dotColor: Color(0xFFFF59D0), duration: Duration(seconds: 20), reverse: true),
      OrbitalRingConfig(offset: 60, dotColor: Color(0xFF7D67FE), duration: Duration(seconds: 25)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    
    // Wrap with rings from innermost to outermost
    for (final ring in rings) {
      result = OrbitalRing(
        size: size + (ring.offset * 2) - 40,
        ringOffset: 20,
        dotColor: ring.dotColor,
        dotSize: ring.dotSize,
        duration: ring.duration,
        reverse: ring.reverse,
        child: result,
      );
    }
    
    return result;
  }
}

/// Configuration for orbital ring appearance.
class OrbitalRingConfig {
  final double offset;
  final Color dotColor;
  final double dotSize;
  final Duration duration;
  final bool reverse;

  const OrbitalRingConfig({
    this.offset = 20,
    this.dotColor = const Color(0xFFFAFF0E),
    this.dotSize = 8,
    this.duration = const Duration(seconds: 15),
    this.reverse = false,
  });
}
