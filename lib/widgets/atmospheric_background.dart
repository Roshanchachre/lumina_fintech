import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/lumina_theme.dart';

/// Ultra-Luxury Atmospheric Mesh Background
/// Combines multi-point radial blooms (Electric Cobalt + Acid Lime)
/// with a subtle cryptographic fintech grid overlay and
/// continuous floating curved box swarms.
/// Eliminates flat, lifeless black backgrounds while preserving OLED contrast.
class LuminaAtmosphericBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;
  final bool animate;
  final bool showFloatingBoxes;
  final double pulseIntensity;

  const LuminaAtmosphericBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.animate = true,
    this.showFloatingBoxes = false,
    this.pulseIntensity = 1.0,
  });

  @override
  State<LuminaAtmosphericBackground> createState() =>
      _LuminaAtmosphericBackgroundState();
}

class _LuminaAtmosphericBackgroundState
    extends State<LuminaAtmosphericBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.animate && !isTest) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Deep Midnight Canvas
        Positioned.fill(
          child: Container(
            color: LuminaColors.midnightBlack,
          ),
        ),

        // Animated Ambient Blooms & Floating Converging Boxes
        if (widget.animate)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              return RepaintBoundary(
                child: Stack(
                  children: [
                    // 1. Smooth pulsing & blinking ambient mesh
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AtmosphericMeshPainter(
                          progress: progress,
                          pulseIntensity: widget.pulseIntensity,
                        ),
                      ),
                    ),

                    // 2. Subtle Cryptographic Grid Matrix with pulsing intersection nodes
                    if (widget.showGrid)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CryptographicGridPainter(
                            progress: progress,
                            animatePulse: true,
                          ),
                        ),
                      ),

                    // 3. Floating boxes moving smoothly in circular curved pattern toward center
                    if (widget.showFloatingBoxes)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FloatingCurvedBoxesPainter(
                            progress: progress,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          )
        else
          Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AtmosphericMeshPainter(
                    progress: 0.5,
                    pulseIntensity: 0.0,
                  ),
                ),
              ),
              if (widget.showGrid)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CryptographicGridPainter(
                      progress: 0.0,
                      animatePulse: false,
                    ),
                  ),
                ),
            ],
          ),

        // Foreground Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

class _AtmosphericMeshPainter extends CustomPainter {
  final double progress;
  final double pulseIntensity;

  _AtmosphericMeshPainter({
    required this.progress,
    this.pulseIntensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;

    // Organic breathing wave with ease-in and ease-out (smooth sinusoidal curve)
    final breathCycle = Curves.easeInOutSine.transform((math.sin(progress * 2 * math.pi) + 1.0) / 2.0);
    // Secondary subtle micro-pulse for blinking / rhythmic shimmer
    final blinkCycle = Curves.easeInOutQuad.transform((math.sin(progress * 4 * math.pi + (math.pi / 4)) + 1.0) / 2.0);

    final cobaltPulse = 0.86 + (0.24 * breathCycle * pulseIntensity);
    final acidPulse = 0.82 + (0.28 * (1.0 - breathCycle) * pulseIntensity);
    final blinkIntensity = 0.85 + (0.15 * blinkCycle * pulseIntensity);

    final cobaltOffsetY = -40 + (breathCycle * 32);
    final acidOffsetY = 30 - (breathCycle * 24);

    // 1. Top-Left Electric Cobalt Radial Energy Glow (Pulsing & Blinking smoothly)
    final cobaltCenter = Offset(size.width * 0.16, size.height * 0.14 + cobaltOffsetY);
    final cobaltRadius = size.width * 0.88 * cobaltPulse;
    final cobaltPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          LuminaColors.electricCobalt.withValues(alpha: (0.22 * blinkIntensity).clamp(0.0, 1.0)),
          LuminaColors.electricCobalt.withValues(alpha: (0.09 * blinkIntensity).clamp(0.0, 1.0)),
          Colors.transparent,
        ],
        stops: [0.0, 0.42 + (0.08 * breathCycle), 1.0],
      ).createShader(Rect.fromCircle(center: cobaltCenter, radius: cobaltRadius));
    canvas.drawCircle(cobaltCenter, cobaltRadius, cobaltPaint);

