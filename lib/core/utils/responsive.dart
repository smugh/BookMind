import 'package:flutter/material.dart';

/// Breakpoint and responsive layout utility for BookMind.
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 650.0;
  static const double desktopBreakpoint = 1100.0;
  static const double maxContentWidth = 980.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}
