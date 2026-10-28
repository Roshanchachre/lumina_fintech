import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../theme/lumina_theme.dart';

class InteractiveCard extends StatefulWidget {
  final double balance;
  final String cardHolder;
  final String cardNumber;
  final String expiry;
  final bool isDiscrete;

  const InteractiveCard({
    super.key,
    this.balance = 48250.75,
    this.cardHolder = 'ROSHAN CHACHRE',
    this.cardNumber = '4820  8391  0294  8492',
    this.expiry = '09/29',
    this.isDiscrete = false,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with TickerProviderStateMixin {
  // Tilting states
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  late AnimationController _tiltResetController;
  late Animation<double> _tiltXAnimation;
  late Animation<double> _tiltYAnimation;

  // Flip 3D state
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _isFrozen = false;

  @override
  void initState() {
    super.initState();

    _tiltResetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutBack,
      ),
    );

    try {
      _sensorSubscription = accelerometerEventStream().listen((event) {
        if (!mounted || _isFlipped) return;
        setState(() {
          _tiltX = (_tiltX + (event.y * 0.0015)).clamp(-0.35, 0.35);
          _tiltY = (_tiltY - (event.x * 0.0015)).clamp(-0.35, 0.35);
        });
      }, onError: (_) {});
    } catch (_) {}
  }

  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _tiltResetController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_isFlipped) return; // Only tilt front

    setState(() {
      // Normalize offset -1.0 to 1.0
      _tiltX += details.delta.dy * 0.0012;
      _tiltY -= details.delta.dx * 0.0012;

      // Clamp max tilt angles
      _tiltX = _tiltX.clamp(-0.35, 0.35);
      _tiltY = _tiltY.clamp(-0.35, 0.35);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isFlipped) return;

    _tiltXAnimation = Tween<double>(begin: _tiltX, end: 0.0).animate(
      CurvedAnimation(
        parent: _tiltResetController,
        curve: Curves.elasticOut,
      ),
    );

    _tiltYAnimation = Tween<double>(begin: _tiltY, end: 0.0).animate(
      CurvedAnimation(
        parent: _tiltResetController,
        curve: Curves.elasticOut,
      ),
    );

    _tiltResetController.reset();
    _tiltResetController.forward();

    _tiltResetController.addListener(() {
      setState(() {
        _tiltX = _tiltXAnimation.value;
        _tiltY = _tiltYAnimation.value;
      });
    });
  }

  void _toggleFlip() {
    HapticFeedback.mediumImpact();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final maxWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : screenWidth - 32;
        final cardWidth = maxWidth.clamp(280.0, 350.0);
        final cardHeight = cardWidth / 1.618;

        return Center(
          child: GestureDetector(
            onPanUpdate: (details) => _onPanUpdate(details, Size(cardWidth, cardHeight)),
            onPanEnd: _onPanEnd,
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final flipAngle = _flipAnimation.value * math.pi;
                final isBackVisible = flipAngle > (math.pi / 2);

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0016) // Perspective
                    ..rotateX(_tiltX)
                    ..rotateY(_tiltY + flipAngle),
                  child: isBackVisible
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildBackCard(cardWidth, cardHeight),
                        )
                      : _buildFrontCard(cardWidth, cardHeight),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrontCard(double cardWidth, double cardHeight) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LuminaColors.cardGradientTitanium,
        border: Border.all(
          color: LuminaColors.surfaceBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: LuminaColors.acidLime.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: Offset(_tiltY * 50, _tiltX * 50 + 15),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 25,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient glowing background orbs
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LuminaColors.electricCobalt.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LuminaColors.acidLime.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Dynamic Specular Sheen (Moves with user pan)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(_tiltY * 260, _tiltX * 260),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LuminaColors.glassSheen,
                  ),
                ),
              ),
            ),

            // Front Card Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: cardWidth < 310 ? 16 : 22,
                vertical: cardWidth < 310 ? 14 : 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: Brand + Chip + Contactless
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: LuminaColors.acidLime.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.diamond_outlined,
                                  color: LuminaColors.acidLime,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'TITANIUM',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: LuminaColors.acidLime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.contactless_rounded,
                            color: LuminaColors.textSecondary.withValues(alpha: 0.7),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          // Hologram interlocking circles
                          SizedBox(
                            width: 32,
                            height: 20,
                            child: Stack(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: LuminaColors.acidLime.withValues(alpha: 0.7),
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: LuminaColors.electricCobalt.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Metallic EMV Chip
                  Container(
                    width: 38,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2C974), Color(0xFF9E8132)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFF7E7A9), width: 0.5),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 24,
                            height: 18,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black26,
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Number (Responsive FittedBox)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.cardNumber,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        color: LuminaColors.textPrimary,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom row: Holder + Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: LuminaColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.cardHolder,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: LuminaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EXPIRES',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: LuminaColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.expiry,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: LuminaColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(double cardWidth, double cardHeight) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LuminaColors.cardGradientTitanium,
        border: Border.all(
          color: LuminaColors.surfaceBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 25,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Magnetic Stripe
          Container(
            width: double.infinity,
            height: 38,
            color: const Color(0xFF090A0D),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Signature / CVV strip
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '842',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CVV CODE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.textMuted,
                        ),
                      ),
                      Text(
                        'Do not share',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: LuminaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: cardWidth < 310 ? 16 : 24,
              vertical: cardWidth < 310 ? 12 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFrozen ? Icons.lock : Icons.lock_open,
                        color: _isFrozen
                            ? LuminaColors.crimsonAlert
                            : LuminaColors.acidLime,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isFrozen ? 'CARD LOCKED' : 'ACTIVE & READY',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _isFrozen
                                ? LuminaColors.crimsonAlert
                                : LuminaColors.acidLime,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isFrozen = !_isFrozen;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isFrozen
                            ? LuminaColors.crimsonAlert.withValues(alpha: 0.4)
                            : LuminaColors.surfaceBorder,
                      ),
                    ),
                    child: Text(
                      _isFrozen ? 'Unlock Card' : 'Freeze Card',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: LuminaColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
