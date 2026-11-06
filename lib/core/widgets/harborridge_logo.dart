import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';

class HarborridgeLogo extends StatelessWidget {
  const HarborridgeLogo({
    super.key,
    this.isCompact = false,
    this.inverted = false,
  });

  final bool isCompact;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleColor = inverted ? const Color(0xFFE5B54B) : colors.harborNavy;
    final subtitleColor = colors.freshSkyBlue;

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 82.0,
            height: 48.0,
            child: CustomPaint(
              painter: _HarborridgeBasketPainter(
                basketColor: colors.freshSkyBlue,
                navyColor: inverted ? Colors.white : colors.harborNavy,
                isInverted: inverted,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'HARBORRIDGE',
              style: GoogleFonts.lexend(
                fontSize: 16.0,
                fontWeight: FontWeight.w900,
                color: titleColor,
                letterSpacing: 0.8,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 2.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 14.0, height: 1.6, color: subtitleColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  'LAUNDRY SERVICE',
                  style: GoogleFonts.lexend(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: subtitleColor,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              Container(width: 14.0, height: 1.6, color: subtitleColor),
            ],
          ),
          const SizedBox(height: 5.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
            decoration: BoxDecoration(
              color: inverted ? Colors.white : colors.harborNavy,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              'FRESH, FOLDED, DELIVERED',
              style: GoogleFonts.lexend(
                fontSize: 6.8,
                fontWeight: FontWeight.w800,
                color: inverted ? colors.harborNavy : Colors.white,
                letterSpacing: 0.45,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 112.0,
          height: 64.0,
          child: CustomPaint(
            painter: _HarborridgeBasketPainter(
              basketColor: colors.freshSkyBlue,
              navyColor: inverted ? Colors.white : colors.harborNavy,
              isInverted: inverted,
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          'HARBORRIDGE',
          style: GoogleFonts.lexend(
            fontSize: 22.0,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: 1.1,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 3.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 22.0, height: 2.0, color: subtitleColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                'LAUNDRY SERVICE',
                style: GoogleFonts.lexend(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w800,
                  color: subtitleColor,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            Container(width: 22.0, height: 2.0, color: subtitleColor),
          ],
        ),
        const SizedBox(height: 6.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.5),
          decoration: BoxDecoration(
            color: inverted ? Colors.white : colors.harborNavy,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            'FRESH, FOLDED, DELIVERED',
            style: GoogleFonts.lexend(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: inverted ? colors.harborNavy : Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _HarborridgeBasketPainter extends CustomPainter {
  const _HarborridgeBasketPainter({
    required this.basketColor,
    required this.navyColor,
    required this.isInverted,
  });

  final Color basketColor;
  final Color navyColor;
  final bool isInverted;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final skyPaint = Paint()
      ..color = basketColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final accentPaint = Paint()
      ..color = navyColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final clothTop = Path()
      ..moveTo(w * 0.28, h * 0.36)
      ..quadraticBezierTo(w * 0.36, h * 0.12, w * 0.56, h * 0.14)
      ..quadraticBezierTo(w * 0.70, h * 0.15, w * 0.72, h * 0.36)
      ..close();
    canvas.drawPath(clothTop, isInverted ? whitePaint : accentPaint);

    final clothFold = Path()
      ..moveTo(w * 0.25, h * 0.38)
      ..quadraticBezierTo(w * 0.44, h * 0.24, w * 0.60, h * 0.28)
      ..quadraticBezierTo(w * 0.72, h * 0.30, w * 0.75, h * 0.39)
      ..close();
    canvas.drawPath(clothFold, skyPaint);

    final rim = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.37, w * 0.64, h * 0.11),
      Radius.circular(h * 0.06),
    );
    canvas.drawRRect(rim, skyPaint);

    final body = Path()
      ..moveTo(w * 0.23, h * 0.46)
      ..lineTo(w * 0.77, h * 0.46)
      ..lineTo(w * 0.69, h * 0.80)
      ..quadraticBezierTo(w * 0.50, h * 0.85, w * 0.31, h * 0.80)
      ..close();
    canvas.drawPath(body, skyPaint);

    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 4; col++) {
        final slotX = w * (0.31 + col * 0.105);
        final slotY = h * (0.53 + row * 0.11);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(slotX, slotY, w * 0.06, h * 0.065),
            const Radius.circular(2.0),
          ),
          whitePaint,
        );
      }
    }

    final wave = Path()
      ..moveTo(w * 0.12, h * 0.76)
      ..quadraticBezierTo(w * 0.38, h * 0.96, w * 0.64, h * 0.82)
      ..quadraticBezierTo(w * 0.78, h * 0.74, w * 0.90, h * 0.86)
      ..quadraticBezierTo(w * 0.76, h * 0.82, w * 0.62, h * 0.89)
      ..quadraticBezierTo(w * 0.36, h * 1.02, w * 0.12, h * 0.76)
      ..close();
    canvas.drawPath(wave, accentPaint);

    canvas.drawCircle(Offset(w * 0.13, h * 0.56), w * 0.042, accentPaint);
    canvas.drawCircle(Offset(w * 0.08, h * 0.67), w * 0.024, accentPaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.53), w * 0.048, accentPaint);
    canvas.drawCircle(Offset(w * 0.89, h * 0.66), w * 0.025, accentPaint);

    final starCx = w * 0.81;
    final starCy = h * 0.24;
    final starR = w * 0.065;
    final star = Path()
      ..moveTo(starCx, starCy - starR)
      ..quadraticBezierTo(starCx, starCy, starCx + starR, starCy)
      ..quadraticBezierTo(starCx, starCy, starCx, starCy + starR)
      ..quadraticBezierTo(starCx, starCy, starCx - starR, starCy)
      ..quadraticBezierTo(starCx, starCy, starCx, starCy - starR)
      ..close();
    canvas.drawPath(star, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _HarborridgeBasketPainter oldDelegate) {
    return oldDelegate.basketColor != basketColor ||
        oldDelegate.navyColor != navyColor ||
        oldDelegate.isInverted != isInverted;
  }
}
