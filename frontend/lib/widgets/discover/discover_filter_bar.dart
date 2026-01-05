/// Filter bar for Discover page.
/// 
/// Three-way toggle (Aligned/Nearby/All), distance slider, 
/// and event type category filters.

import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';
import '../../models/event_data.dart';
import '../../services/discover_service.dart';
import '../glass_card.dart';

class DiscoverFilterBar extends StatelessWidget {
  final DiscoverFilter currentFilter;
  final ValueChanged<DiscoverFilter> onFilterChanged;
  final double distanceMiles;
  final ValueChanged<double> onDistanceChanged;
  final List<EventType> selectedEventTypes;
  final ValueChanged<EventType> onEventTypeToggle;
  final bool showEventTypes;
  final VoidCallback? onToggleEventTypes;

  const DiscoverFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.distanceMiles,
    required this.onDistanceChanged,
    required this.selectedEventTypes,
    required this.onEventTypeToggle,
    this.showEventTypes = false,
    this.onToggleEventTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Filter Bar
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Three-way toggle
              Row(
                children: [
                  _FilterToggle(
                    label: 'Aligned',
                    icon: Icons.auto_awesome,
                    isSelected: currentFilter == DiscoverFilter.aligned,
                    onTap: () => onFilterChanged(DiscoverFilter.aligned),
                  ),
                  const SizedBox(width: 8),
                  _FilterToggle(
                    label: 'Nearby',
                    icon: Icons.near_me,
                    isSelected: currentFilter == DiscoverFilter.nearby,
                    onTap: () => onFilterChanged(DiscoverFilter.nearby),
                  ),
                  const SizedBox(width: 8),
                  _FilterToggle(
                    label: 'All',
                    icon: Icons.grid_view_rounded,
                    isSelected: currentFilter == DiscoverFilter.all,
                    onTap: () => onFilterChanged(DiscoverFilter.all),
                  ),
                  const Spacer(),
                  // Category filter button
                  GestureDetector(
                    onTap: onToggleEventTypes,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: showEventTypes 
                            ? AppColors.teal.withAlpha(51)
                            : Colors.white.withAlpha(13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: showEventTypes 
                              ? AppColors.teal
                              : Colors.white.withAlpha(51),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune,
                            size: 16,
                            color: showEventTypes 
                                ? AppColors.teal
                                : Colors.white.withAlpha(179),
                          ),
                          if (selectedEventTypes.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.teal,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${selectedEventTypes.length}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Distance Slider
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 16,
                    color: Colors.white.withAlpha(128),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.teal,
                        inactiveTrackColor: Colors.white.withAlpha(51),
                        thumbColor: AppColors.teal,
                        overlayColor: AppColors.teal.withAlpha(51),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: distanceMiles,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        onChanged: onDistanceChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${distanceMiles.round()} mi',
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Event Type Filters (collapsible)
        if (showEventTypes) ...[
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventType.values.map((type) {
                final isSelected = selectedEventTypes.contains(type);
                return _EventTypeChip(
                  eventType: type,
                  isSelected: isSelected,
                  onTap: () => onEventTypeToggle(type),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterToggle({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.electricYellow.withAlpha(51)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.electricYellow
                : Colors.white.withAlpha(51),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected 
                  ? AppColors.electricYellow
                  : Colors.white.withAlpha(179),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? AppColors.electricYellow
                    : Colors.white.withAlpha(179),
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

class _EventTypeChip extends StatelessWidget {
  final EventType eventType;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventTypeChip({
    required this.eventType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.electricYellow.withAlpha(51)
              : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? AppColors.electricYellow
                : Colors.white.withAlpha(51),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eventType.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              eventType.displayName,
              style: TextStyle(
                color: isSelected 
                    ? AppColors.electricYellow
                    : Colors.white.withAlpha(204),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
