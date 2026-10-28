import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumina_fintech/bloc/account_bloc.dart';
import 'package:lumina_fintech/screens/main_shell_screen.dart';
import 'package:lumina_fintech/screens/dashboard_screen.dart';
import 'package:lumina_fintech/screens/cards_screen.dart';
import 'package:lumina_fintech/screens/portfolio_screen.dart';
import 'package:lumina_fintech/screens/settings_screen.dart';
import 'package:lumina_fintech/modals/deposit_modal.dart';
import 'package:lumina_fintech/modals/invest_modal.dart';
import 'package:lumina_fintech/modals/more_modal.dart';
import 'package:lumina_fintech/screens/onboarding_screen.dart';
import 'package:lumina_fintech/screens/auth_screen.dart';
import 'package:lumina_fintech/theme/lumina_theme.dart';

void main() {
  final deviceFormFactors = [
    {'name': 'Compact Small (iPhone SE / 320pt)', 'size': const Size(320, 568)},
    {'name': 'Standard Compact (iPhone 8 / 375pt)', 'size': const Size(375, 667)},
    {'name': 'Modern Flagship (iPhone 16 / 393pt)', 'size': const Size(393, 852)},
    {'name': 'Pro Max Large (iPhone 16 Pro Max / 430pt)', 'size': const Size(430, 932)},
    {'name': 'Tablet Form Factor (iPad mini / 768pt)', 'size': const Size(768, 1024)},
  ];

  for (final device in deviceFormFactors) {
    final name = device['name'] as String;
    final size = device['size'] as Size;

    testWidgets('Zero overflow verification on $name across full navigation shell', (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => AccountBloc(),
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: const MainShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Navigate to CardsScreen
      await tester.tap(find.byIcon(Icons.credit_card_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CardsScreen), findsOneWidget);

      // Navigate to PortfolioScreen
      await tester.tap(find.byIcon(Icons.pie_chart_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(PortfolioScreen), findsOneWidget);

      // Navigate to SettingsScreen
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  }

  testWidgets('Zero overflow in Deposit, Invest, and More modals on narrow screen (320px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Test Deposit Modal
    await tester.pumpWidget(
      MaterialApp(
        theme: LuminaTheme.darkTheme,
        home: const Scaffold(body: DepositModal()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('INSTANT DEPOSIT & FUNDING'), findsOneWidget);

    // 2. Test Invest Modal
    await tester.pumpWidget(
      MaterialApp(
        theme: LuminaTheme.darkTheme,
        home: const Scaffold(body: InvestModal()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('HIGH-YIELD WEALTH VAULTS'), findsOneWidget);

    // 3. Test More Modal
    await tester.pumpWidget(
      MaterialApp(
        theme: LuminaTheme.darkTheme,
        home: const Scaffold(body: MoreModal()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('INSTITUTIONAL SERVICES'), findsOneWidget);
  });

  testWidgets('Zero overflow in Onboarding and Auth screens on narrow screen (320px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Onboarding Screen
    await tester.pumpWidget(
      MaterialApp(
        theme: LuminaTheme.darkTheme,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('LUMINA'), findsOneWidget);

    // 2. Auth Screen
    await tester.pumpWidget(
      MaterialApp(
        theme: LuminaTheme.darkTheme,
        home: const AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('LUMINA VAULT'), findsOneWidget);
  });
}
