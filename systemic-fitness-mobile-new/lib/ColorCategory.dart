import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Systemic Fitness brand palette (SF Master Platform Spec v1.0 / 2026)
// Added in Phase 0 — coexists with the legacy palette below.
// Use the kSf* constants on new SF screens; legacy screens keep using the
// existing constants until Phase 8 sweep.
// ---------------------------------------------------------------------------
const Color kSfDeepNavy     = Color(0xFF0A1628); // onboarding background
const Color kSfCharcoal     = Color(0xFF444444); // body text (warmer than pure black)
const Color kSfMidnightBlue = Color(0xFF1B3A5C); // section bg, secondary headers
const Color kSfSystemBlue   = Color(0xFF2E6DA4); // primary action, links
const Color kSfWarmGold     = Color(0xFFB8922E); // signature CTA, highlights
const Color kSfWarmGoldDark = Color(0xFFA07828); // hover/pressed state of warmGold
const Color kSfDeepTeal     = Color(0xFF0B5C5C); // FC pillar, success
const Color kSfIceBlue      = Color(0xFFE8F0F8); // light surface, hover
const Color kSfWarmWhite    = Color(0xFFF8F6F1); // page background (not pure white)

Color bgDarkWhite="#FFFFFF".toColor();
Color primaryColor=Color(0xFFF6F6F6);
Color accentColor="#000000".toColor();
Color subTextColor="#7D7D7D".toColor();
Color greyWhite=Color(0xFFEBEAEF);
Color darkGrey=Color(0xFFEBEAEF);
Color greenButton=Color(0xFF37BD4D);
Color blueButton=Color(0xFF0078FF);
Color quickSvgColor=Color(0xFF283182);
Color bmiBgColor="#2C698D".toColor();
Color bmiDarkBgColor=Color(0xFF134B6D);
Color lightPink=Color(0xFFFBE8EA);
Color itemBgColor=Color(0xFFF2F1F4);
Color textColor=Colors.black;
Color borderColor=Colors.grey.shade200;

Color cellColor="#F9F9F9".toColor();
Color bgColor="#F4F4F4".toColor();
Color category1="#FFF8D1".toColor();
Color category2="#FFDFDF".toColor();
Color category3="#D5F6E4".toColor();
Color category4="#E8E5FF".toColor();
Color category5="#F6D5EF".toColor();
Color category6="#FFECDB".toColor();
Color category7="#D6F4FF".toColor();


getCellColor(int index){
  if(index % 7 == 0){
    return category1;
  }else if(index % 7 == 1){
    return category2;
  }else if(index % 7 == 2){
    return category3;
  }else if(index % 7 == 3){
    return category4;
  }else if(index % 7 == 4){
    return category5;
  }else if(index % 7 == 5){
    return category6;
  }else if(index % 7 == 6){
    return category7;
  }else {
    return category1;
  }
}




extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}