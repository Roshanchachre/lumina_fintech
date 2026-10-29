import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Vault storage interface to allow deterministic unit testing
abstract class IVaultStorage {
  Future<void> write({required String key, required String? value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
}

/// Production implementation using FlutterSecureStorage with hardware enclave protection
class HardwareSecureStorage implements IVaultStorage {
  final FlutterSecureStorage _storage;

  HardwareSecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
              mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<bool> containsKey({required String key}) =>
      _storage.containsKey(key: key);
}

/// In-memory vault storage for isolated unit tests and test fixtures
class InMemoryVaultStorage implements IVaultStorage {
  final Map<String, String> _memory = {};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _memory.remove(key);
    } else {
      _memory[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async => _memory[key];

  @override
  Future<void> delete({required String key}) async {
    _memory.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _memory.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _memory.containsKey(key);
}

/// Bank-grade Cryptographic Secure Vault
/// Encrypts session tokens, biometric enrollment flags, and discrete privacy states.
class SecureVault {
  static const String keyAuthToken = 'lumina_vault_auth_token';
  static const String keyRefreshToken = 'lumina_vault_refresh_token';
  static const String keyBiometricsEnrolled = 'lumina_vault_biometrics_enrolled';
  static const String keyDiscreteMode = 'lumina_vault_discrete_mode';
  static const String keyBaseCurrency = 'lumina_vault_base_currency';
  static const String keyCardPinPrefix = 'lumina_vault_card_pin_salt';
  static const String keyOnboardingCompleted = 'lumina_vault_onboarding_completed';
  static const String keyUserPin = 'lumina_vault_user_pin';
  static const String keySavedEmail = 'lumina_vault_saved_email';

  final IVaultStorage _storage;

  SecureVault({IVaultStorage? storage})
      : _storage = storage ?? HardwareSecureStorage();

  /// Saved Account Email
  Future<void> saveLastEmail(String email) async {
    await _storage.write(key: keySavedEmail, value: email);
  }

  Future<String?> getLastEmail() async {
    return await _storage.read(key: keySavedEmail);
  }

  /// Session Token Management
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: keyAuthToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: keyAuthToken);
  }

  Future<void> clearAuthTokens() async {
    await _storage.delete(key: keyAuthToken);
    await _storage.delete(key: keyRefreshToken);
  }

  /// Biometrics Enrollment Flag
  Future<void> setBiometricsEnrolled(bool enabled) async {
    await _storage.write(
      key: keyBiometricsEnrolled,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> isBiometricsEnrolled() async {
    final value = await _storage.read(key: keyBiometricsEnrolled);
    return value == 'true';
  }

  /// Discrete Gaze Privacy Mode
  Future<void> setDiscreteMode(bool enabled) async {
    await _storage.write(
      key: keyDiscreteMode,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> isDiscreteMode() async {
    final value = await _storage.read(key: keyDiscreteMode);
    return value == 'true';
  }

  /// Base Currency Preference
  Future<void> setBaseCurrency(String currency) async {
    await _storage.write(key: keyBaseCurrency, value: currency);
  }

  Future<String> getBaseCurrency() async {
    final value = await _storage.read(key: keyBaseCurrency);
    return value ?? 'USD';
  }

  /// Onboarding State
  Future<void> setOnboardingCompleted(bool completed) async {
    await _storage.write(
      key: keyOnboardingCompleted,
      value: completed ? 'true' : 'false',
    );
  }

  Future<bool> isOnboardingCompleted() async {
    final value = await _storage.read(key: keyOnboardingCompleted);
    return value == 'true';
  }

  /// User Security PIN (4-digit cryptographic vault pass)
  Future<void> saveUserPin(String pin) async {
    await _storage.write(key: keyUserPin, value: pin);
  }

  Future<bool> hasUserPin() async {
    final pin = await _storage.read(key: keyUserPin);
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> verifyUserPin(String enteredPin) async {
    final storedPin = await _storage.read(key: keyUserPin);
    // Default fallback demo PIN '1234' if none configured yet
    final targetPin = storedPin ?? '1234';
    return enteredPin == targetPin;
  }

  /// User Sign Out / Vault Disconnect
  Future<void> logout() async {
    await clearAuthTokens();
    // Invalidate session while preserving onboarding and hardware configuration
  }

  /// Clear entire vault on logout / factory reset
  Future<void> wipeVault() async {
    await _storage.deleteAll();
  }
}
