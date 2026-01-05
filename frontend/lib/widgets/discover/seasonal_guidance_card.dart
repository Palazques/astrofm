/// Seasonal Guidance Card for Discover page header.
/// 
/// Displays current zodiac season with element badge, 
/// cosmic guidance text, and recommended event type pills.

import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';
import '../../models/event_data.dart';
import '../glass_card.dart';

class SeasonalGuidanceCard extends StatelessWidget {
  final SeasonalGuidance guidance;
  final List<EventType>? selectedEventTypes;
  final ValueChanged<EventType>? onEventTypeToggle;

  const SeasonalGuidanceCard({
    super.key,
    required this.guidance,
    this.selectedEventTypes,
    this.onEventTypeToggle,
  });

  Color _getElementColor(String element) {
    switch (element) {
      case 'Fire':
        return const Color(0xFFFF6B35);
      case 'Earth':
        return const Color(0xFF7CB342);
      case 'Air':
        return const Color(0xFF64B5F6);
      case 'Water':
        return const Color(0xFF7E57C2);
      default:
        return AppColors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final elementColor = _getElementColor(guidance.element);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Season + Element Badge
          Row(
            children: [
              // Zodiac Season
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${guidance.zodiacSign.toUpperCase()} SEASON',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'What to seek this season',
                      style: TextStyle(
                        color: Colors.white.withAlpha(153),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Element Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: elementColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: elementColor.withAlpha(128)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      guidance.elementEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      guidance.element,
                      style: TextStyle(
                        color: elementColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Guidance Text
          Text(
            guidance.guidanceText,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recommended Event Type Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: guidance.recommendedEventTypes.map((typeStr) {
              final eventType = EventTypeExtension.fromString(typeStr);
              final isSelected = selectedEventTypes?.contains(eventType) ?? false;
              
              return _EventTypePill(
                eventType: eventType,
                isSelected: isSelected,
                isRecommended: true,
                onTap: () => onEventTypeToggle?.call(eventType),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EventTypePill extends StatelessWidget {
  final EventType eventType;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback? onTap;

  const _EventTypePill({
    required this.eventType,
    this.isSelected = false,
    this.isRecommended = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.electricYellow.withAlpha(51)
              : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.electricYellow
                : isRecommended
                    ? AppColors.teal.withAlpha(128)
                    : Colors.white.withAlpha(51),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eventType.icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              eventType.displayName,
              style: TextStyle(
                color: isSelected 
                    ? AppColors.electricYellow
                    : Colors.white.withAlpha(204),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
