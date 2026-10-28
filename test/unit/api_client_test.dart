import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_fintech/core/network/api_client.dart';
import 'package:lumina_fintech/core/network/api_exceptions.dart';

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test('sets and clears authentication tokens cleanly', () {
      apiClient.setAuthToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy');
      // Token is set in internal state
      apiClient.clearAuthToken();
    });

    test('NetworkException has descriptive message', () {
      const ex = NetworkException();
      expect(ex.message, contains('Unable to reach institutional banking server'));
    });

    test('DuplicateTransactionException carries idempotency key', () {
      const ex = DuplicateTransactionException(idempotencyKey: 'TEST_KEY_123');
      expect(ex.idempotencyKey, equals('TEST_KEY_123'));
      expect(ex.statusCode, equals(409));
    });

    test('InsufficientFundsException has 422 status code', () {
      const ex = InsufficientFundsException();
      expect(ex.statusCode, equals(422));
    });
  });
}
