import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';

/// Data class representing zodiac season information.
class ZodiacSeasonData {
  final String sign;
  final String symbol;
  final String element;
  final String dateRange;

  const ZodiacSeasonData({
    required this.sign,
    required this.symbol,
    required this.element,
    required this.dateRange,
  });

  /// Get element color based on element type.
  Color get elementColor {
    switch (element.toLowerCase()) {
      case 'fire':
        return const Color(0xFFE84855);
      case 'earth':
        return const Color(0xFF00D4AA);
      case 'air':
        return AppColors.electricYellow;
      case 'water':
        return AppColors.cosmicPurple;
      default:
        return Colors.white;
    }
  }

  /// Get current zodiac season based on date.
  static ZodiacSeasonData getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return const ZodiacSeasonData(sign: 'Aries', symbol: '♈', element: 'Fire', dateRange: 'Mar 21 - Apr 19');
    }
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return const ZodiacSeasonData(sign: 'Taurus', symbol: '♉', element: 'Earth', dateRange: 'Apr 20 - May 20');
    }
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return const ZodiacSeasonData(sign: 'Gemini', symbol: '♊', element: 'Air', dateRange: 'May 21 - Jun 20');
    }
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return const ZodiacSeasonData(sign: 'Cancer', symbol: '♋', element: 'Water', dateRange: 'Jun 21 - Jul 22');
    }
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return const ZodiacSeasonData(sign: 'Leo', symbol: '♌', element: 'Fire', dateRange: 'Jul 23 - Aug 22');
    }
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return const ZodiacSeasonData(sign: 'Virgo', symbol: '♍', element: 'Earth', dateRange: 'Aug 23 - Sep 22');
    }
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return const ZodiacSeasonData(sign: 'Libra', symbol: '♎', element: 'Air', dateRange: 'Sep 23 - Oct 22');
    }
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return const ZodiacSeasonData(sign: 'Scorpio', symbol: '♏', element: 'Water', dateRange: 'Oct 23 - Nov 21');
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return const ZodiacSeasonData(sign: 'Sagittarius', symbol: '♐', element: 'Fire', dateRange: 'Nov 22 - Dec 21');
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return const ZodiacSeasonData(sign: 'Capricorn', symbol: '♑', element: 'Earth', dateRange: 'Dec 22 - Jan 19');
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return const ZodiacSeasonData(sign: 'Aquarius', symbol: '♒', element: 'Air', dateRange: 'Jan 20 - Feb 18');
    }
    return const ZodiacSeasonData(sign: 'Pisces', symbol: '♓', element: 'Water', dateRange: 'Feb 19 - Mar 20');
  }
}

/// A tappable pill widget showing the current zodiac season.
class ZodiacSeasonPill extends StatelessWidget {
  final VoidCallback? onTap;
  final ZodiacSeasonData? seasonData;

  const ZodiacSeasonPill({
    super.key,
    this.onTap,
    this.seasonData,
  });

  @override
  Widget build(BuildContext context) {
    final season = seasonData ?? ZodiacSeasonData.getCurrentSeason();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient zodiac symbol circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cosmicPurple, Color(0xFF5B4BC4)],
                ),
              ),
              child: Center(
                child: Text(
                  season.symbol,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Season text with element badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${season.sign} Season',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Element badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: season.elementColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        season.element,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: season.elementColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 6),
            // Chevron
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.white.withAlpha(102),
            ),
          ],
        ),
      ),
    );
  }
}
