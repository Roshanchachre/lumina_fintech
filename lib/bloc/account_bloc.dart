import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_client.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_vault.dart';
import '../data/datasources/account_remote_datasource.dart';
import '../data/repositories/account_repository_impl.dart';
import '../data/repositories/transfer_repository_impl.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/transfer_repository.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';

// EVENTS
abstract class AccountEvent {}

class LoadAccountData extends AccountEvent {}

class ChangeTimeframe extends AccountEvent {
  final String period;
  ChangeTimeframe(this.period);
}

class ToggleDiscreteMode extends AccountEvent {}

class ToggleCardFreeze extends AccountEvent {
  final String cardId;
  ToggleCardFreeze(this.cardId);
}

class ToggleCardOnline extends AccountEvent {
  final String cardId;
  ToggleCardOnline(this.cardId);
}

class ToggleCardInternational extends AccountEvent {
  final String cardId;
  ToggleCardInternational(this.cardId);
}

class ExecuteWireTransfer extends AccountEvent {
  final String recipient;
  final double amount;
  final String note;
  ExecuteWireTransfer({
    required this.recipient,
    required this.amount,
    this.note = 'Instant L2 Wire',
  });
}

class ToggleBiometrics extends AccountEvent {
  final bool isEnabled;
  ToggleBiometrics(this.isEnabled);
}

class ChangeBaseCurrency extends AccountEvent {
  final String currency;
  ChangeBaseCurrency(this.currency);
}

// STATE
class AccountState {
  final bool isLoading;
  final UserProfile user;
  final String selectedPeriod;
  final bool isDiscreteMode;
  final bool isBiometricsEnabled;
  final String baseCurrency;
  final double balance;
  final double balanceChange;
  final double percentChange;
  final List<LuminaCardModel> cards;
  final List<PortfolioAssetAllocation> allocations;
  final List<TransactionRecord> transactions;
  final Map<String, List<double>> chartPoints;

  const AccountState({
    required this.isLoading,
    required this.user,
    required this.selectedPeriod,
    required this.isDiscreteMode,
    required this.isBiometricsEnabled,
    required this.baseCurrency,
    required this.balance,
    required this.balanceChange,
    required this.percentChange,
    required this.cards,
    required this.allocations,
    required this.transactions,
    required this.chartPoints,
  });

  AccountState copyWith({
    bool? isLoading,
    UserProfile? user,
    String? selectedPeriod,
    bool? isDiscreteMode,
    bool? isBiometricsEnabled,
    String? baseCurrency,
    double? balance,
    double? balanceChange,
    double? percentChange,
    List<LuminaCardModel>? cards,
    List<PortfolioAssetAllocation>? allocations,
    List<TransactionRecord>? transactions,
    Map<String, List<double>>? chartPoints,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isDiscreteMode: isDiscreteMode ?? this.isDiscreteMode,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      balance: balance ?? this.balance,
      balanceChange: balanceChange ?? this.balanceChange,
      percentChange: percentChange ?? this.percentChange,
      cards: cards ?? this.cards,
      allocations: allocations ?? this.allocations,
      transactions: transactions ?? this.transactions,
      chartPoints: chartPoints ?? this.chartPoints,
    );
  }

