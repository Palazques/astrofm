import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../models/sound_recommendation.dart';
import 'glass_card.dart';

// Local color aliases for design consistency
class _Colors {
  static const warning = Color(0xFFFF8C42);  // Orange for gaps
  static const success = Color(0xFF00D4AA);  // Teal for resonances
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0x80FFFFFF);
  static const textTertiary = Color(0x66FFFFFF);
  static const vibrantPurple = AppColors.cosmicPurple;
  static const surfaceSecondary = Color(0x15FFFFFF);
  static const borderSubtle = Color(0x20FFFFFF);
}

/// Sound Recommendation Card for the home screen.
/// Displays personalized planetary frequency recommendations based on
/// natal chart gaps (attunement needs) and resonances (amplification opportunities).
class SoundRecommendationCard extends StatefulWidget {
  final SoundRecommendationsResponse recommendations;
  final VoidCallback? onPrimaryTap;
  final Function(String lifeAreaKey)? onLifeAreaSelect;
  final Function(SoundRecommendation rec)? onSecondaryTap;

  const SoundRecommendationCard({
    super.key,
    required this.recommendations,
    this.onPrimaryTap,
    this.onLifeAreaSelect,
    this.onSecondaryTap,
  });

  @override
  State<SoundRecommendationCard> createState() => _SoundRecommendationCardState();
}

class _SoundRecommendationCardState extends State<SoundRecommendationCard> {
  String? _selectedLifeArea;

  @override
  Widget build(BuildContext context) {
    final primary = widget.recommendations.primaryRecommendation;
    if (primary == null) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildPrimaryRecommendation(primary),
          const SizedBox(height: 16),
          _buildLifeAreaChips(),
          if (widget.recommendations.gaps.length > 1 ||
              widget.recommendations.resonances.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSecondaryRecommendations(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final gapsCount = widget.recommendations.gapsCount;
    final resonancesCount = widget.recommendations.resonancesCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'YOUR SOUND RX',
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _Colors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            if (gapsCount > 0)
              _buildBadge(
                '$gapsCount ${gapsCount == 1 ? 'Gap' : 'Gaps'}',
                _Colors.warning,
              ),
            if (gapsCount > 0 && resonancesCount > 0)
              const SizedBox(width: 8),
            if (resonancesCount > 0)
              _buildBadge(
                '$resonancesCount ${resonancesCount == 1 ? 'Resonance' : 'Resonances'}',
                _Colors.success,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(102)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPrimaryRecommendation(SoundRecommendation rec) {
    final isGap = rec.isGap;
    final statusColor = isGap ? _Colors.warning : _Colors.success;
    final statusLabel = isGap ? 'ATTUNE' : 'AMPLIFY';

    return GestureDetector(
      onTap: widget.onPrimaryTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withAlpha(38),
              statusColor.withAlpha(13),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withAlpha(77)),
        ),
        child: Row(
          children: [
            // Planet symbol
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    statusColor.withAlpha(77),
                    statusColor.withAlpha(26),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withAlpha(102),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  rec.planetSymbol,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(77),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rec.lifeArea,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _Colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${rec.planet} ${rec.frequency.toStringAsFixed(1)} Hz',
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _Colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec.explanation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _Colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Play button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifeAreaChips() {
    // Using refined glyphs instead of emojis for visual consistency
    final lifeAreas = [
      ('career_purpose', 'Career', '△'),
      ('partnerships', 'Love', '◇'),
      ('creativity_joy', 'Create', '✧'),
      ('health_service', 'Health', '◎'),
      ('communication', 'Express', '◈'),
      ('transformation', 'Transform', '⬡'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: lifeAreas.map((area) {
          final isSelected = _selectedLifeArea == area.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLifeArea = isSelected ? null : area.$1;
                });
                if (!isSelected && widget.onLifeAreaSelect != null) {
                  widget.onLifeAreaSelect!(area.$1);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _Colors.vibrantPurple.withAlpha(50)
                      : _Colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? _Colors.vibrantPurple.withAlpha(100)
                        : _Colors.borderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      area.$3, 
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? _Colors.vibrantPurple : _Colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      area.$2,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? _Colors.vibrantPurple
                            : _Colors.textSecondary,
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

  Widget _buildSecondaryRecommendations() {
    final secondary = <SoundRecommendation>[];
    
    // Add remaining gaps first
    if (widget.recommendations.gaps.length > 1) {
      secondary.addAll(widget.recommendations.gaps.skip(1).take(2));
    }
    
    // Add resonances
    if (secondary.length < 3) {
      secondary.addAll(
        widget.recommendations.resonances.take(3 - secondary.length),
      );
    }

    if (secondary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPLORE MORE',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _Colors.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: secondary.map((rec) {
            return Expanded(
              child: _buildMiniCard(rec),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMiniCard(SoundRecommendation rec) {
    final isGap = rec.isGap;
    final color = isGap ? _Colors.warning : _Colors.success;

    return GestureDetector(
      onTap: () {
        if (widget.onSecondaryTap != null) {
          widget.onSecondaryTap!(rec);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Text(
              rec.planetSymbol,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              rec.planet,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _Colors.textPrimary,
              ),
            ),
            Text(
              isGap ? 'Gap' : 'Resonance',
              style: GoogleFonts.inter(
                fontSize: 9,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
