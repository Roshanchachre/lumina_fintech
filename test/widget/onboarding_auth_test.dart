import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumina_fintech/bloc/account_bloc.dart';
import 'package:lumina_fintech/bloc/auth_bloc.dart';
import 'package:lumina_fintech/core/security/biometric_service.dart';
import 'package:lumina_fintech/core/security/secure_vault.dart';
import 'package:lumina_fintech/screens/auth_screen.dart';
import 'package:lumina_fintech/screens/login_screen.dart';
import 'package:lumina_fintech/screens/main_shell_screen.dart';
import 'package:lumina_fintech/screens/onboarding_screen.dart';
import 'package:lumina_fintech/screens/register_screen.dart';
import 'package:lumina_fintech/screens/settings_screen.dart';
import 'package:lumina_fintech/theme/lumina_theme.dart';
import 'package:lumina_fintech/widgets/mascot_widget.dart';
import '../helpers/mock_auth_repository.dart';

void main() {
  group('Onboarding & Authentication Flow Tests', () {
    late SecureVault testVault;
    late InMemoryVaultStorage testStorage;
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      testStorage = InMemoryVaultStorage();
      testVault = SecureVault(storage: testStorage);
      mockAuthRepo = MockAuthRepository();
    });

    testWidgets('OnboardingScreen renders Lumi mascot, pages, and skips to Auth', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AccountBloc(vault: testVault)),
            BlocProvider(create: (_) => AuthBloc(authRepository: mockAuthRepo)),
          ],
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: OnboardingScreen(secureVault: testVault),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Screen 1
      expect(find.text('LUMINA'), findsOneWidget);
      expect(find.text('SKIP'), findsOneWidget);
      expect(find.text('Your Wealth,\nTruly Sovereign'), findsOneWidget);
      expect(find.byType(LumiMascotWidget), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE to go to Screen 2
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      expect(find.text('High-Frequency\nYield Velocity'), findsOneWidget);

      // Tap CONTINUE to go to Screen 3
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      expect(find.text('Biometric Hardware\nVault Protection'), findsOneWidget);
      expect(find.text('INITIALIZE SECURE VAULT'), findsOneWidget);

      // Tap INITIALIZE SECURE VAULT
      await tester.tap(find.text('INITIALIZE SECURE VAULT'));
      await tester.pumpAndSettle();

      expect(await testVault.isOnboardingCompleted(), isTrue);
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('Onboarding SKIP button transitions to LoginScreen with no back route to onboarding', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AccountBloc(vault: testVault)),
            BlocProvider(create: (_) => AuthBloc(authRepository: mockAuthRepo)),
          ],
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: OnboardingScreen(secureVault: testVault),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap SKIP
      await tester.tap(find.text('SKIP'));
      await tester.pumpAndSettle();

      // Verified: Arrives at LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(await testVault.isOnboardingCompleted(), isTrue);

      // Verified: There is NO AppBar and NO back button leading back to Onboarding
      expect(find.byType(AppBar), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);

      // Verified: PopScope protects route with canPop == false
      final popScopeFinder = find.byType(PopScope);
      expect(popScopeFinder, findsOneWidget);
      final popScope = tester.widget<PopScope>(popScopeFinder);
      expect(popScope.canPop, isFalse);
    });

    testWidgets('AuthScreen validates 4-digit PIN correctly and enters MainShellScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => AccountBloc(),
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: AuthScreen(
              secureVault: testVault,
              biometricService: BiometricService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LUMINA VAULT'), findsOneWidget);

      // 1. Enter wrong PIN '9999'
      await tester.tap(find.text('9'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('9'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('9'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('9'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Incorrect passcode. Try again (Default: 1234)'), findsOneWidget);
      expect(find.byType(MainShellScreen), findsNothing);

      // 2. Enter correct PIN '1234'
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Should transition into MainShellScreen
      expect(find.byType(MainShellScreen), findsOneWidget);
    });

    testWidgets('AuthScreen provides UNLOCK WITH PASSWORD INSTEAD fallback to LoginScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AccountBloc(vault: testVault)),
            BlocProvider(create: (_) => AuthBloc(authRepository: mockAuthRepo)),
          ],
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: AuthScreen(
              secureVault: testVault,
              biometricService: BiometricService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('UNLOCK WITH PASSWORD INSTEAD'), findsOneWidget);

      await tester.tap(find.text('UNLOCK WITH PASSWORD INSTEAD'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('SettingsScreen shows SIGN OUT dialog and disconnects vault', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AccountBloc(vault: testVault)),
            BlocProvider(create: (_) => AuthBloc(authRepository: mockAuthRepo)),
          ],
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: SettingsScreen(secureVault: testVault),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify sign out button exists
      expect(find.text('SIGN OUT & DISCONNECT VAULT'), findsOneWidget);

      // Scroll until sign out button is visible
      await tester.scrollUntilVisible(
        find.text('SIGN OUT & DISCONNECT VAULT'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap Sign Out button
      await tester.tap(find.text('SIGN OUT & DISCONNECT VAULT'));
      await tester.pumpAndSettle();

      // Verify modal dialog appeared
      expect(find.text('DISCONNECT VAULT?'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SIGN OUT'), findsOneWidget);

      // Tap SIGN OUT confirmation
      await tester.tap(find.text('SIGN OUT'));
      await tester.pumpAndSettle();

      // Should redirect to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