  factory AccountState.initial() {
    return AccountState(
      isLoading: false,
      user: const UserProfile(
        name: 'Roshan Chachre',
        email: 'roshan@luminawealth.com',
        tier: 'Titanium Sovereign',
        isKycVerified: true,
      ),
      selectedPeriod: '1M',
      isDiscreteMode: false,
      isBiometricsEnabled: true,
      baseCurrency: 'USD',
      balance: 128450.85,
      balanceChange: 3820.40,
      percentChange: 3.06,
      cards: [
        const LuminaCardModel(
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
        const LuminaCardModel(
          id: 'card_cobalt_02',
          cardHolder: 'ROSHAN CHACHRE',
          maskedPan: '5520  ••••  ••••  3918',
          expiry: '11/30',
          cvv: '392',
          balance: 62100.00,
          dailyLimit: 50000.00,
          isFrozen: false,
          isOnlineEnabled: true,
          isInternationalEnabled: true,
          tierName: 'Electric Cobalt Sovereign',
          gradient: LuminaColors.cardGradientCobalt,
          accentColor: LuminaColors.electricCobalt,
        ),
        const LuminaCardModel(
          id: 'card_acid_03',
          cardHolder: 'ROSHAN CHACHRE',
          maskedPan: '4111  ••••  ••••  9921',
          expiry: '04/28',
          cvv: '109',
          balance: 18100.10,
          dailyLimit: 15000.00,
          isFrozen: false,
          isOnlineEnabled: true,
          isInternationalEnabled: false,
          tierName: 'Acid Volt Yield L2',
          gradient: LuminaColors.cardGradientAcid,
          accentColor: LuminaColors.acidLime,
        ),
      ],
      allocations: const [
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
          color: LuminaColors.acidLime,
          icon: Icons.trending_up_rounded,
        ),
      ],
      transactions: const [
        TransactionRecord(
          id: 'tx_01',
          title: 'Stripe SaaS Revenue',
          category: 'Incoming Payout',
          time: '11:42 AM',
          amount: 4250.00,
          isPositive: true,
          icon: Icons.flash_on_rounded,
          iconColor: LuminaColors.acidLime,
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
          iconColor: LuminaColors.electricCobalt,
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
      ],
      chartPoints: const {
        '1D': [40, 48, 45, 58, 52, 65, 62, 74, 70, 85],
        '1W': [30, 42, 38, 55, 48, 62, 59, 72, 80, 92],
        '1M': [35, 45, 40, 60, 55, 70, 65, 82, 78, 95],
        '1Y': [20, 32, 28, 45, 40, 58, 65, 75, 85, 100],
        'ALL': [15, 25, 35, 30, 50, 65, 60, 80, 90, 100],
      },
    );
  }
}

// BLOC
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;
  final TransferRepository transferRepository;
  final SecureVault secureVault;
  final BiometricService biometricService;

  AccountBloc({
    AccountRepository? accountRepo,
    TransferRepository? transferRepo,
    SecureVault? vault,
    BiometricService? bioService,
  })  : accountRepository = accountRepo ??
            AccountRepositoryImpl(
              remoteDataSource: AccountRemoteDataSourceImpl(apiClient: ApiClient()),
            ),
        transferRepository = transferRepo ??
            TransferRepositoryImpl(
              remoteDataSource: AccountRemoteDataSourceImpl(apiClient: ApiClient()),
            ),
        secureVault = vault ?? SecureVault(),
        biometricService = bioService ?? BiometricService(),
        super(AccountState.initial()) {
    on<LoadAccountData>(_onLoadAccountData);
    on<ChangeTimeframe>(_onChangeTimeframe);
    on<ToggleDiscreteMode>(_onToggleDiscreteMode);
    on<ToggleCardFreeze>(_onToggleCardFreeze);
    on<ToggleCardOnline>(_onToggleCardOnline);
    on<ToggleCardInternational>(_onToggleCardInternational);
    on<ExecuteWireTransfer>(_onExecuteWireTransfer);
    on<ToggleBiometrics>(_onToggleBiometrics);
    on<ChangeBaseCurrency>(_onChangeBaseCurrency);
  }

  Future<void> _onLoadAccountData(
    LoadAccountData event,
    Emitter<AccountState> emit,
  ) async {
    final isBioEnrolled = await secureVault.isBiometricsEnrolled();
    final isDiscrete = await secureVault.isDiscreteMode();
    final currency = await secureVault.getBaseCurrency();

    emit(state.copyWith(
      isLoading: false,
      isBiometricsEnabled: isBioEnrolled,
      isDiscreteMode: isDiscrete,
      baseCurrency: currency,
    ));
  }

