import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../core/security/biometric_service.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/interactive_card.dart';
import '../widgets/lumina_snackbar.dart';
import 'card_detail_screen.dart';
import 'issue_card_screen.dart';

enum CardFilter { all, physical, virtual }

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int _selectedCardIndex = 0;
  bool _isCardRevealed = false;
  CardFilter _selectedFilter = CardFilter.all;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToIssueCard() {
    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const IssueCardScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  void _navigateToCardDetail(String cardId) {
    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => CardDetailScreen(cardId: cardId),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  List<LuminaCardModel> _getFilteredCards(List<LuminaCardModel> allCards) {
    switch (_selectedFilter) {
      case CardFilter.physical:
        return allCards.where((c) => c.isPhysical).toList();
      case CardFilter.virtual:
        return allCards.where((c) => c.isVirtual).toList();
      case CardFilter.all:
        return allCards;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0.00", "en_US");

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final allCards = state.cards;
        final filteredCards = _getFilteredCards(allCards);
        final safeIndex = _selectedCardIndex.clamp(0, filteredCards.isEmpty ? 0 : filteredCards.length - 1);
        final currentCard = filteredCards.isNotEmpty ? filteredCards[safeIndex] : null;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header with Issue Card Button
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
                                'Physical & Virtual Suite',
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
                        // Dedicated "Issue New Card" Button
                        GestureDetector(
                          onTap: _navigateToIssueCard,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LuminaColors.cobaltAcid,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: LuminaColors.acidLime.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded, color: LuminaColors.midnightBlack, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  'ISSUE CARD',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: LuminaColors.midnightBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),

                // Category Filter Pills (All / Physical / Virtual)
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        _buildFilterPill(
                          CardFilter.all,
                          'ALL (${allCards.length})',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          CardFilter.physical,
                          'PHYSICAL (${allCards.where((c) => c.isPhysical).length})',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          CardFilter.virtual,
                          'VIRTUAL (${allCards.where((c) => c.isVirtual).length})',
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Card Carousel or Empty State
                if (filteredCards.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: LuminaColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.credit_card_off_rounded, size: 48, color: LuminaColors.textMuted),
                            const SizedBox(height: 16),
                            Text(
                              'NO CARDS IN THIS CATEGORY',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: LuminaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Issue a physical metal card or generate a virtual card instantly for Apple Pay.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LuminaColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LuminaColors.acidLime,
                                foregroundColor: LuminaColors.midnightBlack,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _navigateToIssueCard,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text('ISSUE CARD NOW', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  // 3D Card Carousel
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 260,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: filteredCards.length,
                        onPageChanged: (index) {
                          HapticFeedback.selectionClick();
                          SoundService.instance.play(LuminaSound.cardClick);
                          setState(() {
                            _selectedCardIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final card = filteredCards[index];
                          final displayedPan = _isCardRevealed
                              ? (card.fullPan ?? '4892  8810  2931  0042')
                              : card.maskedPan;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () => _navigateToCardDetail(card.id),
                              child: Center(
                                child: InteractiveCard(
                                  balance: card.balance,
                                  cardHolder: state.user.name.toUpperCase(),
                                  cardNumber: displayedPan,
                                  expiry: card.expiry,
                                  gradient: card.gradient,
                                  tierName: card.tierName,
                                  accentColor: card.accentColor,
                                  cardType: card.cardType,
                                  cardNickname: card.cardNickname,
                                  isDiscrete: state.isDiscreteMode,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
                  ),

                  // Carousel Indicator Dots
                  SliverToBoxAdapter(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(filteredCards.length, (index) {
                          final isActive = safeIndex == index;
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

                  // Card Quick Summary & Controls
                  if (currentCard != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Tier & Balance Summary with Detail Navigation
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: LuminaColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: LuminaColors.surfaceBorder),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
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
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: currentCard.isVirtual
                                                        ? LuminaColors.electricCobalt.withValues(alpha: 0.25)
                                                        : Colors.white.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    currentCard.isVirtual ? 'VIRTUAL' : 'METAL',
                                                    style: GoogleFonts.spaceGrotesk(
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: currentCard.isVirtual ? const Color(0xFF93C5FD) : LuminaColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                                            color: currentCard.isFrozen ? LuminaColors.crimsonAlert : LuminaColors.acidLime,
                                          ),
                                        ),
                                        child: Text(
                                          currentCard.isFrozen ? 'FROZEN' : 'ACTIVE',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: currentCard.isFrozen ? LuminaColors.crimsonAlert : LuminaColors.acidLime,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Direct "CARD DETAILS & SETTINGS" Link
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: LuminaColors.textPrimary,
                                        side: const BorderSide(color: LuminaColors.surfaceBorderSubtle),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () => _navigateToCardDetail(currentCard.id),
                                      icon: const Icon(Icons.tune_rounded, size: 16, color: LuminaColors.acidLime),
                                      label: Text(
                                        'CARD DETAILS & SETTINGS',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
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
                                  setState(() => _isCardRevealed = false);
                                  return;
                                }

                                final bio = BiometricService();
                                final authenticated = await bio.authenticate(
                                  localizedReason: 'Authenticate to reveal card credentials and CVV',
                                );

                                if (authenticated && mounted) {
                                  HapticFeedback.lightImpact();
                                  SoundService.instance.play(LuminaSound.biometricUnlock);
                                  setState(() => _isCardRevealed = true);
                                  if (!context.mounted) return;
                                  LuminaSnackBar.show(
                                    context,
                                    type: LuminaSnackBarType.warning,
                                    title: 'Credentials Unmasked',
                                    message: 'Card number & CVV revealed. Automatic privacy protection in 15s.',
                                  );
                                  Future.delayed(const Duration(seconds: 15), () {
                                    if (mounted && _isCardRevealed) {
                                      setState(() => _isCardRevealed = false);
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
                                    color: _isCardRevealed ? LuminaColors.acidLime.withValues(alpha: 0.6) : LuminaColors.surfaceBorder,
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
                                    localizedReason: val ? 'Authenticate to freeze card' : 'Authenticate to unfreeze card',
                                  );
                                  if (!authed) return;
                                }
                                SoundService.instance.play(LuminaSound.vaultLock);
                                if (!context.mounted) return;
                                context.read<AccountBloc>().add(ToggleCardFreeze(currentCard.id));
                              },
                            ),

                            // Switch 2: Online Payments
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

                            const SizedBox(height: 16),

                            // Dynamic Physical Dispatch or Virtual Protocol Status
                            if (currentCard.isPhysical)
                              GestureDetector(
                                onTap: () => _navigateToCardDetail(currentCard.id),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: LuminaColors.surfaceElevated,
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
                                              'Physical Metal Card In Transit',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: LuminaColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              currentCard.trackingNumber ?? 'DHL Express Tracking #98214-US',
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
                              )
                            else
                              GestureDetector(
                                onTap: () => _navigateToCardDetail(currentCard.id),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: LuminaColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: LuminaColors.acidLime.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.apple_rounded, color: LuminaColors.acidLime, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Apple Pay & Web Ready',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: LuminaColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Instant virtual dynamic tokens active',
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
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(CardFilter filter, String label) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        SoundService.instance.play(LuminaSound.cardClick);
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilter = filter;
          _selectedCardIndex = 0;
        });
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.12) : LuminaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? LuminaColors.acidLime : LuminaColors.surfaceBorderSubtle,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? LuminaColors.acidLime : LuminaColors.textMuted,
          ),
        ),
      ),
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
                    fontSize: 14.5,
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
