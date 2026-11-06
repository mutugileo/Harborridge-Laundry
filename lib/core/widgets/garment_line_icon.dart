import 'dart:math' as math;

import 'package:flutter/material.dart';

enum GarmentType {
  halterTop,
  tanBlazer,
  womensTop,
  denimShorts,
  babyClothes,
  womensDress,
  trousers,
  winterGloves,
  bowTie,
  scarfOnHanger,
  leatherJacket,
  shirtDress,
  camisoleDress,
  stripedTee,
  jeans,
  fedoraHat,
  hoodie,
  blueSuitJacket,
  shirt,
  denimJacket,
  wrapSkirt,
  underGarments,
}

extension GarmentTypeMetadata on GarmentType {
  String get displayName {
    switch (this) {
      case GarmentType.halterTop:
        return 'Pleated Halter Top';
      case GarmentType.tanBlazer:
        return 'Tailored Blazer';
      case GarmentType.womensTop:
        return 'Womens Top';
      case GarmentType.denimShorts:
        return 'Denim Shorts';
      case GarmentType.babyClothes:
        return 'Baby Cloths';
      case GarmentType.womensDress:
        return 'Womens Dress';
      case GarmentType.trousers:
        return 'Tailored Trousers';
      case GarmentType.winterGloves:
        return 'Winter Gloves';
      case GarmentType.bowTie:
        return 'Silk Bow Tie';
      case GarmentType.scarfOnHanger:
        return 'Cashmere Scarf';
      case GarmentType.leatherJacket:
        return 'Biker Jacket';
      case GarmentType.shirtDress:
        return 'Pocket Shirt Dress';
      case GarmentType.camisoleDress:
        return 'Summer Sundress';
      case GarmentType.stripedTee:
        return 'Striped T-Shirt';
      case GarmentType.jeans:
        return 'Jeans';
      case GarmentType.fedoraHat:
        return 'Fedora Hat';
      case GarmentType.hoodie:
        return 'Pullover Hoodie';
      case GarmentType.blueSuitJacket:
        return 'Suit Jacket';
      case GarmentType.shirt:
        return 'Shirt';
      case GarmentType.denimJacket:
        return 'Denim Jacket';
      case GarmentType.wrapSkirt:
        return 'Wrap Skirt';
      case GarmentType.underGarments:
        return 'Under Garments';
    }
  }

  String get defaultServiceType {
    switch (this) {
      case GarmentType.tanBlazer:
      case GarmentType.womensDress:
      case GarmentType.scarfOnHanger:
      case GarmentType.leatherJacket:
      case GarmentType.fedoraHat:
      case GarmentType.blueSuitJacket:
      case GarmentType.wrapSkirt:
        return '[Dry Cleaning]';
      case GarmentType.babyClothes:
      case GarmentType.winterGloves:
      case GarmentType.bowTie:
        return '[Wet Wash]';
      case GarmentType.denimShorts:
      case GarmentType.stripedTee:
      case GarmentType.hoodie:
      case GarmentType.underGarments:
        return '[Wash & Fold]';
      case GarmentType.halterTop:
      case GarmentType.womensTop:
      case GarmentType.trousers:
      case GarmentType.shirtDress:
      case GarmentType.camisoleDress:
      case GarmentType.jeans:
      case GarmentType.shirt:
      case GarmentType.denimJacket:
        return '[Wash & Iron]';
    }
  }

  double get defaultRate {
    switch (this) {
      case GarmentType.halterTop:
        return 22.00;
      case GarmentType.tanBlazer:
        return 85.00;
      case GarmentType.womensTop:
        return 25.00;
      case GarmentType.denimShorts:
        return 18.00;
      case GarmentType.babyClothes:
        return 10.00;
      case GarmentType.womensDress:
        return 100.00;
      case GarmentType.trousers:
        return 40.00;
      case GarmentType.winterGloves:
        return 15.00;
      case GarmentType.bowTie:
        return 12.00;
      case GarmentType.scarfOnHanger:
        return 28.00;
      case GarmentType.leatherJacket:
        return 110.00;
      case GarmentType.shirtDress:
        return 65.00;
      case GarmentType.camisoleDress:
        return 55.00;
      case GarmentType.stripedTee:
        return 20.00;
      case GarmentType.jeans:
        return 60.00;
      case GarmentType.fedoraHat:
        return 30.00;
      case GarmentType.hoodie:
        return 38.00;
      case GarmentType.blueSuitJacket:
        return 80.00;
      case GarmentType.shirt:
        return 45.00;
      case GarmentType.denimJacket:
        return 50.00;
      case GarmentType.wrapSkirt:
        return 42.00;
      case GarmentType.underGarments:
        return 20.00;
    }
  }
}

class GarmentLineIcon extends StatelessWidget {
  const GarmentLineIcon({
    super.key,
    required this.type,
    this.size = 44.0,
    this.color = const Color(0xFF332E2E),
  });

  final GarmentType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GarmentIllustrationPainter(type: type, outlineColor: color),
      ),
    );
  }
}

