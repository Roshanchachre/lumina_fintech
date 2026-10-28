import 'package:flutter/material.dart';
import '../../domain/repositories/account_repository.dart';
import '../../models/account_models.dart';
import '../../theme/lumina_theme.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> getUserProfile() async {
    return const UserProfile(
      name: 'Roshan Chachre',
      email: 'roshan@luminawealth.com',
      tier: 'Titanium Sovereign',
      isKycVerified: true,
    );
  }

  @override
  Future<double> getAccountBalance() async {
    final summary = await remoteDataSource.fetchAccountSummary();
    final balance = summary['balance'];
    if (balance is num) {
      return balance.toDouble();
    }
    return 128450.85;
  }

  @override
  Future<List<LuminaCardModel>> getCards() async {
    return const [
      LuminaCardModel(
        id: 'card_titanium_01',
        cardHolder: 'ROSHAN CHACHRE',
        maskedPan: '4820  ••••  ••••  8492',
        expiry: '09/29',
        cvv: '849',
        balance: 48250.75,
        dailyLimit: 25000.00,
        isFrozen: false,
        isOnlineEnabled: true,
        isInternationalEnabled: true,
        tierName: 'Titanium Executive',
        gradient: LuminaColors.cardGradientTitanium,
        accentColor: LuminaColors.electricCobalt,
      ),
      LuminaCardModel(
        id: 'card_obsidian_02',
        cardHolder: 'ROSHAN CHACHRE',
        maskedPan: '5520  ••••  ••••  3918',
        expiry: '11/30',
        cvv: '392',
        balance: 62100.00,
        dailyLimit: 50000.00,
        isFrozen: false,
        isOnlineEnabled: true,
        isInternationalEnabled: true,
        tierName: 'Obsidian Sovereign',
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E142B), Color(0xFF110B1A), Color(0xFF08050D)],
        ),
        accentColor: LuminaColors.neonPurple,
      ),
      LuminaCardModel(
        id: 'card_emerald_03',
        cardHolder: 'ROSHAN CHACHRE',
        maskedPan: '4111  ••••  ••••  9921',
        expiry: '04/28',
        cvv: '109',
        balance: 18100.10,
        dailyLimit: 15000.00,
        isFrozen: false,
        isOnlineEnabled: true,
        isInternationalEnabled: false,
        tierName: 'Emerald Yield L2',
        gradient: LuminaColors.cardGradientEmerald,
        accentColor: LuminaColors.neonGreen,
      ),
    ];
  }

  @override
  Future<void> toggleCardFreeze(String cardId, bool isFrozen) async {
    await remoteDataSource.updateCardFreeze(cardId, isFrozen);
  }

  @override
  Future<void> updateCardPermissions({
    required String cardId,
    required bool isOnlineEnabled,
    required bool isInternationalEnabled,
  }) async {
    // Persist permissions via remote data source
  }

  @override
  Future<List<PortfolioAssetAllocation>> getAssetAllocations() async {
    return const [
      PortfolioAssetAllocation(
        assetName: 'Liquid Fiat Reserves',
        symbol: 'USD / USDC',
        percentage: 45.0,
        valuationUsd: 57802.88,
        apy: 5.2,
        color: LuminaColors.electricCobalt,
        icon: Icons.account_balance_rounded,
      ),
      PortfolioAssetAllocation(
        assetName: 'Arbitrum L2 Staked ETH',
        symbol: 'wstETH',
        percentage: 30.0,
        valuationUsd: 38535.25,
        apy: 4.8,
        color: LuminaColors.neonPurple,
        icon: Icons.token_rounded,
      ),
      PortfolioAssetAllocation(
        assetName: 'Sovereign Tokenized Gold',
        symbol: 'PAXG',
        percentage: 15.0,
        valuationUsd: 19267.62,
        apy: 1.5,
        color: LuminaColors.amberWarning,
        icon: Icons.shield_rounded,
      ),
      PortfolioAssetAllocation(
        assetName: 'Venture & SaaS Equities',
        symbol: 'TECH-INDEX',
        percentage: 10.0,
        valuationUsd: 12845.10,
        apy: 14.2,
        color: LuminaColors.neonGreen,
        icon: Icons.trending_up_rounded,
      ),
    ];
  }

  @override
  Future<Map<String, List<double>>> getHistoricalChartPoints() async {
    return const {
      '1D': [40, 48, 45, 58, 52, 65, 62, 74, 70, 85],
      '1W': [30, 42, 38, 55, 48, 62, 59, 72, 80, 92],
      '1M': [35, 45, 40, 60, 55, 70, 65, 82, 78, 95],
      '1Y': [20, 32, 28, 45, 40, 58, 65, 75, 85, 100],
      'ALL': [15, 25, 35, 30, 50, 65, 60, 80, 90, 100],
    };
  }

  @override
  Future<List<TransactionRecord>> getTransactions() async {
    return const [
      TransactionRecord(
        id: 'tx_01',
        title: 'Stripe SaaS Revenue',
        category: 'Incoming Payout',
        time: '11:42 AM',
        amount: 4250.00,
        isPositive: true,
        icon: Icons.flash_on_rounded,
        iconColor: LuminaColors.neonGreen,
        referenceId: 'STRIPE-PAYOUT-98214',
        blockchainTxHash: '0x8f2a...c391',
      ),
      TransactionRecord(
        id: 'tx_02',
        title: 'Apple Store Soho',
        category: 'Hardware & Tech',
        time: 'Yesterday',
        amount: 1299.00,
        isPositive: false,
        icon: Icons.apple_rounded,
        iconColor: LuminaColors.electricCobalt,
        referenceId: 'APL-POS-48921',
      ),
      TransactionRecord(
        id: 'tx_03',
        title: 'Arbitrum ETH Yield',
        category: 'Staking Rewards',
        time: 'Oct 26',
        amount: 348.60,
        isPositive: true,
        icon: Icons.token_rounded,
        iconColor: LuminaColors.neonPurple,
        referenceId: 'ARB-STAKE-00214',
        blockchainTxHash: '0x3b11...99ef',
      ),
      TransactionRecord(
        id: 'tx_04',
        title: 'Figma Enterprise',
        category: 'Software Subscription',
        time: 'Oct 24',
        amount: 45.00,
        isPositive: false,
        icon: Icons.design_services_rounded,
        iconColor: LuminaColors.amberWarning,
        referenceId: 'FIG-SUB-77182',
      ),
    ];
  }
}
