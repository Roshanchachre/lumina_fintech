import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/account_bloc.dart';
import '../core/security/biometric_service.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/interactive_card.dart';
import '../widgets/rolling_counter.dart';
import '../widgets/glow_chart.dart';
import '../widgets/slide_to_send.dart';
import '../widgets/transaction_item.dart';
import '../modals/deposit_modal.dart';
import '../modals/invest_modal.dart';
import '../modals/more_modal.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openSendModal(BuildContext context) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _QuickSendModal(
        onTransferConfirmed: (amount, recipient) {
          context.read<AccountBloc>().add(
                ExecuteWireTransfer(
                  recipient: recipient,
                  amount: amount,
                ),
              );
        },
      ),
    );
  }

  void _openDepositModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DepositModal(),
    );
  }

  void _openInvestModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const InvestModal(),
    );
  }

  void _openMoreModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const MoreModal(),
    );
  }

  void _showNotifications(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: LuminaColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'VAULT NOTIFICATIONS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: LuminaColors.electricCobalt,
                            letterSpacing: 1.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'MARK AS READ',
                        style: GoogleFonts.spaceGrotesk(fontSize: 11, color: LuminaColors.acidLime, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _notificationTile(
                    icon: Icons.flash_on_rounded,
                    color: LuminaColors.acidLime,
                    title: 'Arbitrum L2 Yield Compounded',
                    time: '12m ago',
                    description: '+\$348.60 credited to wstETH Staking Vault.',
                  ),
                  _notificationTile(
                    icon: Icons.shield_rounded,
                    color: LuminaColors.electricCobalt,
                    title: 'Biometric Shield Active',
                    time: '1h ago',
                    description: 'Enclave verification passed from Apple M4 Pro.',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _notificationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LuminaColors.surfaceBorderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: LuminaColors.textPrimary)),
                    Text(time, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: LuminaColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LuminaColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllTransactions(BuildContext context, List<TransactionRecord> transactions) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: LuminaColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'COMPLETE ACTIVITY STREAM',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: LuminaColors.acidLime, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Immutable Ledger on Arbitrum One L2',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: LuminaColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return TransactionItemTile(
                          transaction: Transaction(
                            title: tx.title,
                            category: tx.category,
                            time: tx.time,
                            amount: tx.amount,
                            isPositive: tx.isPositive,
                            icon: tx.icon,
                            iconColor: tx.iconColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: LuminaColors.background,
          body: Stack(
            children: [
              // Ambient Gradient Glow in background
              Positioned(
                top: -120,
                left: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        LuminaColors.neonGreen.withValues(alpha: 0.09),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        LuminaColors.electricCobalt.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main Scrollable Content
              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top App Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: _buildTopBar(context, state),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                    ),

                    // Rolling Counter Balance Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: RollingBalanceHeader(
                          isDiscrete: state.isDiscreteMode,
                          onToggleDiscrete: () {
                            context.read<AccountBloc>().add(ToggleDiscreteMode());
                          },
                          onPeriodChanged: (period, balance, change) {
                            context.read<AccountBloc>().add(ChangeTimeframe(period));
                          },
                        ),
                      ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                    ),

                    // Glowing Interactive Spline Chart
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: GlowChart(period: state.selectedPeriod),
                      ).animate().fadeIn(delay: 250.ms, duration: 600.ms),
                    ),

                    // 3D Tilt Card Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: [
                            InteractiveCard(
                              balance: state.cards.first.balance,
                              cardNumber: state.cards.first.maskedPan,
                              isDiscrete: state.isDiscreteMode,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap card to flip • Tilt phone or drag to inspect 3D sheen',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: LuminaColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 350.ms, duration: 700.ms).scale(begin: const Offset(0.95, 0.95)),
                    ),

                    // Quick Action Deck
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: _buildActionDeck(context),
                      ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
                    ),

                    // Recent Transactions Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RECENT ACTIVITY',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: LuminaColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showAllTransactions(context, state.transactions),
                              child: Text(
                                'VIEW ALL',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: LuminaColors.neonGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Transactions List
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = state.transactions[index];
                            return TransactionItemTile(
                              transaction: Transaction(
                                title: tx.title,
                                category: tx.category,
                                time: tx.time,
                                amount: tx.amount,
                                isPositive: tx.isPositive,
                                icon: tx.icon,
                                iconColor: tx.iconColor,
                              ),
                            ).animate().fadeIn(
                                  delay: Duration(milliseconds: 500 + (index * 80)),
                                  duration: 400.ms,
                                ).slideX(begin: 0.1, end: 0);
                          },
                          childCount: state.transactions.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, AccountState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + Greeting (Responsive with Expanded)
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LuminaColors.cobaltAcid,
                ),
                child: const CircleAvatar(
                  radius: 19,
                  backgroundColor: Color(0xFF0D1424),
                  child: Icon(
                    Icons.person_rounded,
                    color: LuminaColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: LuminaColors.textMuted,
                      ),
                    ),
                    Text(
                      state.user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
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
        const SizedBox(width: 12),
        // Bell Notification with Neon Dot
        GestureDetector(
          onTap: () => _showNotifications(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LuminaColors.surfaceBorderSubtle),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: LuminaColors.textPrimary,
                  size: 22,
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: LuminaColors.neonGreen,
                      boxShadow: [
                        BoxShadow(
                          color: LuminaColors.neonGreen,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionDeck(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _actionButton(
            label: 'Transfer',
            icon: Icons.north_east_rounded,
            accentColor: LuminaColors.acidLime,
            onTap: () => _openSendModal(context),
          ),
        ),
        Expanded(
          child: _actionButton(
            label: 'Deposit',
            icon: Icons.south_west_rounded,
            accentColor: LuminaColors.electricCobalt,
            onTap: () => _openDepositModal(context),
          ),
        ),
        Expanded(
          child: _actionButton(
            label: 'Invest',
            icon: Icons.insights_rounded,
            accentColor: LuminaColors.neonPurple,
            onTap: () => _openInvestModal(context),
          ),
        ),
        Expanded(
          child: _actionButton(
            label: 'More',
            icon: Icons.grid_view_rounded,
            accentColor: LuminaColors.textPrimary,
            onTap: () => _openMoreModal(context),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: LuminaColors.surfaceBorderSubtle,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: LuminaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSendModal extends StatefulWidget {
  final Function(double amount, String recipient)? onTransferConfirmed;

  const _QuickSendModal({this.onTransferConfirmed});

  @override
  State<_QuickSendModal> createState() => _QuickSendModalState();
}

class _QuickSendModalState extends State<_QuickSendModal> {
  final double _sendAmount = 1250.00;
  final String _recipient = 'Sarah Connor (Titanium Card)';
  bool _isSent = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: LuminaColors.surfaceBorder),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'INSTANT WIRE TRANSFER',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuminaColors.electricCobalt,
              ),
            ),
            const SizedBox(height: 12),

            // Recipient Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: LuminaColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LuminaColors.surfaceBorderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: LuminaColors.electricCobalt,
                    child: Text('SC', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'To: $_recipient',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: LuminaColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Amount Display
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '\$${_sendAmount.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: LuminaColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Zero gas fee • Instant settlement on Arbitrum L2',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: LuminaColors.textMuted,
              ),
            ),

            const SizedBox(height: 32),

            // The Interactive SlideToSend Widget
            if (!_isSent)
              SlideToSendButton(
                onConfirmed: () async {
                  final isBioEnabled = context.read<AccountBloc>().state.isBiometricsEnabled;
                  if (isBioEnabled) {
                    final bio = BiometricService();
                    final authed = await bio.authenticate(
                      localizedReason:
                          'Authorize instant wire transfer of \$${_sendAmount.toStringAsFixed(2)} to $_recipient',
                    );
                    if (!authed) {
                      SoundService.instance.play(LuminaSound.errorAlert);
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Biometric verification failed. Wire transfer cancelled.'),
                            backgroundColor: LuminaColors.surfaceElevated,
                          ),
                        );
                      }
                      return;
                    }
                  }

                  SoundService.instance.play(LuminaSound.transferSuccess);
                  if (!mounted) return;
                  setState(() {
                    _isSent = true;
                  });
                  widget.onTransferConfirmed?.call(_sendAmount, _recipient);
                  Future.delayed(const Duration(milliseconds: 1400), () {
                    if (!mounted || !context.mounted) return;
                    Navigator.of(context).pop();
                  });
                },
              )
            else
              Container(
                height: 58,
                decoration: BoxDecoration(
                  color: LuminaColors.acidLime.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: LuminaColors.acidLime),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: LuminaColors.acidLime),
                      const SizedBox(width: 8),
                      Text(
                        'TRANSFER SUCCESSFUL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.acidLime,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),

            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
  }
}
