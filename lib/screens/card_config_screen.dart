import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';
import 'card_review_screen.dart';
import 'issue_card_screen.dart';

class CardConfigScreen extends StatefulWidget {
  final CardType cardType;
  final IssueCardTierInfo tierInfo;

  const CardConfigScreen({
    super.key,
    required this.cardType,
    required this.tierInfo,
  });

  @override
  State<CardConfigScreen> createState() => _CardConfigScreenState();
}

class _CardConfigScreenState extends State<CardConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late double _dailyLimit;

  // Switches
  bool _onlineEnabled = true;
  bool _internationalEnabled = true;
  bool _biometricChallenge = true;

  // Physical card fields
  final _streetController = TextEditingController(text: 'Bahnhofstrasse 45');
  final _suiteController = TextEditingController(text: 'Penthouse Suite 8B');
  final _cityController = TextEditingController(text: 'Zurich');
  final _postalController = TextEditingController(text: '8001');
  final _countryController = TextEditingController(text: 'Switzerland');

  final _pinController = TextEditingController(text: '1234');
  final _confirmPinController = TextEditingController(text: '1234');

  @override
  void initState() {
    super.initState();
    final user = context.read<AccountBloc>().state.user;
    _nameController = TextEditingController(text: user.name.toUpperCase());
    _nicknameController = TextEditingController(
      text: widget.cardType == CardType.virtual
          ? '${widget.tierInfo.name} Virtual'
          : '${widget.tierInfo.name} Metal',
    );
    _dailyLimit = widget.tierInfo.defaultLimit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _streetController.dispose();
    _suiteController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _countryController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _onProceedToReview() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      SoundService.instance.play(LuminaSound.errorAlert);
      HapticFeedback.heavyImpact();
      LuminaSnackBar.show(
        context,
        type: LuminaSnackBarType.error,
        title: 'Validation Incomplete',
        message: 'Please complete all required configuration fields.',
      );
      return;
    }

    if (widget.cardType == CardType.physical) {
      if (_pinController.text != _confirmPinController.text) {
        SoundService.instance.play(LuminaSound.errorAlert);
        HapticFeedback.heavyImpact();
        LuminaSnackBar.show(
          context,
          type: LuminaSnackBarType.error,
          title: 'PIN Mismatch',
          message: 'The 4-digit PIN confirmation does not match.',
        );
        return;
      }
    }

    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.mediumImpact();

    final shippingAddress = widget.cardType == CardType.physical
        ? '${_streetController.text.trim()}, ${_suiteController.text.trim()}, ${_cityController.text.trim()} ${_postalController.text.trim()}, ${_countryController.text.trim()}'
        : null;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => CardReviewScreen(
          cardType: widget.cardType,
          tierInfo: widget.tierInfo,
          cardHolder: _nameController.text.trim(),
          cardNickname: _nicknameController.text.trim(),
          dailyLimit: _dailyLimit,
          isOnlineEnabled: _onlineEnabled,
          isInternationalEnabled: _internationalEnabled,
          shippingAddress: shippingAddress,
          cardPin: _pinController.text.trim(),
        ),
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
          child: Column(
            children: [
              // Navigation Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP 2 OF 3 • CONFIGURATION',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: LuminaColors.electricCobalt,
                            ),
                          ),
                          Text(
                            'Security & Specifications',
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

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selected Card Summary Ribbon
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: LuminaColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: widget.tierInfo.accentColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: widget.tierInfo.gradient,
                                  border: Border.all(color: widget.tierInfo.accentColor),
                                ),
                                child: Center(
                                  child: Icon(Icons.diamond_outlined, color: widget.tierInfo.accentColor, size: 18),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.tierInfo.name.toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: widget.tierInfo.accentColor,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Text(
                                      isPhysical ? 'Physical Laser-Etched Metal' : 'Instant Virtual Protocol',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: LuminaColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isPhysical ? 'DHL TRACKED' : 'APPLE PAY READY',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section 1: Cardholder & Nickname
                        _buildSectionHeader('CARD IDENTITY & PURPOSES'),
                        const SizedBox(height: 10),

                        _buildTextFormField(
                          controller: _nameController,
                          label: 'EMBOSSED CARDHOLDER NAME',
                          hint: 'ALEX VANCE',
                          icon: Icons.person_outline_rounded,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Cardholder name is required' : null,
                        ),

                        const SizedBox(height: 14),

                        _buildTextFormField(
                          controller: _nicknameController,
                          label: 'CARD NICKNAME / USAGE NOTE',
                          hint: 'e.g., Primary Everyday Vault',
                          icon: Icons.bookmark_outline_rounded,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Card nickname is required' : null,
                        ),

                        const SizedBox(height: 24),

                        // Section 2: Daily Spending Limit
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
                                  Text(
                                    'Configured Limit',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: LuminaColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '\$${currencyFormatter.format(_dailyLimit)} / day',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: widget.tierInfo.accentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: widget.tierInfo.accentColor,
                                  inactiveTrackColor: Colors.white12,
                                  thumbColor: Colors.white,
                                  overlayColor: widget.tierInfo.accentColor.withValues(alpha: 0.2),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _dailyLimit,
                                  min: 1000,
                                  max: 100000,
                                  divisions: 99,
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _dailyLimit = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [2500.0, 10000.0, 25000.0, 50000.0].map((preset) {
                                  final isSelected = _dailyLimit == preset;
                                  return GestureDetector(
                                    onTap: () {
                                      SoundService.instance.play(LuminaSound.cardClick);
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _dailyLimit = preset;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? widget.tierInfo.accentColor.withValues(alpha: 0.18)
                                            : Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? widget.tierInfo.accentColor
                                              : LuminaColors.surfaceBorderSubtle,
                                        ),
                                      ),
                                      child: Text(
                                        preset % 1000 != 0
                                            ? '\$${(preset / 1000).toStringAsFixed(1)}k'
                                            : '\$${(preset / 1000).toInt()}k',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? widget.tierInfo.accentColor : LuminaColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section 3: Security & Channel Permissions
                        _buildSectionHeader('SECURITY & TRANSACTION CHANNELS'),
                        const SizedBox(height: 10),

                        _buildToggleCard(
                          icon: Icons.language_rounded,
                          title: 'Online E-Commerce Payments',
                          subtitle: 'Allow web checkouts, subscriptions, and recurring SaaS charges',
                          value: _onlineEnabled,
                          accent: LuminaColors.electricCobalt,
                          onChanged: (v) => setState(() => _onlineEnabled = v),
                        ),
                        const SizedBox(height: 10),
                        _buildToggleCard(
                          icon: Icons.flight_takeoff_rounded,
                          title: 'International Cross-Border Rails',
                          subtitle: 'Zero cross-border exchange fee on all global point-of-sale terminals',
                          value: _internationalEnabled,
                          accent: LuminaColors.acidLime,
                          onChanged: (v) => setState(() => _internationalEnabled = v),
                        ),
                        const SizedBox(height: 10),
                        _buildToggleCard(
                          icon: Icons.security_rounded,
                          title: 'Biometric Transaction Challenge',
                          subtitle: 'Require Face ID / Touch ID prompt for transactions over \$1,000',
                          value: _biometricChallenge,
                          accent: LuminaColors.amberWarning,
                          onChanged: (v) => setState(() => _biometricChallenge = v),
                        ),

                        // Section 4: Physical Delivery & Card PIN (Only for Physical Cards)
                        if (isPhysical) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('INSURED COURIER DELIVERY DESTINATION'),
                          const SizedBox(height: 10),

                          _buildTextFormField(
                            controller: _streetController,
                            label: 'STREET ADDRESS',
                            hint: 'Bahnhofstrasse 45',
                            icon: Icons.location_on_outlined,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Street address is required' : null,
                          ),
                          const SizedBox(height: 12),

                          _buildTextFormField(
                            controller: _suiteController,
                            label: 'SUITE / APARTMENT / FLOOR',
                            hint: 'Penthouse Suite 8B (Optional)',
                            icon: Icons.home_outlined,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextFormField(
                                  controller: _cityController,
                                  label: 'CITY',
                                  hint: 'Zurich',
                                  validator: (val) => val == null || val.trim().isEmpty ? 'City is required' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _postalController,
                                  label: 'POSTAL CODE',
                                  hint: '8001',
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildTextFormField(
                            controller: _countryController,
                            label: 'COUNTRY / TERRITORY',
                            hint: 'Switzerland',
                            icon: Icons.public_rounded,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Country is required' : null,
                          ),

                          const SizedBox(height: 24),
                          _buildSectionHeader('PHYSICAL CARD 4-DIGIT CHIP PIN'),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _pinController,
                                  label: 'CREATE 4-DIGIT PIN',
                                  hint: '••••',
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  validator: (val) => val != null && val.length == 4 ? null : '4 digits required',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _confirmPinController,
                                  label: 'CONFIRM PIN',
                                  hint: '••••',
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  validator: (val) => val != null && val.length == 4 ? null : '4 digits required',
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Review CTA
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
                    onPressed: _onProceedToReview,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'REVIEW & CRYPTOGRAPHIC AUTHORIZATION',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: LuminaColors.electricCobalt,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: GoogleFonts.plusJakartaSans(
            color: LuminaColors.textPrimary,
            fontSize: 14.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: LuminaColors.textMuted.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            counterText: '',
            prefixIcon: icon != null ? Icon(icon, color: LuminaColors.textMuted, size: 18) : null,
            filled: true,
            fillColor: LuminaColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LuminaColors.surfaceBorderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: LuminaColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: LuminaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: accent,
            activeTrackColor: accent.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}
