import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_fintech/core/security/secure_vault.dart';

void main() {
  group('SecureVault Cryptographic Storage Tests', () {
    late SecureVault vault;
    late InMemoryVaultStorage storage;

    setUp(() {
      storage = InMemoryVaultStorage();
      vault = SecureVault(storage: storage);
    });

    test('stores and retrieves session auth tokens securely', () async {
      expect(await vault.getAuthToken(), isNull);

      await vault.saveAuthToken('lumina_jwt_mock_token_abc123');
      expect(await vault.getAuthToken(), equals('lumina_jwt_mock_token_abc123'));

      await vault.clearAuthTokens();
      expect(await vault.getAuthToken(), isNull);
    });

    test('persists biometric enrollment flags', () async {
      expect(await vault.isBiometricsEnrolled(), isFalse);

      await vault.setBiometricsEnrolled(true);
      expect(await vault.isBiometricsEnrolled(), isTrue);

      await vault.setBiometricsEnrolled(false);
      expect(await vault.isBiometricsEnrolled(), isFalse);
    });

    test('persists discrete privacy shield mode', () async {
      expect(await vault.isDiscreteMode(), isFalse);

      await vault.setDiscreteMode(true);
      expect(await vault.isDiscreteMode(), isTrue);

      await vault.setDiscreteMode(false);
      expect(await vault.isDiscreteMode(), isFalse);
    });

    test('persists and defaults base currency', () async {
      expect(await vault.getBaseCurrency(), equals('USD'));

      await vault.setBaseCurrency('EUR');
      expect(await vault.getBaseCurrency(), equals('EUR'));

      await vault.setBaseCurrency('GBP');
      expect(await vault.getBaseCurrency(), equals('GBP'));
    });

    test('persists onboarding status flags', () async {
      expect(await vault.isOnboardingCompleted(), isFalse);

      await vault.setOnboardingCompleted(true);
      expect(await vault.isOnboardingCompleted(), isTrue);

      await vault.setOnboardingCompleted(false);
      expect(await vault.isOnboardingCompleted(), isFalse);
    });

    test('persists, checks, and verifies cryptographic vault PIN', () async {
      expect(await vault.hasUserPin(), isFalse);
      // Default demo fallback is 1234
      expect(await vault.verifyUserPin('1234'), isTrue);
      expect(await vault.verifyUserPin('9999'), isFalse);

      await vault.saveUserPin('8842');
      expect(await vault.hasUserPin(), isTrue);
      expect(await vault.verifyUserPin('8842'), isTrue);
      expect(await vault.verifyUserPin('1234'), isFalse);
    });

    test('logout clears auth token while preserving onboarding state', () async {
      await vault.saveAuthToken('session_token_xyz');
      await vault.setOnboardingCompleted(true);

      await vault.logout();
      expect(await vault.getAuthToken(), isNull);
      expect(await vault.isOnboardingCompleted(), isTrue);
    });

    test('wipes entire vault cleanly on factory reset / sign out', () async {
      await vault.saveAuthToken('token_123');
      await vault.setBiometricsEnrolled(true);
      await vault.setDiscreteMode(true);
      await vault.setBaseCurrency('JPY');

      await vault.wipeVault();

      expect(await vault.getAuthToken(), isNull);
      expect(await vault.isBiometricsEnrolled(), isFalse);
      expect(await vault.isDiscreteMode(), isFalse);
      expect(await vault.getBaseCurrency(), equals('USD'));
    });
  });
}
