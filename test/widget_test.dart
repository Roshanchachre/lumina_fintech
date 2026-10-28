import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumina_fintech/main.dart';
import 'package:lumina_fintech/bloc/account_bloc.dart';
import 'package:lumina_fintech/screens/main_shell_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  testWidgets('Lumina fintech splash screen mounts and transitions cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const LuminaFintechApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('LUMINA'), findsOneWidget);
    expect(find.text('SOVEREIGN WEALTH & PRIVATE BANKING'), findsOneWidget);

    // Settle all ignition timers
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  });

  testWidgets('MainShellScreen renders dashboard and nav icons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AccountBloc(),
        child: const MaterialApp(
          home: MainShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Roshan Chachre'), findsOneWidget);
    expect(find.text('RECENT ACTIVITY'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget); // active tab shows text
    expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget); // inactive tabs show icons
    expect(find.byIcon(Icons.pie_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
  });

  testWidgets('Tapping bottom dock tab switches views without errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AccountBloc(),
        child: const MaterialApp(
          home: MainShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Cards icon
    await tester.tap(find.byIcon(Icons.credit_card_rounded));
    await tester.pumpAndSettle();
    expect(find.text('CARDS & VAULT'), findsOneWidget);
    expect(find.text('Cards'), findsOneWidget); // now active

    // Tap Portfolio icon
    await tester.tap(find.byIcon(Icons.pie_chart_rounded));
    await tester.pumpAndSettle();
    expect(find.text('WEALTH ALLOCATION'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget); // now active

    // Tap Settings icon
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('SECURITY & SETTINGS'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget); // now active
  });

  test('Wire transfer dispatches correctly and updates balance', () async {
    final bloc = AccountBloc();
    final initialBalance = bloc.state.balance;

    bloc.add(ExecuteWireTransfer(recipient: 'Sarah Connor', amount: 1000.00));
    await expectLater(
      bloc.stream,
      emits(predicate<AccountState>((state) =>
          state.balance == initialBalance - 1000.00 &&
          state.transactions.first.title == 'Sarah Connor')),
    );
    await bloc.close();
  });
}
