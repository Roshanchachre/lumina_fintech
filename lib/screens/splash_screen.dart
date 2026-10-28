import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_vault.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import 'main_shell_screen.dart';

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

class _SplashScreenState extends State<SplashScreen> {
  late final SecureVault _secureVault;
  late final BiometricService _biometricService;
  bool _needsManualUnlock = false;

  @override
  void initState() {
    super.initState();
    _secureVault = widget.secureVault ?? SecureVault();
    _biometricService = widget.biometricService ?? BiometricService();
    _startIgnitionSequence();
  }

  Future<void> _startIgnitionSequence() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final isEnrolled = await _secureVault.isBiometricsEnrolled();
    if (isEnrolled) {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to access Lumina Sovereign Vault',
      );
      if (!authenticated) {
        if (mounted) {
          setState(() {
            _needsManualUnlock = true;
          });
        }
        return;
      }
    }

    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    SoundService.instance.play(LuminaSound.biometricUnlock);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
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
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Radial Light
          Positioned(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    LuminaColors.electricCobalt.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ).animate().scale(duration: 1200.ms, curve: Curves.easeOutCubic),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Cyber Diamond Logo (Acid Lime on Midnight Black)
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: LuminaColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: LuminaColors.acidLime.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LuminaColors.acidLime.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: LuminaColors.electricCobalt.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.diamond_outlined,
                      color: LuminaColors.acidLime,
                      size: 44,
                    ),
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).shimmer(delay: 600.ms, duration: 800.ms),

                const SizedBox(height: 24),

                Text(
                  'LUMINA',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6.0,
                    color: LuminaColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 6),

                Text(
                  'SOVEREIGN WEALTH & PRIVATE BANKING',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: LuminaColors.electricCobalt,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                if (_needsManualUnlock) ...[
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _needsManualUnlock = false;
                      });
                      _startIgnitionSequence();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: LuminaColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: LuminaColors.neonGreen),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fingerprint_rounded, color: LuminaColors.neonGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'UNLOCK WITH BIOMETRICS',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: LuminaColors.neonGreen,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).scale(),
                ],
              ],
            ),
          ),

          // Bottom Security Status
          Positioned(
            bottom: 40,
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: LuminaColors.textMuted, size: 14),
                const SizedBox(width: 6),
                Text(
                  'ENCLAVE ENCRYPTION ACTIVE • ARBITRUM L2',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: LuminaColors.textMuted,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms),
          ),
        ],
      ),
    );
  }
}

