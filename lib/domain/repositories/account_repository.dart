import '../../models/account_models.dart';

abstract class AccountRepository {
  Future<UserProfile> getUserProfile();
  Future<double> getAccountBalance();
  Future<List<LuminaCardModel>> getCards();
  Future<void> toggleCardFreeze(String cardId, bool isFrozen);
  Future<void> updateCardPermissions({
    required String cardId,
    required bool isOnlineEnabled,
    required bool isInternationalEnabled,
  });
  Future<List<PortfolioAssetAllocation>> getAssetAllocations();
  Future<Map<String, List<double>>> getHistoricalChartPoints();
  Future<List<TransactionRecord>> getTransactions();
}
