import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lumina_theme.dart';
import '../widgets/lumina_snackbar.dart';

class DepositModal extends StatelessWidget {
  const DepositModal({super.key});

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
                'INSTANT DEPOSIT & FUNDING',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: LuminaColors.electricCobalt,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select funding method with zero gateway fees',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: LuminaColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Option 1: Instant Bank Wire (FedNow / SEPA / IMPS)
              _buildDepositOption(
                context: context,
                icon: Icons.account_balance_rounded,
                title: 'Instant Bank Wire',
                subtitle: 'FedNow / SEPA Instant • Settlement in < 30 sec',
                badge: 'NO LIMIT',
                accentColor: LuminaColors.acidLime,
                onTap: () {
                  Navigator.pop(context);
                  LuminaSnackBar.show(
                    context,
                    type: LuminaSnackBarType.info,
                    title: 'Wire Routing Instructions',
                    message: 'Virtual Routing: 021000021 • Account: 9821489201',
                  );
                },
              ),

              // Option 2: Crypto Deposit (Arbitrum L2)
              _buildDepositOption(
                context: context,
                icon: Icons.qr_code_2_rounded,
                title: 'Crypto Deposit (Arbitrum L2)',
                subtitle: 'Send USDC, USDT or ETH to your sovereign address',
                badge: 'ZERO GAS',
                accentColor: LuminaColors.electricCobalt,
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: '0x71C83912048921820489B29A'));
                  Navigator.pop(context);
                  LuminaSnackBar.show(
                    context,
                    type: LuminaSnackBarType.success,
                    title: 'Address Copied',
                    message: 'Arbitrum L2 Address copied: 0x71C...B29A',
                  );
                },
              ),

              // Option 3: Apple Pay / Debit Card
              _buildDepositOption(
                context: context,
                icon: Icons.apple_rounded,
                title: 'Apple Pay / Debit Card',
                subtitle: 'Instant debit from linked card • Up to \$10,000/day',
                badge: 'INSTANT',
                accentColor: LuminaColors.textPrimary,
                onTap: () {
                  Navigator.pop(context);
                  LuminaSnackBar.show(
                    context,
                    type: LuminaSnackBarType.success,
                    title: 'Top-Up Initiated',
                    message: 'Apple Pay instant deposit authorized and clearing.',
                  );
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepositOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            const Icon(Icons.chevron_right_rounded, color: LuminaColors.textMuted),
          ],
        ),
      ),
    );
  }
}
