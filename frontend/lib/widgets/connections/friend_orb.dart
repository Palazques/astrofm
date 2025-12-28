
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/friend_data.dart';
import '../../services/position_service.dart';

/// Individual friend orb widget for the constellation map.
/// Displays as a glowing circular orb with initials and optional online indicator.
class FriendOrb extends StatefulWidget {
  final FriendData friend;
  final bool isSelected;
  final bool isHighlighted;
  final bool isDimmed;
  final VoidCallback onTap;
  final VoidCallback? onHover;
  final VoidCallback? onHoverExit;

  const FriendOrb({
    super.key,
    required this.friend,
    required this.isSelected,
    this.isHighlighted = false,
    this.isDimmed = false,
    required this.onTap,
    this.onHover,
    this.onHoverExit,
  });

  @override
  State<FriendOrb> createState() => _FriendOrbState();
}

class _FriendOrbState extends State<FriendOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  final _positionService = PositionService();
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Float animation with seeded duration
    final floatDuration = 5000 + (_positionService.seededRandom(widget.friend.id) * 3000).toInt();
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: floatDuration),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _positionService.calculateOrbSize(widget.friend.compatibilityScore);
    final glowOpacity = _positionService.calculateGlowOpacity(widget.friend.compatibilityScore);
    final color = Color(widget.friend.primaryColorValue);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHover?.call();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        widget.onHoverExit?.call();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final floatOffset = (_floatController.value - 0.5) * 6; // -3 to +3 px
            
            return Transform.translate(
              offset: Offset(0, floatOffset),
              child: AnimatedScale(
                scale: widget.isSelected ? 1.25 : (_isHovered ? 1.15 : 1.0),
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: widget.isDimmed ? 0.3 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: size + 20, // Extra space for glow
                    height: size + 30, // Extra space for name label
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Glow effect
                        Positioned(
                          top: 0,
                          child: Container(
                            width: size + 20,
                            height: size + 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(
                                    alpha: widget.isSelected ? 0.6 : 
                                    widget.isHighlighted ? 0.45 : 
                                    glowOpacity,
                                  ),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Main orb
                        Positioned(
                          top: 10,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.3, -0.3),
                                colors: [
                                  color,
                                  color.withValues(alpha: 0.6),
                                ],
                              ),
                              border: Border.all(
                                color: widget.isSelected 
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.1),
                                width: widget.isSelected ? 2 : 1,
                              ),
                              boxShadow: widget.isSelected ? [
                                BoxShadow(
                                  color: color,
                                  blurRadius: 20,
                                ),
                              ] : null,
                            ),
                            child: Center(
                              child: Text(
                                widget.friend.initials,
                                style: GoogleFonts.syne(
                                  fontSize: size * 0.38,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Online indicator
                        if (widget.friend.status == 'online')
                          Positioned(
                            top: 10 + size - 11,
                            right: (20 + size) / 2 - size / 2 - 2,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4AA),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0A0A10),
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF00D4AA),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        // Name label (shown on hover/selection)
                        Positioned(
                          bottom: 0,
                          child: AnimatedOpacity(
                            opacity: widget.isSelected || _isHovered ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              widget.friend.name.split(' ').first,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: color,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