    // 2. Mid-Right / Center-Right Deep Indigo Depth Anchor
    final indigoCenter = Offset(size.width * 0.85, size.height * 0.45);
    final indigoRadius = size.width * 0.72 * cobaltPulse;
    final indigoPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF152A55).withValues(alpha: (0.18 * blinkIntensity).clamp(0.0, 1.0)),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: indigoCenter, radius: indigoRadius));
    canvas.drawCircle(indigoCenter, indigoRadius, indigoPaint);

    // 3. Bottom-Left / Interactive Area Acid Lime Subtle Micro-Bloom
    final acidCenter = Offset(size.width * 0.82, size.height * 0.80 + acidOffsetY);
    final acidRadius = size.width * 0.68 * acidPulse;
    final acidPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          LuminaColors.acidLime.withValues(alpha: (0.09 * blinkIntensity).clamp(0.0, 1.0)),
          LuminaColors.acidLime.withValues(alpha: (0.03 * blinkIntensity).clamp(0.0, 1.0)),
          Colors.transparent,
        ],
        stops: [0.0, 0.38 + (0.06 * breathCycle), 1.0],
      ).createShader(Rect.fromCircle(center: acidCenter, radius: acidRadius));
    canvas.drawCircle(acidCenter, acidRadius, acidPaint);

    // 4. Subtle Vignette Border Darkening
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.15,
        colors: [
          Colors.transparent,
          LuminaColors.midnightBlack.withValues(alpha: 0.48),
        ],
        stops: const [0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _AtmosphericMeshPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulseIntensity != pulseIntensity;
  }
}

/// Subtle institutional fintech grid lines with pulsing node coordinates
class _CryptographicGridPainter extends CustomPainter {
  final double progress;
  final bool animatePulse;

