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
import '../widgets/interactive_card.dart';
import 'card_config_screen.dart';

class IssueCardTierInfo {
  final String id;
  final String name;
  final String materialName;
  final LinearGradient gradient;
  final Color accentColor;
  final double defaultLimit;
  final String description;

  const IssueCardTierInfo({
    required this.id,
    required this.name,
    required this.materialName,
    required this.gradient,
    required this.accentColor,
    required this.defaultLimit,
    required this.description,
  });
}

class IssueCardScreen extends StatefulWidget {
  const IssueCardScreen({super.key});

  @override
  State<IssueCardScreen> createState() => _IssueCardScreenState();
}

class _IssueCardScreenState extends State<IssueCardScreen> {
  CardType _selectedCardType = CardType.virtual;
  int _selectedTierIndex = 0;

  static const List<IssueCardTierInfo> _tiers = [
    IssueCardTierInfo(
      id: 'titanium',
      name: 'Titanium Executive',
      materialName: 'Aerospace Brushed Titanium',
      gradient: LuminaColors.cardGradientTitanium,
      accentColor: LuminaColors.electricCobalt,
      defaultLimit: 25000.0,
      description: 'Ultra-durable titanium alloy with laser-cut chamfered edges and zero foreign exchange fees.',
    ),
    IssueCardTierInfo(
      id: 'cobalt',
      name: 'Cobalt Sovereign',
      materialName: 'Ionized Royal Cobalt',
      gradient: LuminaColors.cardGradientCobalt,
      accentColor: LuminaColors.electricCobalt,
      defaultLimit: 50000.0,
      description: 'Luminous deep royal cobalt finish with 24/7 dedicated private banking concierge and lounge pass.',
    ),
    IssueCardTierInfo(
      id: 'acid',
      name: 'Acid Lime Quantum',
      materialName: 'Cyber Luminous Neon',
      gradient: LuminaColors.cardGradientAcid,
      accentColor: LuminaColors.acidLime,
      defaultLimit: 10000.0,
      description: 'High-contrast luminescent edge design engineered for instant Arbitrum L2 yield settlements.',
    ),
    IssueCardTierInfo(
      id: 'obsidian',
      name: 'Obsidian Midnight',
      materialName: 'Heavy Matte Obsidian',
      gradient: LuminaColors.cardGradientObsidian,
      accentColor: LuminaColors.neonPurple,
      defaultLimit: 100000.0,
      description: 'Dense tungsten-matrix metal card with velvet matte finish and highest liquid spending limits.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTier = _tiers[_selectedTierIndex];

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: LuminaAtmosphericBackground(
        animate: true,
        showGrid: true,
        child: SafeArea(
          child: Column(
            children: [
              // Navigation Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LuminaColors.textPrimary, size: 18),
                      onPressed: () {
                        SoundService.instance.play(LuminaSound.cardClick);
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP 1 OF 3 • CARD ISSUANCE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: LuminaColors.electricCobalt,
                            ),
                          ),
                          Text(
                            'Select Type & Material',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: LuminaColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: LuminaColors.acidLime.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'NO FEE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.acidLime,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Options Content
              Expanded(
                child: BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                    final userName = state.user.name.toUpperCase();

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Live Interactive 3D Card Preview
                          Center(
                            child: InteractiveCard(
                              balance: 50000.00,
                              cardHolder: userName,
                              cardNumber: _selectedCardType == CardType.virtual
                                  ? '4890  ••••  ••••  1024'
                                  : '4820  ••••  ••••  8492',
                              expiry: '10/31',
                              gradient: selectedTier.gradient,
                              tierName: selectedTier.name,
                              accentColor: selectedTier.accentColor,
                              cardType: _selectedCardType,
                              cardNickname: selectedTier.name,
                            ),
                          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.96, 0.96)),

                          const SizedBox(height: 8),

                          Center(
                            child: Text(
                              'Tap card to flip • Tilt phone to inspect holographic specular sheen',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: LuminaColors.textMuted,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Form Factor Segmented Toggle (Virtual vs Physical Metal)
                          Text(
                            'CARD FORM FACTOR',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: LuminaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _buildFormFactorCard(
                                  type: CardType.virtual,
                                  title: 'Virtual Card',
                                  subtitle: 'Instant generation • Apple Pay ready • Dynamic CVV',
                                  icon: Icons.bolt_rounded,
                                  accent: LuminaColors.acidLime,
                                  badge: 'INSTANT MINT',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormFactorCard(
                                  type: CardType.physical,
                                  title: 'Physical Metal',
                                  subtitle: 'Aerospace metal • NFC chip • DHL Express courier',
                                  icon: Icons.credit_card_rounded,
                                  accent: LuminaColors.electricCobalt,
                                  badge: 'DHL COURIER',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Design & Tier Selection
                          Text(
                            'SOVEREIGN FINISH & ALLOY',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: LuminaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          ...List.generate(_tiers.length, (index) {
                            final tier = _tiers[index];
                            final isSelected = _selectedTierIndex == index;

                            return GestureDetector(
                              onTap: () {
                                SoundService.instance.play(LuminaSound.cardClick);
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedTierIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: LuminaColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? tier.accentColor : LuminaColors.surfaceBorderSubtle,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: tier.accentColor.withValues(alpha: 0.2),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: tier.gradient,
                                        border: Border.all(color: tier.accentColor.withValues(alpha: 0.5)),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.diamond_outlined, color: tier.accentColor, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  tier.name,
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: LuminaColors.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                'Up to \$${(tier.defaultLimit / 1000).toInt()}k/day',
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: tier.accentColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            tier.description,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              color: LuminaColors.textMuted,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                      color: isSelected ? tier.accentColor : LuminaColors.textMuted,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Sticky Action Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: LuminaColors.surfaceElevated.withValues(alpha: 0.95),
                  border: const Border(top: BorderSide(color: LuminaColors.surfaceBorderSubtle)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LuminaColors.electricCobalt,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      SoundService.instance.play(LuminaSound.cardClick);
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 350),
                          pageBuilder: (_, __, ___) => CardConfigScreen(
                            cardType: _selectedCardType,
                            tierInfo: selectedTier,
                          ),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        ),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PROCEED TO SPECIFICATIONS',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
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

  Widget _buildFormFactorCard({
    required CardType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String badge,
  }) {
    final isSelected = _selectedCardType == type;

    return GestureDetector(
      onTap: () {
        SoundService.instance.play(LuminaSound.cardClick);
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCardType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : LuminaColors.surfaceBorderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: LuminaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: LuminaColors.textMuted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
