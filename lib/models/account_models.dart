import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final String email;
  final String tier;
  final bool isKycVerified;
  final String avatarUrl;

  const UserProfile({
    required this.name,
    required this.email,
    required this.tier,
    required this.isKycVerified,
    this.avatarUrl = '',
  });
}

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
  });

  LuminaCardModel copyWith({
    bool? isFrozen,
    bool? isOnlineEnabled,
    bool? isInternationalEnabled,
    double? dailyLimit,
    double? balance,
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
