import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lumina_theme.dart';

class SlideToSendButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  final String label;

  const SlideToSendButton({
    super.key,
    required this.onConfirmed,
    this.label = 'SLIDE TO INSTANT TRANSFER',
  });

  @override
  State<SlideToSendButton> createState() => _SlideToSendButtonState();
}

class _SlideToSendButtonState extends State<SlideToSendButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isCompleted = false;

  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (_isCompleted) return;

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });

    // Provide light tick at 50%
    if (_dragPosition > maxDrag * 0.5 && _dragPosition - details.delta.dx <= maxDrag * 0.5) {
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd(DragEndDetails details, double maxDrag) {
    if (_isCompleted) return;

    if (_dragPosition >= maxDrag * 0.88) {
      // Confirmed!
      setState(() {
        _dragPosition = maxDrag;
        _isCompleted = true;
      });
      HapticFeedback.heavyImpact();
      widget.onConfirmed();
    } else {
      // Elastic snap-back
      _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
        CurvedAnimation(
          parent: _resetController,
          curve: Curves.easeOutBack,
        ),
      );

      _resetController.reset();
      _resetController.forward();
      _resetController.addListener(() {
        setState(() {
          _dragPosition = _resetAnimation.value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const height = 58.0;
    const thumbWidth = 50.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = totalWidth - thumbWidth - 8.0;

        final progress = maxDrag > 0 ? (_dragPosition / maxDrag).clamp(0.0, 1.0) : 0.0;

        return Container(
          height: height,
          width: totalWidth,
          decoration: BoxDecoration(
            color: LuminaColors.surfaceElevated,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color.lerp(
                LuminaColors.surfaceBorder,
                LuminaColors.neonGreen.withValues(alpha: 0.6),
                progress,
              )!,
              width: 1.2,
            ),
            boxShadow: [
              if (progress > 0.1)
                BoxShadow(
                  color: LuminaColors.neonGreen.withValues(alpha: 0.2 * progress),
                  blurRadius: 20 * progress,
                  spreadRadius: 2 * progress,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Liquid Gradient Fill Following Thumb
              Container(
                width: _dragPosition + thumbWidth + 4,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      LuminaColors.electricCobalt.withValues(alpha: 0.3),
                      LuminaColors.acidLime.withValues(alpha: 0.35 * progress),
                    ],
                  ),
                ),
              ),

              // Shimmering Label Text in Center
              Center(
                child: Opacity(
                  opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: LuminaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: LuminaColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Draggable Floating Thumb
              Positioned(
                left: 4.0 + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxDrag),
                  onHorizontalDragEnd: (d) => _onDragEnd(d, maxDrag),
                  child: Container(
                    width: thumbWidth,
                    height: height - 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LuminaColors.cobaltAcid,
                      boxShadow: [
                        BoxShadow(
                          color: LuminaColors.acidLime.withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey('done'),
                                color: Colors.black,
                                size: 26,
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                key: ValueKey('arrow'),
                                color: Colors.black,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
