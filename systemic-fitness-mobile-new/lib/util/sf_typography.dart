import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ColorCategory.dart';

/// Systemic Fitness typography helper (Phase 0 — Spec Lock & Branding Tokens).
///
/// Pulls DM Serif Display, DM Sans, and DM Mono on demand via google_fonts so
/// new SF screens stay aligned with the brand spec without forcing a global
/// theme swap (legacy screens keep using SFProText / SecularOne until the
/// Phase 8 sweep).
///
/// Spec reference: SF_Master_Platform_Spec.docx §7.2 (Tipografi).
class SfTypography {
  SfTypography._();

  /// Editorial display headline (Hero / cover). 32–48px regular.
  static TextStyle headline({
    double fontSize = 32,
    Color color = kSfCharcoal,
    double? height,
  }) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
        height: height ?? 1.2,
      );

  /// Section title / sub-headline. 20–28px medium.
  static TextStyle subheadline({
    double fontSize = 22,
    Color color = kSfCharcoal,
    double? height,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color,
        height: height ?? 1.35,
      );

  /// Default body copy. 14–16px regular, line-height 1.7.
  static TextStyle body({
    double fontSize = 15,
    Color color = kSfCharcoal,
    FontWeight weight = FontWeight.w400,
    double? height,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height ?? 1.7,
      );

  /// Caption / label / badge. 11–13px medium with a slight letter-spacing.
  /// Use ALL CAPS only for tight pill badges.
  static TextStyle label({
    double fontSize = 12,
    Color color = kSfCharcoal,
    double letterSpacing = 0.8,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Numeric / data display (System Score, BPM, metrics). 24–48px regular.
  static TextStyle data({
    double fontSize = 32,
    Color color = kSfCharcoal,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.dmMono(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
      );

  /// Primary CTA label.
  static TextStyle ctaPrimary({Color color = Colors.white}) => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.3,
      );
}
