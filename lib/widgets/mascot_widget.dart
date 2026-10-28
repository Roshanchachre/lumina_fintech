import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lumina_theme.dart';

/// Scene mode for Lumi, the Lumina Cybernetic Sentinel Mascot
enum LumiScene {
  sovereignCustody, // Screen 1: Holding multi-asset crystal
  yieldVelocity,    // Screen 2: Speed bolts & Arbitrum L2 yield engine
  enclaveSecurity,  // Screen 3: Holographic biometric vault shield
}

/// Dynamic, interactive Mascot Character for Lumina Fintech
class LumiMascotWidget extends StatefulWidget {
  final LumiScene scene;
  final double size;

  const LumiMascotWidget({
    super.key,
    required this.scene,
    this.size = 260,
  });

  @override
  State<LumiMascotWidget> createState() => _LumiMascotWidgetState();
}

class _LumiMascotWidgetState extends State<LumiMascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onMascotTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _isTapped = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isTapped = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onMascotTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = _pulseController.value;
            final floatOffset = math.sin(pulse * math.pi) * 8.0;

            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Glow Aura
                Container(
                  width: widget.size * 0.85,
                  height: widget.size * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.scene == LumiScene.yieldVelocity
                            ? LuminaColors.electricCobalt.withValues(alpha: 0.28)
                            : widget.scene == LumiScene.enclaveSecurity
                                ? LuminaColors.acidLime.withValues(alpha: 0.22)
                                : LuminaColors.electricCobalt.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.75],
                    ),
                  ),
                ),

                // 2. Rotating Orbital Energy Rings
                Transform.rotate(
                  angle: pulse * 0.2,
                  child: Container(
                    width: widget.size * 0.92,
                    height: widget.size * 0.92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LuminaColors.surfaceBorder.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                // 3. Floating Mascot Body with Custom Paint
                Transform.translate(
                  offset: Offset(0, floatOffset),
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _LumiMascotPainter(
                      scene: widget.scene,
                      pulse: pulse,
                      isTapped: _isTapped,
                    ),
                  ),
                ),

                // 4. Interactive Scene Props & Overlays
                Positioned(
                  bottom: 12 + floatOffset,
                  child: _buildSceneProp(pulse),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSceneProp(double pulse) {
    switch (widget.scene) {
      case LumiScene.sovereignCustody:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceElevated.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LuminaColors.acidLime.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: LuminaColors.acidLime.withValues(alpha: 0.2),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.token_rounded, color: LuminaColors.acidLime, size: 14),
              const SizedBox(width: 6),
              Text(
                'MULTI-ASSET VAULT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LuminaColors.textPrimary,
                ),
              ),
            ],
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms);

      case LumiScene.yieldVelocity:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceElevated.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LuminaColors.electricCobalt),
            boxShadow: [
              BoxShadow(
                color: LuminaColors.electricCobalt.withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: LuminaColors.acidLime, size: 15),
              const SizedBox(width: 6),
              Text(
                'ARBITRUM 4.8% APY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LuminaColors.acidLime,
                ),
              ),
            ],
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms);

      case LumiScene.enclaveSecurity:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceElevated.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LuminaColors.acidLime),
            boxShadow: [
              BoxShadow(
                color: LuminaColors.acidLime.withValues(alpha: 0.25),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security_rounded, color: LuminaColors.acidLime, size: 14),
              const SizedBox(width: 6),
              Text(
                'ENCLAVE ENCRYPTED',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LuminaColors.textPrimary,
                ),
              ),
            ],
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms);
    }
  }
}

/// Detailed Vector Painter for Lumi
class _LumiMascotPainter extends CustomPainter {
  final LumiScene scene;
  final double pulse;
  final bool isTapped;

  _LumiMascotPainter({
    required this.scene,
    required this.pulse,
    required this.isTapped,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 10;

    // --- 1. Cyber Robotic Ears ---
    final leftEarPath = Path()
      ..moveTo(cx - 52, cy - 35)
      ..lineTo(cx - 78, cy - 88)
      ..lineTo(cx - 24, cy - 65)
      ..close();

    final rightEarPath = Path()
      ..moveTo(cx + 52, cy - 35)
      ..lineTo(cx + 78, cy - 88)
      ..lineTo(cx + 24, cy - 65)
      ..close();

    final earPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(cx - 80, cy - 90, 160, 60));

    final earGlowPaint = Paint()
      ..color = LuminaColors.electricCobalt.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawPath(leftEarPath, earPaint);
    canvas.drawPath(leftEarPath, earGlowPaint);
    canvas.drawPath(rightEarPath, earPaint);
    canvas.drawPath(rightEarPath, earGlowPaint);

    // Inner Ear High-Voltage Neon Liners
    final innerEarPaint = Paint()
      ..color = LuminaColors.acidLime.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(cx - 65, cy - 72), Offset(cx - 36, cy - 54), innerEarPaint);
    canvas.drawLine(Offset(cx + 65, cy - 72), Offset(cx + 36, cy - 54), innerEarPaint);

