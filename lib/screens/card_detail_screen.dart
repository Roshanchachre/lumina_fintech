import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../core/security/biometric_service.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/interactive_card.dart';
import '../widgets/lumina_snackbar.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  bool _isCredentialsRevealed = false;
  late double _editingLimit;
  bool _isAppleWalletAdded = false;

  @override
  void initState() {
    super.initState();
    final card = _findCard();
    _editingLimit = card?.dailyLimit ?? 25000.0;
  }

  LuminaCardModel? _findCard() {
    final cards = context.read<AccountBloc>().state.cards;
    try {
      return cards.firstWhere((c) => c.id == widget.cardId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _revealCredentials() async {
    HapticFeedback.mediumImpact();
    if (_isCredentialsRevealed) {
      setState(() => _isCredentialsRevealed = false);
      return;
    }

    final bio = BiometricService();
    final authed = await bio.authenticate(
      localizedReason: 'Authenticate to reveal card credentials and CVV',
    );

    if (authed && mounted) {
      SoundService.instance.play(LuminaSound.biometricUnlock);
      HapticFeedback.lightImpact();
      setState(() => _isCredentialsRevealed = true);
      LuminaSnackBar.show(
        context,
        type: LuminaSnackBarType.warning,
        title: 'Credentials Revealed',
        message: 'Card credentials unmasked. Automatic privacy protection in 20s.',
      );
      Future.delayed(const Duration(seconds: 20), () {
        if (mounted && _isCredentialsRevealed) {
          setState(() => _isCredentialsRevealed = false);
        }
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text.replaceAll(' ', '')));
    LuminaSnackBar.show(
      context,
      type: LuminaSnackBarType.success,
      title: 'Copied to Clipboard',
      message: '$label copied. Securely cleared in 30 seconds.',
    );
  }

  void _addToAppleWallet(LuminaCardModel card) {
    SoundService.instance.play(LuminaSound.biometricUnlock);
    HapticFeedback.mediumImpact();
    setState(() => _isAppleWalletAdded = true);
    LuminaSnackBar.show(
      context,
      type: LuminaSnackBarType.success,
      title: 'Apple Wallet Provisioned',
      message: '${card.tierName} successfully added to Apple Pay.',
    );
  }

  void _showChangePinDialog(BuildContext context, LuminaCardModel card) {
    SoundService.instance.play(LuminaSound.cardClick);
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LuminaColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: LuminaColors.surfaceBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.password_rounded, color: LuminaColors.acidLime, size: 22),
            const SizedBox(width: 10),
            Text(
              'CHANGE CHIP PIN',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: LuminaColors.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a new 4-digit PIN for physical point-of-sale and ATM cash access:',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LuminaColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: GoogleFonts.spaceGrotesk(fontSize: 16, color: LuminaColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: LuminaColors.background,
                hintText: 'New 4-digit PIN',
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LuminaColors.surfaceBorder)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: GoogleFonts.spaceGrotesk(fontSize: 16, color: LuminaColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: LuminaColors.background,
                hintText: 'Confirm 4-digit PIN',
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LuminaColors.surfaceBorder)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(color: LuminaColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LuminaColors.acidLime, foregroundColor: LuminaColors.midnightBlack),
            onPressed: () async {
              if (pinController.text.length != 4 || pinController.text != confirmController.text) {
                LuminaSnackBar.show(context, type: LuminaSnackBarType.error, title: 'Invalid PIN', message: 'PINs must match and contain 4 digits.');
                return;
              }
              Navigator.pop(ctx);
              context.read<AccountBloc>().add(SetCardPin(card.id, pinController.text));
              LuminaSnackBar.show(context, type: LuminaSnackBarType.success, title: 'PIN Updated', message: 'Card PIN updated in Secure Enclave.');
            },
            child: Text('SAVE PIN', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmTerminateCard(BuildContext context, LuminaCardModel card) {
    SoundService.instance.play(LuminaSound.errorAlert);
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LuminaColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: LuminaColors.crimsonAlert),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: LuminaColors.crimsonAlert, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'DEACTIVATE CARD?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LuminaColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently deactivate ${card.tierName} (${card.maskedPan}) and destroy its tokenized cryptographic keys. Any recurring subscriptions tied to this card will be declined.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            height: 1.4,
            color: LuminaColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(color: LuminaColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LuminaColors.crimsonAlert,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              context.read<AccountBloc>().add(TerminateCard(card.id));
              Navigator.pop(context); // Return to Cards Screen
              LuminaSnackBar.show(
                context,
                type: LuminaSnackBarType.warning,
                title: 'Card Deactivated',
                message: '${card.tierName} has been purged from your active vault.',
              );
            },
            child: Text('TERMINATE CARD', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0.00", "en_US");

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final card = _findCard();

        if (card == null) {
          return Scaffold(
            backgroundColor: LuminaColors.background,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.credit_card_off_rounded, size: 48, color: LuminaColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'CARD NOT FOUND',
                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: LuminaColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Return to Cards'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isPhysical = card.isPhysical;
        final displayedPan = _isCredentialsRevealed
            ? (card.fullPan ?? '4820  8391  0294  8492')
            : card.maskedPan;

        return Scaffold(
          backgroundColor: LuminaColors.background,
          body: LuminaAtmosphericBackground(
            animate: true,
            showGrid: true,
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LuminaColors.textPrimary, size: 18),
                          onPressed: () {
                            SoundService.instance.play(LuminaSound.cardClick);
                            Navigator.of(context).pop();
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                card.tierName.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: LuminaColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isPhysical ? 'Physical Laser Metal' : 'Instant Virtual Protocol',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: LuminaColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: LuminaColors.crimsonAlert, size: 22),
                          onPressed: () => _confirmTerminateCard(context, card),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3D Tilt Card
                          Center(
                            child: InteractiveCard(
                              balance: card.balance,
                              cardHolder: card.cardHolder,
                              cardNumber: displayedPan,
                              expiry: card.expiry,
                              gradient: card.gradient,
                              tierName: card.tierName,
                              accentColor: card.accentColor,
                              cardType: card.cardType,
                              cardNickname: card.cardNickname,
                            ),
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 8),

                          Center(
                            child: Text(
                              'Tap card to flip • Tilt phone to inspect 3D metallic sheen',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: LuminaColors.textMuted,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Unmask Credentials Button
                          GestureDetector(
                            onTap: _revealCredentials,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: LuminaColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _isCredentialsRevealed ? LuminaColors.acidLime : LuminaColors.surfaceBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isCredentialsRevealed ? Icons.visibility_off_rounded : Icons.fingerprint_rounded,
                                    color: _isCredentialsRevealed ? LuminaColors.acidLime : LuminaColors.electricCobalt,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _isCredentialsRevealed ? 'HIDE CARD CREDENTIALS' : 'REVEAL FULL PAN & CVV (BIOMETRIC)',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: _isCredentialsRevealed ? LuminaColors.acidLime : LuminaColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Credential Details Box (When Revealed)
                          if (_isCredentialsRevealed) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: LuminaColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('FULL CARD NUMBER (PAN)', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: LuminaColors.textMuted)),
                                          const SizedBox(height: 2),
                                          Text(displayedPan, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: LuminaColors.textPrimary)),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, color: LuminaColors.acidLime, size: 18),
                                        onPressed: () => _copyToClipboard(displayedPan, 'Card Number'),
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
                                          Text('EXPIRATION', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: LuminaColors.textMuted)),
                                          const SizedBox(height: 2),
                                          Text(card.expiry, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: LuminaColors.textPrimary)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('CVV SECURITY CODE', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: LuminaColors.textMuted)),
                                          const SizedBox(height: 2),
                                          Text(card.cvv, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: LuminaColors.acidLime)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 300.ms),
                          ],

                          const SizedBox(height: 20),

                          // Quick Apple Wallet Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: _isAppleWalletAdded ? LuminaColors.neonGreen : Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: Icon(_isAppleWalletAdded ? Icons.check_circle_rounded : Icons.apple_rounded, color: _isAppleWalletAdded ? LuminaColors.neonGreen : Colors.white, size: 18),
                              label: Text(
                                _isAppleWalletAdded ? 'ADDED TO APPLE WALLET' : 'ADD TO APPLE WALLET',
                                style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              onPressed: _isAppleWalletAdded ? null : () => _addToAppleWallet(card),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Daily Spending Limit Section
                          _buildSectionHeader('DAILY SPENDING LIMIT'),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: LuminaColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Configured Limit', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: LuminaColors.textSecondary)),
                                    Text(
                                      '\$${currencyFormatter.format(_editingLimit)} / day',
                                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: card.accentColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: card.accentColor,
                                    inactiveTrackColor: Colors.white12,
                                    thumbColor: Colors.white,
                                    overlayColor: card.accentColor.withValues(alpha: 0.2),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: _editingLimit,
                                    min: 1000,
                                    max: 100000,
                                    divisions: 99,
                                    onChanged: (val) {
                                      HapticFeedback.selectionClick();
                                      setState(() => _editingLimit = val);
                                    },
                                    onChangeEnd: (val) {
                                      context.read<AccountBloc>().add(UpdateCardDailyLimit(card.id, val));
                                      LuminaSnackBar.show(
                                        context,
                                        type: LuminaSnackBarType.success,
                                        title: 'Limit Saved',
                                        message: 'Daily spending limit set to \$${currencyFormatter.format(val)}',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Security Controls
                          _buildSectionHeader('SECURITY & PERMISSIONS'),
                          const SizedBox(height: 10),

                          _buildControlTile(
                            icon: Icons.ac_unit_rounded,
                            title: 'Freeze Card',
                            subtitle: 'Instantly decline all point-of-sale and online transactions',
                            value: card.isFrozen,
                            accentColor: LuminaColors.crimsonAlert,
                            onChanged: (val) async {
                              HapticFeedback.mediumImpact();
                              final bio = BiometricService();
                              final authed = await bio.authenticate(
                                localizedReason: val ? 'Authenticate to freeze card' : 'Authenticate to unfreeze card',
                              );
                              if (!authed) return;
                              SoundService.instance.play(LuminaSound.vaultLock);
                              if (!context.mounted) return;
                              context.read<AccountBloc>().add(ToggleCardFreeze(card.id));
                            },
                          ),
                          const SizedBox(height: 10),

                          _buildControlTile(
                            icon: Icons.language_rounded,
                            title: 'Online Payments',
                            subtitle: 'Allow e-commerce transactions and subscriptions',
                            value: card.isOnlineEnabled,
                            accentColor: LuminaColors.electricCobalt,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              context.read<AccountBloc>().add(ToggleCardOnline(card.id));
                            },
                          ),
                          const SizedBox(height: 10),

                          _buildControlTile(
                            icon: Icons.flight_takeoff_rounded,
                            title: 'International Usage',
                            subtitle: 'Zero cross-border exchange fee on Arbitrum L2',
                            value: card.isInternationalEnabled,
                            accentColor: LuminaColors.acidLime,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              context.read<AccountBloc>().add(ToggleCardInternational(card.id));
                            },
                          ),

                          if (isPhysical) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _showChangePinDialog(context, card),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: LuminaColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: LuminaColors.acidLime.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.password_rounded, color: LuminaColors.acidLime, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Change 4-Digit Chip PIN', style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w600, color: LuminaColors.textPrimary)),
                                          Text('Configure ATM & terminal PIN', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LuminaColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: LuminaColors.textMuted, size: 20),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Physical Card Dispatch Timeline
                            _buildSectionHeader('INSURED COURIER DISPATCH TRACKING'),
                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: LuminaColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'DHL Express Priority',
                                        style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: LuminaColors.textPrimary),
                                      ),
                                      Text(
                                        card.trackingNumber ?? 'DHL-LUMINA-98214',
                                        style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: LuminaColors.electricCobalt),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTrackingStep(0, 'Order Placed & Queued', 'Zurich Sovereign Vault Enclave', isCompleted: true),
                                  _buildTrackingStep(1, 'Laser Etching & Chip Bond', 'Precision CNC Titanium Finish', isCompleted: true),
                                  _buildTrackingStep(2, 'Dispatched with DHL Express', 'In transit to recipient address', isCompleted: card.shippingStep >= 2, isActive: card.shippingStep == 2),
                                  _buildTrackingStep(3, 'Delivered & Activated', 'Signed delivery required', isCompleted: card.shippingStep >= 3, isLast: true),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: LuminaColors.textSecondary,
      ),
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LuminaColors.surfaceBorderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: LuminaColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: LuminaColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(int index, String title, String subtitle, {bool isCompleted = false, bool isActive = false, bool isLast = false}) {
    final color = isCompleted
        ? LuminaColors.neonGreen
        : (isActive ? LuminaColors.acidLime : LuminaColors.textMuted);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? LuminaColors.neonGreen : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 10, color: LuminaColors.midnightBlack)
                  : (isActive ? Container(margin: const EdgeInsets.all(3), decoration: const BoxDecoration(shape: BoxShape.circle, color: LuminaColors.acidLime)) : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? LuminaColors.neonGreen.withValues(alpha: 0.4) : LuminaColors.surfaceBorderSubtle,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
                  color: isCompleted || isActive ? LuminaColors.textPrimary : LuminaColors.textMuted,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: LuminaColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
