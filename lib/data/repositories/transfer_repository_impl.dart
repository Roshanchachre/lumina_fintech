import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../models/account_models.dart';
import '../../theme/lumina_theme.dart';
import '../datasources/account_remote_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final AccountRemoteDataSource remoteDataSource;
  final Uuid uuid;
  final Set<String> _processedIdempotencyKeys = {};

  TransferRepositoryImpl({
    required this.remoteDataSource,
    Uuid? customUuid,
  }) : uuid = customUuid ?? const Uuid();

  @override
  Future<TransactionRecord> executeTransfer({
    required String recipient,
    required double amount,
    String? note,
    String? customIdempotencyKey,
  }) async {
    final key = customIdempotencyKey ?? uuid.v4();

    // Prevent client-side duplicate replay
    if (_processedIdempotencyKeys.contains(key)) {
      throw DuplicateTransactionException(idempotencyKey: key);
    }

    _processedIdempotencyKeys.add(key);

    try {
      final result = await remoteDataSource.postWireTransfer(
        idempotencyKey: key,
        recipient: recipient,
        amount: amount,
        category: 'Instant L2 Wire',
      );

      final refId = result['reference_id']?.toString() ?? 'WIRE-${key.substring(0, 8).toUpperCase()}';
      final txHash = result['blockchain_tx_hash']?.toString() ?? '0x71c...b29a';

      return TransactionRecord(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: recipient,
        category: 'Instant Wire Transfer',
        time: 'Just now',
        amount: amount,
        isPositive: false,
        icon: Icons.north_east_rounded,
        iconColor: LuminaColors.electricCobalt,
        referenceId: refId,
        blockchainTxHash: txHash,
      );
    } catch (e) {
      // Remove key if network failure occurred before dispatch
      if (e is! DuplicateTransactionException) {
        _processedIdempotencyKeys.remove(key);
      }
      rethrow;
    }
  }
}
