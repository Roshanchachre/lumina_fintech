import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/account_bloc.dart';
import 'theme/lumina_theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/privacy_veil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LuminaColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LuminaFintechApp());
}

class LuminaFintechApp extends StatelessWidget {
  const LuminaFintechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountBloc()..add(LoadAccountData()),
      child: MaterialApp(
        title: 'Lumina Wealth',
        debugShowCheckedModeBanner: false,
        theme: LuminaTheme.darkTheme,
        builder: (context, child) => LuminaPrivacyGuard(
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

