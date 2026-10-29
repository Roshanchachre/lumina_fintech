import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/account_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'core/network/api_client.dart';
import 'core/security/secure_vault.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'screens/splash_screen.dart';
import 'theme/lumina_theme.dart';
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
  final AuthRepository? authRepository;
  final SecureVault? secureVault;

  const LuminaFintechApp({
    super.key,
    this.authRepository,
    this.secureVault,
  });

  @override
  Widget build(BuildContext context) {
    final vault = secureVault ?? SecureVault();
    final apiClient = ApiClient();
    final authRepo = authRepository ??
        AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(client: apiClient),
          secureVault: vault,
          apiClient: apiClient,
        );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: authRepo)..add(CheckAuthStatus()),
        ),
        BlocProvider<AccountBloc>(
          create: (_) => AccountBloc(vault: vault)..add(LoadAccountData()),
        ),
      ],
      child: MaterialApp(
        title: 'Lumina Wealth',
        debugShowCheckedModeBanner: false,
        theme: LuminaTheme.darkTheme,
        builder: (context, child) => LuminaPrivacyGuard(
          child: child ?? const SizedBox.shrink(),
        ),
        home: SplashScreen(secureVault: vault),
      ),
    );
  }
}
