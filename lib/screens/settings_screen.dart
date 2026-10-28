import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/account_bloc.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/privacy_veil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = SoundService.instance.isEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: LuminaColors.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SECURITY & SETTINGS',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: LuminaColors.acidLime,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Account Preferences',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: LuminaColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),

                // User Profile Hero Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: LuminaColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: LuminaColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LuminaColors.cobaltAcid,
                            ),
                            child: const CircleAvatar(
                              radius: 26,
                              backgroundColor: Color(0xFF1E2433),
                              child: Icon(Icons.person_rounded, color: LuminaColors.textPrimary, size: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        state.user.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: LuminaColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, color: LuminaColors.electricCobalt, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.user.email,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: LuminaColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: LuminaColors.acidLime.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    state.user.tier.toUpperCase(),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: LuminaColors.acidLime,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                ),

                // Security & Privacy Vault Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECURITY & VAULT PROTECTION',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: LuminaColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Biometrics Switch
                        _buildSettingToggle(
                          icon: Icons.fingerprint_rounded,
                          title: 'Biometric FaceID / TouchID',
                          subtitle: 'Require biometric scan upon cold launch and transactions',
                          value: state.isBiometricsEnabled,
                          accentColor: LuminaColors.acidLime,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            context.read<AccountBloc>().add(ToggleBiometrics(val));
                          },
                        ),

                        // Discrete Gaze Privacy Switch
                        _buildSettingToggle(
                          icon: Icons.shield_rounded,
                          title: 'Discrete Gaze Privacy Shield',
                          subtitle: 'Double tap balance or shake phone to mask financial numbers',
                          value: state.isDiscreteMode,
                          accentColor: LuminaColors.electricCobalt,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            context.read<AccountBloc>().add(ToggleDiscreteMode());
                          },
                        ),

                        // Acoustic & Sound Feedback Switch
                        _buildSettingToggle(
                          icon: Icons.volume_up_rounded,
                          title: 'Tactile Sound Design',
                          subtitle: 'Spatial acoustic chimes on wire transfers and biometric vault unlock',
                          value: _soundEnabled,
                          accentColor: LuminaColors.acidLime,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _soundEnabled = val;
                              SoundService.instance.isEnabled = val;
                            });
                            if (val) {
                              SoundService.instance.play(LuminaSound.moneyReceived);
                            }
                          },
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'REGIONAL & SETTLEMENT',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: LuminaColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Base Currency Picker
                        _buildSelectTile(
                          icon: Icons.currency_exchange_rounded,
                          title: 'Base Currency',
                          value: state.baseCurrency,
                          accentColor: LuminaColors.amberWarning,
                          onTap: () {
                            _showCurrencyPicker(context, state.baseCurrency);
                          },
                        ),

                        // L2 Network Status
                        _buildSelectTile(
                          icon: Icons.hub_rounded,
                          title: 'L2 Settlement Network',
                          value: 'Arbitrum One L2 (0x82...1)',
                          accentColor: LuminaColors.electricCobalt,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connected to Arbitrum One RPC • 240 TPS'),
                                backgroundColor: LuminaColors.surfaceElevated,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Lock App / Sign out button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: LuminaColors.crimsonAlert,
                              side: BorderSide(color: LuminaColors.crimsonAlert.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.lock_rounded, size: 18),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'LOCK VAULT & SECURE SESSION',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              LuminaPrivacyGuard.of(context)?.lockVault();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vault Locked. Biometric re-authentication required.'),
                                  backgroundColor: LuminaColors.surfaceElevated,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 250.ms),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showCurrencyPicker(BuildContext context, String currentCurrency) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: LuminaColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final currencies = ['USD (\$)', 'EUR (€)', 'INR (₹)', 'GBP (£)'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT BASE CURRENCY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: LuminaColors.electricCobalt,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...currencies.map((curr) {
                  final code = curr.split(' ')[0];
                  final isSelected = code == currentCurrency;
                  return ListTile(
                    title: Text(curr, style: GoogleFonts.plusJakartaSans(color: LuminaColors.textPrimary)),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: LuminaColors.neonGreen) : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<AccountBloc>().add(ChangeBaseCurrency(code));
                      Navigator.pop(sheetContext);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                    fontSize: 15,
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

  Widget _buildSelectTile({
    required IconData icon,
    required String title,
    required String value,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: LuminaColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: LuminaColors.electricCobalt,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: LuminaColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
