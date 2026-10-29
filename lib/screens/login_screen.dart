import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/account_bloc.dart';
import '../core/network/api_endpoints.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_vault.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';
import 'forgot_password_screen.dart';
import 'main_shell_screen.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _canUseBiometrics = false;
  late final SecureVault _secureVault;
  late final BiometricService _biometricService;

  @override
  void initState() {
    super.initState();
    _secureVault = SecureVault();
    _biometricService = BiometricService();
    _initBiometricsAndEmail();
  }

  Future<void> _initBiometricsAndEmail() async {
    final email = await _secureVault.getLastEmail();
    if (email != null && email.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = email;
      });
    }

    final isEnrolled = await _secureVault.isBiometricsEnrolled();
    final canBio = await _biometricService.isBiometricReady();
    final hasToken = (await _secureVault.getAuthToken()) != null;

    if (canBio && (isEnrolled || hasToken) && mounted) {
      setState(() {
        _canUseBiometrics = true;
      });
    }
  }

  Future<void> _triggerBiometricUnlock() async {
    HapticFeedback.lightImpact();
    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Authenticate to access Lumina Sovereign Vault',
    );

    if (!mounted) return;

    if (authenticated) {
      final token = await _secureVault.getAuthToken();
      if (token != null && token.isNotEmpty) {
        SoundService.instance.play(LuminaSound.biometricUnlock);
        HapticFeedback.mediumImpact();
        if (!mounted) return;
        try {
          context.read<AuthBloc>().add(CheckAuthStatus());
          context.read<AccountBloc>().add(LoadAccountData());
        } catch (_) {}

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const MainShellScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return;
      }
    }

    if (mounted) {
      LuminaSnackBar.show(
        context,
        type: LuminaSnackBarType.info,
        title: 'Enter Password',
        message: 'Face ID cancelled or unavailable. Enter your password to unlock.',
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      SoundService.instance.play(LuminaSound.errorAlert);
      HapticFeedback.heavyImpact();
      return;
    }

    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.mediumImpact();

    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          SoundService.instance.play(LuminaSound.biometricUnlock);
          HapticFeedback.mediumImpact();
          // Update AccountBloc user state
          context.read<AccountBloc>().add(LoadAccountData());
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => const MainShellScreen(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        } else if (state.status == AuthStatus.profileIncomplete && state.user != null) {
          SoundService.instance.play(LuminaSound.biometricUnlock);
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => ProfileSetupScreen(initialUser: state.user!),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        } else if (state.status == AuthStatus.unverifiedEmail && state.pendingEmail != null) {
          LuminaSnackBar.show(
            context,
            type: LuminaSnackBarType.warning,
            title: 'Verification Required',
            message: state.errorMessage ?? 'Please verify your email before logging in.',
          );
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => OtpVerificationScreen(
                email: state.pendingEmail!,
                type: 'register',
              ),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          LuminaSnackBar.show(
            context,
            type: LuminaSnackBarType.error,
            title: 'Authentication Error',
            message: state.errorMessage!,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: LuminaColors.background,
            body: LuminaAtmosphericBackground(
              showFloatingBoxes: true,
              pulseIntensity: 1.0,
              child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vault Monogram Icon
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: LuminaColors.cobaltAcid,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: LuminaColors.electricCobalt.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF030407),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: LuminaColors.acidLime,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          'WELCOME TO LUMINA',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: LuminaColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Authenticate to access your sovereign vault',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: LuminaColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Email Field
                        Text(
                          'INSTITUTIONAL EMAIL',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: LuminaColors.electricCobalt,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: GoogleFonts.plusJakartaSans(
                            color: LuminaColors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'alex.vance@lumina.io',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: LuminaColors.textMuted.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                              color: LuminaColors.textMuted,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: LuminaColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.electricCobalt, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.crimsonAlert),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'CIPHER KEY (PASSWORD)',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: LuminaColors.electricCobalt,
                                  letterSpacing: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                SoundService.instance.play(LuminaSound.cardClick);
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
                                    transitionsBuilder: (_, animation, __, child) =>
                                        FadeTransition(opacity: animation, child: child),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Cipher?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: LuminaColors.acidLime,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.plusJakartaSans(
                            color: LuminaColors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: LuminaColors.textMuted.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.key_rounded,
                              color: LuminaColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: LuminaColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: LuminaColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.electricCobalt, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.crimsonAlert),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // Login Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LuminaColors.electricCobalt,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: LuminaColors.electricCobalt.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'AUTHENTICATE VAULT',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        // Quick Biometric Unlock (Direct app entry without password)
                        if (_canUseBiometrics) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : _triggerBiometricUnlock,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: LuminaColors.acidLime,
                                side: BorderSide(
                                  color: LuminaColors.acidLime.withValues(alpha: 0.6),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.fingerprint_rounded,
                                size: 22,
                                color: LuminaColors.acidLime,
                              ),
                              label: Text(
                                'UNLOCK WITH FACE ID / BIOMETRICS',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: LuminaColors.acidLime,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Create Account Link
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to Lumina Wealth? ',
                                style: GoogleFonts.plusJakartaSans(
                                  color: LuminaColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  SoundService.instance.play(LuminaSound.cardClick);
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => const RegisterScreen(),
                                      transitionsBuilder: (_, animation, __, child) =>
                                          FadeTransition(opacity: animation, child: child),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Create Account',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: LuminaColors.acidLime,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // API Node Host Pill (Configurable for local network/physical devices)
                        Center(
                          child: GestureDetector(
                            onTap: () => _showServerConfigDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: LuminaColors.surfaceElevated.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: LuminaColors.acidLime,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'NODE: ${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: LuminaColors.textMuted,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.settings_outlined,
                                      size: 11,
                                      color: LuminaColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    );
  }

  void _showServerConfigDialog(BuildContext context) {
    SoundService.instance.play(LuminaSound.cardClick);
    final ipController = TextEditingController(
      text: ApiEndpoints.baseUrl.replaceAll('/api/v1', ''),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LuminaColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: LuminaColors.surfaceBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.dns_rounded, color: LuminaColors.acidLime, size: 20),
            const SizedBox(width: 10),
            Text(
              'API NODE CONFIG',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: LuminaColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select or enter the host address of your Lumina API server:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: LuminaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildNodePresetChip(ctx, ipController, 'Mac Wi-Fi', 'http://192.168.1.4:4040'),
                _buildNodePresetChip(ctx, ipController, 'Localhost', 'http://127.0.0.1:4040'),
                _buildNodePresetChip(ctx, ipController, 'Android Emu', 'http://10.0.2.2:4040'),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ipController,
              style: GoogleFonts.spaceGrotesk(color: LuminaColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: LuminaColors.background,
                hintText: 'http://192.168.1.4:4040',
                hintStyle: GoogleFonts.spaceGrotesk(color: LuminaColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.spaceGrotesk(color: LuminaColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LuminaColors.acidLime,
              foregroundColor: LuminaColors.midnightBlack,
            ),
            onPressed: () {
              var host = ipController.text.trim();
              if (!host.endsWith('/api/v1')) {
                host = '$host/api/v1';
              }
              setState(() {
                ApiEndpoints.baseUrl = host;
              });
              Navigator.of(ctx).pop();
              LuminaSnackBar.show(
                context,
                type: LuminaSnackBarType.success,
                title: 'Node Reconfigured',
                message: 'API Node endpoint updated to $host',
              );
            },
            child: Text(
              'SAVE NODE',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodePresetChip(
    BuildContext ctx,
    TextEditingController controller,
    String label,
    String url,
  ) {
    return GestureDetector(
      onTap: () {
        controller.text = url;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceBorderSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: LuminaColors.surfaceBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: LuminaColors.acidLime,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
