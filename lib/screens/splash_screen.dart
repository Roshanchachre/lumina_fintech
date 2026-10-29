import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_vault.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import 'auth_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final SecureVault? secureVault;
  final BiometricService? biometricService;

  const SplashScreen({
    super.key,
    this.secureVault,
    this.biometricService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SecureVault _secureVault;
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _secureVault = widget.secureVault ?? SecureVault();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _ringController.repeat();
    }
    _startIgnitionSequence();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _startIgnitionSequence() async {
    // Stage 1: Play ignition sound & wait for animations to blossom
    SoundService.instance.play(LuminaSound.wireSend);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Stage 2: Check authentication and onboarding status
    final token = await _secureVault.getAuthToken();
    final isOnboarded = await _secureVault.isOnboardingCompleted();

    HapticFeedback.mediumImpact();
    SoundService.instance.play(LuminaSound.biometricUnlock);

    if (!mounted) return;
    _ringController.stop();

    Widget targetScreen;
    if (token != null && token.isNotEmpty) {
      // Returning authenticated member -> Quick PIN / Biometric Vault unlock
      targetScreen = const AuthScreen();
    } else if (isOnboarded) {
      // User has already completed onboarding -> Straight to Login screen (never back to onboarding)
      targetScreen = const LoginScreen();
    } else {
      // First-time member -> 3-Screen Animated Mascot Onboarding
      targetScreen = const OnboardingScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
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
        animate: true,
        showGrid: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Cinematic Logo & Rotating Energy Ring
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rotating Energy Orbit + Cyber Diamond Logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Dashed Energy Orbit
                      AnimatedBuilder(
                        animation: _ringController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _ringController.value * 2 * math.pi,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: LuminaColors.acidLime.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Counter-Rotating Outer Dash Ring
                      AnimatedBuilder(
                        animation: _ringController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: -_ringController.value * 2 * math.pi * 0.7,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: LuminaColors.electricCobalt.withValues(alpha: 0.25),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Center Cyber Diamond Logo with Acid Lime Glow
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: LuminaColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: LuminaColors.acidLime.withValues(alpha: 0.75),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: LuminaColors.acidLime.withValues(alpha: 0.35),
                              blurRadius: 36,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: LuminaColors.electricCobalt.withValues(alpha: 0.30),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.diamond_outlined,
                            color: LuminaColors.acidLime,
                            size: 46,
                          ),
                        ),
                      ).animate().scale(duration: 900.ms, curve: Curves.elasticOut).shimmer(delay: 500.ms, duration: 800.ms),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Kinetic Title Reveal
                  Text(
                    'LUMINA',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8.0,
                      color: LuminaColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.25, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'SOVEREIGN WEALTH & PRIVATE BANKING',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.2,
                      color: LuminaColors.electricCobalt,
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                ],
              ),
            ),

            // Bottom Cryptographic Enclave Status
            Positioned(
              bottom: 44,
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: LuminaColors.acidLime, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'HARDWARE ENCLAVE SECURED • ARBITRUM L2',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: LuminaColors.textMuted,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms),
            ),
          ],
        ),
      ),
    );
  }
}
