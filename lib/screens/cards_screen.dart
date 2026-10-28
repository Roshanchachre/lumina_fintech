import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../core/security/biometric_service.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/interactive_card.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int _selectedCardIndex = 0;
  bool _isCardRevealed = false;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0.00", "en_US");

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final cards = state.cards;
        final currentCard = cards[_selectedCardIndex];

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
                                'CARDS & VAULT',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: LuminaColors.electricCobalt,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Manage Physical & Virtual',
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
                        const SizedBox(width: 12),
                        // Add new card button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: LuminaColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add_rounded, color: LuminaColors.neonGreen),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Custom Titanium Card Issuance is active.'),
                                  backgroundColor: LuminaColors.surfaceElevated,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),

                // Card Carousel
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: cards.length,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        SoundService.instance.play(LuminaSound.cardClick);
                        setState(() {
                          _selectedCardIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        final displayedPan = _isCardRevealed
                            ? '4892  8810  2931  0042'
                            : card.maskedPan;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Center(
                            child: InteractiveCard(
                              balance: card.balance,
                              cardHolder: card.cardHolder,
                              cardNumber: displayedPan,
                              expiry: card.expiry,
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
                ),

                // Carousel Dots
                SliverToBoxAdapter(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(cards.length, (index) {
                        final isActive = _selectedCardIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? LuminaColors.acidLime : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // Card Details & Security Controls
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Tier & Balance Summary
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: LuminaColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: LuminaColors.surfaceBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentCard.tierName.toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: currentCard.accentColor,
                                        letterSpacing: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        state.isDiscreteMode
                                            ? '\$••••••'
                                            : '\$${currencyFormatter.format(currentCard.balance)}',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: LuminaColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: currentCard.isFrozen
                                      ? LuminaColors.crimsonAlert.withValues(alpha: 0.15)
                                      : LuminaColors.acidLime.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: currentCard.isFrozen
                                        ? LuminaColors.crimsonAlert
                                        : LuminaColors.acidLime,
                                  ),
                                ),
                                child: Text(
                                  currentCard.isFrozen ? 'FROZEN' : 'ACTIVE',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: currentCard.isFrozen
                                        ? LuminaColors.crimsonAlert
                                        : LuminaColors.acidLime,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Biometric Unmask Credentials Button
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            if (_isCardRevealed) {
                              setState(() {
                                _isCardRevealed = false;
                              });
                              return;
                            }

                            final bio = BiometricService();
                            final authenticated = await bio.authenticate(
                              localizedReason: 'Authenticate to reveal card credentials and CVV',
                            );

                            if (authenticated && mounted) {
                              HapticFeedback.lightImpact();
                              SoundService.instance.play(LuminaSound.biometricUnlock);
                              setState(() {
                                _isCardRevealed = true;
                              });
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Card credentials revealed • Auto-masking in 15s'),
                                  backgroundColor: LuminaColors.surfaceElevated,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              Future.delayed(const Duration(seconds: 15), () {
                                if (mounted && _isCardRevealed) {
                                  setState(() {
                                    _isCardRevealed = false;
                                  });
                                }
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: LuminaColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _isCardRevealed
                                    ? LuminaColors.acidLime.withValues(alpha: 0.6)
                                    : LuminaColors.surfaceBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCardRevealed ? Icons.visibility_off_rounded : Icons.fingerprint_rounded,
                                  color: _isCardRevealed ? LuminaColors.acidLime : LuminaColors.electricCobalt,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _isCardRevealed ? 'HIDE CARD CREDENTIALS' : 'REVEAL FULL PAN & CVV (BIOMETRIC)',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                      color: _isCardRevealed ? LuminaColors.acidLime : LuminaColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'SECURITY & PERMISSIONS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: LuminaColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Switch 1: Freeze Card
                        _buildControlTile(
                          icon: Icons.ac_unit_rounded,
                          title: 'Freeze Card',
                          subtitle: 'Instantly decline all point-of-sale and online transactions',
                          value: currentCard.isFrozen,
                          accentColor: LuminaColors.crimsonAlert,
                          onChanged: (val) async {
                            HapticFeedback.mediumImpact();
                            if (state.isBiometricsEnabled) {
                              final bio = BiometricService();
                              final authed = await bio.authenticate(
                                localizedReason: val
                                    ? 'Authenticate to freeze Titanium Card'
                                    : 'Authenticate to unfreeze Titanium Card',
                              );
                              if (!authed) {
                                SoundService.instance.play(LuminaSound.errorAlert);
                                return;
                              }
                            }
                            SoundService.instance.play(LuminaSound.vaultLock);
                            if (!context.mounted) return;
                            context.read<AccountBloc>().add(ToggleCardFreeze(currentCard.id));
                          },
                        ),

                        // Switch 2: Online Transactions
                        _buildControlTile(
                          icon: Icons.language_rounded,
                          title: 'Online Payments',
                          subtitle: 'Allow e-commerce transactions and subscriptions',
                          value: currentCard.isOnlineEnabled,
                          accentColor: LuminaColors.electricCobalt,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            context.read<AccountBloc>().add(ToggleCardOnline(currentCard.id));
                          },
                        ),

                        // Switch 3: International Transactions
                        _buildControlTile(
                          icon: Icons.flight_takeoff_rounded,
                          title: 'International Usage',
                          subtitle: 'Zero cross-border exchange fee on Arbitrum L2',
                          value: currentCard.isInternationalEnabled,
                          accentColor: LuminaColors.acidLime,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            context.read<AccountBloc>().add(ToggleCardInternational(currentCard.id));
                          },
                        ),

                        const SizedBox(height: 20),

                        // Physical Card Dispatch Pill
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: LuminaColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: LuminaColors.electricCobalt.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_shipping_rounded, color: LuminaColors.electricCobalt, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Physical Metal Card Dispatched',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: LuminaColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'DHL Express Tracking #98214-US',
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
                              const Icon(Icons.chevron_right_rounded, color: LuminaColors.textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlTile({
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
}
