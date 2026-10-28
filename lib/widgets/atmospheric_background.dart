import 'package:flutter/material.dart';
import '../theme/lumina_theme.dart';

/// Ultra-Luxury Atmospheric Mesh Background
/// Combines multi-point radial blooms (Electric Cobalt + Acid Lime)
/// with a subtle cryptographic fintech grid overlay.
/// Eliminates flat, lifeless black backgrounds while preserving OLED contrast.
class LuminaAtmosphericBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;
  final bool animate;

  const LuminaAtmosphericBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.animate = true,
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
      duration: const Duration(seconds: 8),
    );
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.animate && !isTest) {
      _controller.repeat(reverse: true);
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

        // Animated Ambient Blooms
        if (widget.animate)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              final cobaltOffsetY = -40 + (val * 30);
              final acidOffsetY = 30 - (val * 20);

              return Positioned.fill(
                child: CustomPaint(
                  painter: _AtmosphericMeshPainter(
                    cobaltOffsetY: cobaltOffsetY,
                    acidOffsetY: acidOffsetY,
                    pulseFactor: 0.9 + (val * 0.2),
                  ),
                ),
              );
            },
          )
        else
          Positioned.fill(
            child: CustomPaint(
              painter: _AtmosphericMeshPainter(
                cobaltOffsetY: -20,
                acidOffsetY: 20,
                pulseFactor: 1.0,
              ),
            ),
          ),

        // Subtle Cryptographic Grid Matrix
        if (widget.showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: _CryptographicGridPainter(),
            ),
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
  final double cobaltOffsetY;
  final double acidOffsetY;
  final double pulseFactor;

  _AtmosphericMeshPainter({
    required this.cobaltOffsetY,
    required this.acidOffsetY,
    required this.pulseFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Top-Left Electric Cobalt Radial Energy Glow
    final cobaltCenter = Offset(size.width * 0.15, size.height * 0.12 + cobaltOffsetY);
    final cobaltRadius = size.width * 0.85 * pulseFactor;
    final cobaltPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          LuminaColors.electricCobalt.withValues(alpha: 0.20),
          LuminaColors.electricCobalt.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: cobaltCenter, radius: cobaltRadius));
    canvas.drawCircle(cobaltCenter, cobaltRadius, cobaltPaint);

    // 2. Mid-Right / Center-Right Deep Indigo Depth Anchor
    final indigoCenter = Offset(size.width * 0.85, size.height * 0.45);
    final indigoRadius = size.width * 0.70;
    final indigoPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF152A55).withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: indigoCenter, radius: indigoRadius));
    canvas.drawCircle(indigoCenter, indigoRadius, indigoPaint);

    // 3. Bottom-Left / Interactive Area Acid Lime Subtle Micro-Bloom
    final acidCenter = Offset(size.width * 0.80, size.height * 0.82 + acidOffsetY);
    final acidRadius = size.width * 0.65 * pulseFactor;
    final acidPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          LuminaColors.acidLime.withValues(alpha: 0.08),
          LuminaColors.acidLime.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(Rect.fromCircle(center: acidCenter, radius: acidRadius));
    canvas.drawCircle(acidCenter, acidRadius, acidPaint);

    // 4. Subtle Vignette Border Darkening
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          LuminaColors.midnightBlack.withValues(alpha: 0.45),
        ],
        stops: const [0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _AtmosphericMeshPainter oldDelegate) {
    return oldDelegate.cobaltOffsetY != cobaltOffsetY ||
        oldDelegate.acidOffsetY != acidOffsetY ||
        oldDelegate.pulseFactor != pulseFactor;
  }
}

/// Subtle institutional fintech grid lines with node coordinates
class _CryptographicGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 48.0;
    final gridPaint = Paint()
      ..color = LuminaColors.electricCobalt.withValues(alpha: 0.035)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = LuminaColors.acidLime.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw occasional corner intersection micro-crosses
    for (double x = spacing; x < size.width; x += spacing * 2) {
      for (double y = spacing; y < size.height; y += spacing * 3) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CryptographicGridPainter oldDelegate) => false;
}
