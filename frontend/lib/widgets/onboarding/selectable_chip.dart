import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Selectable chip for multi-select options in onboarding.
class SelectableChip extends StatelessWidget {
  /// Label text for the chip.
  final String label;

  /// Whether the chip is selected.
  final bool isSelected;

  /// Callback when the chip is tapped.
  final VoidCallback onTap;

  /// Optional icon to show.
  final IconData? icon;

  /// Selected color accent.
  final Color selectedColor;

  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor = AppColors.hotPink,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withAlpha(38)
              : Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? selectedColor.withAlpha(179)
                : Colors.white.withAlpha(26),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? selectedColor : Colors.white.withAlpha(153),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? selectedColor : Colors.white,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 18,
                color: selectedColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A group of selectable chips with wrap layout.
class SelectableChipGroup extends StatelessWidget {
  /// List of options to display.
  final List<String> options;

  /// Currently selected options.
  final List<String> selectedOptions;

  /// Callback when an option is toggled.
  final Function(String) onToggle;

  /// Selected color accent.
  final Color selectedColor;

  const SelectableChipGroup({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onToggle,
    this.selectedColor = AppColors.hotPink,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        return SelectableChip(
          label: option,
          isSelected: selectedOptions.contains(option),
          onTap: () => onToggle(option),
          selectedColor: selectedColor,
        );
      }).toList(),
    );
  }
}
