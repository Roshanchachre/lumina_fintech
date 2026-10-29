import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../data/chart_dataset.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';

class GlowChart extends StatefulWidget {
  final String period;

  const GlowChart({
    super.key,
    required this.period,
  });

  @override
  State<GlowChart> createState() => _GlowChartState();
}

class _GlowChartState extends State<GlowChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _drawAnimation;

  double? _scrubX;
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _drawAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant GlowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _animController.reset();
      _animController.forward();
      setState(() {
        _scrubX = null;
        _isScrubbing = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, double width) {
    HapticFeedback.selectionClick();
    setState(() {
      _isScrubbing = true;
      _scrubX = details.localPosition.dx.clamp(0.0, width);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isScrubbing = false;
      _scrubX = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = LuminaChartData.forPeriod(widget.period);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 150.0;

        return GestureDetector(
          onHorizontalDragUpdate: (details) => _onPanUpdate(details, width),
          onHorizontalDragEnd: _onPanEnd,
          onTapDown: (details) {
            setState(() {
              _isScrubbing = true;
              _scrubX = details.localPosition.dx.clamp(0.0, width);
            });
          },
          onTapUp: (_) => _onPanEnd(DragEndDetails()),
          child: SizedBox(
            height: height,
            width: width,
            child: AnimatedBuilder(
              animation: _drawAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(width, height),
                  painter: _SplineChartPainter(
                    dataPoints: dataPoints,
                    progress: _drawAnimation.value,
                    scrubX: _scrubX,
                    isScrubbing: _isScrubbing,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  final List<FinancialDataPoint> dataPoints;
  final double progress;
  final double? scrubX;
  final bool isScrubbing;

  _SplineChartPainter({
    required this.dataPoints,
    required this.progress,
    this.scrubX,
    required this.isScrubbing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final values = dataPoints.map((d) => d.value).toList();

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final valRange = (maxVal - minVal) <= 0 ? 1.0 : (maxVal - minVal);

    final stepX = width / (dataPoints.length - 1);
    final offsets = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (values[i] - minVal) / valRange;
      // Chart line occupies 70% of canvas height to leave top breathing room for scrub HUD
      final y = height - (normalizedY * (height * 0.65) + (height * 0.12));
      offsets.add(Offset(x, y));
    }

    // Build Smooth Bézier Spline Path
    final path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];

      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Path measurement for smooth progressive draw
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;
    final metric = pathMetrics.first;
    final extractLength = metric.length * progress;
    final animatedPath = metric.extractPath(0.0, extractLength);

    // 1. Draw glowing gradient fill under the curve
    final fillPath = Path.from(animatedPath)
      ..lineTo(offsets.last.dx * progress, height)
      ..lineTo(0, height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, height),
        [
          LuminaColors.acidLime.withValues(alpha: 0.22 * progress),
          LuminaColors.electricCobalt.withValues(alpha: 0.08 * progress),
          Colors.transparent,
        ],
        [0.0, 0.55, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw Bloom / Ambient Blur on Stroke
    final bloomPaint = Paint()
      ..color = LuminaColors.acidLime.withValues(alpha: 0.40 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(animatedPath, bloomPaint);

    // 3. Draw Sharp Main Stroke with Cobalt-to-Acid Lime Gradient
    final strokePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(width, 0),
        [
          LuminaColors.electricCobalt,
          LuminaColors.acidLime,
        ],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(animatedPath, strokePaint);

    // 4. Interactive Scrubbing HUD
    if (isScrubbing && scrubX != null) {
      final normalizedScrub = (scrubX! / width).clamp(0.0, 1.0);
      final distance = metric.length * normalizedScrub;
      final tangent = metric.getTangentForOffset(distance);

      if (tangent != null) {
        final pos = tangent.position;

        // Vertical Guide Line
        final guidePaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(pos.dx, 0),
            Offset(pos.dx, height),
            [
              Colors.transparent,
              LuminaColors.electricCobalt.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          )
          ..strokeWidth = 1.2;

        canvas.drawLine(Offset(pos.dx, 0), Offset(pos.dx, height), guidePaint);

        // Outer Glow Ring
        final outerDotPaint = Paint()
          ..color = LuminaColors.acidLime.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 11, outerDotPaint);

        // Inner Sharp Dot
        final innerDotPaint = Paint()
          ..color = LuminaColors.acidLime
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 4.5, innerDotPaint);

        // Core White Highlight
        final coreDotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 2.0, coreDotPaint);

        // Floating HUD Pill
        final closestIndex = (normalizedScrub * (dataPoints.length - 1)).round().clamp(0, dataPoints.length - 1);
        final activePoint = dataPoints[closestIndex];
        final priceStr = '\$${NumberFormat("#,##0.00").format(activePoint.value)}';
        final labelStr = '${activePoint.timeLabel} • $priceStr';

        final textSpan = TextSpan(
          text: labelStr,
          style: const TextStyle(
            color: LuminaColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontFamily: 'SpaceGrotesk',
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: ui.TextDirection.ltr,
        )..layout();

        final hudWidth = textPainter.width + 16;
        final hudHeight = textPainter.height + 8;
        // Clamp HUD horizontally so it never exceeds screen bounds
        final hudX = (pos.dx - (hudWidth / 2)).clamp(6.0, width - hudWidth - 6.0);
        final hudY = (pos.dy - 34.0) < 4.0 ? (pos.dy + 14.0) : (pos.dy - 34.0);

        final hudRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(hudX, hudY, hudWidth, hudHeight),
          const Radius.circular(8),
        );

        final hudBgPaint = Paint()
          ..color = LuminaColors.surfaceElevated.withValues(alpha: 0.95)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(hudRRect, hudBgPaint);

        final hudBorderPaint = Paint()
          ..color = LuminaColors.acidLime.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRRect(hudRRect, hudBorderPaint);

        textPainter.paint(canvas, Offset(hudX + 8, hudY + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scrubX != scrubX ||
        oldDelegate.isScrubbing != isScrubbing ||
        oldDelegate.dataPoints != dataPoints;
  }
}
