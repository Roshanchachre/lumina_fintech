import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';

enum LuminaSnackBarType {
  info,
  success,
  warning,
  error,
}

/// Ultra-Luxury Toast & SnackBar Design System
/// Replaces generic unstyled snackbars with floating neon-bordered micro-cards,
/// rich typography, status glyphs, and spatial haptic feedback.
class LuminaSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    LuminaSnackBarType type = LuminaSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
    double? bottomMargin,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final bottomInset = MediaQuery.maybePaddingOf(context)?.bottom ?? 0.0;
    final effectiveBottomMargin = bottomMargin ?? (bottomInset + 88.0);

    Color accentColor;
    Color iconBgColor;
    IconData icon;
    LuminaSound soundCue;

    switch (type) {
      case LuminaSnackBarType.success:
        accentColor = LuminaColors.acidLime;
        iconBgColor = LuminaColors.acidLime.withValues(alpha: 0.15);
        icon = Icons.check_circle_rounded;
        soundCue = LuminaSound.moneyReceived;
        HapticFeedback.mediumImpact();
        break;
      case LuminaSnackBarType.warning:
        accentColor = LuminaColors.amberWarning;
        iconBgColor = LuminaColors.amberWarning.withValues(alpha: 0.15);
        icon = Icons.warning_amber_rounded;
        soundCue = LuminaSound.cardClick;
        HapticFeedback.mediumImpact();
        break;
      case LuminaSnackBarType.error:
        accentColor = LuminaColors.crimsonAlert;
        iconBgColor = LuminaColors.crimsonAlert.withValues(alpha: 0.18);
        icon = Icons.error_outline_rounded;
        soundCue = LuminaSound.errorAlert;
        HapticFeedback.heavyImpact();
        break;
      case LuminaSnackBarType.info:
        accentColor = LuminaColors.electricCobalt;
        iconBgColor = LuminaColors.electricCobalt.withValues(alpha: 0.15);
        icon = Icons.hub_rounded;
        soundCue = LuminaSound.cardClick;
        HapticFeedback.lightImpact();
        break;
    }

    SoundService.instance.play(soundCue);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: EdgeInsets.fromLTRB(16, 0, 16, effectiveBottomMargin),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0B101D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.12),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Monogram Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 14),

              // Title & Message Content
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty) ...[
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Optional Action Button
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                    onAction();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      actionLabel,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
