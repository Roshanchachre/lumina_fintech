import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/account_bloc.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';

enum ActivityFilter {
  all,
  inflow,
  outflow,
  yields,
}

class ActivitiesScreen extends StatefulWidget {
  final List<TransactionRecord>? initialTransactions;

  const ActivitiesScreen({
    super.key,
    this.initialTransactions,
  });

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  ActivityFilter _activeFilter = ActivityFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionRecord> _filterTransactions(List<TransactionRecord> all) {
    return all.where((tx) {
      // Category filter
      if (_activeFilter == ActivityFilter.inflow && !tx.isPositive) return false;
      if (_activeFilter == ActivityFilter.outflow && tx.isPositive) return false;
      if (_activeFilter == ActivityFilter.yields && !tx.category.toLowerCase().contains('yield') && !tx.title.toLowerCase().contains('yield')) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = tx.title.toLowerCase().contains(q);
        final matchesCat = tx.category.toLowerCase().contains(q);
        final matchesRef = tx.referenceId.toLowerCase().contains(q);
        final matchesHash = (tx.blockchainTxHash ?? '').toLowerCase().contains(q);
        return matchesTitle || matchesCat || matchesRef || matchesHash;
      }

      return true;
    }).toList();
  }

  void _showTransactionDetails(BuildContext context, TransactionRecord tx) {
    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: LuminaColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: tx.iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: tx.iconColor.withValues(alpha: 0.35)),
                        ),
                        child: Icon(tx.icon, color: tx.iconColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: LuminaColors.textPrimary,
                            ),
                          ),
                          Text(
                            tx.category,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: LuminaColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: LuminaColors.acidLime.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'SETTLED L2',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: LuminaColors.acidLime,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Big Amount Callout
              Center(
                child: Column(
                  children: [
                    Text(
                      '${tx.isPositive ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: tx.isPositive ? LuminaColors.acidLime : LuminaColors.textPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Arbitrum One Cryptographic Finality',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: LuminaColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ledger Receipt Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LuminaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Execution Time', tx.time),
                    const Divider(color: LuminaColors.surfaceBorderSubtle, height: 20),
                    _buildReceiptRow('Reference ID', tx.referenceId),
                    const Divider(color: LuminaColors.surfaceBorderSubtle, height: 20),
                    _buildReceiptRow(
                      'Blockchain Rail',
                      'Arbitrum One (L2)',
                      valueColor: LuminaColors.electricCobalt,
                    ),
                    const Divider(color: LuminaColors.surfaceBorderSubtle, height: 20),
                    _buildReceiptRow(
                      'Network Gas Fee',
                      '\$0.00 (Zero Network Fee)',
                      valueColor: LuminaColors.acidLime,
                    ),
                    if (tx.blockchainTxHash != null) ...[
                      const Divider(color: LuminaColors.surfaceBorderSubtle, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TxHash',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: LuminaColors.textMuted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: tx.blockchainTxHash!));
                              HapticFeedback.lightImpact();
                              LuminaSnackBar.show(
                                context,
                                type: LuminaSnackBarType.success,
                                title: 'Copied to Clipboard',
                                message: 'Transaction Hash ${tx.blockchainTxHash!} copied.',
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  '${tx.blockchainTxHash!.substring(0, 10)}...${tx.blockchainTxHash!.substring(tx.blockchainTxHash!.length - 6)}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.electricCobalt,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy_rounded, size: 14, color: LuminaColors.electricCobalt),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuminaColors.acidLime,
                    foregroundColor: LuminaColors.midnightBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'CLOSE RECEIPT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
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

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(fontSize: 12, color: LuminaColors.textMuted),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? LuminaColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountState = context.watch<AccountBloc>().state;
    final allTransactions = widget.initialTransactions ?? accountState.transactions;
    final filtered = _filterTransactions(allTransactions);

    // Compute metrics
    final totalInflow = allTransactions.where((t) => t.isPositive).fold(0.0, (acc, t) => acc + t.amount);
    final totalOutflow = allTransactions.where((t) => !t.isPositive).fold(0.0, (acc, t) => acc + t.amount);

    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LuminaColors.textPrimary, size: 18),
          onPressed: () {
            SoundService.instance.play(LuminaSound.cardClick);
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'ACTIVITY LEDGER',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: LuminaColors.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LuminaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: LuminaColors.acidLime,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'SYNCED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: LuminaColors.acidLime,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: LuminaAtmosphericBackground(
        showGrid: true,
        child: SafeArea(
          child: Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      style: GoogleFonts.spaceGrotesk(color: LuminaColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: LuminaColors.surfaceElevated,
                        hintText: 'Search by recipient, token, or TxHash...',
                        hintStyle: GoogleFonts.spaceGrotesk(color: LuminaColors.textMuted, fontSize: 12),
                        prefixIcon: const Icon(Icons.search_rounded, color: LuminaColors.textMuted, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: LuminaColors.textMuted, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: LuminaColors.surfaceBorderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: LuminaColors.surfaceBorderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: LuminaColors.electricCobalt),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterPill('ALL', ActivityFilter.all),
                          const SizedBox(width: 8),
                          _buildFilterPill('INFLOW (+)', ActivityFilter.inflow),
                          const SizedBox(width: 8),
                          _buildFilterPill('OUTFLOW (-)', ActivityFilter.outflow),
                          const SizedBox(width: 8),
                          _buildFilterPill('YIELDS', ActivityFilter.yields),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Volume Summary Mini-Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LuminaColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL INFLOW',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: LuminaColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '+\$${totalInflow.toStringAsFixed(2)}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: LuminaColors.acidLime,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: LuminaColors.surfaceBorderSubtle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL OUTFLOW',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: LuminaColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '-\$${totalOutflow.toStringAsFixed(2)}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: LuminaColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: LuminaColors.surfaceBorderSubtle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NETWORK FEE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: LuminaColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$0.00 (L2)',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: LuminaColors.electricCobalt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Activity Stream List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return _buildTransactionCard(tx, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, ActivityFilter filter) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _activeFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? LuminaColors.acidLime : LuminaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? LuminaColors.acidLime : LuminaColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isSelected ? LuminaColors.midnightBlack : LuminaColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionRecord tx, int index) {
    return GestureDetector(
      onTap: () => _showTransactionDetails(context, tx),
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
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tx.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: tx.iconColor.withValues(alpha: 0.3)),
              ),
              child: Icon(tx.icon, color: tx.iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: LuminaColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${tx.category} • ${tx.time}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: LuminaColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount & Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${tx.isPositive ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: tx.isPositive ? LuminaColors.acidLime : LuminaColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: LuminaColors.acidLime,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'L2 CLEARED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: LuminaColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: LuminaColors.surfaceBorder),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: LuminaColors.textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'NO ACTIVITIES FOUND',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: LuminaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search query or filter pills.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: LuminaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
