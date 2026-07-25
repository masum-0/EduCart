import 'package:flutter/material.dart';

import 'app_theme.dart';

/// The EduCart brand mark — a graduation cap (with tassel) resting on a
/// shopping-cart basket. Drawn as vector shapes so it matches
/// assets/icon/app_icon.png (the launcher icon) at any size, and stays
/// crisp on every screen density without shipping a raster asset.
///
/// Usage:
///   const AppLogo(size: 96)                          // white mark, pink tassel — for dark/blue backgrounds
///   const AppLogo(size: 96, markColor: primaryBlue)   // for light backgrounds
class AppLogo extends StatelessWidget {
  final double size;
  final Color markColor;
  final Color tasselColor;

  const AppLogo({
    super.key,
    this.size = 84,
    this.markColor = Colors.white,
    this.tasselColor = pinkColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AppLogoPainter(markColor: markColor, tasselColor: tasselColor),
      ),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  final Color markColor;
  final Color tasselColor;

  _AppLogoPainter({required this.markColor, required this.tasselColor});

  Offset _p(Size s, double x, double y) => Offset(x * s.width, y * s.height);

  @override
  void paint(Canvas canvas, Size size) {
    final markPaint = Paint()
      ..color = markColor
      ..style = PaintingStyle.fill;
    final tasselPaint = Paint()
      ..color = tasselColor
      ..style = PaintingStyle.fill;

    // --- Graduation cap (mortarboard) ---
    final diamond = Path()
      ..moveTo(_p(size, 0.5, 0.02).dx, _p(size, 0.5, 0.02).dy)
      ..lineTo(_p(size, 0.94, 0.26).dx, _p(size, 0.94, 0.26).dy)
      ..lineTo(_p(size, 0.5, 0.5).dx, _p(size, 0.5, 0.5).dy)
      ..lineTo(_p(size, 0.06, 0.26).dx, _p(size, 0.06, 0.26).dy)
      ..close();
    canvas.drawPath(diamond, markPaint);

    // center button
    canvas.drawCircle(_p(size, 0.5, 0.26), size.width * 0.028, tasselPaint);

    // tassel cord + bead
    final cordPaint = Paint()
      ..color = tasselColor
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      _p(size, 0.5, 0.26),
      _p(size, 0.67, 0.47),
      cordPaint,
    );
    canvas.drawCircle(_p(size, 0.67, 0.47), size.width * 0.034, tasselPaint);

    // --- Cart basket (open trapezoid outline) ---
    final basketPaint = Paint()
      ..color = markColor
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final topL = _p(size, 0.22, 0.58);
    final topR = _p(size, 0.78, 0.58);
    final botL = _p(size, 0.32, 0.86);
    final botR = _p(size, 0.68, 0.86);

    final basket = Path()
      ..moveTo(botL.dx, botL.dy)
      ..lineTo(topL.dx, topL.dy)
      ..lineTo(topR.dx, topR.dy)
      ..lineTo(botR.dx, botR.dy);
    canvas.drawPath(basket, basketPaint);

    // handle
    canvas.drawLine(topL, _p(size, 0.12, 0.46), basketPaint);

    // wheels
    final wheelPaint = Paint()
      ..color = markColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(_p(size, 0.40, 0.955), size.width * 0.04, wheelPaint);
    canvas.drawCircle(_p(size, 0.60, 0.955), size.width * 0.04, wheelPaint);
  }

  @override
  bool shouldRepaint(covariant _AppLogoPainter oldDelegate) {
    return oldDelegate.markColor != markColor || oldDelegate.tasselColor != tasselColor;
  }
}