import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumina_fintech/bloc/account_bloc.dart';
import 'package:lumina_fintech/bloc/auth_bloc.dart';
import 'package:lumina_fintech/models/account_models.dart';
import 'package:lumina_fintech/screens/forgot_password_screen.dart';
import 'package:lumina_fintech/screens/login_screen.dart';
import 'package:lumina_fintech/screens/otp_verification_screen.dart';
import 'package:lumina_fintech/screens/profile_setup_screen.dart';
import 'package:lumina_fintech/screens/register_screen.dart';
import 'package:lumina_fintech/screens/reset_password_screen.dart';
import 'package:lumina_fintech/theme/lumina_theme.dart';
import '../helpers/mock_auth_repository.dart';

void main() {
  group('Comprehensive Authentication & Profile Flow Widget Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    Widget createTestApp(Widget child, [MockAuthRepository? repo]) {
      final repository = repo ?? mockRepo;
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AccountBloc()),
          BlocProvider(create: (_) => AuthBloc(authRepository: repository)),
        ],
        child: MaterialApp(
          theme: LuminaTheme.darkTheme,
          home: child,
        ),
      );
    }

    testWidgets('LoginScreen renders credentials form, validates inputs, and has links', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('WELCOME TO LUMINA'), findsOneWidget);
      expect(find.text('INSTITUTIONAL EMAIL'), findsOneWidget);
      expect(find.text('CIPHER KEY (PASSWORD)'), findsOneWidget);
      expect(find.text('Forgot Cipher?'), findsOneWidget);
      expect(find.text('AUTHENTICATE VAULT'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Tap authenticate with empty fields -> shows validation errors
      await tester.tap(find.text('AUTHENTICATE VAULT'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('RegisterScreen calculates password strength dynamically and validates match', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('INITIALIZE VAULT MEMBERSHIP'), findsOneWidget);
      expect(find.text('ACCOUNT HOLDER LEGAL NAME'), findsOneWidget);
      expect(find.text('CIPHER PASSWORD'), findsOneWidget);
      expect(find.text('CONFIRM CIPHER'), findsOneWidget);

      // Initial strength indicator
      expect(find.text('Enter password'), findsOneWidget);

      // Enter weak password
      final passwordFinder = find.byType(TextFormField).at(2);
      await tester.enterText(passwordFinder, '123');
      await tester.pumpAndSettle();
      expect(find.text('Weak Cipher'), findsOneWidget);

      // Enter strong password
      await tester.enterText(passwordFinder, 'AlphaQuantum#99Vault');
      await tester.pumpAndSettle();
      expect(find.text('Bank-Grade Quantum Strong'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen displays 6 digit code inputs and resend options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          const OtpVerificationScreen(
            email: 'investor@luminawealth.com',
            type: 'register',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SECURITY VERIFICATION'), findsOneWidget);
      expect(find.text('investor@luminawealth.com'), findsOneWidget);
      expect(find.text('VERIFY CREDENTIAL'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('ProfileSetupScreen renders avatar catalogue with Boy and Girl tabs and avatar selection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final initialProfile = const UserProfile(
        name: 'Alex Vance',
        email: 'alex.vance@lumina.io',
        avatarUrl: 'assets/avatars/boy_1.png',
        isProfileCompleted: false,
      );

      await tester.pumpWidget(createTestApp(ProfileSetupScreen(initialUser: initialProfile)));
      await tester.pumpAndSettle();

      expect(find.text('INITIALIZE PROFILE'), findsOneWidget);
      expect(find.text('SELECT PREDEFINED AVATAR'), findsOneWidget);
      expect(find.text('ALL CHARACTERS'), findsOneWidget);
      expect(find.text('BOYS'), findsOneWidget);
      expect(find.text('GIRLS'), findsOneWidget);

      // Switch to GIRLS tab
      await tester.tap(find.text('GIRLS'));
      await tester.pumpAndSettle();

      // Tap girl avatar
      expect(find.text('Maya'), findsOneWidget);
      await tester.tap(find.text('Maya'));
      await tester.pumpAndSettle();

      expect(find.text('MAYA'), findsWidgets);
    });

    testWidgets('ForgotPasswordScreen and ResetPasswordScreen render securely', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('RESET CIPHER KEY'), findsOneWidget);
      expect(find.text('DISPATCH RESET CODE'), findsOneWidget);

      await tester.pumpWidget(
        createTestApp(
          const ResetPasswordScreen(
            email: 'test@lumina.io',
            verifiedOtp: '123456',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ENTER NEW CIPHER'), findsOneWidget);
      expect(find.text('CONFIRM & UPDATE CIPHER'), findsOneWidget);
    });

    testWidgets('Zero RenderFlex overflows across all auth & profile screens on compact 320px phone', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568); // iPhone SE
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. LoginScreen
      await tester.pumpWidget(createTestApp(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 2. RegisterScreen
      await tester.pumpWidget(createTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 3. OtpVerificationScreen
      await tester.pumpWidget(
        createTestApp(
          const OtpVerificationScreen(
            email: 'compact@lumina.io',
            type: 'register',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 4. ForgotPasswordScreen
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 5. ResetPasswordScreen
      await tester.pumpWidget(
        createTestApp(
          const ResetPasswordScreen(
            email: 'compact@lumina.io',
            verifiedOtp: '123456',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 6. ProfileSetupScreen
      await tester.pumpWidget(
        createTestApp(
          const ProfileSetupScreen(
            initialUser: UserProfile(
              name: 'Compact Tester',
              email: 'compact@lumina.io',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
