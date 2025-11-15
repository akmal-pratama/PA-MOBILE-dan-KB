import 'package:flutter/material.dart';

class ResponsiveUtil {
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 48; // Desktop
    if (width >= 768) return 32;  // Tablet
    return 16;                    // Mobile
  }

  static double getVerticalPadding(BuildContext context) {
    return 16;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}