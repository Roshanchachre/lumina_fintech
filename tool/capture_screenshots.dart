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

Future<void> loadAllFonts() async {
  // 1. Material Icons
  final iconFile = File('assets/google_fonts/MaterialIcons-Regular.otf');
  if (iconFile.existsSync()) {
    final loader = FontLoader('MaterialIcons');
    loader.addFont(Future.value(ByteData.view(iconFile.readAsBytesSync().buffer)));
    await loader.load();
  }

  // 2. Cupertino Icons
  final cupertinoFile = File('assets/google_fonts/CupertinoIcons.ttf');
  if (cupertinoFile.existsSync()) {
    final loader = FontLoader('packages/cupertino_icons/CupertinoIcons');
    loader.addFont(Future.value(ByteData.view(cupertinoFile.readAsBytesSync().buffer)));
    await loader.load();
  }

  // 3. Google Fonts (Plus Jakarta Sans & Space Grotesk)
  final pjsBytes = File('assets/google_fonts/PlusJakartaSans[wght].ttf').readAsBytesSync();
  final sgBytes = File('assets/google_fonts/SpaceGrotesk[wght].ttf').readAsBytesSync();

  final pjsVariants = [
    'PlusJakartaSans',
    'PlusJakartaSans_regular',
    'PlusJakartaSans_300',
    'PlusJakartaSans_400',
    'PlusJakartaSans_500',
    'PlusJakartaSans_600',
    'PlusJakartaSans_700',
    'PlusJakartaSans_800',
    'PlusJakartaSans_300normal',
    'PlusJakartaSans_400normal',
    'PlusJakartaSans_500normal',
    'PlusJakartaSans_600normal',
    'PlusJakartaSans_700normal',
    'PlusJakartaSans_800normal',
  ];

  final sgVariants = [
    'SpaceGrotesk',
    'SpaceGrotesk_regular',
    'SpaceGrotesk_300',
    'SpaceGrotesk_400',
    'SpaceGrotesk_500',
    'SpaceGrotesk_600',
    'SpaceGrotesk_700',
    'SpaceGrotesk_300normal',
    'SpaceGrotesk_400normal',
    'SpaceGrotesk_500normal',
    'SpaceGrotesk_600normal',
    'SpaceGrotesk_700normal',
  ];

  for (final name in pjsVariants) {
    final loader = FontLoader(name);
    loader.addFont(Future.value(ByteData.view(pjsBytes.buffer)));
    await loader.load();
  }

  for (final name in sgVariants) {
    final loader = FontLoader(name);
    loader.addFont(Future.value(ByteData.view(sgBytes.buffer)));
    await loader.load();
  }
}

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

  testWidgets('Generate Mobile and Tablet Screenshots with Real Fonts', (tester) async {
    await loadAllFonts();

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

    // 1. Mobile Shell Tabs (393 x 852 logical)
    await captureTab(filename: 'mobile_dashboard.png', size: const Size(393, 852), tabIndex: 0);
    await captureTab(filename: 'mobile_cards.png', size: const Size(393, 852), tabIndex: 1);
    await captureTab(filename: 'mobile_portfolio.png', size: const Size(393, 852), tabIndex: 2);
    await captureTab(filename: 'mobile_settings.png', size: const Size(393, 852), tabIndex: 3);

    // 2. Dedicated Mobile Feature Screens
    await captureWidget(filename: 'mobile_activities.png', size: const Size(393, 852), widget: const ActivitiesScreen());
    await captureWidget(filename: 'mobile_notifications.png', size: const Size(393, 852), widget: const NotificationsScreen());
    await captureWidget(filename: 'mobile_card_issuance.png', size: const Size(393, 852), widget: const IssueCardScreen());

    // 3. Tablet Shell Tabs (768 x 1024 logical)
    await captureTab(filename: 'tablet_dashboard.png', size: const Size(768, 1024), tabIndex: 0);
    await captureTab(filename: 'tablet_cards.png', size: const Size(768, 1024), tabIndex: 1);
    await captureTab(filename: 'tablet_portfolio.png', size: const Size(768, 1024), tabIndex: 2);
    await captureTab(filename: 'tablet_settings.png', size: const Size(768, 1024), tabIndex: 3);
  });
}
