import 'package:flutter/material.dart';

class MyardsColors {
  static const Color primary = Color(0xFF039D55);
  static const Color primaryDark = Color(0xFF006B3E);
  static const Color freshGreen = Color(0xFF2A9849);
  static const Color mint = Color(0xFFEAFBF1);
  static const Color surface = Color(0xFFF7FAF6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF102018);
  static const Color textSoft = Color(0xFF647067);
  static const Color offerYellow = Color(0xFFF8C846);
  static const Color error = Color(0xFFE84D4F);
  static const Color success = Color(0xFF16B559);
}

class MyardsRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
}

class MyardsSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class MyardsShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> greenGlow = [
    BoxShadow(
      color: MyardsColors.primary.withOpacity(0.14),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
