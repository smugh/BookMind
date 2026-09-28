import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

enum BookMindLogoStyle {
  vertical,
  horizontal,
  iconOnly,
}

/// Logo component created based on BookMind Logo Guide and Visual Identity.
/// Left book page: Coffee (#6B4E3D)
/// Right book page: Terracotta (#D97757)
class BookMindLogo extends StatelessWidget {
  final double iconSize;
  final BookMindLogoStyle style;
  final Color? coffeeColor;
  final Color? terracottaColor;
  final Color? textColor;

  const BookMindLogo({
    super.key,
    this.iconSize = 48,
    this.style = BookMindLogoStyle.vertical,
    this.coffeeColor,
    this.terracottaColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final cColor = coffeeColor ?? AppColors.primaryCoffee;
    final tColor = terracottaColor ?? AppColors.primaryTerracotta;
    final tTextColor = textColor ?? AppColors.primaryCoffee;

    final iconWidget = SizedBox(
      width: iconSize,
      height: iconSize * 0.95,
      child: CustomPaint(
        painter: _BookMindLogoPainter(
          coffeeColor: cColor,
          terracottaColor: tColor,
        ),
      ),
    );

    if (style == BookMindLogoStyle.iconOnly) {
      return iconWidget;
    }

    final titleText = Text(
      'BookMind',
      style: GoogleFonts.lora(
        fontSize: iconSize * 0.45,
        fontWeight: FontWeight.bold,
        color: tTextColor,
        letterSpacing: 0.5,
      ),
    );

    final subtitleText = Text(
      'READ · REFLECT · GROW',
      style: GoogleFonts.plusJakartaSans(
        fontSize: iconSize * 0.16,
        fontWeight: FontWeight.w600,
        color: AppColors.n500,
        letterSpacing: 2.2,
      ),
    );

    if (style == BookMindLogoStyle.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: iconSize * 0.3),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText,
              const SizedBox(height: 2),
              subtitleText,
            ],
          ),
        ],
      );
    }

    // Vertical style
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(height: iconSize * 0.25),
        titleText,
        const SizedBox(height: 4),
        subtitleText,
      ],
    );
  }
}

class _BookMindLogoPainter extends CustomPainter {
  final Color coffeeColor;
  final Color terracottaColor;

  _BookMindLogoPainter({
    required this.coffeeColor,
    required this.terracottaColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final leftPaint = Paint()
      ..color = coffeeColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final rightPaint = Paint()
      ..color = terracottaColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final gap = w * 0.05;
    final spineX = w / 2;

    // Left Page
    final leftPath = Path();
    final leftStart = spineX - (gap / 2);
    final leftOuter = w * 0.08;

    leftPath.moveTo(leftStart, h * 0.88);
    // Bottom curve to left outer
    leftPath.quadraticBezierTo(w * 0.25, h * 0.82, leftOuter, h * 0.76);
    // Outer edge up
    leftPath.lineTo(leftOuter, h * 0.22);
    // Top curved edge to spine
    leftPath.quadraticBezierTo(w * 0.26, h * 0.08, leftStart, h * 0.16);
    // Inner spine edge down
    leftPath.lineTo(leftStart, h * 0.88);
    leftPath.close();

    // Right Page
    final rightPath = Path();
    final rightStart = spineX + (gap / 2);
    final rightOuter = w * 0.92;

    rightPath.moveTo(rightStart, h * 0.88);
    // Bottom curve to right outer
    rightPath.quadraticBezierTo(w * 0.75, h * 0.82, rightOuter, h * 0.76);
    // Outer edge up
    rightPath.lineTo(rightOuter, h * 0.22);
    // Top curved edge to spine
    rightPath.quadraticBezierTo(w * 0.74, h * 0.08, rightStart, h * 0.16);
    // Inner spine edge down
    rightPath.lineTo(rightStart, h * 0.88);
    rightPath.close();

    // Draw shadow or pages
    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  bool shouldRepaint(covariant _BookMindLogoPainter oldDelegate) {
    return oldDelegate.coffeeColor != coffeeColor ||
        oldDelegate.terracottaColor != terracottaColor;
  }
}