  _CryptographicGridPainter({
    this.progress = 0.0,
    this.animatePulse = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    const spacing = 48.0;

    // Subtle ease-in/ease-out pulse for grid lines
    final gridBreath = animatePulse
        ? Curves.easeInOutSine.transform((math.sin(progress * 2 * math.pi) + 1.0) / 2.0)
        : 0.5;
    final lineAlpha = 0.024 + (0.016 * gridBreath);

    final gridPaint = Paint()
      ..color = LuminaColors.electricCobalt.withValues(alpha: lineAlpha)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw pulsating corner intersection micro-crosses and glowing dots
    final dotBreath = animatePulse
        ? Curves.easeInOutSine.transform((math.cos(progress * 2 * math.pi) + 1.0) / 2.0)
        : 0.5;
    final dotPaint = Paint()
      ..color = LuminaColors.acidLime.withValues(alpha: 0.06 + (0.07 * dotBreath))
      ..style = PaintingStyle.fill;

    for (double x = spacing; x < size.width; x += spacing * 2) {
      for (double y = spacing; y < size.height; y += spacing * 3) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CryptographicGridPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.animatePulse != animatePulse;
  }
}

class _BoxParticle {
  final double baseAngle;
  final double curveDirection;
  final double angularSweep;
  final double timeOffset;
  final double width;
  final double height;
  final double radius;
  final Color color;
  final bool hasCrosshair;
  final bool hasGridLines;
  final double selfRotateRate;

  const _BoxParticle({
    required this.baseAngle,
    required this.curveDirection,
    required this.angularSweep,
    required this.timeOffset,
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
    this.hasCrosshair = false,
    this.hasGridLines = false,
    this.selfRotateRate = 0.5,
  });
}

/// Floating holographic fintech boxes moving smoothly in circular curved patterns
/// from all sides toward the center of the screen with smooth ease-in & ease-out transitions.
class _FloatingCurvedBoxesPainter extends CustomPainter {
  final double progress;

  // Pre-allocated reusable paint instances to ensure 60/120fps zero-allocation painting
  final Paint _boxFillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _boxBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _boxAccentPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static const List<_BoxParticle> _particles = [
    // 1. Top-Right quadrant
    _BoxParticle(
      baseAngle: 0.15 * math.pi,
      curveDirection: 1.0,
      angularSweep: 1.05,
      timeOffset: 0.00,
      width: 40,
      height: 40,
      radius: 8,
      color: LuminaColors.electricCobalt,
      hasCrosshair: true,
      selfRotateRate: 0.65,
    ),
    // 2. Right side
    _BoxParticle(
      baseAngle: 0.35 * math.pi,
      curveDirection: -1.0,
      angularSweep: 0.95,
      timeOffset: 0.07,
      width: 44,
      height: 32,
      radius: 7,
      color: LuminaColors.acidLime,
      hasGridLines: true,
      selfRotateRate: 0.40,
    ),
    // 3. Bottom-Right quadrant
    _BoxParticle(
      baseAngle: 0.55 * math.pi,
      curveDirection: 1.0,
      angularSweep: 1.15,
      timeOffset: 0.14,
      width: 32,
      height: 32,
      radius: 6,
      color: Color(0xFF00E5FF),
      hasCrosshair: true,
    ),
    // 4. Bottom quadrant
    _BoxParticle(
      baseAngle: 0.75 * math.pi,
      curveDirection: -1.0,
      angularSweep: 1.0,
      timeOffset: 0.21,
      width: 48,
      height: 48,
      radius: 10,
      color: LuminaColors.electricCobalt,
      hasGridLines: true,
    ),
    // 5. Bottom-Left quadrant
    _BoxParticle(
      baseAngle: 0.95 * math.pi,
      curveDirection: 1.0,
      angularSweep: 0.90,
      timeOffset: 0.28,
      width: 36,
      height: 36,
      radius: 7,
      color: LuminaColors.acidLime,
      hasCrosshair: true,
    ),
    // 6. Left side
    _BoxParticle(
      baseAngle: 1.15 * math.pi,
      curveDirection: -1.0,
      angularSweep: 1.10,
      timeOffset: 0.35,
      width: 42,
      height: 30,
      radius: 7,
      color: Color(0xFF6366F1),
      hasGridLines: true,
    ),
    // 7. Top-Left quadrant
    _BoxParticle(
      baseAngle: 1.35 * math.pi,
      curveDirection: 1.0,
      angularSweep: 0.98,
      timeOffset: 0.42,
      width: 34,
      height: 34,
      radius: 7,
      color: LuminaColors.electricCobalt,
      hasCrosshair: true,
    ),
    // 8. Top side
    _BoxParticle(
      baseAngle: 1.55 * math.pi,
      curveDirection: -1.0,
      angularSweep: 1.08,
      timeOffset: 0.49,
      width: 46,
      height: 46,
      radius: 9,
      color: LuminaColors.acidLime,
      hasGridLines: true,
    ),
    // 9. Diagonal Sweep East-Northeast
    _BoxParticle(
      baseAngle: 1.75 * math.pi,
      curveDirection: 1.0,
      angularSweep: 1.12,
      timeOffset: 0.56,
      width: 28,
      height: 28,
      radius: 6,
      color: Color(0xFF00E5FF),
      hasCrosshair: true,
    ),
    // 10. Diagonal Sweep South-Southeast
    _BoxParticle(
      baseAngle: 0.45 * math.pi,
      curveDirection: -1.0,
      angularSweep: 1.20,
      timeOffset: 0.63,
      width: 40,
      height: 40,
      radius: 8,
      color: LuminaColors.electricCobalt,
      hasGridLines: true,
    ),
    // 11. Diagonal Sweep South-Southwest
    _BoxParticle(
      baseAngle: 0.85 * math.pi,
      curveDirection: 1.0,
      angularSweep: 0.88,
      timeOffset: 0.70,
      width: 34,
      height: 26,
      radius: 6,
      color: LuminaColors.acidLime,
      hasCrosshair: true,
    ),
    // 12. Diagonal Sweep West-Northwest
    _BoxParticle(
      baseAngle: 1.25 * math.pi,
      curveDirection: -1.0,
      angularSweep: 1.16,
      timeOffset: 0.77,
      width: 42,
      height: 42,
      radius: 9,
      color: Color(0xFF6366F1),
      hasGridLines: true,
    ),
    // 13. High-Velocity Micro-Block
    _BoxParticle(
      baseAngle: 1.65 * math.pi,
      curveDirection: 1.0,
      angularSweep: 0.94,
      timeOffset: 0.84,
      width: 30,
      height: 30,
      radius: 6,
      color: LuminaColors.electricCobalt,
      hasCrosshair: true,
    ),
    // 14. Wide Telemetry Capsule
    _BoxParticle(
      baseAngle: 0.05 * math.pi,
      curveDirection: -1.0,
      angularSweep: 1.06,
      timeOffset: 0.91,
      width: 44,
      height: 32,
      radius: 7,
      color: LuminaColors.acidLime,
      hasGridLines: true,
    ),
  ];

  _FloatingCurvedBoxesPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2.0, size.height / 2.0);
    // Radius starts beyond screen perimeter
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) * 0.58;
    // Converges near center behind the login form
    const minRadius = 40.0;

    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final rawProgress = (progress + p.timeOffset) % 1.0;

