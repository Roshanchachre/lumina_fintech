import '../../models/account_models.dart';

abstract class TransferRepository {
  Future<TransactionRecord> executeTransfer({
    required String recipient,
    required double amount,
    String? note,
    String? customIdempotencyKey,
  });
}
