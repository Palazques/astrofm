/// User profile model - Firebase-ready structure for all user data.
/// Designed for easy migration from SharedPreferences to Firestore.

import 'birth_data.dart';

/// Membership type enum
enum MembershipType { free, premium }

/// Plan type enum for premium subscriptions
enum PlanType { monthly, sixMonth, annual }

/// Complete user profile model
class UserProfile {
  final String id;
  final String displayName;
  final BirthData? birthData;
  final List<String> genres;
  final List<String> subgenres;
  final Membership membership;
  final Referral referral;
  final OnboardingStatus onboarding;
  final String? howFoundUs;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.displayName,
    this.birthData,
    this.genres = const [],
    this.subgenres = const [],
    Membership? membership,
    Referral? referral,
    OnboardingStatus? onboarding,
    this.howFoundUs,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : membership = membership ?? Membership(),
        referral = referral ?? Referral(),
        onboarding = onboarding ?? OnboardingStatus(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? displayName,
    BirthData? birthData,
    List<String>? genres,
    List<String>? subgenres,
    Membership? membership,
    Referral? referral,
    OnboardingStatus? onboarding,
    String? howFoundUs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      birthData: birthData ?? this.birthData,
      genres: genres ?? this.genres,
      subgenres: subgenres ?? this.subgenres,
      membership: membership ?? this.membership,
      referral: referral ?? this.referral,
      onboarding: onboarding ?? this.onboarding,
      howFoundUs: howFoundUs ?? this.howFoundUs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'birth_data': birthData?.toJson(),
      'genres': genres,
      'subgenres': subgenres,
      'membership': membership.toJson(),
      'referral': referral.toJson(),
      'onboarding': onboarding.toJson(),
      'how_found_us': howFoundUs,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      birthData: json['birth_data'] != null
          ? BirthData.fromJson(json['birth_data'] as Map<String, dynamic>)
          : null,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      subgenres: (json['subgenres'] as List<dynamic>?)?.cast<String>() ?? [],
      membership: json['membership'] != null
          ? Membership.fromJson(json['membership'] as Map<String, dynamic>)
          : Membership(),
      referral: json['referral'] != null
          ? Referral.fromJson(json['referral'] as Map<String, dynamic>)
          : Referral(),
      onboarding: json['onboarding'] != null
          ? OnboardingStatus.fromJson(json['onboarding'] as Map<String, dynamic>)
          : OnboardingStatus(),
      howFoundUs: json['how_found_us'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Membership status and subscription details
class Membership {
  final MembershipType type;
  final PlanType? plan;
  final DateTime? expiresAt;
  final bool hasReferralDiscount;
  final DateTime? referralDiscountEndsAt;

  Membership({
    this.type = MembershipType.free,
    this.plan,
    this.expiresAt,
    this.hasReferralDiscount = false,
    this.referralDiscountEndsAt,
  });

  bool get isPremium => type == MembershipType.premium;
  
  bool get isDiscountActive {
    if (!hasReferralDiscount || referralDiscountEndsAt == null) return false;
    return DateTime.now().isBefore(referralDiscountEndsAt!);
  }

  Membership copyWith({
    MembershipType? type,
    PlanType? plan,
    DateTime? expiresAt,
    bool? hasReferralDiscount,
    DateTime? referralDiscountEndsAt,
  }) {
    return Membership(
      type: type ?? this.type,
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      hasReferralDiscount: hasReferralDiscount ?? this.hasReferralDiscount,
      referralDiscountEndsAt: referralDiscountEndsAt ?? this.referralDiscountEndsAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'plan': plan?.name,
      'expires_at': expiresAt?.toIso8601String(),
      'has_referral_discount': hasReferralDiscount,
      'referral_discount_ends_at': referralDiscountEndsAt?.toIso8601String(),
    };
  }

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      type: MembershipType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MembershipType.free,
      ),
      plan: json['plan'] != null
          ? PlanType.values.firstWhere(
              (e) => e.name == json['plan'],
              orElse: () => PlanType.monthly,
            )
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      hasReferralDiscount: json['has_referral_discount'] as bool? ?? false,
      referralDiscountEndsAt: json['referral_discount_ends_at'] != null
          ? DateTime.parse(json['referral_discount_ends_at'] as String)
          : null,
    );
  }
}

/// Referral tracking for friend invites
class Referral {
  final int sharedWithCount;
  final DateTime? sharedAt;
  final bool earnedDiscount;
  final DateTime? discountEndsAt;

  Referral({
    this.sharedWithCount = 0,
    this.sharedAt,
    this.earnedDiscount = false,
    this.discountEndsAt,
  });

  bool get hasEarnedDiscount => sharedWithCount >= 3 && earnedDiscount;
  
  bool get isDiscountActive {
    if (!hasEarnedDiscount || discountEndsAt == null) return false;
    return DateTime.now().isBefore(discountEndsAt!);
  }

  Referral copyWith({
    int? sharedWithCount,
    DateTime? sharedAt,
    bool? earnedDiscount,
    DateTime? discountEndsAt,
  }) {
    return Referral(
      sharedWithCount: sharedWithCount ?? this.sharedWithCount,
      sharedAt: sharedAt ?? this.sharedAt,
      earnedDiscount: earnedDiscount ?? this.earnedDiscount,
      discountEndsAt: discountEndsAt ?? this.discountEndsAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shared_with_count': sharedWithCount,
      'shared_at': sharedAt?.toIso8601String(),
      'earned_discount': earnedDiscount,
      'discount_ends_at': discountEndsAt?.toIso8601String(),
    };
  }

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      sharedWithCount: json['shared_with_count'] as int? ?? 0,
      sharedAt: json['shared_at'] != null
          ? DateTime.parse(json['shared_at'] as String)
          : null,
      earnedDiscount: json['earned_discount'] as bool? ?? false,
      discountEndsAt: json['discount_ends_at'] != null
          ? DateTime.parse(json['discount_ends_at'] as String)
          : null,
    );
  }
}

/// Onboarding completion status
class OnboardingStatus {
  final bool completed;
  final DateTime? completedAt;
  final List<String> skippedScreens;

  OnboardingStatus({
    this.completed = false,
    this.completedAt,
    this.skippedScreens = const [],
  });

  OnboardingStatus copyWith({
    bool? completed,
    DateTime? completedAt,
    List<String>? skippedScreens,
  }) {
    return OnboardingStatus(
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      skippedScreens: skippedScreens ?? this.skippedScreens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
      'skipped_screens': skippedScreens,
    };
  }

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      skippedScreens:
          (json['skipped_screens'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
