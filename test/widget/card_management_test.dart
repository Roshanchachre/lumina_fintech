import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumina_fintech/bloc/account_bloc.dart';
import 'package:lumina_fintech/core/services/notification_service.dart';
import 'package:lumina_fintech/models/account_models.dart';
import 'package:lumina_fintech/screens/cards_screen.dart';
import 'package:lumina_fintech/screens/issue_card_screen.dart';
import 'package:lumina_fintech/screens/card_config_screen.dart';
import 'package:lumina_fintech/screens/card_detail_screen.dart';
import 'package:lumina_fintech/theme/lumina_theme.dart';

void main() {
  group('CardsScreen Category Filtering & Navigation Tests', () {
    testWidgets('filters cards by ALL, PHYSICAL, and VIRTUAL categories', (WidgetTester tester) async {
      final bloc = AccountBloc();
      await tester.pumpWidget(
        BlocProvider<AccountBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: const CardsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and default filter
      expect(find.text('CARDS & VAULT'), findsOneWidget);
      expect(find.text('Physical & Virtual Suite'), findsOneWidget);
      expect(find.text('ISSUE CARD'), findsOneWidget);

      // Verify category filter pills
      expect(find.text('ALL (3)'), findsOneWidget);
      expect(find.text('PHYSICAL (1)'), findsOneWidget);
      expect(find.text('VIRTUAL (2)'), findsOneWidget);

      // Tap PHYSICAL filter
      await tester.tap(find.text('PHYSICAL (1)'));
      await tester.pumpAndSettle();

      // Tap VIRTUAL filter
      await tester.tap(find.text('VIRTUAL (2)'));
      await tester.pumpAndSettle();

      // Tap ALL filter
      await tester.tap(find.text('ALL (3)'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping ISSUE CARD navigates directly to IssueCardScreen', (WidgetTester tester) async {
      final bloc = AccountBloc();
      await tester.pumpWidget(
        BlocProvider<AccountBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: const CardsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('ISSUE CARD'));
      await tester.pumpAndSettle();

      expect(find.byType(IssueCardScreen), findsOneWidget);
      expect(find.text('STEP 1 OF 3 • CARD ISSUANCE'), findsOneWidget);
      expect(find.text('Virtual Card'), findsOneWidget);
      expect(find.text('Physical Metal'), findsOneWidget);
    });
  });

  group('IssueCardScreen Tier & Form Factor Selection Tests', () {
    testWidgets('allows switching between Virtual and Physical Metal form factors', (WidgetTester tester) async {
      final bloc = AccountBloc();
      await tester.pumpWidget(
        BlocProvider<AccountBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: const IssueCardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CARD FORM FACTOR'), findsOneWidget);
      expect(find.text('SOVEREIGN FINISH & ALLOY'), findsOneWidget);

      // Tap Physical Metal Card
      await tester.tap(find.text('Physical Metal'));
      await tester.pumpAndSettle();

      // Tap PROCEED TO SPECIFICATIONS
      expect(find.text('PROCEED TO SPECIFICATIONS'), findsOneWidget);
      await tester.tap(find.text('PROCEED TO SPECIFICATIONS'));
      await tester.pumpAndSettle();

      expect(find.byType(CardConfigScreen), findsOneWidget);
      expect(find.text('STEP 2 OF 3 • CONFIGURATION'), findsOneWidget);
    });
  });

  group('CardConfigScreen Configuration & Validation Tests', () {
    testWidgets('renders daily limit presets and shipping address for physical card', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final bloc = AccountBloc();
      await tester.pumpWidget(
        BlocProvider<AccountBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: const CardConfigScreen(
              cardType: CardType.physical,
              tierInfo: IssueCardTierInfo(
                id: 'titanium',
                name: 'Titanium Executive',
                materialName: 'Aerospace Brushed Titanium',
                gradient: LuminaColors.cardGradientTitanium,
                accentColor: LuminaColors.electricCobalt,
                defaultLimit: 25000.0,
                description: 'Ultra-durable titanium alloy with laser-cut chamfered edges.',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DAILY SPENDING LIMIT'), findsOneWidget);
      expect(find.text('\$2.5k'), findsOneWidget);
      expect(find.text('\$10k'), findsOneWidget);
      expect(find.text('\$25k'), findsOneWidget);
      expect(find.text('\$50k'), findsOneWidget);

      // Select a preset limit
      await tester.tap(find.text('\$25k'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Scroll to reveal shipping and PIN sections
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('INSURED COURIER DELIVERY DESTINATION'), findsOneWidget);
      expect(find.text('PHYSICAL CARD 4-DIGIT CHIP PIN'), findsOneWidget);

      // Verify button to review
      expect(find.text('REVIEW & CRYPTOGRAPHIC AUTHORIZATION'), findsOneWidget);
    });
  });

  group('AccountBloc Card Events & State Machine Tests', () {
    test('IssueNewCard adds new card to state and emits notification', () async {
      final bloc = AccountBloc();
      final initialCount = bloc.state.cards.length;

      const newCard = LuminaCardModel(
        id: 'test_card_new',
        cardHolder: 'ROSHAN CHACHRE',
        maskedPan: '4111  ••••  ••••  8899',
        expiry: '12/29',
        cvv: '777',
        balance: 50000.0,
        dailyLimit: 25000.0,
        isFrozen: false,
        isOnlineEnabled: true,
        isInternationalEnabled: true,
        tierName: 'Obsidian Midnight',
        gradient: LuminaColors.cardGradientObsidian,
        accentColor: LuminaColors.acidLime,
        cardType: CardType.physical,
        cardNickname: 'Emergency Gold Vault',
        fullPan: '4111  2233  4455  8899',
      );

      bloc.add(IssueNewCard(newCard));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.cards.length, equals(initialCount + 1));
      expect(bloc.state.cards.first.id, equals('test_card_new'));
      expect(bloc.state.cards.first.cardNickname, equals('Emergency Gold Vault'));
      expect(bloc.state.cards.first.isPhysical, isTrue);

      // Check notification was logged in NotificationService
      final notifications = NotificationService.instance.notifications;
      expect(notifications.any((n) => n.title.contains('Card Minted')), isTrue);
    });

    test('UpdateCardDailyLimit adjusts daily spending limit', () async {
      final bloc = AccountBloc();
      final cardId = bloc.state.cards.first.id;

      bloc.add(UpdateCardDailyLimit(cardId, 12500.0));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final updatedCard = bloc.state.cards.firstWhere((c) => c.id == cardId);
      expect(updatedCard.dailyLimit, equals(12500.0));
    });

    test('SetCardPin updates 4-digit PIN in state', () async {
      final bloc = AccountBloc();
      final cardId = bloc.state.cards.first.id;

      bloc.add(SetCardPin(cardId, '9876'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final updatedCard = bloc.state.cards.firstWhere((c) => c.id == cardId);
      expect(updatedCard.cardPin, equals('9876'));
    });

    test('TerminateCard removes card from active vault', () async {
      final bloc = AccountBloc();
      final initialCount = bloc.state.cards.length;
      final targetCardId = bloc.state.cards.first.id;

      bloc.add(TerminateCard(targetCardId));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.cards.length, equals(initialCount - 1));
      expect(bloc.state.cards.any((c) => c.id == targetCardId), isFalse);
    });
  });

  group('CardDetailScreen Management & Controls Tests', () {
    testWidgets('renders card detail screen with limit slider, security controls, and tracking', (WidgetTester tester) async {
      final bloc = AccountBloc();
      final cardId = bloc.state.cards.first.id;

      await tester.pumpWidget(
        BlocProvider<AccountBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: LuminaTheme.darkTheme,
            home: CardDetailScreen(cardId: cardId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DAILY SPENDING LIMIT'), findsOneWidget);
      expect(find.text('SECURITY & PERMISSIONS'), findsOneWidget);
      expect(find.text('Freeze Card'), findsOneWidget);
      expect(find.text('Online Payments'), findsOneWidget);
      expect(find.text('International Usage'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });
  });
}
