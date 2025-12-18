import 'package:flutter/material.dart';

/// A custom toggle switch with gradient styling when active.
/// Matches the design mockup toggle switches with smooth animations.
class GradientToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final List<Color> activeGradient;
  final Color inactiveColor;
  final double width;
  final double height;

  const GradientToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeGradient = const [Color(0xFF7D67FE), Color(0xFFFF59D0)],
    this.inactiveColor = const Color(0x1AFFFFFF),
    this.width = 52,
    this.height = 30,
  });

  @override
  State<GradientToggle> createState() => _GradientToggleState();
}

class _GradientToggleState extends State<GradientToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(GradientToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = widget.height - 6;
    final slideDistance = widget.width - thumbSize - 6;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: widget.value
                  ? LinearGradient(
                      colors: widget.activeGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: widget.value ? null : widget.inactiveColor,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 3 + (_slideAnimation.value * slideDistance),
                  top: 3,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
