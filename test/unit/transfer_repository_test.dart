import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_fintech/core/network/api_client.dart';
import 'package:lumina_fintech/core/network/api_exceptions.dart';
import 'package:lumina_fintech/data/datasources/account_remote_datasource.dart';
import 'package:lumina_fintech/data/repositories/transfer_repository_impl.dart';

void main() {
  group('TransferRepositoryImpl Idempotency & Execution Tests', () {
    late TransferRepositoryImpl repository;
    late AccountRemoteDataSource remoteDataSource;

    setUp(() {
      remoteDataSource = AccountRemoteDataSourceImpl(apiClient: ApiClient());
      repository = TransferRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test('executes instant wire transfer successfully', () async {
      final tx = await repository.executeTransfer(
        recipient: 'Sarah Connor',
        amount: 1250.00,
        note: 'Arbitrum L2 Wire',
      );

      expect(tx.title, equals('Sarah Connor'));
      expect(tx.amount, equals(1250.00));
      expect(tx.isPositive, isFalse);
      expect(tx.referenceId, startsWith('WIRE-'));
      expect(tx.blockchainTxHash, isNotNull);
    });

    test('prevents duplicate transactions with same idempotency key', () async {
      const fixedKey = 'IDEMPOTENCY_KEY_ABC_123';

      // First execution should succeed
      final firstTx = await repository.executeTransfer(
        recipient: 'Sarah Connor',
        amount: 500.00,
        customIdempotencyKey: fixedKey,
      );
      expect(firstTx.title, equals('Sarah Connor'));

      // Second execution with same key MUST throw DuplicateTransactionException
      expect(
        () => repository.executeTransfer(
          recipient: 'Sarah Connor',
          amount: 500.00,
          customIdempotencyKey: fixedKey,
        ),
        throwsA(isA<DuplicateTransactionException>()),
      );
    });
  });
}
