/// Event card for Discover page.
/// 
/// Shows event type icon, name, date/time, distance, price,
/// alignment badge, and cosmic reasoning.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/event_data.dart';
import '../glass_card.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  Color _getElementColor(String? tag) {
    if (tag == null) return AppColors.teal;
    final t = tag.toLowerCase();
    if (t.contains('fire')) return const Color(0xFFFF6B35);
    if (t.contains('water')) return const Color(0xFF7E57C2);
    if (t.contains('air')) return const Color(0xFF64B5F6);
    if (t.contains('earth')) return const Color(0xFF7CB342);
    return AppColors.teal;
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _getElementColor(event.vibeTags.firstOrNull);
    final bool isAligned = event.alignmentTier == AlignmentTier.aligned;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isAligned 
                  ? AppColors.electricYellow.withAlpha(128)
                  : accentColor.withAlpha(60),
              width: isAligned ? 1.5 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withAlpha(20),
                Colors.black.withAlpha(40),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Image + Details + Alignment Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Image with Type Icon overlay
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black38,
                            image: event.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(event.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: event.imageUrl == null
                              ? Center(
                                  child: Text(
                                    event.eventType.icon,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                )
                              : null,
                        ),
                        // Event Type Badge
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(179),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.eventType.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    
                    // Event Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            event.title,
                            style: GoogleFonts.syne(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          
                          // Date & Time
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.dateDisplay,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Location & Distance
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.locationName,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (event.distanceMiles != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  event.distanceDisplay,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Price
                          Text(
                            event.priceDisplay,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: event.price == null || event.price == 0
                                  ? const Color(0xFF4CAF50)
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Alignment Badge
                    if (event.alignmentTier != null)
                      _AlignmentBadge(
                        tier: event.alignmentTier!,
                      ),
                  ],
                ),
                
                // Cosmic Reasoning
                if (event.cosmicReasoning != null && event.cosmicReasoning!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAligned
                          ? AppColors.electricYellow.withAlpha(26)
                          : Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAligned
                            ? AppColors.electricYellow.withAlpha(77)
                            : Colors.white.withAlpha(26),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAligned ? Icons.auto_awesome : Icons.explore,
                          size: 14,
                          color: isAligned 
                              ? AppColors.electricYellow
                              : Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.cosmicReasoning!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isAligned
                                  ? AppColors.electricYellow.withAlpha(230)
                                  : Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlignmentBadge extends StatelessWidget {
  final AlignmentTier tier;

  const _AlignmentBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final bool isAligned = tier == AlignmentTier.aligned;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: isAligned
            ? LinearGradient(
                colors: [
                  AppColors.electricYellow.withAlpha(77),
                  AppColors.electricYellow.withAlpha(26),
                ],
              )
            : null,
        color: isAligned ? null : Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAligned 
              ? AppColors.electricYellow
              : Colors.white.withAlpha(77),
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: AppColors.electricYellow.withAlpha(51),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAligned) ...[
            const Text('✨', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Text(
            isAligned ? 'Aligned' : 'Explore',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isAligned 
                  ? AppColors.electricYellow
                  : Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
