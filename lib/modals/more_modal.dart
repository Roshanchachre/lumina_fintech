import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lumina_theme.dart';
import '../widgets/lumina_snackbar.dart';

class MoreModal extends StatelessWidget {
  const MoreModal({super.key});

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
                'INSTITUTIONAL SERVICES',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: LuminaColors.acidLime,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Private banking concierge and accounting utilities',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: LuminaColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Service 1: VIP Private Banker
              _buildServiceTile(
                context: context,
                icon: Icons.support_agent_rounded,
                title: 'Private Wealth Concierge',
                subtitle: 'Direct 24/7 priority line to your designated banker',
                accentColor: LuminaColors.acidLime,
                onTap: () {
                  _action(context, 'Connecting to Senior Private Banker (Average reply: < 2 min)...');
                },
              ),

              // Service 2: Statements & Tax
              _buildServiceTile(
                context: context,
                icon: Icons.receipt_long_rounded,
                title: 'Export Certified Statements',
                subtitle: 'Download monthly PDF summaries and CPA-ready CSVs',
                accentColor: LuminaColors.electricCobalt,
                onTap: () {
                  _action(context, 'October 2026 Certified Wealth Statement downloaded (PDF).');
                },
              ),

              // Service 3: Corporate Tier Privileges
              _buildServiceTile(
                context: context,
                icon: Icons.diamond_rounded,
                title: 'Sovereign Lounge Access',
                subtitle: 'Digital Priority Pass across 1,400+ international airport lounges',
                accentColor: LuminaColors.acidLime,
                onTap: () {
                  _action(context, 'Digital Lounge Pass Active • Valid through 2029.');
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static void _action(BuildContext context, String message) {
    Navigator.pop(context);
    LuminaSnackBar.show(
      context,
      type: LuminaSnackBarType.info,
      title: 'Institutional Service',
      message: message,
    );
  }

  Widget _buildServiceTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
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
