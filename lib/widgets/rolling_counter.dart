import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/lumina_theme.dart';

class RollingBalanceHeader extends StatefulWidget {
  final Function(String period, double newBalance, double newChange) onPeriodChanged;
  final bool isDiscrete;
  final VoidCallback? onToggleDiscrete;

  const RollingBalanceHeader({
    super.key,
    required this.onPeriodChanged,
    this.isDiscrete = false,
    this.onToggleDiscrete,
  });

  @override
  State<RollingBalanceHeader> createState() => _RollingBalanceHeaderState();
}

class _RollingBalanceHeaderState extends State<RollingBalanceHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _balanceAnimation;

  double _currentBalance = 128450.85;
  double _targetBalance = 128450.85;
  double _currentChange = 3820.40;
  double _percentChange = 3.06;
  String _selectedPeriod = '1M';

  final Map<String, Map<String, double>> _periodData = {
    '1D': {'balance': 124630.45, 'change': 680.15, 'pct': 0.55},
    '1W': {'balance': 121890.00, 'change': 2740.85, 'pct': 2.30},
    '1M': {'balance': 128450.85, 'change': 3820.40, 'pct': 3.06},
    '1Y': {'balance': 154210.60, 'change': 29580.00, 'pct': 23.73},
    'ALL': {'balance': 186900.20, 'change': 62270.50, 'pct': 49.96},
  };

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _balanceAnimation = Tween<double>(
      begin: _currentBalance * 0.9,
      end: _targetBalance,
    ).animate(
      CurvedAnimation(
        parent: _counterController,
        curve: Curves.easeOutCubic,
      ),
    );

    _counterController.forward();
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  void _selectPeriod(String period) {
    if (_selectedPeriod == period) return;

    HapticFeedback.selectionClick();
    final data = _periodData[period]!;
    final newBalance = data['balance']!;
    final newChange = data['change']!;
    final newPct = data['pct']!;

    setState(() {
      _selectedPeriod = period;
      _currentBalance = _balanceAnimation.value;
      _targetBalance = newBalance;
      _currentChange = newChange;
      _percentChange = newPct;

      _balanceAnimation = Tween<double>(
        begin: _currentBalance,
        end: _targetBalance,
      ).animate(
        CurvedAnimation(
          parent: _counterController,
          curve: Curves.easeOutExpo,
        ),
      );
    });

    _counterController.reset();
    _counterController.forward();

    widget.onPeriodChanged(period, newBalance, newChange);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0.00", "en_US");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'TOTAL LIQUID PORTFOLIO',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: LuminaColors.textMuted,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LuminaColors.neonGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: LuminaColors.neonGreen.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
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
                  const SizedBox(width: 6),
                  Text(
                    'LIVE FEED',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: LuminaColors.neonGreen,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Rolling Numbers Balance (with discrete mode tap)
        GestureDetector(
          onTap: () {
            if (widget.onToggleDiscrete != null) {
              HapticFeedback.selectionClick();
              widget.onToggleDiscrete!();
            }
          },
          child: AnimatedBuilder(
            animation: _balanceAnimation,
            builder: (context, child) {
              if (widget.isDiscrete) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        '\$••••••••••',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: LuminaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.visibility_off_rounded, color: LuminaColors.electricCobalt, size: 20),
                    ],
                  ),
                );
              }

              final formatted = currencyFormatter.format(_balanceAnimation.value);
              final parts = formatted.split('.');
              final wholePart = parts[0];
              final decimalPart = parts.length > 1 ? parts[1] : '00';

              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: LuminaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      wholePart,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                        color: LuminaColors.textPrimary,
                      ),
                    ),
                    Text(
                      '.$decimalPart',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: LuminaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Gain / Loss Tag + Time Period Pills (Responsive LayoutBuilder)
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 400;

            final profitPill = Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: LuminaColors.acidLime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: LuminaColors.acidLime.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: LuminaColors.acidLime,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '+ \$${NumberFormat("#,##0.00").format(_currentChange)} (+${_percentChange.toStringAsFixed(2)}%)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: LuminaColors.acidLime,
                      ),
                    ),
                  ),
                ],
              ),
            );

            final timeSelector = Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LuminaColors.surfaceBorderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['1D', '1W', '1M', '1Y', 'ALL'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return GestureDetector(
                    onTap: () => _selectPeriod(period),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutQuad,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: isSelected
                            ? Border.all(
                                color: LuminaColors.electricCobalt.withValues(alpha: 0.4),
                              )
                            : null,
                      ),
                      child: Text(
                        period,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? LuminaColors.textPrimary
                              : LuminaColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profitPill,
                  const SizedBox(height: 10),
                  timeSelector,
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: profitPill),
                const SizedBox(width: 8),
                timeSelector,
              ],
            );
          },
        ),
      ],
    );
  }
}
