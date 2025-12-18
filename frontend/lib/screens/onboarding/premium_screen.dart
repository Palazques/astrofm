import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../config/onboarding_options.dart';
import '../../models/user_profile.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_cta.dart';

/// Screen 9: Premium subscription selection.
/// Shows pricing tiers with optional referral discount applied.
class PremiumScreen extends StatefulWidget {
  final bool hasReferralDiscount;
  final Function(PlanType? selectedPlan) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const PremiumScreen({
    super.key,
    this.hasReferralDiscount = false,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  PlanType? _selectedPlan;

  final _premiumFeatures = [
    {'icon': Icons.playlist_play_rounded, 'label': '20-song cosmic playlists'},
    {'icon': Icons.group_rounded, 'label': 'Unlimited friend alignments'},
    {'icon': Icons.sync_rounded, 'label': 'Unlimited personal alignments'},
    {'icon': Icons.calendar_month_rounded, 'label': 'Monthly zodiac playlist'},
  ];

  final _freeFeatures = [
    {'icon': Icons.auto_awesome, 'label': 'Daily reading'},
    {'icon': Icons.music_note, 'label': '4-song daily playlist'},
    {'icon': Icons.people_outline, 'label': '4 friend alignments/week'},
    {'icon': Icons.sync_alt, 'label': '4 personal alignments/week'},
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 9,
      onBack: widget.onBack,
      showSkip: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Header icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [AppColors.electricYellow, AppColors.hotPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricYellow.withAlpha(77),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFF0A0A0F),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Referral discount badge
            if (widget.hasReferralDiscount)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, AppColors.cosmicPurple],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '50% OFF FIRST 3 MONTHS',
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // Title
            Text(
              'Choose Your Plan',
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock your full cosmic potential',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: Colors.white.withAlpha(128),
              ),
            ),
            const SizedBox(height: 32),

            // Pricing cards
            _buildPricingCard(
              plan: PlanType.monthly,
              title: 'Monthly',
              price: PremiumPricing.monthlyPrice,
              discountedPrice: widget.hasReferralDiscount 
                  ? PremiumPricing.monthlyDiscounted 
                  : null,
              perMonth: PremiumPricing.monthlyPerMonth,
              badge: null,
            ),
            const SizedBox(height: 12),
            _buildPricingCard(
              plan: PlanType.sixMonth,
              title: '6 Months',
              price: PremiumPricing.sixMonthPrice,
              discountedPrice: widget.hasReferralDiscount 
                  ? PremiumPricing.sixMonthDiscounted 
                  : null,
              perMonth: PremiumPricing.sixMonthPerMonth,
              badge: '20% OFF',
              badgeColor: AppColors.cosmicPurple,
            ),
            const SizedBox(height: 12),
            _buildPricingCard(
              plan: PlanType.annual,
              title: 'Annual',
              price: PremiumPricing.annualPrice,
              discountedPrice: widget.hasReferralDiscount 
                  ? PremiumPricing.annualDiscounted 
                  : null,
              perMonth: PremiumPricing.annualPerMonth,
              badge: 'BEST VALUE',
              badgeColor: AppColors.electricYellow,
              isRecommended: true,
            ),
            const SizedBox(height: 24),

            // Premium features
            _buildFeatureSection('PREMIUM INCLUDES', _premiumFeatures, AppColors.electricYellow),
            const SizedBox(height: 16),

            // Free features
            _buildFeatureSection('FREE TIER', _freeFeatures, Colors.white.withAlpha(128)),
            const SizedBox(height: 32),

            // Subscribe button
            OnboardingCta(
              label: _selectedPlan != null 
                  ? 'Subscribe to ${_getPlanName(_selectedPlan!)}' 
                  : 'Select a Plan',
              onPressed: _selectedPlan != null 
                  ? () => widget.onNext(_selectedPlan)
                  : null,
              gradientColors: const [AppColors.electricYellow, AppColors.hotPink],
              textColor: const Color(0xFF0A0A0F),
            ),
            const SizedBox(height: 12),

            // Maybe later
            TextButton(
              onPressed: () => widget.onNext(null), // Pass null for free tier
              child: Text(
                'Maybe later',
                style: GoogleFonts.syne(
                  fontSize: 14,
                  color: Colors.white.withAlpha(128),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getPlanName(PlanType plan) {
    switch (plan) {
      case PlanType.monthly:
        return 'Monthly';
      case PlanType.sixMonth:
        return '6-Month';
      case PlanType.annual:
        return 'Annual';
    }
  }

  Widget _buildPricingCard({
    required PlanType plan,
    required String title,
    required double price,
    double? discountedPrice,
    required double perMonth,
    String? badge,
    Color badgeColor = AppColors.cosmicPurple,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPlan == plan;
    final displayPrice = discountedPrice ?? price;
    final hasDiscount = discountedPrice != null;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.electricYellow.withAlpha(13) 
              : Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.electricYellow 
                : Colors.white.withAlpha(26),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [
                  BoxShadow(
                    color: AppColors.electricYellow.withAlpha(26),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.electricYellow : Colors.transparent,
                border: Border.all(
                  color: isSelected 
                      ? AppColors.electricYellow 
                      : Colors.white.withAlpha(77),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF0A0A0F))
                  : null,
            ),
            const SizedBox(width: 16),

            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.syne(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${perMonth.toStringAsFixed(2)}/month',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white.withAlpha(128),
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount)
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      color: Colors.white.withAlpha(77),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  '\$${displayPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: hasDiscount ? AppColors.teal : Colors.white,
                  ),
                ),
                if (hasDiscount)
                  Text(
                    'first 3 mo',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppColors.teal,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(String title, List<Map<String, dynamic>> features, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(f['icon'] as IconData, color: color, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    f['label'] as String,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
