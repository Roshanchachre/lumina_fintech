import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/security/biometric_service.dart';
import '../core/sound/sound_service.dart';
import '../screens/login_screen.dart';
import '../theme/lumina_theme.dart';

/// App-level Privacy Guard that masks the screen when app is in the background,
/// multitasking app switcher, or when explicitly locked by the user.
class LuminaPrivacyGuard extends StatefulWidget {
  final Widget child;
  final BiometricService? biometricService;
  final bool initialVeiled;

  const LuminaPrivacyGuard({
    super.key,
    required this.child,
    this.biometricService,
    this.initialVeiled = false,
  });

  static LuminaPrivacyGuardState? of(BuildContext context) {
    return context.findAncestorStateOfType<LuminaPrivacyGuardState>();
  }

  @override
  State<LuminaPrivacyGuard> createState() => LuminaPrivacyGuardState();
}

class LuminaPrivacyGuardState extends State<LuminaPrivacyGuard>
    with WidgetsBindingObserver {
  late final BiometricService _biometricService;
  bool _isVeiled = false;
  bool _isAuthenticating = false;

  bool get isVeiled => _isVeiled;

  @override
  void initState() {
    super.initState();
    _biometricService = widget.biometricService ?? BiometricService();
    _isVeiled = widget.initialVeiled;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // App entered switcher or background: immediately deploy privacy veil
      if (!_isVeiled) {
        setState(() {
          _isVeiled = true;
        });
      }
    }
  }

  /// Lock vault immediately from UI
  void lockVault() {
    SoundService.instance.play(LuminaSound.vaultLock);
    setState(() {
      _isVeiled = true;
    });
  }

  /// Request biometric challenge to dismiss veil
  Future<void> unlockVault() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
    });

    HapticFeedback.mediumImpact();
    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Authenticate to access Lumina Sovereign Vault',
    );

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        if (authenticated) {
          _isVeiled = false;
        }
      });
      if (authenticated) {
        HapticFeedback.lightImpact();
        SoundService.instance.play(LuminaSound.biometricUnlock);
      } else {
        SoundService.instance.play(LuminaSound.errorAlert);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // High-security Privacy Veil Overlay
        if (_isVeiled)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  color: LuminaColors.background.withValues(alpha: 0.92),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Shield Emblem
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LuminaColors.surfaceElevated,
                              border: Border.all(
                                color: LuminaColors.acidLime.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: LuminaColors.acidLime.withValues(alpha: 0.25),
                                  blurRadius: 28,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: LuminaColors.electricCobalt.withValues(alpha: 0.2),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.security_rounded,
                                color: LuminaColors.acidLime,
                                size: 40,
                              ),
                            ),
                          ).animate().scale(
                            begin: const Offset(0.92, 0.92),
                            end: const Offset(1.0, 1.0),
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),

                          const SizedBox(height: 28),

                          Text(
                            'VAULT SECURED',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4.0,
                              color: LuminaColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Institutional privacy shield active.\nFinancial balances and card credentials are encrypted.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              height: 1.5,
                              color: LuminaColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Unlock Button (Acid Lime with Midnight Black text)
                          GestureDetector(
                            onTap: _isAuthenticating ? null : unlockVault,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LuminaColors.cobaltAcid,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: LuminaColors.acidLime.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.fingerprint_rounded,
                                    color: LuminaColors.midnightBlack,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isAuthenticating ? 'VERIFYING...' : 'UNLOCK WITH BIOMETRICS',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: LuminaColors.midnightBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Fallback to password unlock
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isVeiled = false;
                              });
                              Navigator.of(context).pushAndRemoveUntil(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const LoginScreen(),
                                  transitionsBuilder: (_, a, __, c) =>
                                      FadeTransition(opacity: a, child: c),
                                ),
                                (route) => false,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
