import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumina_fintech/bloc/account_bloc.dart';
import 'package:lumina_fintech/core/services/notification_service.dart';
import 'package:lumina_fintech/data/chart_dataset.dart';
import 'package:lumina_fintech/models/account_models.dart';
import 'package:lumina_fintech/screens/activities_screen.dart';
import 'package:lumina_fintech/screens/notifications_screen.dart';
import 'package:lumina_fintech/theme/lumina_theme.dart';
import 'package:lumina_fintech/widgets/lumina_snackbar.dart';

void main() {
  group('NotificationsScreen Tests', () {
    testWidgets('renders all notifications, filters by category, and marks read', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LuminaTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title and chips
      expect(find.text('VAULT NOTIFICATIONS'), findsOneWidget);
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('YIELDS'), findsOneWidget);
      expect(find.text('TRANSFERS'), findsOneWidget);
      expect(find.text('SECURITY'), findsOneWidget);

      // Verify notifications are present
      expect(find.text('Arbitrum L2 Yield Compounded'), findsOneWidget);
      expect(find.text('Biometric Shield Active'), findsOneWidget);

      // Filter by YIELDS
      await tester.tap(find.text('YIELDS'));
      await tester.pumpAndSettle();
      expect(find.text('Arbitrum L2 Yield Compounded'), findsOneWidget);
      expect(find.text('Biometric Shield Active'), findsNothing);

      // Filter by SECURITY
      await tester.tap(find.text('SECURITY'));
      await tester.pumpAndSettle();
      expect(find.text('Biometric Shield Active'), findsOneWidget);
      expect(find.text('Arbitrum L2 Yield Compounded'), findsNothing);

      // Switch back to ALL
      await tester.tap(find.text('ALL'));
      await tester.pumpAndSettle();

      // Tap MARK READ
      expect(find.text('MARK READ'), findsOneWidget);
      await tester.tap(find.text('MARK READ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify uppercase formatted floating toast appears
      expect(find.text('LEDGER SYNCED'), findsOneWidget);
      expect(find.text('All vault notifications marked as read.'), findsOneWidget);
    });

    testWidgets('zero overflow on compact 320px screen width', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: LuminaTheme.darkTheme,
          home: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('VAULT NOTIFICATIONS'), findsOneWidget);
    });
  });

  group('ActivitiesScreen Tests', () {
    late AccountBloc accountBloc;

    setUp(() {
      accountBloc = AccountBloc();
    });

    tearDown(() {
      accountBloc.close();
    });

    testWidgets('renders activities, filters by search, and shows cryptographic receipt', (WidgetTester tester) async {
      final sampleTransactions = <TransactionRecord>[
        const TransactionRecord(
          id: 'tx_101',
          title: 'Arbitrum Staking Yield',
          category: 'Yield Staking',
          amount: 348.60,
          time: 'Today, 02:40 PM',
          isPositive: true,
          icon: Icons.bolt_rounded,
          iconColor: LuminaColors.acidLime,
          blockchainTxHash: '0x9b3f4...e981',
          referenceId: 'REF-L2-39182',
        ),
        const TransactionRecord(
          id: 'tx_102',
          title: 'Quantum Hardware Foundry',
          category: 'Venture Capital',
          amount: 12500.00,
          time: 'Yesterday, 11:20 AM',
          isPositive: false,
          icon: Icons.south_west_rounded,
          iconColor: LuminaColors.electricCobalt,
          blockchainTxHash: '0x4a1c8...3b21',
          referenceId: 'REF-L2-48291',
        ),
      ];

      await tester.pumpWidget(
        BlocProvider<AccountBloc>.value(
          value: accountBloc,
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: ActivitiesScreen(initialTransactions: sampleTransactions),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header and search bar exist
      expect(find.text('ACTIVITY LEDGER'), findsOneWidget);
      expect(find.text('Search by recipient, token, or TxHash...'), findsOneWidget);

      // Verify transactions render
      expect(find.text('Arbitrum Staking Yield'), findsOneWidget);
      expect(find.text('Quantum Hardware Foundry'), findsOneWidget);

      // Test Search filtering
      await tester.enterText(find.byType(TextField), 'Quantum');
      await tester.pumpAndSettle();

      expect(find.text('Quantum Hardware Foundry'), findsOneWidget);
      expect(find.text('Arbitrum Staking Yield'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Tap on transaction to open receipt sheet
      await tester.tap(find.text('Arbitrum Staking Yield'));
      await tester.pumpAndSettle();

      // Receipt modal should be visible
      expect(find.text('SETTLED L2'), findsOneWidget);
      expect(find.text('Arbitrum One Cryptographic Finality'), findsOneWidget);
      expect(find.text('Execution Time'), findsOneWidget);
      expect(find.text('REF-L2-39182'), findsOneWidget);
    });

    testWidgets('zero overflow on compact 320px screen width', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        BlocProvider<AccountBloc>.value(
          value: accountBloc,
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: const ActivitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('ACTIVITY LEDGER'), findsOneWidget);
    });
  });

  group('LuminaSnackBar Tests', () {
    testWidgets('renders floating snackbar with title, message, and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LuminaTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    LuminaSnackBar.show(
                      ctx,
                      type: LuminaSnackBarType.success,
                      title: 'Vault Connected',
                      message: 'Arbitrum One L2 RPC active at 240 TPS.',
                    );
                  },
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('VAULT CONNECTED'), findsOneWidget);
      expect(find.text('Arbitrum One L2 RPC active at 240 TPS.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('NotificationService & Chart Datasets Tests', () {
    test('NotificationService synchronizes unreadCount across screens in real-time', () {
      final service = NotificationService.instance;
      service.resetToDefaults();

      expect(service.hasUnread, isTrue);
      final initialUnread = service.unreadCount;
      expect(initialUnread, greaterThan(0));

      // Mark single item read
      final firstUnread = service.notifications.firstWhere((n) => !n.isRead);
      service.markAsRead(firstUnread.id);
      expect(service.unreadCount, equals(initialUnread - 1));

      // Mark all read
      service.markAllAsRead();
      expect(service.unreadCount, equals(0));
      expect(service.hasUnread, isFalse);
    });

    test('LuminaChartData provides structured realistic market datasets for 1D, 1W, 1M', () {
      // 1D Intraday checkpoints
      final d1 = LuminaChartData.forPeriod('1D');
      expect(d1.length, equals(12));
      expect(d1.first.timeLabel, equals('00:00'));
      expect(d1.last.timeLabel, equals('22:00'));
      expect(d1.last.value, greaterThan(d1.first.value)); // Positive intraday yield

      // 1W Macro weekly snapshots
      final w1 = LuminaChartData.forPeriod('1W');
      expect(w1.length, equals(12));
      expect(w1.first.timeLabel, contains('Mon'));
      expect(w1.last.timeLabel, contains('Sun'));
      expect(w1.last.value, greaterThan(w1.first.value));

      // 1M 30-Day compounded staking
      final m1 = LuminaChartData.forPeriod('1M');
      expect(m1.length, equals(14));
      expect(m1.first.timeLabel, equals('Day 01'));
      expect(m1.last.timeLabel, equals('Day 30'));
      expect(m1.last.value, equals(128450.85));

      // Verify value extraction helper
      final values1D = LuminaChartData.valuesForPeriod('1D');
      expect(values1D.length, equals(12));
      expect(values1D.first, equals(d1.first.value));
    });
  });
}
