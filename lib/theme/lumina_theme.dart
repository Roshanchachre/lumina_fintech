import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ultra-Luxury Midnight Neo Palette
/// Core Identity: Midnight Black (#030407) + Electric Cobalt Blue (#1558C9) + Acid Lime (#D4FF24)
class LuminaColors {
  // Midnight Void Core Palette (Exact User Tokens)
  static const Color midnightBlack = Color(0xFF030407);
  static const Color electricCobalt = Color(0xFF1558C9);
  static const Color acidLime = Color(0xFFD4FF24);

  // Background & Surfaces
  static const Color background = midnightBlack;
  static const Color surface = Color(0xFF080C16);
  static const Color surfaceElevated = Color(0xFF0D1424);
  static const Color surfaceBorder = Color(0x331558C9);
  static const Color surfaceBorderSubtle = Color(0x181558C9);

  // High-voltage Neo Accents
  static const Color neonGreen = acidLime;          // Acid Lime hero accent (#D4FF24)
  static const Color neonCyan = Color(0xFF2979FF);   // Electric Cobalt highlight
  static const Color neonPurple = Color(0xFF7C4DFF); // Deep royal violet
  static const Color electricViolet = Color(0xFF1558C9); // Electric Cobalt
  static const Color amberWarning = Color(0xFFFFB800);
  static const Color crimsonAlert = Color(0xFFFF3366);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Signature Gradients
  static const LinearGradient cardGradientTitanium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF111A30),
      Color(0xFF0A0F1E),
      Color(0xFF030407),
    ],
  );

  static const LinearGradient cardGradientCobalt = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E40AF),
      Color(0xFF1558C9),
      Color(0xFF0A1530),
    ],
  );

  static const LinearGradient cardGradientAcid = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2D08),
      Color(0xFF0E1604),
      Color(0xFF030407),
    ],
  );

  static const LinearGradient cardGradientEmerald = cardGradientAcid;

  static const LinearGradient cardGradientObsidian = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF231633),
      Color(0xFF130A1F),
      Color(0xFF07030C),
    ],
  );

  static const LinearGradient neonGreenCyan = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [acidLime, electricCobalt],
  );

  static const LinearGradient cobaltAcid = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [electricCobalt, acidLime],
  );

  static const LinearGradient purpleViolet = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [neonPurple, electricCobalt],
  );

  static const LinearGradient glassSheen = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    stops: [0.0, 0.45, 0.55, 1.0],
    colors: [
      Colors.transparent,
      Color(0x281558C9),
      Color(0x35D4FF24),
      Colors.transparent,
    ],
  );
}

class LuminaTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LuminaColors.background,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          color: LuminaColors.textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: LuminaColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: LuminaColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: LuminaColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: LuminaColors.textSecondary,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: LuminaColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        surface: LuminaColors.surface,
        primary: LuminaColors.acidLime,
        secondary: LuminaColors.electricCobalt,
      ),
    );
  }
}
