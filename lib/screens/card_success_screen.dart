import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/interactive_card.dart';
import '../widgets/lumina_snackbar.dart';

class CardSuccessScreen extends StatefulWidget {
  final LuminaCardModel card;

  const CardSuccessScreen({super.key, required this.card});

  @override
  State<CardSuccessScreen> createState() => _CardSuccessScreenState();
}

class _CardSuccessScreenState extends State<CardSuccessScreen> {
  bool _isAppleWalletAdded = false;

  void _addToAppleWallet() {
    SoundService.instance.play(LuminaSound.biometricUnlock);
    HapticFeedback.mediumImpact();
    setState(() {
      _isAppleWalletAdded = true;
    });
    LuminaSnackBar.show(
      context,
      type: LuminaSnackBarType.success,
      title: 'Added to Apple Wallet',
      message: '${widget.card.tierName} provisioned to Apple Pay on this device.',
    );
  }

  void _copyCardNumber() {
    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.selectionClick();
    final pan = widget.card.fullPan ?? widget.card.maskedPan;
    Clipboard.setData(ClipboardData(text: pan.replaceAll(' ', '')));
    LuminaSnackBar.show(
      context,
      type: LuminaSnackBarType.success,
      title: 'Card Copied',
      message: 'Card number copied to clipboard. Securely purged in 30s.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhysical = widget.card.isPhysical;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: LuminaColors.background,
        body: LuminaAtmosphericBackground(
          animate: true,
          showGrid: true,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Celebration Animated Badge
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: LuminaColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.card.accentColor,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.card.accentColor.withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: widget.card.accentColor,
                        size: 38,
                      ),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 18),

                  Text(
                    'CARD MINTED SUCCESSFULLY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: LuminaColors.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 6),

                  Text(
                    isPhysical
                        ? 'Your aerospace metal card has been queued for laser etching in Zurich and express dispatch.'
                        : 'Your virtual card is cryptographically active and ready for online payments & Apple Pay.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.4,
                      color: LuminaColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // Display the freshly minted card in all its glory
                  Center(
                    child: InteractiveCard(
                      balance: widget.card.balance,
                      cardHolder: widget.card.cardHolder,
                      cardNumber: widget.card.fullPan ?? widget.card.maskedPan,
                      expiry: widget.card.expiry,
                      gradient: widget.card.gradient,
                      tierName: widget.card.tierName,
                      accentColor: widget.card.accentColor,
                      cardType: widget.card.cardType,
                      cardNickname: widget.card.cardNickname,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 20),

                  // Unmasked credentials card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: LuminaColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CARD NUMBER (PAN)',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.electricCobalt,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.card.fullPan ?? widget.card.maskedPan,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: LuminaColors.acidLime, size: 20),
                              onPressed: _copyCardNumber,
                            ),
                          ],
                        ),
                        const Divider(height: 16, thickness: 1, color: LuminaColors.surfaceBorderSubtle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EXPIRATION',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.electricCobalt,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.card.expiry,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'SECURITY CODE (CVV)',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.electricCobalt,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.card.cvv,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.acidLime,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // If physical: Shipping tracking info card
                  if (isPhysical && widget.card.trackingNumber != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LuminaColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: LuminaColors.electricCobalt.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_shipping_rounded, color: LuminaColors.electricCobalt, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Insured Express Dispatch',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: LuminaColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  widget.card.trackingNumber!,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.electricCobalt,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: LuminaColors.neonGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'QUEUED',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: LuminaColors.neonGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Add to Apple Wallet button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: _isAppleWalletAdded ? LuminaColors.neonGreen : Colors.white24,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(
                        _isAppleWalletAdded ? Icons.check_circle_rounded : Icons.apple_rounded,
                        color: _isAppleWalletAdded ? LuminaColors.neonGreen : Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        _isAppleWalletAdded ? 'ADDED TO APPLE WALLET' : 'ADD TO APPLE WALLET',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      onPressed: _isAppleWalletAdded ? null : _addToAppleWallet,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Return to Cards Vault
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LuminaColors.acidLime,
                        foregroundColor: LuminaColors.midnightBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        SoundService.instance.play(LuminaSound.cardClick);
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'RETURN TO CARDS VAULT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
