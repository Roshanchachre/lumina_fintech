import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lumina_fintech/core/security/biometric_service.dart';
import 'package:lumina_fintech/widgets/privacy_veil.dart';

class TestMockLocalAuth extends Fake implements LocalAuthentication {
  bool authSuccess = true;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> get canCheckBiometrics async => true;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    return authSuccess;
  }
}

void main() {
  group('LuminaPrivacyGuard Security Veil Tests', () {
    late TestMockLocalAuth mockAuth;
    late BiometricService bioService;

    setUp(() {
      mockAuth = TestMockLocalAuth();
      bioService = BiometricService(auth: mockAuth);
    });

    testWidgets('renders child cleanly when veil is inactive', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LuminaPrivacyGuard(
            biometricService: bioService,
            initialVeiled: false,
            child: const Scaffold(
              body: Center(
                child: Text('Secret Financial Balance: \$128,450.85'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Secret Financial Balance: \$128,450.85'), findsOneWidget);
      expect(find.text('VAULT SECURED'), findsNothing);
    });

    testWidgets('obscures screen with VAULT SECURED when initialVeiled is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LuminaPrivacyGuard(
            biometricService: bioService,
            initialVeiled: true,
            child: const Scaffold(
              body: Center(
                child: Text('Secret Financial Balance: \$128,450.85'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('VAULT SECURED'), findsOneWidget);
      expect(find.text('UNLOCK WITH BIOMETRICS'), findsOneWidget);
    });

    testWidgets('lifts veil upon successful biometric authentication', (tester) async {
      mockAuth.authSuccess = true;

      await tester.pumpWidget(
        MaterialApp(
          home: LuminaPrivacyGuard(
            biometricService: bioService,
            initialVeiled: true,
            child: const Scaffold(
              body: Center(
                child: Text('Secret Financial Balance: \$128,450.85'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('VAULT SECURED'), findsOneWidget);

      // Tap unlock button
      await tester.tap(find.text('UNLOCK WITH BIOMETRICS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Veil is dismissed
      expect(find.text('VAULT SECURED'), findsNothing);
      expect(find.text('Secret Financial Balance: \$128,450.85'), findsOneWidget);
    });

    testWidgets('activates veil on app lifecycle inactive state', (tester) async {
      final key = GlobalKey<State<LuminaPrivacyGuard>>();

      await tester.pumpWidget(
        MaterialApp(
          home: LuminaPrivacyGuard(
            key: key,
            biometricService: bioService,
            initialVeiled: false,
            child: const Scaffold(
              body: Center(
                child: Text('Protected Data'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('VAULT SECURED'), findsNothing);

      // Simulate app switcher lifecycle event
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('VAULT SECURED'), findsOneWidget);
    });
  });
}
