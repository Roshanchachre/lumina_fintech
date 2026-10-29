import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../theme/lumina_theme.dart';
import '../widgets/lumina_snackbar.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0.00", "en_US");

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final allocations = state.allocations;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
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
                                'WEALTH ALLOCATION',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: LuminaColors.electricCobalt,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Global Multi-Asset Vault',
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
                        const SizedBox(width: 8),
                        // Discrete Mode Toggle Button
                        IconButton(
                          icon: Icon(
                            state.isDiscreteMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: state.isDiscreteMode ? LuminaColors.acidLime : LuminaColors.textSecondary,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            context.read<AccountBloc>().add(ToggleDiscreteMode());
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),

                // Total Portfolio Value Hero
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D1424),
                            Color(0xFF080C16),
                            LuminaColors.midnightBlack,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: LuminaColors.surfaceBorder),
                        boxShadow: [
                          BoxShadow(
                            color: LuminaColors.electricCobalt.withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NET ASSET VALUE (NAV)',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: LuminaColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              state.isDiscreteMode
                                  ? '\$••••••••••'
                                  : '\$${currencyFormatter.format(state.balance)}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: LuminaColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: LuminaColors.acidLime.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.arrow_upward_rounded, color: LuminaColors.acidLime, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${state.percentChange}%',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: LuminaColors.acidLime,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  '30-Day Net Yield Growth',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: LuminaColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Multi-color segmented asset allocation bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 10,
                              child: Row(
                                children: allocations.map((asset) {
                                  return Expanded(
                                    flex: asset.percentage.round(),
                                    child: Container(color: asset.color),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Legend Pills
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: allocations.map((asset) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: asset.color),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${asset.symbol} ${asset.percentage.toInt()}%',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      color: LuminaColors.textMuted,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ),

                // L2 Staking High-Yield Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Container(
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
                              color: LuminaColors.neonGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.flash_on_rounded, color: LuminaColors.neonGreen),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arbitrum L2 Yield Active',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Earning 4.8% APY compounded hourly',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: LuminaColors.neonGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              LuminaSnackBar.show(
                                context,
                                type: LuminaSnackBarType.success,
                                title: 'Autonomous Yield Engine',
                                message: 'Hourly auto-rebalancing is active on Arbitrum One L2.',
                              );
                            },
                            child: Text(
                              'MANAGE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: LuminaColors.acidLime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ),

                // Asset Breakdown List
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Text(
                      'ASSET HOLDINGS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: LuminaColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final asset = allocations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: LuminaColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: asset.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: asset.color.withValues(alpha: 0.3)),
                                ),
                                child: Icon(asset.icon, color: asset.color, size: 22),
                              ),
                              const SizedBox(width: 14),
                                Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asset.assetName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: LuminaColors.textPrimary,
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${asset.symbol} • ${asset.apy}% APY',
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
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      state.isDiscreteMode
                                          ? '\$••••••'
                                          : '\$${currencyFormatter.format(asset.valuationUsd)}',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: LuminaColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${asset.percentage.toStringAsFixed(1)}%',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: asset.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: 350 + (index * 60))).slideX(begin: 0.05, end: 0);
                      },
                      childCount: allocations.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