class _GarmentIllustrationPainter extends CustomPainter {
  const _GarmentIllustrationPainter({
    required this.type,
    required this.outlineColor,
  });

  final GarmentType type;
  final Color outlineColor;

  static const Color _tan = Color(0xFFC5B39B);
  static const Color _tanDark = Color(0xFFB39E82);
  static const Color _terracotta = Color(0xFFC85A43);
  static const Color _coral = Color(0xFFE08272);
  static const Color _salmon = Color(0xFFE59183);
  static const Color _denimBlue = Color(0xFF8EB3CE);
  static const Color _lightBlue = Color(0xFFA8C6DC);
  static const Color _iceBlue = Color(0xFFC8DFEE);
  static const Color _steelBlue = Color(0xFF7FA6C4);
  static const Color _mustard = Color(0xFFE8D07A);
  static const Color _gold = Color(0xFFE2B447);
  static const Color _slatePurple = Color(0xFF7D6E83);
  static const Color _taupePurple = Color(0xFF9C8994);
  static const Color _mint = Color(0xFFBFE3D8);
  static const Color _sageTeal = Color(0xFF84B59F);

  Paint _fill(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  Paint _stroke(double width) => Paint()
    ..color = outlineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  void _fillAndStroke(Canvas canvas, Path path, Color fillColor, Paint stroke) {
    canvas.drawPath(path, _fill(fillColor));
    canvas.drawPath(path, stroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = _stroke((w * 0.032).clamp(1.15, 1.85));

    switch (type) {
      case GarmentType.halterTop:
        _drawHalterTop(canvas, w, h, stroke);
      case GarmentType.tanBlazer:
        _drawTanBlazer(canvas, w, h, stroke);
      case GarmentType.womensTop:
        _drawPatternedBlouse(canvas, w, h, stroke);
      case GarmentType.denimShorts:
        _drawDenimShorts(canvas, w, h, stroke);
      case GarmentType.babyClothes:
        _drawGraphicTee(canvas, w, h, stroke);
      case GarmentType.womensDress:
        _drawSheathDress(canvas, w, h, stroke);
      case GarmentType.trousers:
        _drawTrousers(canvas, w, h, stroke);
      case GarmentType.winterGloves:
        _drawWinterGloves(canvas, w, h, stroke);
      case GarmentType.bowTie:
        _drawBowTie(canvas, w, h, stroke);
      case GarmentType.scarfOnHanger:
        _drawScarfOnHanger(canvas, w, h, stroke);
      case GarmentType.leatherJacket:
        _drawLeatherJacket(canvas, w, h, stroke);
      case GarmentType.shirtDress:
        _drawShirtDress(canvas, w, h, stroke);
      case GarmentType.camisoleDress:
        _drawCamisoleDress(canvas, w, h, stroke);
      case GarmentType.stripedTee:
        _drawStripedTee(canvas, w, h, stroke);
      case GarmentType.jeans:
        _drawRippedJeans(canvas, w, h, stroke);
      case GarmentType.fedoraHat:
        _drawFedoraHat(canvas, w, h, stroke);
      case GarmentType.hoodie:
        _drawHoodie(canvas, w, h, stroke);
      case GarmentType.blueSuitJacket:
        _drawBlueSuitJacket(canvas, w, h, stroke);
      case GarmentType.shirt:
        _drawDressShirt(canvas, w, h, stroke);
      case GarmentType.denimJacket:
        _drawDenimJacket(canvas, w, h, stroke);
      case GarmentType.wrapSkirt:
        _drawWrapSkirt(canvas, w, h, stroke);
      case GarmentType.underGarments:
        _drawUnderGarments(canvas, w, h, stroke);
    }
  }

  void _drawHalterTop(Canvas canvas, double w, double h, Paint stroke) {
    final straps = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.50, h * 0.28)
      ..lineTo(w * 0.64, h * 0.12)
      ..lineTo(w * 0.69, h * 0.28)
      ..lineTo(w * 0.31, h * 0.28)
      ..close();
    _fillAndStroke(canvas, straps, _tanDark, stroke);

    final bodice = Path()
      ..moveTo(w * 0.31, h * 0.26)
      ..quadraticBezierTo(w * 0.50, h * 0.32, w * 0.69, h * 0.26)
      ..lineTo(w * 0.67, h * 0.39)
      ..lineTo(w * 0.33, h * 0.39)
      ..close();
    _fillAndStroke(canvas, bodice, _tan, stroke);

    final skirt = Path()
      ..moveTo(w * 0.33, h * 0.39)
      ..lineTo(w * 0.67, h * 0.39)
      ..lineTo(w * 0.75, h * 0.86)
      ..quadraticBezierTo(w * 0.50, h * 0.90, w * 0.25, h * 0.86)
      ..close();
    _fillAndStroke(canvas, skirt, _tan, stroke);

    for (final x in [0.39, 0.46, 0.54, 0.61]) {
      canvas.drawLine(
        Offset(w * x, h * 0.39),
        Offset(w * (x + (x - 0.50) * 0.28), h * 0.86),
        stroke,
      );
    }
  }

  void _drawTanBlazer(Canvas canvas, double w, double h, Paint stroke) {
    final innerNeck = Path()
      ..moveTo(w * 0.40, h * 0.13)
      ..lineTo(w * 0.60, h * 0.13)
      ..lineTo(w * 0.50, h * 0.54)
      ..close();
    _fillAndStroke(canvas, innerNeck, _taupePurple, stroke);

    final body = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.20, h * 0.20)
      ..lineTo(w * 0.16, h * 0.84)
      ..lineTo(w * 0.28, h * 0.84)
      ..lineTo(w * 0.30, h * 0.38)
      ..lineTo(w * 0.30, h * 0.86)
      ..lineTo(w * 0.70, h * 0.86)
      ..lineTo(w * 0.70, h * 0.38)
      ..lineTo(w * 0.72, h * 0.84)
      ..lineTo(w * 0.84, h * 0.84)
      ..lineTo(w * 0.80, h * 0.20)
      ..lineTo(w * 0.64, h * 0.12)
      ..lineTo(w * 0.50, h * 0.54)
      ..close();
    _fillAndStroke(canvas, body, _tan, stroke);

    final lapels = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.32, h * 0.32)
      ..lineTo(w * 0.50, h * 0.54)
      ..lineTo(w * 0.68, h * 0.32)
      ..lineTo(w * 0.64, h * 0.12);
    canvas.drawPath(lapels, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.54),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.60), w * 0.015, stroke);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.33, h * 0.68, w * 0.11, h * 0.05),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.56, h * 0.68, w * 0.11, h * 0.05),
      stroke,
    );
  }

  void _drawPatternedBlouse(Canvas canvas, double w, double h, Paint stroke) {
    final body = Path()
      ..moveTo(w * 0.38, h * 0.13)
      ..lineTo(w * 0.62, h * 0.13)
      ..lineTo(w * 0.80, h * 0.24)
      ..lineTo(w * 0.72, h * 0.38)
      ..lineTo(w * 0.66, h * 0.33)
      ..lineTo(w * 0.68, h * 0.78)
      ..lineTo(w * 0.70, h * 0.86)
      ..lineTo(w * 0.30, h * 0.86)
      ..lineTo(w * 0.32, h * 0.78)
      ..lineTo(w * 0.34, h * 0.33)
      ..lineTo(w * 0.28, h * 0.38)
      ..lineTo(w * 0.20, h * 0.24)
      ..close();
    _fillAndStroke(canvas, body, _coral, stroke);

    final sidePanels = Path()
      ..moveTo(w * 0.34, h * 0.33)
      ..lineTo(w * 0.42, h * 0.22)
      ..lineTo(w * 0.42, h * 0.78)
      ..lineTo(w * 0.32, h * 0.78)
      ..close()
      ..moveTo(w * 0.66, h * 0.33)
      ..lineTo(w * 0.58, h * 0.22)
      ..lineTo(w * 0.58, h * 0.78)
      ..lineTo(w * 0.68, h * 0.78)
      ..close();
    _fillAndStroke(canvas, sidePanels, _tan, stroke);

    canvas.drawLine(
      Offset(w * 0.32, h * 0.78),
      Offset(w * 0.68, h * 0.78),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.16),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );

    final waveLeft = Path()
      ..moveTo(w * 0.45, h * 0.22)
      ..quadraticBezierTo(w * 0.41, h * 0.34, w * 0.46, h * 0.46)
      ..quadraticBezierTo(w * 0.49, h * 0.58, w * 0.44, h * 0.74);
    final waveRight = Path()
      ..moveTo(w * 0.55, h * 0.22)
      ..quadraticBezierTo(w * 0.59, h * 0.34, w * 0.54, h * 0.46)
      ..quadraticBezierTo(w * 0.51, h * 0.58, w * 0.56, h * 0.74);
    canvas.drawPath(waveLeft, stroke);
    canvas.drawPath(waveRight, stroke);
  }

  void _drawDenimShorts(Canvas canvas, double w, double h, Paint stroke) {
    final shorts = Path()
      ..moveTo(w * 0.24, h * 0.28)
      ..lineTo(w * 0.76, h * 0.28)
      ..lineTo(w * 0.82, h * 0.68)
      ..lineTo(w * 0.53, h * 0.68)
      ..lineTo(w * 0.50, h * 0.54)
      ..lineTo(w * 0.47, h * 0.68)
      ..lineTo(w * 0.18, h * 0.68)
      ..close();
    _fillAndStroke(canvas, shorts, _denimBlue, stroke);

    canvas.drawLine(
      Offset(w * 0.23, h * 0.36),
      Offset(w * 0.77, h * 0.36),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.36),
      Offset(w * 0.50, h * 0.54),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.32), w * 0.015, stroke);

    final leftPocket = Path()
      ..moveTo(w * 0.23, h * 0.43)
      ..quadraticBezierTo(w * 0.33, h * 0.44, w * 0.36, h * 0.36);
    final rightPocket = Path()
      ..moveTo(w * 0.77, h * 0.43)
      ..quadraticBezierTo(w * 0.67, h * 0.44, w * 0.64, h * 0.36);
    canvas.drawPath(leftPocket, stroke);
    canvas.drawPath(rightPocket, stroke);
  }

  void _drawGraphicTee(Canvas canvas, double w, double h, Paint stroke) {
    final tee = Path()
      ..moveTo(w * 0.35, h * 0.13)
      ..quadraticBezierTo(w * 0.50, h * 0.22, w * 0.65, h * 0.13)
      ..lineTo(w * 0.88, h * 0.29)
      ..lineTo(w * 0.76, h * 0.44)
      ..lineTo(w * 0.68, h * 0.37)
      ..lineTo(w * 0.68, h * 0.86)
      ..lineTo(w * 0.32, h * 0.86)
      ..lineTo(w * 0.32, h * 0.37)
      ..lineTo(w * 0.24, h * 0.44)
      ..lineTo(w * 0.12, h * 0.29)
      ..close();
    _fillAndStroke(canvas, tee, _mustard, stroke);

    final neckRing = Path()
      ..moveTo(w * 0.38, h * 0.15)
      ..quadraticBezierTo(w * 0.50, h * 0.26, w * 0.62, h * 0.15);
    canvas.drawPath(neckRing, stroke);

    final triangle = Path()
      ..moveTo(w * 0.50, h * 0.33)
      ..lineTo(w * 0.63, h * 0.64)
      ..lineTo(w * 0.37, h * 0.64)
      ..close();
    _fillAndStroke(canvas, triangle, _coral, stroke);

    canvas.drawCircle(
      Offset(w * 0.50, h * 0.53),
      w * 0.10,
      _fill(_slatePurple),
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.53), w * 0.10, stroke);
  }

  void _drawSheathDress(Canvas canvas, double w, double h, Paint stroke) {
    final dress = Path()
      ..moveTo(w * 0.36, h * 0.13)
      ..lineTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.64, h * 0.13)
      ..lineTo(w * 0.74, h * 0.20)
      ..lineTo(w * 0.67, h * 0.31)
      ..lineTo(w * 0.61, h * 0.42)
      ..quadraticBezierTo(w * 0.70, h * 0.56, w * 0.66, h * 0.86)
      ..quadraticBezierTo(w * 0.50, h * 0.89, w * 0.34, h * 0.86)
      ..quadraticBezierTo(w * 0.30, h * 0.56, w * 0.39, h * 0.42)
      ..lineTo(w * 0.33, h * 0.31)
      ..lineTo(w * 0.26, h * 0.20)
      ..close();
    _fillAndStroke(canvas, dress, _terracotta, stroke);

    canvas.drawLine(
      Offset(w * 0.39, h * 0.42),
      Offset(w * 0.61, h * 0.42),
      stroke,
    );
  }

  void _drawTrousers(Canvas canvas, double w, double h, Paint stroke) {
    final pants = Path()
      ..moveTo(w * 0.33, h * 0.12)
      ..lineTo(w * 0.67, h * 0.12)
      ..lineTo(w * 0.70, h * 0.36)
      ..lineTo(w * 0.65, h * 0.88)
      ..lineTo(w * 0.53, h * 0.88)
      ..lineTo(w * 0.50, h * 0.38)
      ..lineTo(w * 0.47, h * 0.88)
      ..lineTo(w * 0.35, h * 0.88)
      ..lineTo(w * 0.30, h * 0.36)
      ..close();
    _fillAndStroke(canvas, pants, _tan, stroke);

    canvas.drawLine(
      Offset(w * 0.33, h * 0.18),
      Offset(w * 0.67, h * 0.18),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.18),
      Offset(w * 0.50, h * 0.38),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.41, h * 0.24),
      Offset(w * 0.41, h * 0.88),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.59, h * 0.24),
      Offset(w * 0.59, h * 0.88),
      stroke,
    );
  }

  void _drawSingleGlove(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    Paint stroke,
  ) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    final body = Path()
      ..moveTo(-12, 12)
      ..lineTo(-14, -4)
      ..lineTo(-22, -10)
      ..quadraticBezierTo(-24, -15, -18, -14)
      ..lineTo(-12, -8)
      ..lineTo(-12, -26)
      ..quadraticBezierTo(-9, -30, -6, -26)
      ..lineTo(-6, -14)
      ..lineTo(-4, -30)
      ..quadraticBezierTo(-1, -34, 2, -30)
      ..lineTo(2, -14)
      ..lineTo(4, -27)
      ..quadraticBezierTo(7, -31, 10, -27)
      ..lineTo(10, -12)
      ..lineTo(12, -21)
      ..quadraticBezierTo(15, -24, 17, -20)
      ..lineTo(14, 12)
      ..close();
    _fillAndStroke(canvas, body, _slatePurple, stroke);

    final cuff = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-11, 12, 24, 14),
      const Radius.circular(2),
    );
    canvas.drawRRect(cuff, _fill(_coral));
    canvas.drawRRect(cuff, stroke);
    canvas.drawLine(const Offset(-3, 12), const Offset(-3, 26), stroke);
    canvas.drawLine(const Offset(5, 12), const Offset(5, 26), stroke);
    canvas.restore();
  }

  void _drawWinterGloves(Canvas canvas, double w, double h, Paint stroke) {
    final s = w / 95.0;
    _drawSingleGlove(canvas, w * 0.34, h * 0.50, s, stroke);
    _drawSingleGlove(canvas, w * 0.67, h * 0.60, s, stroke);
  }

  void _drawBowTie(Canvas canvas, double w, double h, Paint stroke) {
    final strap = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.45, w * 0.72, h * 0.10),
      const Radius.circular(2),
    );
    canvas.drawRRect(strap, _fill(_tan));
    canvas.drawRRect(strap, stroke);

    final leftWing = Path()
      ..moveTo(w * 0.45, h * 0.44)
      ..lineTo(w * 0.25, h * 0.34)
      ..quadraticBezierTo(w * 0.22, h * 0.50, w * 0.25, h * 0.66)
      ..lineTo(w * 0.45, h * 0.56)
      ..close();
    _fillAndStroke(canvas, leftWing, _gold, stroke);

    final rightWing = Path()
      ..moveTo(w * 0.55, h * 0.44)
      ..lineTo(w * 0.75, h * 0.34)
      ..quadraticBezierTo(w * 0.78, h * 0.50, w * 0.75, h * 0.66)
      ..lineTo(w * 0.55, h * 0.56)
      ..close();
    _fillAndStroke(canvas, rightWing, _gold, stroke);

    final knot = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.41, w * 0.12, h * 0.18),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(knot, _fill(_gold));
    canvas.drawRRect(knot, stroke);
  }

  void _drawScarfOnHanger(Canvas canvas, double w, double h, Paint stroke) {
    final hook = Path()
      ..moveTo(w * 0.47, h * 0.16)
      ..quadraticBezierTo(w * 0.53, h * 0.11, w * 0.55, h * 0.18)
      ..quadraticBezierTo(w * 0.55, h * 0.23, w * 0.50, h * 0.25)
      ..lineTo(w * 0.50, h * 0.29);
    canvas.drawPath(hook, stroke);

    final hanger = Path()
      ..moveTo(w * 0.50, h * 0.28)
      ..lineTo(w * 0.80, h * 0.42)
      ..lineTo(w * 0.20, h * 0.42)
      ..close();
    _fillAndStroke(canvas, hanger, _coral, stroke);

    final scarfLeft = Rect.fromLTWH(w * 0.33, h * 0.42, w * 0.17, h * 0.38);
    canvas.drawRect(scarfLeft, _fill(_denimBlue));
    canvas.drawRect(scarfLeft, stroke);

    final scarfRight = Rect.fromLTWH(w * 0.50, h * 0.42, w * 0.17, h * 0.32);
    canvas.drawRect(scarfRight, _fill(_sageTeal));
    canvas.drawRect(scarfRight, stroke);

    final stripe = Path()
      ..moveTo(w * 0.33, h * 0.52)
      ..lineTo(w * 0.50, h * 0.44)
      ..lineTo(w * 0.50, h * 0.54)
      ..lineTo(w * 0.33, h * 0.62)
      ..close();
    _fillAndStroke(canvas, stripe, _slatePurple, stroke);

    for (var i = 0; i < 5; i++) {
      final lx = w * (0.35 + i * 0.032);
      canvas.drawLine(Offset(lx, h * 0.80), Offset(lx, h * 0.87), stroke);
      final rx = w * (0.52 + i * 0.032);
      canvas.drawLine(Offset(rx, h * 0.74), Offset(rx, h * 0.81), stroke);
    }
  }

  void _drawLeatherJacket(Canvas canvas, double w, double h, Paint stroke) {
    final jacket = Path()
      ..moveTo(w * 0.36, h * 0.14)
      ..lineTo(w * 0.64, h * 0.14)
      ..lineTo(w * 0.79, h * 0.26)
      ..lineTo(w * 0.86, h * 0.82)
      ..lineTo(w * 0.74, h * 0.82)
      ..lineTo(w * 0.70, h * 0.42)
      ..lineTo(w * 0.70, h * 0.80)
      ..lineTo(w * 0.30, h * 0.80)
      ..lineTo(w * 0.30, h * 0.42)
      ..lineTo(w * 0.26, h * 0.82)
      ..lineTo(w * 0.14, h * 0.82)
      ..lineTo(w * 0.21, h * 0.26)
      ..close();
    _fillAndStroke(canvas, jacket, _tanDark, stroke);

    final lapels = Path()
      ..moveTo(w * 0.36, h * 0.14)
      ..lineTo(w * 0.30, h * 0.36)
      ..lineTo(w * 0.48, h * 0.46)
      ..lineTo(w * 0.68, h * 0.34)
      ..lineTo(w * 0.64, h * 0.14);
    canvas.drawPath(lapels, stroke);

    canvas.drawLine(
      Offset(w * 0.48, h * 0.46),
      Offset(w * 0.44, h * 0.80),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.30, h * 0.74),
      Offset(w * 0.70, h * 0.74),
      stroke,
    );
  }

  void _drawShirtDress(Canvas canvas, double w, double h, Paint stroke) {
    final dress = Path()
      ..moveTo(w * 0.38, h * 0.13)
      ..lineTo(w * 0.62, h * 0.13)
      ..lineTo(w * 0.78, h * 0.24)
      ..lineTo(w * 0.71, h * 0.36)
      ..lineTo(w * 0.65, h * 0.32)
      ..lineTo(w * 0.68, h * 0.86)
      ..lineTo(w * 0.32, h * 0.86)
      ..lineTo(w * 0.35, h * 0.32)
      ..lineTo(w * 0.29, h * 0.36)
      ..lineTo(w * 0.22, h * 0.24)
      ..close();
    _fillAndStroke(canvas, dress, _denimBlue, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.18),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.32, w * 0.08, h * 0.09),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.54, h * 0.32, w * 0.08, h * 0.09),
      stroke,
    );
  }

  void _drawCamisoleDress(Canvas canvas, double w, double h, Paint stroke) {
    canvas.drawLine(
      Offset(w * 0.39, h * 0.13),
      Offset(w * 0.39, h * 0.27),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.61, h * 0.13),
      Offset(w * 0.61, h * 0.27),
      stroke,
    );

    final dress = Path()
      ..moveTo(w * 0.36, h * 0.25)
      ..quadraticBezierTo(w * 0.44, h * 0.22, w * 0.50, h * 0.29)
      ..quadraticBezierTo(w * 0.56, h * 0.22, w * 0.64, h * 0.25)
      ..lineTo(w * 0.61, h * 0.44)
      ..lineTo(w * 0.76, h * 0.83)
      ..quadraticBezierTo(w * 0.66, h * 0.89, w * 0.58, h * 0.84)
      ..quadraticBezierTo(w * 0.50, h * 0.89, w * 0.42, h * 0.84)
      ..quadraticBezierTo(w * 0.34, h * 0.89, w * 0.24, h * 0.83)
      ..lineTo(w * 0.39, h * 0.44)
      ..close();
    _fillAndStroke(canvas, dress, _salmon, stroke);

    canvas.drawLine(
      Offset(w * 0.39, h * 0.44),
      Offset(w * 0.61, h * 0.44),
      stroke,
    );
  }

  void _drawStripedTee(Canvas canvas, double w, double h, Paint stroke) {
    final tee = Path()
      ..moveTo(w * 0.35, h * 0.14)
      ..lineTo(w * 0.50, h * 0.25)
      ..lineTo(w * 0.65, h * 0.14)
      ..lineTo(w * 0.88, h * 0.29)
      ..lineTo(w * 0.77, h * 0.43)
      ..lineTo(w * 0.69, h * 0.37)
      ..lineTo(w * 0.69, h * 0.86)
      ..lineTo(w * 0.31, h * 0.86)
      ..lineTo(w * 0.31, h * 0.37)
      ..lineTo(w * 0.23, h * 0.43)
      ..lineTo(w * 0.12, h * 0.29)
      ..close();
    _fillAndStroke(canvas, tee, _denimBlue, stroke);

    canvas.save();
    canvas.clipPath(tee);
    for (final y in [0.34, 0.54, 0.74]) {
      final band = Rect.fromLTWH(w * 0.10, h * y, w * 0.80, h * 0.10);
      canvas.drawRect(band, _fill(_iceBlue));
      canvas.drawRect(band, stroke);
    }
    canvas.restore();
    canvas.drawPath(tee, stroke);
  }

  void _drawRippedJeans(Canvas canvas, double w, double h, Paint stroke) {
    final pants = Path()
      ..moveTo(w * 0.33, h * 0.12)
      ..lineTo(w * 0.67, h * 0.12)
      ..lineTo(w * 0.69, h * 0.36)
      ..lineTo(w * 0.65, h * 0.88)
      ..lineTo(w * 0.53, h * 0.88)
      ..lineTo(w * 0.50, h * 0.38)
      ..lineTo(w * 0.47, h * 0.88)
      ..lineTo(w * 0.35, h * 0.88)
      ..lineTo(w * 0.31, h * 0.36)
      ..close();
    _fillAndStroke(canvas, pants, _denimBlue, stroke);

    canvas.drawLine(
      Offset(w * 0.33, h * 0.18),
      Offset(w * 0.67, h * 0.18),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.18),
      Offset(w * 0.50, h * 0.36),
      stroke,
    );

    for (final rip in [
      Rect.fromLTWH(w * 0.35, h * 0.44, w * 0.08, h * 0.04),
      Rect.fromLTWH(w * 0.56, h * 0.58, w * 0.08, h * 0.04),
      Rect.fromLTWH(w * 0.36, h * 0.66, w * 0.07, h * 0.04),
    ]) {
      canvas.drawRect(rip, _fill(Colors.white));
      canvas.drawRect(rip, stroke);
    }
  }

  void _drawFedoraHat(Canvas canvas, double w, double h, Paint stroke) {
    final brim = Rect.fromLTWH(w * 0.12, h * 0.54, w * 0.76, h * 0.18);
    canvas.drawOval(brim, _fill(_tanDark));
    canvas.drawOval(brim, stroke);

    final crown = Path()
      ..moveTo(w * 0.27, h * 0.58)
      ..lineTo(w * 0.32, h * 0.32)
      ..quadraticBezierTo(w * 0.40, h * 0.27, w * 0.50, h * 0.33)
      ..quadraticBezierTo(w * 0.60, h * 0.27, w * 0.68, h * 0.32)
      ..lineTo(w * 0.73, h * 0.58)
      ..quadraticBezierTo(w * 0.50, h * 0.64, w * 0.27, h * 0.58)
      ..close();
    _fillAndStroke(canvas, crown, _tan, stroke);

    final band = Path()
      ..moveTo(w * 0.28, h * 0.50)
      ..quadraticBezierTo(w * 0.50, h * 0.55, w * 0.72, h * 0.50)
      ..lineTo(w * 0.73, h * 0.58)
      ..quadraticBezierTo(w * 0.50, h * 0.64, w * 0.27, h * 0.58)
      ..close();
    _fillAndStroke(canvas, band, _denimBlue, stroke);
  }

  void _drawHoodie(Canvas canvas, double w, double h, Paint stroke) {
    final hood = Path()
      ..moveTo(w * 0.35, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.08, w * 0.65, h * 0.22)
      ..close();
    _fillAndStroke(canvas, hood, _terracotta, stroke);

    final body = Path()
      ..moveTo(w * 0.35, h * 0.20)
      ..lineTo(w * 0.65, h * 0.20)
      ..lineTo(w * 0.80, h * 0.32)
      ..lineTo(w * 0.85, h * 0.82)
      ..lineTo(w * 0.73, h * 0.82)
      ..lineTo(w * 0.69, h * 0.42)
      ..lineTo(w * 0.69, h * 0.84)
      ..lineTo(w * 0.31, h * 0.84)
      ..lineTo(w * 0.31, h * 0.42)
      ..lineTo(w * 0.27, h * 0.82)
      ..lineTo(w * 0.15, h * 0.82)
      ..lineTo(w * 0.20, h * 0.32)
      ..close();
    _fillAndStroke(canvas, body, _terracotta, stroke);

    final pocket = Path()
      ..moveTo(w * 0.39, h * 0.58)
      ..lineTo(w * 0.61, h * 0.58)
      ..lineTo(w * 0.65, h * 0.78)
      ..lineTo(w * 0.35, h * 0.78)
      ..close();
    _fillAndStroke(canvas, pocket, _slatePurple, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.22),
      Offset(w * 0.50, h * 0.84),
      stroke,
    );
  }

  void _drawBlueSuitJacket(Canvas canvas, double w, double h, Paint stroke) {
    final jacket = Path()
      ..moveTo(w * 0.36, h * 0.13)
      ..lineTo(w * 0.21, h * 0.22)
      ..lineTo(w * 0.18, h * 0.84)
      ..lineTo(w * 0.29, h * 0.84)
      ..lineTo(w * 0.31, h * 0.40)
      ..lineTo(w * 0.31, h * 0.86)
      ..lineTo(w * 0.69, h * 0.86)
      ..lineTo(w * 0.69, h * 0.40)
      ..lineTo(w * 0.71, h * 0.84)
      ..lineTo(w * 0.82, h * 0.84)
      ..lineTo(w * 0.79, h * 0.22)
      ..lineTo(w * 0.64, h * 0.13)
      ..lineTo(w * 0.50, h * 0.48)
      ..close();
    _fillAndStroke(canvas, jacket, _steelBlue, stroke);

    final lapels = Path()
      ..moveTo(w * 0.36, h * 0.13)
      ..lineTo(w * 0.33, h * 0.33)
      ..lineTo(w * 0.50, h * 0.48)
      ..lineTo(w * 0.67, h * 0.33)
      ..lineTo(w * 0.64, h * 0.13);
    canvas.drawPath(lapels, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.48),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );

    final hanky = Path()
      ..moveTo(w * 0.56, h * 0.38)
      ..lineTo(w * 0.61, h * 0.32)
      ..lineTo(w * 0.65, h * 0.38)
      ..close();
    _fillAndStroke(canvas, hanky, Colors.white, stroke);
  }

  void _drawDressShirt(Canvas canvas, double w, double h, Paint stroke) {
    final shirt = Path()
      ..moveTo(w * 0.36, h * 0.13)
      ..lineTo(w * 0.64, h * 0.13)
      ..lineTo(w * 0.82, h * 0.25)
      ..lineTo(w * 0.86, h * 0.82)
      ..lineTo(w * 0.74, h * 0.82)
      ..lineTo(w * 0.70, h * 0.38)
      ..lineTo(w * 0.70, h * 0.84)
      ..quadraticBezierTo(w * 0.50, h * 0.89, w * 0.30, h * 0.84)
      ..lineTo(w * 0.30, h * 0.38)
      ..lineTo(w * 0.26, h * 0.82)
      ..lineTo(w * 0.14, h * 0.82)
      ..lineTo(w * 0.18, h * 0.25)
      ..close();
    _fillAndStroke(canvas, shirt, _mint, stroke);

    final collar = Path()
      ..moveTo(w * 0.36, h * 0.13)
      ..lineTo(w * 0.44, h * 0.25)
      ..lineTo(w * 0.50, h * 0.19)
      ..lineTo(w * 0.56, h * 0.25)
      ..lineTo(w * 0.64, h * 0.13);
    canvas.drawPath(collar, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.19),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );

    final pocket = Path()
      ..moveTo(w * 0.55, h * 0.34)
      ..lineTo(w * 0.65, h * 0.34)
      ..lineTo(w * 0.65, h * 0.44)
      ..lineTo(w * 0.60, h * 0.47)
      ..lineTo(w * 0.55, h * 0.44)
      ..close();
    canvas.drawPath(pocket, stroke);
  }

  void _drawDenimJacket(Canvas canvas, double w, double h, Paint stroke) {
    final jacket = Path()
      ..moveTo(w * 0.36, h * 0.16)
      ..lineTo(w * 0.64, h * 0.16)
      ..lineTo(w * 0.81, h * 0.28)
      ..lineTo(w * 0.85, h * 0.80)
      ..lineTo(w * 0.73, h * 0.80)
      ..lineTo(w * 0.70, h * 0.40)
      ..lineTo(w * 0.70, h * 0.80)
      ..lineTo(w * 0.30, h * 0.80)
      ..lineTo(w * 0.30, h * 0.40)
      ..lineTo(w * 0.27, h * 0.80)
      ..lineTo(w * 0.15, h * 0.80)
      ..lineTo(w * 0.19, h * 0.28)
      ..close();
    _fillAndStroke(canvas, jacket, _lightBlue, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.22),
      Offset(w * 0.50, h * 0.80),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.30, h * 0.73),
      Offset(w * 0.70, h * 0.73),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.34, h * 0.35, w * 0.11, h * 0.11),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.55, h * 0.35, w * 0.11, h * 0.11),
      stroke,
    );
  }

  void _drawWrapSkirt(Canvas canvas, double w, double h, Paint stroke) {
    final skirt = Path()
      ..moveTo(w * 0.32, h * 0.16)
      ..lineTo(w * 0.68, h * 0.16)
      ..quadraticBezierTo(w * 0.76, h * 0.50, w * 0.64, h * 0.86)
      ..lineTo(w * 0.54, h * 0.86)
      ..lineTo(w * 0.50, h * 0.68)
      ..lineTo(w * 0.46, h * 0.86)
      ..lineTo(w * 0.36, h * 0.86)
      ..quadraticBezierTo(w * 0.24, h * 0.50, w * 0.32, h * 0.16)
      ..close();
    _fillAndStroke(canvas, skirt, _tan, stroke);

    final trim = Path()
      ..moveTo(w * 0.63, h * 0.16)
      ..lineTo(w * 0.68, h * 0.16)
      ..lineTo(w * 0.46, h * 0.86)
      ..lineTo(w * 0.40, h * 0.86)
      ..close();
    _fillAndStroke(canvas, trim, _slatePurple, stroke);

    canvas.drawLine(
      Offset(w * 0.31, h * 0.22),
      Offset(w * 0.69, h * 0.22),
      stroke,
    );
  }

  void _drawUnderGarments(Canvas canvas, double w, double h, Paint stroke) {
    canvas.drawLine(
      Offset(w * 0.30, h * 0.12),
      Offset(w * 0.29, h * 0.32),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.70, h * 0.12),
      Offset(w * 0.71, h * 0.32),
      stroke,
    );

    final bra = Path()
      ..moveTo(w * 0.26, h * 0.32)
      ..quadraticBezierTo(w * 0.38, h * 0.25, w * 0.50, h * 0.37)
      ..quadraticBezierTo(w * 0.62, h * 0.25, w * 0.74, h * 0.32)
      ..quadraticBezierTo(w * 0.76, h * 0.46, w * 0.68, h * 0.48)
      ..quadraticBezierTo(w * 0.50, h * 0.45, w * 0.32, h * 0.48)
      ..quadraticBezierTo(w * 0.24, h * 0.46, w * 0.26, h * 0.32)
      ..close();
    _fillAndStroke(canvas, bra, _terracotta, stroke);

    final brief = Path()
      ..moveTo(w * 0.25, h * 0.64)
      ..quadraticBezierTo(w * 0.50, h * 0.72, w * 0.75, h * 0.64)
      ..lineTo(w * 0.73, h * 0.71)
      ..quadraticBezierTo(w * 0.56, h * 0.76, w * 0.52, h * 0.89)
      ..lineTo(w * 0.48, h * 0.89)
      ..quadraticBezierTo(w * 0.44, h * 0.76, w * 0.27, h * 0.71)
      ..close();
    _fillAndStroke(canvas, brief, _terracotta, stroke);

    final math.Point<double> center = math.Point(w * 0.50, h * 0.40);
    canvas.drawCircle(Offset(center.x, center.y), w * 0.015, stroke);
  }

  @override
  bool shouldRepaint(covariant _GarmentIllustrationPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.outlineColor != outlineColor;
  }
}
