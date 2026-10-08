import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colours taken straight from the Sahaara website.
class AppColors {
  static const cream = Color(0xFFECDFC8); // main page bg
  static const sand = Color(0xFFE1D4BE); // panels
  static const maroon = Color(0xFF60181E); // brand-red
  static const maroonDark = Color(0xFF4A1218); // hover / pressed
  static const tan = Color(0xFFA08C74); // secondary text
  static const brown = Color(0xFF8A5A3C); // accents
  static const text = Color(0xFF554240); // body text
  static const muted = Color(0xFF707070); // labels
  static const success = Color(0xFF2E7D5B);
  // Medical imaging (X-rays & scans) uses a cool, dark "lightbox" look so it
  // is instantly distinguishable from paper documents.
  static const scanDark = Color(0xFF151A22);
  static const scanAccent = Color(0xFF9DB7CC);
}

class AppTheme {
  /// Serif for headlines = premium / editorial feel.
  static TextStyle heading(double size, {Color color = AppColors.maroon}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle body(double size,
          {Color color = AppColors.text, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, height: 1.5);

  static TextStyle label() => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.muted,
      );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.maroon,
        primary: AppColors.maroon,
        surface: AppColors.cream,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.maroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
