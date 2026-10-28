import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lumina_theme.dart';

class Transaction {
  final String title;
  final String category;
  final String time;
  final double amount;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;

  const Transaction({
    required this.title,
    required this.category,
    required this.time,
    required this.amount,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
  });
}

class TransactionItemTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionItemTile({
    super.key,
    required this.transaction,
  });

  void _showDetailSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TransactionDetailModal(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailSheet(context),
          borderRadius: BorderRadius.circular(18),
          splashColor: LuminaColors.neonGreen.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: LuminaColors.surfaceElevated.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: LuminaColors.surfaceBorderSubtle,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Glowing Category Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: transaction.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: transaction.iconColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      transaction.icon,
                      color: transaction.iconColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: LuminaColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${transaction.category} • ${transaction.time}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: LuminaColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.isPositive ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: transaction.isPositive
                            ? LuminaColors.acidLime
                            : LuminaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: LuminaColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailModal extends StatelessWidget {
  final Transaction transaction;

  const _TransactionDetailModal({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: LuminaColors.surfaceBorder,
          width: 1.2,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Icon + Status
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: transaction.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: transaction.iconColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  transaction.icon,
                  color: transaction.iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),

              Text(
                '${transaction.isPositive ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: transaction.isPositive
                      ? LuminaColors.acidLime
                      : LuminaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: LuminaColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // Receipt Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LuminaColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                ),
                child: Column(
                  children: [
                    _receiptRow('Transaction ID', 'TX-9482-LUMINA'),
                    const Divider(color: Colors.white10, height: 20),
                    _receiptRow('Network Fee', '\$0.00 (Zero Fee Titanium)'),
                    const Divider(color: Colors.white10, height: 20),
                    _receiptRow('Status', 'Settled on Arbitrum L2'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Share Receipt Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuminaColors.electricCobalt.withValues(alpha: 0.2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: LuminaColors.electricCobalt),
                    ),
                  ),
                  child: Text(
                    'DOWNLOAD RECEIPT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: LuminaColors.textPrimary,
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

  Widget _receiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: LuminaColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: LuminaColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