  void _onChangeTimeframe(ChangeTimeframe event, Emitter<AccountState> emit) {
    final periodMap = {
      '1D': {'balance': 124630.45, 'change': 680.15, 'pct': 0.55},
      '1W': {'balance': 121890.00, 'change': 2740.85, 'pct': 2.30},
      '1M': {'balance': 128450.85, 'change': 3820.40, 'pct': 3.06},
      '1Y': {'balance': 154210.60, 'change': 29580.00, 'pct': 23.73},
      'ALL': {'balance': 186900.20, 'change': 62270.50, 'pct': 49.96},
    };

    final data = periodMap[event.period] ?? periodMap['1M']!;
    emit(state.copyWith(
      selectedPeriod: event.period,
      balance: data['balance']!,
      balanceChange: data['change']!,
      percentChange: data['pct']!,
    ));
  }

  Future<void> _onToggleDiscreteMode(
    ToggleDiscreteMode event,
    Emitter<AccountState> emit,
  ) async {
    final nextVal = !state.isDiscreteMode;
    await secureVault.setDiscreteMode(nextVal);
    emit(state.copyWith(isDiscreteMode: nextVal));
  }

  void _onToggleCardFreeze(ToggleCardFreeze event, Emitter<AccountState> emit) {
    final updatedCards = state.cards.map((card) {
      if (card.id == event.cardId) {
        return card.copyWith(isFrozen: !card.isFrozen);
      }
      return card;
    }).toList();
    emit(state.copyWith(cards: updatedCards));
  }

  void _onToggleCardOnline(ToggleCardOnline event, Emitter<AccountState> emit) {
    final updatedCards = state.cards.map((card) {
      if (card.id == event.cardId) {
        return card.copyWith(isOnlineEnabled: !card.isOnlineEnabled);
      }
      return card;
    }).toList();
    emit(state.copyWith(cards: updatedCards));
  }

  void _onToggleCardInternational(ToggleCardInternational event, Emitter<AccountState> emit) {
    final updatedCards = state.cards.map((card) {
      if (card.id == event.cardId) {
        return card.copyWith(isInternationalEnabled: !card.isInternationalEnabled);
      }
      return card;
    }).toList();
    emit(state.copyWith(cards: updatedCards));
  }

  Future<void> _onExecuteWireTransfer(
    ExecuteWireTransfer event,
    Emitter<AccountState> emit,
  ) async {
    try {
      final newTx = await transferRepository.executeTransfer(
        recipient: event.recipient,
        amount: event.amount,
        note: event.note,
      );

      final newBalance = state.balance - event.amount;
      emit(state.copyWith(
        balance: newBalance,
        transactions: [newTx, ...state.transactions],
      ));
    } catch (_) {
      final fallbackTx = TransactionRecord(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: event.recipient,
        category: 'Instant Wire Transfer',
        time: 'Just now',
        amount: event.amount,
        isPositive: false,
        icon: Icons.north_east_rounded,
        iconColor: LuminaColors.electricCobalt,
        referenceId: 'WIRE-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        blockchainTxHash: '0x71c...b29a',
      );

      emit(state.copyWith(
        balance: state.balance - event.amount,
        transactions: [fallbackTx, ...state.transactions],
      ));
    }
  }

  Future<void> _onToggleBiometrics(
    ToggleBiometrics event,
    Emitter<AccountState> emit,
  ) async {
    if (event.isEnabled) {
      final success = await biometricService.authenticate(
        localizedReason: 'Authenticate with Face ID / Biometrics to enable Lumina Security Vault',
      );
      if (success) {
        await secureVault.setBiometricsEnrolled(true);
        emit(state.copyWith(isBiometricsEnabled: true));
      } else {
        emit(state.copyWith(isBiometricsEnabled: false));
      }
    } else {
      await secureVault.setBiometricsEnrolled(false);
      emit(state.copyWith(isBiometricsEnabled: false));
    }
  }

  Future<void> _onChangeBaseCurrency(
    ChangeBaseCurrency event,
    Emitter<AccountState> emit,
  ) async {
    await secureVault.setBaseCurrency(event.currency);
    emit(state.copyWith(baseCurrency: event.currency));
  }
}
