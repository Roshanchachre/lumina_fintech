import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String tier;
  final bool isKycVerified;
  final String avatarUrl;
  final String phoneNumber;
  final String bio;
  final bool isProfileCompleted;

  const UserProfile({
    this.id = '',
    required this.name,
    required this.email,
    this.tier = 'Titanium Sovereign',
    this.isKycVerified = true,
    this.avatarUrl = 'assets/avatars/boy_1.png',
    this.phoneNumber = '',
    this.bio = '',
    this.isProfileCompleted = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['fullName'] ?? json['full_name'] ?? json['name'] ?? 'Lumina Pioneer').toString(),
      email: (json['email'] ?? '').toString(),
      tier: (json['tier'] ?? 'Titanium Sovereign').toString(),
      isKycVerified: json['isVerified'] == true || json['is_verified'] == 1 || json['isKycVerified'] == true,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url'] ?? 'assets/avatars/boy_1.png').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone_number'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      isProfileCompleted: json['isProfileCompleted'] == true || json['is_profile_completed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'email': email,
      'tier': tier,
      'isVerified': isKycVerified,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'isProfileCompleted': isProfileCompleted,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? tier,
    bool? isKycVerified,
    String? avatarUrl,
    String? phoneNumber,
    String? bio,
    bool? isProfileCompleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      tier: tier ?? this.tier,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}

class AvatarItem {
  final String id;
  final String gender; // 'boy' | 'girl'
  final String name;
  final String assetPath;
  final String description;
  final String style;

  const AvatarItem({
    required this.id,
    required this.gender,
    required this.name,
    required this.assetPath,
    required this.description,
    required this.style,
  });

  factory AvatarItem.fromJson(Map<String, dynamic> json) {
    return AvatarItem(
      id: json['id'] as String? ?? '',
      gender: json['gender'] as String? ?? 'boy',
      name: json['name'] as String? ?? '',
      assetPath: json['assetPath'] as String? ?? 'assets/avatars/boy_1.png',
      description: json['description'] as String? ?? '',
      style: json['style'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gender': gender,
      'name': name,
      'assetPath': assetPath,
      'description': description,
      'style': style,
    };
  }

  static const List<AvatarItem> defaults = [
    AvatarItem(
      id: 'boy_1',
      gender: 'boy',
      name: 'Kai',
      assetPath: 'assets/avatars/boy_1.png',
      description: 'Messy spiky hair, wireframe glasses, cozy sweater vest.',
      style: 'Lofi Scholar',
    ),
    AvatarItem(
      id: 'boy_2',
      gender: 'boy',
      name: 'Ren',
      assetPath: 'assets/avatars/boy_2.png',
      description: 'Wavy brown hair, confident smirk, cyberpunk bomber jacket.',
      style: 'Cyber Streetwear',
    ),
    AvatarItem(
      id: 'boy_3',
      gender: 'boy',
      name: 'Aiden',
      assetPath: 'assets/avatars/boy_3.png',
      description: 'Platinum undercut, cybernetic earpiece, high-collar shell.',
      style: 'Quantum Techwear',
    ),
    AvatarItem(
      id: 'boy_4',
      gender: 'boy',
      name: 'Leo',
      assetPath: 'assets/avatars/boy_4.png',
      description: 'Curly dark hair, retro sunglasses, relaxed oversized hoodie.',
      style: 'Retro Vibe',
    ),
    AvatarItem(
      id: 'girl_1',
      gender: 'girl',
      name: 'Maya',
      assetPath: 'assets/avatars/girl_1.png',
      description: 'Sharp dark bob with chic bangs, cat-eye glasses, emerald knit.',
      style: 'Minimalist Chic',
    ),
    AvatarItem(
      id: 'girl_2',
      gender: 'girl',
      name: 'Zara',
      assetPath: 'assets/avatars/girl_2.png',
      description: 'Flowing auburn hair, energetic smile, audio headset, neon windbreaker.',
      style: 'Speed & Sound',
    ),
    AvatarItem(
      id: 'girl_3',
      gender: 'girl',
      name: 'Yuki',
      assetPath: 'assets/avatars/girl_3.png',
      description: 'High braided ponytail, sharp focused gaze, cyber ear cuff.',
      style: 'Sovereign Enclave',
    ),
    AvatarItem(
      id: 'girl_4',
      gender: 'girl',
      name: 'Chloe',
      assetPath: 'assets/avatars/girl_4.png',
      description: 'Lilac pixie cut, gentle smile, oversized structured blazer.',
      style: 'High Fashion',
    ),
  ];
}

enum CardType { physical, virtual }

class LuminaCardModel {
  final String id;
  final String cardHolder;
  final String maskedPan;
  final String expiry;
  final String cvv;
  final double balance;
  final double dailyLimit;
  final bool isFrozen;
  final bool isOnlineEnabled;
  final bool isInternationalEnabled;
  final String tierName;
  final LinearGradient gradient;
  final Color accentColor;
  final CardType cardType;
  final String? cardNickname;
  final String? shippingAddress;
  final String? trackingNumber;
  final String? cardPin;
  final String? fullPan;
  final DateTime? issuedAt;
  final int shippingStep;

  const LuminaCardModel({
    required this.id,
    required this.cardHolder,
    required this.maskedPan,
    required this.expiry,
    required this.cvv,
    required this.balance,
    required this.dailyLimit,
    required this.isFrozen,
    required this.isOnlineEnabled,
    required this.isInternationalEnabled,
    required this.tierName,
    required this.gradient,
    required this.accentColor,
    this.cardType = CardType.physical,
    this.cardNickname,
    this.shippingAddress,
    this.trackingNumber,
    this.cardPin = '1234',
    this.fullPan,
    this.issuedAt,
    this.shippingStep = 2,
  });

  bool get isVirtual => cardType == CardType.virtual;
  bool get isPhysical => cardType == CardType.physical;

  LuminaCardModel copyWith({
    bool? isFrozen,
    bool? isOnlineEnabled,
    bool? isInternationalEnabled,
    double? dailyLimit,
    double? balance,
    String? cardPin,
    String? cardNickname,
    int? shippingStep,
    String? trackingNumber,
    String? shippingAddress,
  }) {
    return LuminaCardModel(
      id: id,
      cardHolder: cardHolder,
      maskedPan: maskedPan,
      expiry: expiry,
      cvv: cvv,
      balance: balance ?? this.balance,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      isFrozen: isFrozen ?? this.isFrozen,
      isOnlineEnabled: isOnlineEnabled ?? this.isOnlineEnabled,
      isInternationalEnabled: isInternationalEnabled ?? this.isInternationalEnabled,
      tierName: tierName,
      gradient: gradient,
      accentColor: accentColor,
      cardType: cardType,
      cardNickname: cardNickname ?? this.cardNickname,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      cardPin: cardPin ?? this.cardPin,
      fullPan: fullPan,
      issuedAt: issuedAt,
      shippingStep: shippingStep ?? this.shippingStep,
    );
  }
}

class PortfolioAssetAllocation {
  final String assetName;
  final String symbol;
  final double percentage;
  final double valuationUsd;
  final double apy;
  final Color color;
  final IconData icon;

  const PortfolioAssetAllocation({
    required this.assetName,
    required this.symbol,
    required this.percentage,
    required this.valuationUsd,
    required this.apy,
    required this.color,
    required this.icon,
  });
}

class TransactionRecord {
  final String id;
  final String title;
  final String category;
  final String time;
  final double amount;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final String referenceId;
  final String? blockchainTxHash;
  final double fee;

  const TransactionRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.amount,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
    required this.referenceId,
    this.blockchainTxHash,
    this.fee = 0.0,
  });
}

/// Structured Financial Time-Series Point for 1D, 1W, and 1M Market Curves
class FinancialDataPoint {
  final String timeLabel;
  final double value;
  final String? note;

  const FinancialDataPoint({
    required this.timeLabel,
    required this.value,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'timeLabel': timeLabel,
        'value': value,
        if (note != null) 'note': note,
      };

  factory FinancialDataPoint.fromJson(Map<String, dynamic> json) =>
      FinancialDataPoint(
        timeLabel: json['timeLabel'] as String,
        value: (json['value'] as num).toDouble(),
        note: json['note'] as String?,
      );
}
