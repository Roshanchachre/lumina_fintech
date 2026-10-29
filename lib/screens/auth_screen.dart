import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/account_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_vault.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import 'login_screen.dart';
import 'main_shell_screen.dart';

class AuthScreen extends StatefulWidget {
  final SecureVault? secureVault;
  final BiometricService? biometricService;

  const AuthScreen({
    super.key,
    this.secureVault,
    this.biometricService,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final SecureVault _secureVault;
  late final BiometricService _biometricService;

  String _enteredPin = '';
  bool _hasError = false;
  String _statusMessage = 'Enter 4-digit Passcode or Biometrics';

  @override
  void initState() {
    super.initState();
    _secureVault = widget.secureVault ?? SecureVault();
    _biometricService = widget.biometricService ?? BiometricService();
    _attemptAutoBiometrics();
  }

  Future<void> _attemptAutoBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final isEnrolled = await _secureVault.isBiometricsEnrolled();
    if (isEnrolled) {
      _triggerBiometrics();
    }
  }

  Future<void> _triggerBiometrics() async {
    HapticFeedback.lightImpact();
    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Authenticate to access Lumina Sovereign Vault',
    );

    if (authenticated && mounted) {
      _unlockSuccess();
    } else if (mounted) {
      setState(() {
        _statusMessage = 'Biometrics cancelled. Enter passcode or use password';
      });
    }
  }

  void _onKeyPress(String val) {
    if (_enteredPin.length >= 4) return;

    HapticFeedback.selectionClick();
    SoundService.instance.play(LuminaSound.cardClick);

    setState(() {
      _hasError = false;
      _statusMessage = 'Enter 4-digit Passcode or Biometrics';
      _enteredPin += val;
    });

    if (_enteredPin.length == 4) {
      _verifyPin(_enteredPin);
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;

    HapticFeedback.selectionClick();
    SoundService.instance.play(LuminaSound.cardClick);

    setState(() {
      _hasError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin(String pin) async {
    final isValid = await _secureVault.verifyUserPin(pin);

    if (isValid) {
      _unlockSuccess();
    } else {
      HapticFeedback.heavyImpact();
      SoundService.instance.play(LuminaSound.errorAlert);

      if (!mounted) return;
      setState(() {
        _hasError = true;
        _enteredPin = '';
        _statusMessage = 'Incorrect passcode. Try again (Default: 1234)';
      });
    }
  }

  Future<void> _unlockSuccess() async {
    HapticFeedback.mediumImpact();
    SoundService.instance.play(LuminaSound.biometricUnlock);

    if (!mounted) return;

    // Refresh auth state and account data directly so no re-authentication is needed
    try {
      context.read<AuthBloc>().add(CheckAuthStatus());
      context.read<AccountBloc>().add(LoadAccountData());
    } catch (_) {}

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const MainShellScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: LuminaAtmosphericBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 640;
              final keySize = isCompact ? 56.0 : 72.0;
              final rowSpacing = isCompact ? 8.0 : 14.0;
              final headerTop = isCompact ? 12.0 : 24.0;
              final logoSize = isCompact ? 48.0 : 64.0;
              final logoIconSize = isCompact ? 24.0 : 32.0;
              final pinSpacing = isCompact ? 16.0 : 28.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: headerTop),

                        // Header Branding
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: BoxDecoration(
                                  color: LuminaColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(isCompact ? 16 : 22),
                                  border: Border.all(
                                    color: LuminaColors.acidLime.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: LuminaColors.acidLime.withValues(alpha: 0.25),
                                      blurRadius: 24,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.diamond_outlined,
                                    color: LuminaColors.acidLime,
                                    size: logoIconSize,
                                  ),
                                ),
                              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                              SizedBox(height: isCompact ? 10 : 16),

                              Text(
                                'LUMINA VAULT',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: isCompact ? 18 : 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4.0,
                                  color: LuminaColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _statusMessage,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: _hasError ? LuminaColors.crimsonAlert : LuminaColors.textSecondary,
                                  fontWeight: _hasError ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: pinSpacing),

                        // PIN Indicator Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final isFilled = index < _enteredPin.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              width: isFilled ? 16 : 12,
                              height: isFilled ? 16 : 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled
                                    ? (_hasError ? LuminaColors.crimsonAlert : LuminaColors.acidLime)
                                    : LuminaColors.surfaceElevated,
                                border: Border.all(
                                  color: isFilled
                                      ? (_hasError ? LuminaColors.crimsonAlert : LuminaColors.acidLime)
                                      : LuminaColors.surfaceBorder,
                                  width: 2,
                                ),
                                boxShadow: isFilled
                                    ? [
                                        BoxShadow(
                                          color: (_hasError ? LuminaColors.crimsonAlert : LuminaColors.acidLime)
                                              .withValues(alpha: 0.6),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ).animate(target: _hasError ? 1 : 0).shake(duration: 350.ms, hz: 6),

                        const Spacer(),

                        // Custom Neo Numeric Keypad
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              _buildKeypadRow(['1', '2', '3'], keySize),
                              SizedBox(height: rowSpacing),
                              _buildKeypadRow(['4', '5', '6'], keySize),
                              SizedBox(height: rowSpacing),
                              _buildKeypadRow(['7', '8', '9'], keySize),
                              SizedBox(height: rowSpacing),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionKey(
                                    icon: Icons.fingerprint_rounded,
                                    color: LuminaColors.acidLime,
                                    keySize: keySize,
                                    onTap: _triggerBiometrics,
                                  ),
                                  _buildDigitKey('0', keySize),
                                  _buildActionKey(
                                    icon: Icons.backspace_outlined,
                                    color: LuminaColors.textMuted,
                                    keySize: keySize,
                                    onTap: _onBackspace,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isCompact ? 10 : 16),

                        // Unlock with Password instead option
                        TextButton.icon(
                          onPressed: () {
                            SoundService.instance.play(LuminaSound.cardClick);
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 400),
                                pageBuilder: (_, __, ___) => const LoginScreen(),
                                transitionsBuilder: (_, animation, __, child) =>
                                    FadeTransition(opacity: animation, child: child),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.password_rounded,
                            color: LuminaColors.acidLime,
                            size: 16,
                          ),
                          label: Text(
                            'UNLOCK WITH PASSWORD INSTEAD',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: LuminaColors.acidLime,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Security Trust Footer
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_outline_rounded, color: LuminaColors.textMuted, size: 13),
                                const SizedBox(width: 6),
                                Text(
                                  'HARDWARE KEYSTORE PROTECTED • 256-BIT ENCLAVE',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    color: LuminaColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits, double keySize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitKey(d, keySize)).toList(),
    );
  }

  Widget _buildDigitKey(String digit, double keySize) {
    return GestureDetector(
      onTap: () => _onKeyPress(digit),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: keySize,
        height: keySize,
        decoration: BoxDecoration(
          color: LuminaColors.surfaceElevated.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: LuminaColors.surfaceBorderSubtle, width: 1.2),
        ),
        child: Center(
          child: Text(
            digit,
            style: GoogleFonts.spaceGrotesk(
              fontSize: keySize * 0.38,
              fontWeight: FontWeight.w600,
              color: LuminaColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required Color color,
    required double keySize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: keySize,
        height: keySize,
        decoration: BoxDecoration(
          color: LuminaColors.surfaceElevated.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: LuminaColors.surfaceBorderSubtle, width: 1.2),
        ),
        child: Center(
          child: Icon(icon, color: color, size: keySize * 0.38),
        ),
      ),
    );
  }
}
