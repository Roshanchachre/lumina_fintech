import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final Map<String, List<double>> _chartPoints = {
    '1D': [40, 48, 45, 58, 52, 65, 62, 74, 70, 85],
    '1W': [30, 42, 38, 55, 48, 62, 59, 72, 80, 92],
    '1M': [35, 45, 40, 60, 55, 70, 65, 82, 78, 95],
    '1Y': [20, 32, 28, 45, 40, 58, 65, 75, 85, 100],
    'ALL': [15, 25, 35, 30, 50, 65, 60, 80, 90, 100],
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    final rawPoints = _chartPoints[widget.period] ?? _chartPoints['1M']!;

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
                    points: rawPoints,
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
  final List<double> points;
  final double progress;
  final double? scrubX;
  final bool isScrubbing;

  _SplineChartPainter({
    required this.points,
    required this.progress,
    this.scrubX,
    required this.isScrubbing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final width = size.width;
    final height = size.height;

    final minVal = points.reduce((a, b) => a < b ? a : b) * 0.8;
    final maxVal = points.reduce((a, b) => a > b ? a : b) * 1.1;
    final valRange = (maxVal - minVal).clamp(1.0, 999999.0);

    final stepX = width / (points.length - 1);
    final offsets = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final normalizedY = (points[i] - minVal) / valRange;
      final y = height - (normalizedY * (height * 0.85) + (height * 0.05));
      offsets.add(Offset(x, y));
    }

    // Build Spline Path
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

    // Path measurement for animated draw
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
          LuminaColors.acidLime.withValues(alpha: 0.25 * progress),
          LuminaColors.electricCobalt.withValues(alpha: 0.08 * progress),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw Bloom / Ambient Blur on Stroke
    final bloomPaint = Paint()
      ..color = LuminaColors.acidLime.withValues(alpha: 0.45 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

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
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(animatedPath, strokePaint);

    // 4. Scrubbing interaction indicator
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
        canvas.drawCircle(pos, 12, outerDotPaint);

        // Inner Sharp Dot
        final innerDotPaint = Paint()
          ..color = LuminaColors.acidLime
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 5, innerDotPaint);

        // Core White Highlight
        final coreDotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 2.5, coreDotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scrubX != scrubX ||
        oldDelegate.isScrubbing != isScrubbing ||
        oldDelegate.points != points;
  }
}
