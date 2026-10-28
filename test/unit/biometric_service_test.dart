import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lumina_fintech/core/security/biometric_service.dart';

class MockLocalAuthentication extends Fake implements LocalAuthentication {
  bool supported = true;
  bool canCheck = true;
  bool authResult = true;
  List<BiometricType> types = [BiometricType.face, BiometricType.fingerprint];
  bool throwOnAuth = false;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => types;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    if (throwOnAuth) {
      throw PlatformException(code: 'LockedOut', message: 'Too many attempts');
    }
    return authResult;
  }

  @override
  Future<bool> stopAuthentication() async => true;
}

void main() {
  group('BiometricService Institutional Security Tests', () {
    late MockLocalAuthentication mockAuth;
    late BiometricService bioService;

    setUp(() {
      mockAuth = MockLocalAuthentication();
      bioService = BiometricService(auth: mockAuth);
    });

    test('detects device biometric readiness correctly', () async {
      expect(await bioService.isBiometricReady(), isTrue);

      mockAuth.canCheck = false;
      expect(await bioService.isBiometricReady(), isFalse);

      mockAuth.canCheck = true;
      mockAuth.supported = false;
      expect(await bioService.isBiometricReady(), isFalse);
    });

    test('returns enrolled biometric types accurately', () async {
      final types = await bioService.getAvailableBiometrics();
      expect(types, contains(BiometricType.face));
      expect(types, contains(BiometricType.fingerprint));
    });

    test('authenticates successfully when user provides valid biometric', () async {
      mockAuth.authResult = true;
      final result = await bioService.authenticate(
        localizedReason: 'Authenticate to access vault',
      );
      expect(result, isTrue);
    });

    test('returns false when user cancels or biometric fails', () async {
      mockAuth.authResult = false;
      final result = await bioService.authenticate(
        localizedReason: 'Authenticate to access vault',
      );
      expect(result, isFalse);
    });

    test('handles platform exceptions gracefully without crashing', () async {
      mockAuth.throwOnAuth = true;
      final result = await bioService.authenticate(
        localizedReason: 'Authenticate to access vault',
      );
      expect(result, isFalse);
    });
  });
}
