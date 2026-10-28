import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/security/secure_vault.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/mascot_widget.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final SecureVault? secureVault;

  const OnboardingScreen({
    super.key,
    this.secureVault,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final SecureVault _secureVault;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _secureVault = widget.secureVault ?? SecureVault();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    SoundService.instance.play(LuminaSound.cardClick);
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.heavyImpact();
    SoundService.instance.play(LuminaSound.biometricUnlock);
    await _secureVault.setOnboardingCompleted(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: LuminaAtmosphericBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Skip & Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: LuminaColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: LuminaColors.acidLime.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.diamond_outlined,
                            color: LuminaColors.acidLime,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LUMINA',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: LuminaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'SKIP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LuminaColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal 3-Screen Carousel
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildOnboardingPage(
                      scene: LumiScene.sovereignCustody,
                      badge: 'SOVEREIGN CUSTODY',
                      title: 'Your Wealth,\nTruly Sovereign',
                      subtitle:
                          'Institutional-grade custody with zero counterparty lock-in. Track and hold liquid fiat, tokenized LBMA gold, and crypto assets in one secure vault.',
                      tags: ['Zero Custody Lock', 'Self-Sovereign', 'Multi-Asset'],
                    ),
                    _buildOnboardingPage(
                      scene: LumiScene.yieldVelocity,
                      badge: 'ARBITRUM L2 SPEED',
                      title: 'High-Frequency\nYield Velocity',
                      subtitle:
                          'Compounding yields running hourly on Arbitrum L2. Dispatch instant zero-fee wire transfers globally with sub-second cryptographic finality.',
                      tags: ['4.8% APY Hourly', 'Zero Network Fee', 'Instant Wires'],
                    ),
                    _buildOnboardingPage(
                      scene: LumiScene.enclaveSecurity,
                      badge: 'MILITARY-GRADE ENCLAVE',
                      title: 'Biometric Hardware\nVault Protection',
                      subtitle:
                          'Protected by on-device Secure Enclave & Android KeyStore. Zero-knowledge privacy veils automatically shield your balances from shoulder-surfers.',
                      tags: ['Secure Enclave', 'Face ID / Touch ID', 'Privacy Veil'],
                    ),
                  ],
                ),
              ),

              // Bottom Section: Dots & Primary Action Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  children: [
                    // Page Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isSelected = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? LuminaColors.acidLime
                                : LuminaColors.surfaceBorder,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: LuminaColors.acidLime.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LuminaColors.acidLime,
                          foregroundColor: LuminaColors.midnightBlack,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _onNextPressed,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == 2
                                    ? 'INITIALIZE SECURE VAULT'
                                    : 'CONTINUE',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: LuminaColors.midnightBlack,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: LuminaColors.midnightBlack,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required LumiScene scene,
    required String badge,
    required String title,
    required String subtitle,
    required List<String> tags,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Interactive Animated Mascot
          LumiMascotWidget(
            scene: scene,
            size: 240,
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

          const SizedBox(height: 20),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: LuminaColors.electricCobalt.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: LuminaColors.electricCobalt.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              badge,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuminaColors.electricCobalt,
              ),
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: LuminaColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 10),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.45,
              color: LuminaColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 16),

          // Feature Tags Pill Wrap
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LuminaColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: LuminaColors.textMuted,
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
