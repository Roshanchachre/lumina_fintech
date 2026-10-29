import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lumina_theme.dart';
import '../widgets/lumina_snackbar.dart';

class InvestModal extends StatelessWidget {
  const InvestModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: LuminaColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: LuminaColors.surfaceBorder, width: 1.5)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'HIGH-YIELD WEALTH VAULTS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: LuminaColors.electricCobalt,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Automated capital compounding with institutional custody',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: LuminaColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Vault 1: Arbitrum L2 Staked ETH
              _buildVaultOption(
                context: context,
                icon: Icons.token_rounded,
                title: 'Arbitrum L2 Liquid Staking',
                apy: '4.8% APY',
                description: 'wstETH liquidity protocol • Hourly yield compounding',
                accentColor: LuminaColors.electricCobalt,
                onTap: () {
                  _showSuccess(context, 'Allocated \$5,000 into Arbitrum L2 Staked ETH.');
                },
              ),

              // Vault 2: Tokenized Sovereign Gold
              _buildVaultOption(
                context: context,
                icon: Icons.shield_rounded,
                title: 'Physical Tokenized Gold (PAXG)',
                apy: '1.5% APY + Spot',
                description: '100% backed by London Bullion Market Association (LBMA)',
                accentColor: LuminaColors.amberWarning,
                onTap: () {
                  _showSuccess(context, 'Allocated \$2,500 into LBMA Tokenized Gold.');
                },
              ),

              // Vault 3: SaaS & Tech Equities Index
              _buildVaultOption(
                context: context,
                icon: Icons.insights_rounded,
                title: 'Silicon Valley AI & SaaS Index',
                apy: '14.2% YTD',
                description: 'Top-tier public tech & AI hardware equities basket',
                accentColor: LuminaColors.acidLime,
                onTap: () {
                  _showSuccess(context, 'Allocated \$10,000 into AI & SaaS Equities Index.');
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static void _showSuccess(BuildContext context, String message) {
    Navigator.pop(context);
    LuminaSnackBar.show(
      context,
      type: LuminaSnackBarType.success,
      title: 'Allocation Executed',
      message: message,
    );
  }

  Widget _buildVaultOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String apy,
    required String description,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LuminaColors.surfaceBorderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              apy,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: LuminaColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
