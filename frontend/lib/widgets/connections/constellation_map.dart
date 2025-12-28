import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/friend_data.dart';
import '../../models/constellation_connection.dart';
import '../../services/compatibility_service.dart';
import '../../services/position_service.dart';
import 'friend_orb.dart';

/// Main constellation map widget displaying friends as connected stars.
class ConstellationMap extends StatefulWidget {
  final List<FriendData> friends;
  final FriendData? selectedFriend;
  final FriendData? hoveredFriend;
  final Function(FriendData?) onFriendSelected;
  final Function(FriendData?) onFriendHovered;

  const ConstellationMap({
    super.key,
    required this.friends,
    this.selectedFriend,
    this.hoveredFriend,
    required this.onFriendSelected,
    required this.onFriendHovered,
  });

  @override
  State<ConstellationMap> createState() => _ConstellationMapState();
}

class _ConstellationMapState extends State<ConstellationMap> {
  final _compatibilityService = CompatibilityService();
  final _positionService = PositionService();

  static const double containerWidth = 340;
  static const double containerHeight = 320;
  static const double padding = 35;

  late Map<int, Offset> _positions;
  late List<ConstellationConnection> _connections;

  @override
  void initState() {
    super.initState();
    _calculateLayout();
  }

  @override
  void didUpdateWidget(ConstellationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.friends != widget.friends) {
      _calculateLayout();
    }
  }

  void _calculateLayout() {
    _positions = _positionService.calculatePositions(
      widget.friends,
      const Size(containerWidth, containerHeight),
      padding: padding,
    );
    _connections = _compatibilityService.buildConnections(widget.friends);
  }

  /// Check if a friend is connected to the currently active (selected/hovered) friend
  bool _isConnectedToActive(FriendData friend) {
    final activeFriend = widget.selectedFriend ?? widget.hoveredFriend;
    if (activeFriend == null) return false;
    
    final connected = _compatibilityService.getConnectedFriends(activeFriend, _connections);
    return connected.any((f) => f.id == friend.id);
  }

  /// Check if a line should be highlighted
  bool _isLineHighlighted(int fromId, int toId) {
    final activeFriend = widget.selectedFriend ?? widget.hoveredFriend;
    if (activeFriend == null) return false;
    return fromId == activeFriend.id || toId == activeFriend.id;
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveSelection = widget.selectedFriend != null || widget.hoveredFriend != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Constellation container
          SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: Stack(
              children: [
                // Connection lines
                CustomPaint(
                  size: const Size(containerWidth, containerHeight),
                  painter: _ConnectionLinesPainter(
                    connections: _connections,
                    positions: _positions,
                    hasActiveSelection: hasActiveSelection,
                    isLineHighlighted: _isLineHighlighted,
                  ),
                ),
                
                // Friend orbs
                ...widget.friends.map((friend) {
                  final position = _positions[friend.id];
                  if (position == null) return const SizedBox.shrink();
                  
                  final size = _positionService.calculateOrbSize(friend.compatibilityScore);
                  final isSelected = widget.selectedFriend?.id == friend.id;
                  final isHighlighted = _isConnectedToActive(friend) || 
                                        friend.id == widget.selectedFriend?.id ||
                                        friend.id == widget.hoveredFriend?.id;
                  final isDimmed = hasActiveSelection && !isHighlighted && !isSelected;
                  
                  return Positioned(
                    left: position.dx - (size + 20) / 2,
                    top: position.dy - (size + 30) / 2,
                    child: FriendOrb(
                      friend: friend,
                      isSelected: isSelected,
                      isHighlighted: isHighlighted,
                      isDimmed: isDimmed,
                      onTap: () {
                        widget.onFriendSelected(isSelected ? null : friend);
                      },
                      onHover: () => widget.onFriendHovered(friend),
                      onHoverExit: () => widget.onFriendHovered(null),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Legend
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.03))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  icon: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFF00D4AA), blurRadius: 4)],
                    ),
                  ),
                  label: 'ONLINE',
                ),
                const SizedBox(width: 20),
                _LegendItem(
                  icon: Container(
                    width: 14,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  label: 'COMPATIBLE',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Widget icon;
  final String label;

  const _LegendItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.35),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for constellation connection lines
class _ConnectionLinesPainter extends CustomPainter {
  final List<ConstellationConnection> connections;
  final Map<int, Offset> positions;
  final bool hasActiveSelection;
  final bool Function(int, int) isLineHighlighted;

  _ConnectionLinesPainter({
    required this.connections,
    required this.positions,
    required this.hasActiveSelection,
    required this.isLineHighlighted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connections) {
      final from = positions[conn.from.id];
      final to = positions[conn.to.id];
      
      if (from == null || to == null) continue;
      
      final highlighted = isLineHighlighted(conn.from.id, conn.to.id);
      
      final paint = Paint()
        ..color = Colors.white.withValues(
          alpha: highlighted ? 0.5 : (hasActiveSelection ? 0.05 : 0.15)
        )
        ..strokeWidth = highlighted ? 1.5 : 1
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionLinesPainter oldDelegate) {
    return oldDelegate.hasActiveSelection != hasActiveSelection;
  }
}
