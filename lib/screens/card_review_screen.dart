import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../core/security/biometric_service.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';
import 'card_success_screen.dart';
import 'issue_card_screen.dart';

class CardReviewScreen extends StatefulWidget {
  final CardType cardType;
  final IssueCardTierInfo tierInfo;
  final String cardHolder;
  final String cardNickname;
  final double dailyLimit;
  final bool isOnlineEnabled;
  final bool isInternationalEnabled;
  final String? shippingAddress;
  final String cardPin;

  const CardReviewScreen({
    super.key,
    required this.cardType,
    required this.tierInfo,
    required this.cardHolder,
    required this.cardNickname,
    required this.dailyLimit,
    required this.isOnlineEnabled,
    required this.isInternationalEnabled,
    this.shippingAddress,
    this.cardPin = '1234',
  });

  @override
  State<CardReviewScreen> createState() => _CardReviewScreenState();
}

class _CardReviewScreenState extends State<CardReviewScreen> {
  bool _isMinting = false;
  String _mintingStatus = 'Generating 256-bit Enclave Seed...';

  Future<void> _authorizeAndMint() async {
    HapticFeedback.mediumImpact();
    SoundService.instance.play(LuminaSound.cardClick);

    final bio = BiometricService();
    final authenticated = await bio.authenticate(
      localizedReason: 'Authenticate to authorize Sovereign Card minting',
    );

    if (!authenticated) {
      if (!mounted) return;
      LuminaSnackBar.show(
        context,
        type: LuminaSnackBarType.warning,
        title: 'Authorization Required',
        message: 'Biometric authorization was cancelled or failed.',
      );
      return;
    }

    setState(() {
      _isMinting = true;
      _mintingStatus = 'Generating 256-bit Enclave cryptographic seed...';
    });

    SoundService.instance.play(LuminaSound.biometricUnlock);
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _mintingStatus = 'Minting tokenized EMV credentials on Arbitrum L2...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _mintingStatus = 'Enclave signature verified & card activated!';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Generate authentic card credentials
    final random = math.Random();
    final p1 = 4820 + random.nextInt(80);
    final p2 = 1000 + random.nextInt(8999);
    final p3 = 1000 + random.nextInt(8999);
    final p4 = 1000 + random.nextInt(8999);
    final fullPan = '$p1  $p2  $p3  $p4';
    final maskedPan = '$p1  ••••  ••••  $p4';
    final cvv = (100 + random.nextInt(899)).toString();
    final expYear = DateTime.now().year + 5;
    final expMonth = (1 + random.nextInt(12)).toString().padLeft(2, '0');
    final expiry = '$expMonth/${expYear.toString().substring(2)}';
    final cardId = 'card_${widget.tierInfo.id}_${DateTime.now().millisecondsSinceEpoch}';

    final tracking = widget.cardType == CardType.physical
        ? 'DHL-LUMINA-${100000 + random.nextInt(899999)}'
        : null;

    final newCard = LuminaCardModel(
      id: cardId,
      cardHolder: widget.cardHolder.toUpperCase(),
      maskedPan: maskedPan,
      expiry: expiry,
      cvv: cvv,
      balance: 0.00,
      dailyLimit: widget.dailyLimit,
      isFrozen: false,
      isOnlineEnabled: widget.isOnlineEnabled,
      isInternationalEnabled: widget.isInternationalEnabled,
      tierName: widget.tierInfo.name,
      gradient: widget.tierInfo.gradient,
      accentColor: widget.tierInfo.accentColor,
      cardType: widget.cardType,
      cardNickname: widget.cardNickname,
      shippingAddress: widget.shippingAddress,
      trackingNumber: tracking,
      cardPin: widget.cardPin,
      fullPan: fullPan,
      issuedAt: DateTime.now(),
      shippingStep: 0,
    );

    context.read<AccountBloc>().add(IssueNewCard(newCard));
    SoundService.instance.play(LuminaSound.moneyReceived);
    HapticFeedback.mediumImpact();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => CardSuccessScreen(card: newCard),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "en_US");
    final isPhysical = widget.cardType == CardType.physical;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: LuminaAtmosphericBackground(
        animate: true,
        showGrid: true,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Navigation Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LuminaColors.textPrimary, size: 18),
                          onPressed: _isMinting
                              ? null
                              : () {
                                  SoundService.instance.play(LuminaSound.cardClick);
                                  Navigator.of(context).pop();
                                },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STEP 3 OF 3 • ENCLAVE REVIEW',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: LuminaColors.electricCobalt,
                                ),
                              ),
                              Text(
                                'Cryptographic Authorization',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: LuminaColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Review Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Miniature Card Preview Banner
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: widget.tierInfo.gradient,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: widget.tierInfo.accentColor.withValues(alpha: 0.6), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.tierInfo.accentColor.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.tierInfo.name.toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: widget.tierInfo.accentColor,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isPhysical ? 'PHYSICAL METAL' : 'VIRTUAL TOKEN',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  '4820  ••••  ••••  ••••',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.5,
                                    color: LuminaColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.cardHolder.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: LuminaColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'EXP 5 YRS',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: LuminaColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Summary Specification Table
                          Text(
                            'ORDER SPECIFICATIONS & METRICS',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: LuminaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            decoration: BoxDecoration(
                              color: LuminaColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow('Card Form Factor', isPhysical ? 'Physical Laser Metal' : 'Instant Virtual Protocol'),
                                _buildDivider(),
                                _buildSummaryRow('Sovereign Alloy', widget.tierInfo.materialName),
                                _buildDivider(),
                                _buildSummaryRow('Card Purpose', widget.cardNickname),
                                _buildDivider(),
                                _buildSummaryRow('Spending Limit', '\$${currencyFormatter.format(widget.dailyLimit)} / day'),
                                _buildDivider(),
                                _buildSummaryRow('Online Payments', widget.isOnlineEnabled ? 'Active' : 'Disabled'),
                                _buildDivider(),
                                _buildSummaryRow('Cross-Border FX', widget.isInternationalEnabled ? '0.0% Zero Fee' : 'Disabled'),
                                if (isPhysical && widget.shippingAddress != null) ...[
                                  _buildDivider(),
                                  _buildSummaryRow('Courier Delivery', 'DHL Express Priority (Complimentary)'),
                                  _buildDivider(),
                                  _buildSummaryRow('Destination', widget.shippingAddress!, multiLine: true),
                                ],
                                _buildDivider(),
                                _buildSummaryRow('Issuance Minting Fee', 'FREE (Sovereign Member)', highlightGreen: true),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Hardware Security Trust Pill
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: LuminaColors.surfaceElevated.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_rounded, color: LuminaColors.acidLime, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Keys generated inside hardware enclave. EMV parameters signed with zero exposure to web rails.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: LuminaColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Authorization Button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: BoxDecoration(
                      color: LuminaColors.surfaceElevated.withValues(alpha: 0.95),
                      border: const Border(top: BorderSide(color: LuminaColors.surfaceBorderSubtle)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LuminaColors.electricCobalt,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _isMinting ? null : _authorizeAndMint,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fingerprint_rounded, size: 22, color: LuminaColors.acidLime),
                              const SizedBox(width: 10),
                              Text(
                                'AUTHORIZE & MINT CARD',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Cryptographic Minting Overlay
              if (_isMinting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: LuminaColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.6)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 52,
                              height: 52,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                valueColor: AlwaysStoppedAnimation<Color>(LuminaColors.acidLime),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'MINTING SOVEREIGN ENCLAVE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: LuminaColors.acidLime,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _mintingStatus,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: LuminaColors.textSecondary,
                              ),
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
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlightGreen = false, bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: LuminaColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: highlightGreen ? LuminaColors.neonGreen : LuminaColors.textPrimary,
              ),
              maxLines: multiLine ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: LuminaColors.surfaceBorderSubtle);
  }
}
