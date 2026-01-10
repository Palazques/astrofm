import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Chart mode toggle between "My Chart" and "Sky Mode".
class ChartModeToggle extends StatelessWidget {
  final String activeMode;
  final ValueChanged<String> onModeChanged;

  const ChartModeToggle({
    super.key,
    required this.activeMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'MY CHART',
            value: 'my_chart',
            activeColor: AppColors.cosmicPurple,
          ),
          _buildTab(
            label: 'SKY MODE',
            value: 'sky_mode',
            activeColor: AppColors.electricYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required String value,
    required Color activeColor,
  }) {
    final isActive = activeMode == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withAlpha(77) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            border: isActive 
                ? Border.all(color: activeColor.withAlpha(128)) 
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.white.withAlpha(128),
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