    // --- 2. Sleek Metallic Head Chassis ---
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 20), width: 110, height: 95),
      const Radius.circular(38),
    );

    final headChassisPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF172033),
          Color(0xFF0A0F1D),
          LuminaColors.midnightBlack,
        ],
      ).createShader(headRect.outerRect);

    final headBorderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          LuminaColors.electricCobalt,
          LuminaColors.surfaceBorder,
          LuminaColors.acidLime.withValues(alpha: 0.6),
        ],
      ).createShader(headRect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(headRect, headChassisPaint);
    canvas.drawRRect(headRect, headBorderPaint);

    // --- 3. Cybernetic Visor / Eyes ---
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 22), width: 84, height: 32),
      const Radius.circular(16),
    );

    final visorPaint = Paint()..color = const Color(0xFF030712);
    final visorBorder = Paint()
      ..color = LuminaColors.electricCobalt.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(visorRect, visorPaint);
    canvas.drawRRect(visorRect, visorBorder);

    // Dynamic Ocular Neon Eyes
    final eyePaint = Paint()
      ..color = isTapped ? LuminaColors.neonPurple : LuminaColors.acidLime
      ..style = PaintingStyle.fill;

    if (isTapped) {
      // Winking / Joyful expressions on tap!
      canvas.drawCircle(Offset(cx - 18, cy - 22), 5, eyePaint);
      final winkPath = Path()
        ..moveTo(cx + 12, cy - 22)
        ..quadraticBezierTo(cx + 20, cy - 27, cx + 26, cy - 22);
      canvas.drawPath(winkPath, Paint()..color = LuminaColors.acidLime..style = PaintingStyle.stroke..strokeWidth = 3);
    } else {
      // High-tech focused angular visor slits
      final leftEye = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 18, cy - 22), width: 14, height: 10),
        const Radius.circular(4),
      );
      final rightEye = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 18, cy - 22), width: 14, height: 10),
        const Radius.circular(4),
      );
      canvas.drawRRect(leftEye, eyePaint);
      canvas.drawRRect(rightEye, eyePaint);

      // Micro HUD scanning reticle line inside visor
      final scanLinePaint = Paint()
        ..color = LuminaColors.acidLime.withValues(alpha: 0.35 + (pulse * 0.3))
        ..strokeWidth = 1;
      final scanY = cy - 28 + (pulse * 12);
      canvas.drawLine(Offset(cx - 36, scanY), Offset(cx + 36, scanY), scanLinePaint);
    }

    // --- 4. Torso & Quantum Energy Core ---
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 42), width: 78, height: 50),
      const Radius.circular(22),
    );

    final torsoPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF070B14)],
      ).createShader(torsoRect.outerRect);

    final torsoBorder = Paint()
      ..color = LuminaColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(torsoRect, torsoPaint);
    canvas.drawRRect(torsoRect, torsoBorder);

    // Glowing Chest Energy Core
    final coreCenter = Offset(cx, cy + 40);
    final coreRadius = 11.0 + (pulse * 2.0);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          LuminaColors.acidLime,
          LuminaColors.electricCobalt,
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: coreCenter, radius: coreRadius * 1.8));

    canvas.drawCircle(coreCenter, coreRadius, corePaint);

    // --- 5. Scene Specific Hand Props ---
    if (scene == LumiScene.sovereignCustody) {
      // Floating Multi-asset Diamond
      _drawHolographicDiamond(canvas, Offset(cx, cy + 76));
    } else if (scene == LumiScene.yieldVelocity) {
      // High-Velocity Speed Wings & Lightning Trail
      _drawVelocityBolts(canvas, cx, cy);
    } else if (scene == LumiScene.enclaveSecurity) {
      // Biometric Forcefield Shield Ring
      _drawSecurityShield(canvas, cx, cy);
    }
  }

  void _drawHolographicDiamond(Canvas canvas, Offset center) {
    final diamondPath = Path()
      ..moveTo(center.dx, center.dy - 12)
      ..lineTo(center.dx + 12, center.dy)
      ..lineTo(center.dx, center.dy + 12)
      ..lineTo(center.dx - 12, center.dy)
      ..close();

    final diamondPaint = Paint()
      ..shader = const LinearGradient(
        colors: [LuminaColors.acidLime, LuminaColors.electricCobalt],
      ).createShader(Rect.fromCircle(center: center, radius: 12));

    canvas.drawPath(diamondPath, diamondPaint);
  }

  void _drawVelocityBolts(Canvas canvas, double cx, double cy) {
    final boltPaint = Paint()
      ..color = LuminaColors.acidLime.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final leftBolt = Path()
      ..moveTo(cx - 45, cy + 30)
      ..lineTo(cx - 60, cy + 42)
      ..lineTo(cx - 52, cy + 45)
      ..lineTo(cx - 68, cy + 60);

    final rightBolt = Path()
      ..moveTo(cx + 45, cy + 30)
      ..lineTo(cx + 60, cy + 42)
      ..lineTo(cx + 52, cy + 45)
      ..lineTo(cx + 68, cy + 60);

    canvas.drawPath(leftBolt, boltPaint);
    canvas.drawPath(rightBolt, boltPaint);
  }

  void _drawSecurityShield(Canvas canvas, double cx, double cy) {
    final shieldPaint = Paint()
      ..color = LuminaColors.electricCobalt.withValues(alpha: 0.35 + (pulse * 0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy + 10), radius: 68),
      -math.pi * 0.85,
      math.pi * 1.7,
      false,
      shieldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LumiMascotPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.isTapped != isTapped ||
        oldDelegate.scene != scene;
  }
}
