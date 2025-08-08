import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  // headings
  static TextStyle h1 = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static TextStyle h3 = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  //  body text
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  //  botton text
  static TextStyle buttonMedium = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle buttonSmall = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  //  label text
  static TextStyle buttonLarge = GoogleFonts.montserrat(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // helper functions for color variations
  static TextStyle withColor(TextStyle style, Color? color) {
    return style.copyWith(color: color);
  }

  //
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