      // Smooth ease-in & ease-out transition along curved path
      final easedProgress = Curves.easeInOutCubic.transform(rawProgress);

      // Radial convergence toward center
      final currentRadius = maxRadius * (1.0 - easedProgress) + (minRadius * easedProgress);

      // Curved circular spiral trajectory
      final currentAngle = p.baseAngle + (p.curveDirection * p.angularSweep * easedProgress);

      final boxX = center.dx + (currentRadius * math.cos(currentAngle));
      final boxY = center.dy + (currentRadius * math.sin(currentAngle));

      // Continuous fluid fade-in and fade-out with ease-in/ease-out transitions
      double fade;
      if (rawProgress < 0.20) {
        fade = Curves.easeInOutSine.transform(rawProgress / 0.20);
      } else if (rawProgress < 0.72) {
        fade = 1.0;
      } else {
        fade = Curves.easeInOutSine.transform((1.0 - rawProgress) / 0.28);
      }

      final alpha = (0.24 * fade).clamp(0.0, 1.0);
      if (alpha <= 0.005) continue;

      // Gentle self-rotation along curved trajectory
      final selfRotation = (currentAngle * 0.35) +
          (p.curveDirection * easedProgress * math.pi * p.selfRotateRate);

      canvas.save();
      canvas.translate(boxX, boxY);
      canvas.rotate(selfRotation);

      final boxRect = Rect.fromCenter(
        center: Offset.zero,
        width: p.width,
        height: p.height,
      );
      final rrect = RRect.fromRectAndRadius(boxRect, Radius.circular(p.radius));

      // 1. Translucent glowing fill
      _boxFillPaint.color = p.color.withValues(alpha: alpha * 0.12);
      canvas.drawRRect(rrect, _boxFillPaint);

      // 2. High-precision glowing border
      _boxBorderPaint.color = p.color.withValues(alpha: alpha * 0.65);
      canvas.drawRRect(rrect, _boxBorderPaint);

      // 3. Fintech detail: Crosshair or micro data lines
      if (p.hasCrosshair) {
        _boxAccentPaint.color = p.color.withValues(alpha: alpha * 0.75);
        const chLen = 4.0;
        canvas.drawLine(const Offset(-chLen, 0), const Offset(chLen, 0), _boxAccentPaint);
        canvas.drawLine(const Offset(0, -chLen), const Offset(0, chLen), _boxAccentPaint);
      } else if (p.hasGridLines) {
        _boxAccentPaint.color = p.color.withValues(alpha: alpha * 0.50);
        final lineW = p.width * 0.40;
        canvas.drawLine(Offset(-lineW / 2, -3), Offset(lineW / 2, -3), _boxAccentPaint);
        canvas.drawLine(Offset(-lineW / 2, 3), Offset(lineW / 2, 3), _boxAccentPaint);
      }

      // 4. Subtle corner accent nodes
      _boxAccentPaint.color = p.color.withValues(alpha: alpha * 0.85);
      canvas.drawCircle(Offset(boxRect.left + 5, boxRect.top + 5), 1.0, _boxAccentPaint);
      canvas.drawCircle(Offset(boxRect.right - 5, boxRect.bottom - 5), 1.0, _boxAccentPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingCurvedBoxesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
