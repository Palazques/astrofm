import 'package:flutter/material.dart';
import '../models/attunement.dart';

/// Map of planet names to their emoji representations.
const Map<String, String> planetEmojis = {
  'Sun': '☀️',
  'Moon': '🌙',
  'Mercury': '☿️',
  'Venus': '♀️',
  'Mars': '♂️',
  'Jupiter': '♃',
  'Saturn': '♄',
  'Uranus': '⛢',
  'Neptune': '♆',
  'Pluto': '♇',
};

/// Displays a single planet's attunement status card.
class AttunementPlanetCard extends StatelessWidget {
  final PlanetAttunement planet;
  final bool isSelected;
  final VoidCallback? onTap;

  const AttunementPlanetCard({
    super.key,
    required this.planet,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGap = planet.isGap;
    final isResonance = planet.isResonance;
    
    // Status colors
    final statusColor = isGap 
        ? const Color(0xFFFF6B6B) 
        : isResonance 
            ? const Color(0xFF4ECDC4) 
            : Colors.white38;
    
    final statusIcon = isGap ? '🔴' : isResonance ? '🟢' : '⚪';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [statusColor.withOpacity(0.3), statusColor.withOpacity(0.1)]
                : [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? statusColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planet header
            Row(
              children: [
                // Planet emoji and name
                Text(
                  '${planetEmojis[planet.planet] ?? '⭐'} ${planet.planet}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$statusIcon ${isGap ? 'Gap' : isResonance ? 'Resonance' : 'Balanced'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Intensity comparison bars
            _IntensityComparisonRow(
              label: 'Natal',
              percent: planet.natalPercent,
              color: const Color(0xFF9C27B0),
            ),
            const SizedBox(height: 6),
            _IntensityComparisonRow(
              label: 'Transit',
              percent: planet.transitPercent,
              color: statusColor,
            ),
            
            const SizedBox(height: 12),
            
            // Explanation
            Text(
              planet.explanation,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            
            // Priority badge for gaps
            if (planet.priority > 0 && isGap) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Priority #${planet.priority}',
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// Intensity comparison row with label and bar.
class _IntensityComparisonRow extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;

  const _IntensityComparisonRow({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}


/// Duration selector for attunement sessions.
class AttunementDurationSelector extends StatelessWidget {
  final String selectedDuration;
  final ValueChanged<String> onDurationChanged;

  const AttunementDurationSelector({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  static const durations = [
    ('quick', 'Quick', '1 min'),
    ('standard', 'Standard', '3 min'),
    ('meditate', 'Meditate', '∞'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: durations.map((d) {
          final isSelected = selectedDuration == d.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onDurationChanged(d.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      d.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.$3,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white70 : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


/// Mode selector for Attune, Amplify, and Prescribe.
class AttunementModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final bool hasGaps;
  final bool hasResonances;
  final VoidCallback? onAttuneUnavailable;
  final VoidCallback? onAmplifyUnavailable;

  const AttunementModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    required this.hasGaps,
    required this.hasResonances,
    this.onAttuneUnavailable,
    this.onAmplifyUnavailable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Attune button
        Expanded(
          child: _ModeButton(
            label: 'Attune',
            icon: Icons.tune,
            description: 'Bridge gaps',
            isSelected: selectedMode == 'attune',
            isEnabled: hasGaps,
            color: const Color(0xFFFF6B6B),
            onTap: hasGaps 
                ? () => onModeChanged('attune') 
                : onAttuneUnavailable,
          ),
        ),
        const SizedBox(width: 8),
        // Amplify button
        Expanded(
          child: _ModeButton(
            label: 'Amplify',
            icon: Icons.speaker,
            description: 'Boost strengths',
            isSelected: selectedMode == 'amplify',
            isEnabled: hasResonances,
            color: const Color(0xFF4ECDC4),
            onTap: hasResonances 
                ? () => onModeChanged('amplify') 
                : onAmplifyUnavailable,
          ),
        ),
        const SizedBox(width: 8),
        // Prescribe button (always enabled)
        Expanded(
          child: _ModeButton(
            label: 'Prescribe',
            icon: Icons.local_pharmacy_outlined,
            description: 'Cosmic Rx',
            isSelected: selectedMode == 'prescribe',
            isEnabled: true,
            color: const Color(0xFF9333EA),
            onTap: () => onModeChanged('prescribe'),
          ),
        ),
      ],
    );
  }
}


class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final bool isEnabled;
  final Color color;
  final VoidCallback? onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.isEnabled,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isEnabled ? color : color.withOpacity(0.3);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [effectiveColor.withOpacity(0.4), effectiveColor.withOpacity(0.2)],
                )
              : null,
          color: !isSelected ? Colors.white.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? effectiveColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: effectiveColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.white38,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: isEnabled ? Colors.white60 : Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Alignment score dashboard card.
class AlignmentDashboardCard extends StatelessWidget {
  final int alignmentScore;
  final int gapCount;
  final int resonanceCount;
  final String? dominantEnergy;

  const AlignmentDashboardCard({
    super.key,
    required this.alignmentScore,
    required this.gapCount,
    required this.resonanceCount,
    this.dominantEnergy,
  });

  @override
  Widget build(BuildContext context) {
    // Score color gradient
    final scoreColor = alignmentScore >= 70
        ? const Color(0xFF4ECDC4)
        : alignmentScore >= 40
            ? const Color(0xFFFFA726)
            : const Color(0xFFFF6B6B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scoreColor.withOpacity(0.2),
            Colors.black.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Score display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$alignmentScore',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 24,
                    color: scoreColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Cosmic Alignment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: '🔴',
                label: '$gapCount Gap${gapCount != 1 ? 's' : ''}',
                color: const Color(0xFFFF6B6B),
              ),
              const SizedBox(width: 16),
              _StatChip(
                icon: '🟢',
                label: '$resonanceCount Resonance${resonanceCount != 1 ? 's' : ''}',
                color: const Color(0xFF4ECDC4),
              ),
            ],
          ),
          
          if (dominantEnergy != null) ...[
            const SizedBox(height: 12),
            Text(
              'Focus: $dominantEnergy',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


/// Weekly digest card for Sound screen.
class WeeklyDigestCard extends StatelessWidget {
  final WeeklyDigest digest;

  const WeeklyDigestCard({
    super.key,
    required this.digest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.purple, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Weekly Sound Digest',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${digest.averageAlignment}% avg',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Best and challenging days
          Row(
            children: [
              Expanded(
                child: _DayCard(
                  label: 'Best Day',
                  day: digest.bestDay,
                  score: digest.bestDayScore,
                  color: const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DayCard(
                  label: 'Challenging',
                  day: digest.challengingDay,
                  score: digest.challengingDayScore,
                  color: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Summary
          Text(
            digest.summary,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          
          // Common gaps
          if (digest.commonGaps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: digest.commonGaps.map((planet) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${planetEmojis[planet] ?? '⭐'} $planet',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}


class _DayCard extends StatelessWidget {
  final String label;
  final String day;
  final int score;
  final Color color;

  const _DayCard({
    required this.label,
    required this.day,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
