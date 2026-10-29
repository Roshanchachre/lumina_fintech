import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina_fintech/bloc/account_bloc.dart';
import 'package:lumina_fintech/screens/main_shell_screen.dart';
import 'package:lumina_fintech/screens/notifications_screen.dart';
import 'package:lumina_fintech/screens/activities_screen.dart';
import 'package:lumina_fintech/screens/issue_card_screen.dart';
import 'package:lumina_fintech/theme/lumina_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('google_fonts') ||
        details.exception.toString().contains('GoogleFonts')) {
      return;
    }
    originalOnError?.call(details);
  };

  const sensorChannel = MethodChannel('dev.fluttercommunity.plus/sensors/method');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(sensorChannel, (call) async => null);

  testWidgets('Generate Mobile and Tablet Screenshots', (tester) async {
    final screenshotsDir = Directory('docs/screenshots');
    if (!screenshotsDir.existsSync()) {
      screenshotsDir.createSync(recursive: true);
    }

    Future<void> captureWidget({
      required String filename,
      required Size size,
      required Widget widget,
    }) async {
      final key = GlobalKey();
      tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
      tester.view.devicePixelRatio = 2.0;

      final bloc = AccountBloc();

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: BlocProvider<AccountBloc>.value(
            value: bloc,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: LuminaTheme.darkTheme,
              home: widget,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        File('docs/screenshots/$filename').writeAsBytesSync(bytes);
        print('Captured docs/screenshots/$filename (${bytes.length} bytes, ${image.width}x${image.height})');
      });
    }

    Future<void> captureTab({
      required String filename,
      required Size size,
      required int tabIndex,
    }) async {
      final key = GlobalKey();
      tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
      tester.view.devicePixelRatio = 2.0;

      final bloc = AccountBloc();

      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: BlocProvider<AccountBloc>.value(
            value: bloc,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: LuminaTheme.darkTheme,
              home: const MainShellScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (tabIndex > 0) {
        final iconFinders = [
          find.byIcon(Icons.home_filled),
          find.byIcon(Icons.credit_card_rounded),
          find.byIcon(Icons.pie_chart_rounded),
          find.byIcon(Icons.tune_rounded),
        ];
        await tester.tap(iconFinders[tabIndex]);
        await tester.pumpAndSettle();
      }

      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        File('docs/screenshots/$filename').writeAsBytesSync(bytes);
        print('Captured docs/screenshots/$filename (${bytes.length} bytes, ${image.width}x${image.height})');
      });
    }

    // 1. Mobile Shell Tabs
    await captureTab(filename: 'mobile_dashboard.png', size: const Size(393, 852), tabIndex: 0);
    await captureTab(filename: 'mobile_cards.png', size: const Size(393, 852), tabIndex: 1);
    await captureTab(filename: 'mobile_portfolio.png', size: const Size(393, 852), tabIndex: 2);
    await captureTab(filename: 'mobile_settings.png', size: const Size(393, 852), tabIndex: 3);

    // 2. Dedicated Mobile Feature Screens
    await captureWidget(filename: 'mobile_activities.png', size: const Size(393, 852), widget: const ActivitiesScreen());
    await captureWidget(filename: 'mobile_notifications.png', size: const Size(393, 852), widget: const NotificationsScreen());
    await captureWidget(filename: 'mobile_card_issuance.png', size: const Size(393, 852), widget: const IssueCardScreen());

    // 3. Tablet Shell Tabs (iPad mini / 768 x 1024)
    await captureTab(filename: 'tablet_dashboard.png', size: const Size(768, 1024), tabIndex: 0);
    await captureTab(filename: 'tablet_cards.png', size: const Size(768, 1024), tabIndex: 1);
    await captureTab(filename: 'tablet_portfolio.png', size: const Size(768, 1024), tabIndex: 2);
    await captureTab(filename: 'tablet_settings.png', size: const Size(768, 1024), tabIndex: 3);
  });
}
