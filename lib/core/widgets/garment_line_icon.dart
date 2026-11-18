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
  generalLaundryLoad,
  curtains,
  tableclothsTowels,
  threePieceSuit,
  kaundaSuit,
  kitengeSuit,
  skirtSuit,
  duvetKingQueen,
  duvetStandard,
  woollenBlanket,
  comfortAndVelvet,
  babyBlanketSheers,
  largeBedCover,
  smallBedCover,
  bedsheets,
  pillowcase,
  dustTrenchBathrobe,
  religiousClothes,
  graduationGown,
  traditionalAttire,
  weddingGown,
  bulkIroning,
}

enum GarmentServiceSection {
  all('All Services'),
  byWeight('Laundry by Weight'),
  dryCleaning('Dry Cleaning'),
  apparelSpecial('Apparel & Special'),
  ironing('Ironing Only'),
  washAndIron('Wash & Iron');

  const GarmentServiceSection(this.label);
  final String label;
}

extension GarmentTypeMetadata on GarmentType {
  bool get isWeightBased =>
      this == GarmentType.generalLaundryLoad ||
      this == GarmentType.curtains ||
      this == GarmentType.tableclothsTowels;

  GarmentServiceSection get serviceSection {
    final clean = defaultServiceType
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim();
    switch (clean) {
      case 'Laundry by Weight':
        return GarmentServiceSection.byWeight;
      case 'Dry Cleaning':
        return GarmentServiceSection.dryCleaning;
      case 'Apparel & Special':
        return GarmentServiceSection.apparelSpecial;
      case 'Ironing Only':
        return GarmentServiceSection.ironing;
      default:
        return GarmentServiceSection.washAndIron;
    }
  }

  String get displayName {
    switch (this) {
      case GarmentType.halterTop:
        return 'Pleated Dress';
      case GarmentType.tanBlazer:
        return 'Coat / Jacket';
      case GarmentType.womensTop:
        return 'Light Jacket';
      case GarmentType.denimShorts:
        return 'Dust Coat';
      case GarmentType.babyClothes:
        return "Kids' Clothes";
      case GarmentType.womensDress:
        return 'Special Dress';
      case GarmentType.trousers:
        return 'Trousers';
      case GarmentType.winterGloves:
        return 'Converse Shoes / Pillows';
      case GarmentType.bowTie:
        return 'Ties';
      case GarmentType.scarfOnHanger:
        return 'Bed Sheet (Ironing)';
      case GarmentType.leatherJacket:
        return 'Leather Jacket';
      case GarmentType.shirtDress:
        return 'Normal Dress';
      case GarmentType.camisoleDress:
        return 'Skirt (Ironing)';
      case GarmentType.stripedTee:
        return 'T-Shirts';
      case GarmentType.jeans:
        return 'Trousers (Ironing)';
      case GarmentType.fedoraHat:
        return 'Sneakers / Caps';
      case GarmentType.hoodie:
        return 'Heavy Jacket / Cardigan';
      case GarmentType.blueSuitJacket:
        return '2-Piece Suit';
      case GarmentType.shirt:
        return 'Normal Shirts';
      case GarmentType.denimJacket:
        return 'Shirts (Ironing)';
      case GarmentType.wrapSkirt:
        return 'Skirts';
      case GarmentType.underGarments:
        return 'Suit (Ironing)';
      case GarmentType.generalLaundryLoad:
        return 'General Laundry (Load)';
      case GarmentType.curtains:
        return 'Curtains';
      case GarmentType.tableclothsTowels:
        return 'Tablecloths / Bulk Towels';
      case GarmentType.threePieceSuit:
        return '3-Piece Suit';
      case GarmentType.kaundaSuit:
        return 'Kaunda Suit';
      case GarmentType.kitengeSuit:
        return 'Kitenge Suit';
      case GarmentType.skirtSuit:
        return 'Skirt Suit';
      case GarmentType.duvetKingQueen:
        return 'Duvet 6×6 / 5×6 / Fluffy Blankets';
      case GarmentType.duvetStandard:
        return 'Duvet 4×6';
      case GarmentType.woollenBlanket:
        return 'Woollen Blanket / Duvet Covers';
      case GarmentType.comfortAndVelvet:
        return 'Comfort and Velvet';
      case GarmentType.babyBlanketSheers:
        return 'Baby Blanket / Sheers';
      case GarmentType.largeBedCover:
        return 'Large Bed Cover';
      case GarmentType.smallBedCover:
        return 'Small Bed Cover';
      case GarmentType.bedsheets:
        return 'Bedsheets';
      case GarmentType.pillowcase:
        return 'Pillowcases';
      case GarmentType.dustTrenchBathrobe:
        return 'Dust / Trench Coat / Bathrobe';
      case GarmentType.religiousClothes:
        return 'Religious Clothes';
      case GarmentType.graduationGown:
        return 'Graduation Gown';
      case GarmentType.traditionalAttire:
        return 'Traditional Attire';
      case GarmentType.weddingGown:
        return 'Wedding Gown';
      case GarmentType.bulkIroning:
        return 'Bulk Ironing';
    }
  }

  String get defaultServiceType {
    switch (this) {
      case GarmentType.tanBlazer:
      case GarmentType.womensDress:
      case GarmentType.leatherJacket:
      case GarmentType.blueSuitJacket:
      case GarmentType.threePieceSuit:
      case GarmentType.kaundaSuit:
      case GarmentType.kitengeSuit:
      case GarmentType.skirtSuit:
      case GarmentType.religiousClothes:
      case GarmentType.graduationGown:
      case GarmentType.traditionalAttire:
      case GarmentType.weddingGown:
        return 'Dry Cleaning';
      case GarmentType.babyClothes:
      case GarmentType.winterGloves:
      case GarmentType.fedoraHat:
      case GarmentType.duvetKingQueen:
      case GarmentType.duvetStandard:
      case GarmentType.woollenBlanket:
      case GarmentType.comfortAndVelvet:
      case GarmentType.babyBlanketSheers:
      case GarmentType.largeBedCover:
      case GarmentType.smallBedCover:
      case GarmentType.bedsheets:
      case GarmentType.pillowcase:
        return 'Apparel & Special';
      case GarmentType.generalLaundryLoad:
      case GarmentType.curtains:
      case GarmentType.tableclothsTowels:
        return 'Laundry by Weight';
      case GarmentType.bowTie:
      case GarmentType.scarfOnHanger:
      case GarmentType.camisoleDress:
      case GarmentType.jeans:
      case GarmentType.denimJacket:
      case GarmentType.underGarments:
      case GarmentType.bulkIroning:
        return 'Ironing Only';
      case GarmentType.halterTop:
      case GarmentType.womensTop:
      case GarmentType.denimShorts:
      case GarmentType.trousers:
      case GarmentType.shirtDress:
      case GarmentType.stripedTee:
      case GarmentType.hoodie:
      case GarmentType.shirt:
      case GarmentType.wrapSkirt:
      case GarmentType.dustTrenchBathrobe:
        return 'Wash & Iron';
    }
  }

  String get unitBasisLabel {
    switch (this) {
      case GarmentType.generalLaundryLoad:
        return '/ kg (Min KES 500)';
      case GarmentType.curtains:
        return '/ kg (Min KES 600)';
      case GarmentType.tableclothsTowels:
        return '/ kg (Min KES 700)';
      case GarmentType.bulkIroning:
        return '/ piece';
      case GarmentType.traditionalAttire:
        return '/ item (KES 1,500–2,500)';
      default:
        return '/ item';
    }
  }

  String get priceDisplayLabel {
    switch (this) {
      case GarmentType.generalLaundryLoad:
      case GarmentType.curtains:
        return 'KES 120/kg';
      case GarmentType.tableclothsTowels:
        return 'KES 150/kg';
      case GarmentType.traditionalAttire:
        return 'KES 1,500–2,500';
      case GarmentType.bulkIroning:
        return 'KES 50/pc';
      default:
        return 'KES ${defaultRate.toStringAsFixed(0)}';
    }
  }

  double get minimumChargeKes {
    switch (this) {
      case GarmentType.generalLaundryLoad:
        return 500.00;
      case GarmentType.curtains:
        return 600.00;
      case GarmentType.tableclothsTowels:
        return 700.00;
      default:
        return 0.00;
    }
  }

  double get defaultRate {
    switch (this) {
      case GarmentType.halterTop:
        return 300.00;
      case GarmentType.tanBlazer:
        return 350.00;
      case GarmentType.womensTop:
        return 300.00;
      case GarmentType.denimShorts:
        return 300.00;
      case GarmentType.babyClothes:
        return 250.00;
      case GarmentType.womensDress:
        return 800.00;
      case GarmentType.trousers:
        return 200.00;
      case GarmentType.winterGloves:
        return 200.00;
      case GarmentType.bowTie:
        return 50.00;
      case GarmentType.scarfOnHanger:
        return 80.00;
      case GarmentType.leatherJacket:
        return 800.00;
      case GarmentType.shirtDress:
        return 400.00;
      case GarmentType.camisoleDress:
        return 100.00;
      case GarmentType.stripedTee:
        return 150.00;
      case GarmentType.jeans:
        return 200.00;
      case GarmentType.fedoraHat:
        return 200.00;
      case GarmentType.hoodie:
        return 400.00;
      case GarmentType.blueSuitJacket:
        return 650.00;
      case GarmentType.shirt:
        return 250.00;
      case GarmentType.denimJacket:
        return 150.00;
      case GarmentType.wrapSkirt:
        return 100.00;
      case GarmentType.underGarments:
        return 400.00;
      case GarmentType.generalLaundryLoad:
        return 120.00;
      case GarmentType.curtains:
        return 120.00;
      case GarmentType.tableclothsTowels:
        return 150.00;
      case GarmentType.threePieceSuit:
        return 700.00;
      case GarmentType.kaundaSuit:
        return 600.00;
      case GarmentType.kitengeSuit:
        return 500.00;
      case GarmentType.skirtSuit:
        return 600.00;
      case GarmentType.duvetKingQueen:
        return 800.00;
      case GarmentType.duvetStandard:
        return 700.00;
      case GarmentType.woollenBlanket:
        return 500.00;
      case GarmentType.comfortAndVelvet:
        return 900.00;
      case GarmentType.babyBlanketSheers:
        return 300.00;
      case GarmentType.largeBedCover:
        return 500.00;
      case GarmentType.smallBedCover:
        return 400.00;
      case GarmentType.bedsheets:
        return 150.00;
      case GarmentType.pillowcase:
        return 100.00;
      case GarmentType.dustTrenchBathrobe:
        return 250.00;
      case GarmentType.religiousClothes:
        return 500.00;
      case GarmentType.graduationGown:
        return 750.00;
      case GarmentType.traditionalAttire:
        return 1500.00;
      case GarmentType.weddingGown:
        return 3800.00;
      case GarmentType.bulkIroning:
        return 50.00;
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
    final stroke = _stroke((w * 0.034).clamp(1.15, 1.85));

    switch (type) {
      case GarmentType.halterTop:
        _drawPleatedDress(canvas, w, h, stroke);
      case GarmentType.tanBlazer:
        _drawTanBlazer(canvas, w, h, stroke);
      case GarmentType.womensTop:
        _drawLightJacket(canvas, w, h, stroke);
      case GarmentType.denimShorts:
        _drawDustCoat(canvas, w, h, stroke);
      case GarmentType.babyClothes:
        _drawKidsOveralls(canvas, w, h, stroke);
      case GarmentType.womensDress:
        _drawSpecialDress(canvas, w, h, stroke);
      case GarmentType.trousers:
        _drawTrousers(canvas, w, h, stroke);
      case GarmentType.winterGloves:
        _drawConverseSneaker(canvas, w, h, stroke);
      case GarmentType.bowTie:
        _drawTies(canvas, w, h, stroke);
      case GarmentType.scarfOnHanger:
        _drawBedSheetIroning(canvas, w, h, stroke);
      case GarmentType.leatherJacket:
        _drawLeatherJacket(canvas, w, h, stroke);
      case GarmentType.shirtDress:
        _drawShirtDress(canvas, w, h, stroke);
      case GarmentType.camisoleDress:
        _drawSkirtIroning(canvas, w, h, stroke);
      case GarmentType.stripedTee:
        _drawGraphicTee(canvas, w, h, stroke);
      case GarmentType.jeans:
        _drawTrousersIroning(canvas, w, h, stroke);
      case GarmentType.fedoraHat:
        _drawSneakersCaps(canvas, w, h, stroke);
      case GarmentType.hoodie:
        _drawHeavyCardigan(canvas, w, h, stroke);
      case GarmentType.blueSuitJacket:
        _drawBlueSuitJacket(canvas, w, h, stroke);
      case GarmentType.shirt:
        _drawDressShirt(canvas, w, h, stroke);
      case GarmentType.denimJacket:
        _drawShirtsIroning(canvas, w, h, stroke);
      case GarmentType.wrapSkirt:
        _drawWrapSkirt(canvas, w, h, stroke);
      case GarmentType.underGarments:
        _drawSuitIroning(canvas, w, h, stroke);
      case GarmentType.generalLaundryLoad:
        _drawGeneralLaundry(canvas, w, h, stroke);
      case GarmentType.curtains:
        _drawCurtains(canvas, w, h, stroke);
      case GarmentType.tableclothsTowels:
        _drawTableclothsTowels(canvas, w, h, stroke);
      case GarmentType.threePieceSuit:
        _drawThreePieceSuit(canvas, w, h, stroke);
      case GarmentType.kaundaSuit:
        _drawKaundaSuit(canvas, w, h, stroke);
      case GarmentType.kitengeSuit:
        _drawKitengeSuit(canvas, w, h, stroke);
      case GarmentType.skirtSuit:
        _drawSkirtSuit(canvas, w, h, stroke);
      case GarmentType.duvetKingQueen:
        _drawDuvetFluffy(canvas, w, h, stroke);
      case GarmentType.duvetStandard:
        _drawDuvetStandard(canvas, w, h, stroke);
      case GarmentType.woollenBlanket:
        _drawWoollenBlanket(canvas, w, h, stroke);
      case GarmentType.comfortAndVelvet:
        _drawComfortVelvet(canvas, w, h, stroke);
      case GarmentType.babyBlanketSheers:
        _drawBabyBlanketSheers(canvas, w, h, stroke);
      case GarmentType.largeBedCover:
        _drawBedCoverLarge(canvas, w, h, stroke);
      case GarmentType.smallBedCover:
        _drawBedCoverSmall(canvas, w, h, stroke);
      case GarmentType.bedsheets:
        _drawBedsheets(canvas, w, h, stroke);
      case GarmentType.pillowcase:
        _drawPillowcase(canvas, w, h, stroke);
      case GarmentType.dustTrenchBathrobe:
        _drawDustTrenchBathrobe(canvas, w, h, stroke);
      case GarmentType.religiousClothes:
        _drawReligiousClothes(canvas, w, h, stroke);
      case GarmentType.graduationGown:
        _drawGraduationGown(canvas, w, h, stroke);
      case GarmentType.traditionalAttire:
        _drawTraditionalAttire(canvas, w, h, stroke);
      case GarmentType.weddingGown:
        _drawWeddingGown(canvas, w, h, stroke);
      case GarmentType.bulkIroning:
        _drawBulkIroning(canvas, w, h, stroke);
    }
  }

  void _drawPleatedDress(Canvas canvas, double w, double h, Paint stroke) {
    final straps = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..lineTo(w * 0.42, h * 0.28)
      ..lineTo(w * 0.58, h * 0.28)
      ..lineTo(w * 0.65, h * 0.12);
    canvas.drawPath(straps, stroke);

    final bodice = Path()
      ..moveTo(w * 0.30, h * 0.28)
      ..quadraticBezierTo(w * 0.50, h * 0.35, w * 0.70, h * 0.28)
      ..lineTo(w * 0.65, h * 0.44)
      ..lineTo(w * 0.35, h * 0.44)
      ..close();
    _fillAndStroke(canvas, bodice, _terracotta, stroke);

    final belt = Path()
      ..moveTo(w * 0.33, h * 0.44)
      ..lineTo(w * 0.67, h * 0.44)
      ..lineTo(w * 0.67, h * 0.49)
      ..lineTo(w * 0.33, h * 0.49)
      ..close();
    _fillAndStroke(canvas, belt, _tanDark, stroke);

    final skirt = Path()
      ..moveTo(w * 0.33, h * 0.49)
      ..lineTo(w * 0.67, h * 0.49)
      ..lineTo(w * 0.82, h * 0.88)
      ..quadraticBezierTo(w * 0.50, h * 0.93, w * 0.18, h * 0.88)
      ..close();
    _fillAndStroke(canvas, skirt, _coral, stroke);

    for (final x in [0.38, 0.44, 0.50, 0.56, 0.62]) {
      final bottomX = 0.50 + (x - 0.50) * 2.3;
      canvas.drawLine(
        Offset(w * x, h * 0.49),
        Offset(w * bottomX, h * 0.89),
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

  void _drawLightJacket(Canvas canvas, double w, double h, Paint stroke) {
    final collar = Path()
      ..moveTo(w * 0.36, h * 0.16)
      ..quadraticBezierTo(w * 0.50, h * 0.22, w * 0.64, h * 0.16)
      ..lineTo(w * 0.61, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.27, w * 0.39, h * 0.22)
      ..close();
    _fillAndStroke(canvas, collar, _salmon, stroke);

    final body = Path()
      ..moveTo(w * 0.36, h * 0.18)
      ..lineTo(w * 0.16, h * 0.32)
      ..lineTo(w * 0.24, h * 0.76)
      ..lineTo(w * 0.32, h * 0.70)
      ..lineTo(w * 0.32, h * 0.82)
      ..lineTo(w * 0.68, h * 0.82)
      ..lineTo(w * 0.68, h * 0.70)
      ..lineTo(w * 0.76, h * 0.76)
      ..lineTo(w * 0.84, h * 0.32)
      ..lineTo(w * 0.64, h * 0.18)
      ..close();
    _fillAndStroke(canvas, body, _coral, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.22),
      Offset(w * 0.50, h * 0.82),
      stroke,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.32),
        width: w * 0.04,
        height: h * 0.05,
      ),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.77),
      Offset(w * 0.68, h * 0.77),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.36, h * 0.58),
      Offset(w * 0.44, h * 0.65),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.64, h * 0.58),
      Offset(w * 0.56, h * 0.65),
      stroke,
    );
  }

  void _drawDustCoat(Canvas canvas, double w, double h, Paint stroke) {
    final neck = Path()
      ..moveTo(w * 0.40, h * 0.12)
      ..lineTo(w * 0.60, h * 0.12)
      ..lineTo(w * 0.50, h * 0.34)
      ..close();
    _fillAndStroke(canvas, neck, _lightBlue, stroke);

    final coat = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.18, h * 0.26)
      ..lineTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.29, h * 0.65)
      ..lineTo(w * 0.28, h * 0.90)
      ..lineTo(w * 0.72, h * 0.90)
      ..lineTo(w * 0.71, h * 0.65)
      ..lineTo(w * 0.78, h * 0.68)
      ..lineTo(w * 0.82, h * 0.26)
      ..lineTo(w * 0.64, h * 0.12)
      ..lineTo(w * 0.50, h * 0.34)
      ..close();
    _fillAndStroke(canvas, coat, const Color(0xFFF1F5F9), stroke);

    final lapels = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.32, h * 0.24)
      ..lineTo(w * 0.50, h * 0.38)
      ..lineTo(w * 0.68, h * 0.24)
      ..lineTo(w * 0.64, h * 0.12);
    canvas.drawPath(lapels, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.38),
      Offset(w * 0.50, h * 0.90),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.46), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.56), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.66), w * 0.015, stroke);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.33, h * 0.40, w * 0.12, h * 0.10),
        const Radius.circular(2.0),
      ),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.36, h * 0.37),
      Offset(w * 0.36, h * 0.43),
      stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.31, h * 0.68, w * 0.15, h * 0.13),
        const Radius.circular(3.0),
      ),
      stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.68, w * 0.15, h * 0.13),
        const Radius.circular(3.0),
      ),
      stroke,
    );
  }

  void _drawKidsOveralls(Canvas canvas, double w, double h, Paint stroke) {
    final straps = Path()
      ..moveTo(w * 0.32, h * 0.15)
      ..lineTo(w * 0.36, h * 0.35)
      ..moveTo(w * 0.68, h * 0.15)
      ..lineTo(w * 0.64, h * 0.35);
    canvas.drawPath(straps, stroke..strokeWidth = 2.5);

    final dungarees = Path()
      ..moveTo(w * 0.32, h * 0.32)
      ..lineTo(w * 0.68, h * 0.32)
      ..lineTo(w * 0.72, h * 0.52)
      ..lineTo(w * 0.76, h * 0.84)
      ..lineTo(w * 0.54, h * 0.84)
      ..lineTo(w * 0.50, h * 0.62)
      ..lineTo(w * 0.46, h * 0.84)
      ..lineTo(w * 0.24, h * 0.84)
      ..lineTo(w * 0.28, h * 0.52)
      ..close();
    _fillAndStroke(canvas, dungarees, _denimBlue, stroke);

    canvas.drawCircle(Offset(w * 0.36, h * 0.35), w * 0.02, _fill(_gold));
    canvas.drawCircle(Offset(w * 0.36, h * 0.35), w * 0.02, stroke);
    canvas.drawCircle(Offset(w * 0.64, h * 0.35), w * 0.02, _fill(_gold));
    canvas.drawCircle(Offset(w * 0.64, h * 0.35), w * 0.02, stroke);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.38, w * 0.16, h * 0.12),
        const Radius.circular(3.0),
      ),
      stroke,
    );
  }

  void _drawSpecialDress(Canvas canvas, double w, double h, Paint stroke) {
    final dress = Path()
      ..moveTo(w * 0.36, h * 0.13)
      ..lineTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.64, h * 0.13)
      ..lineTo(w * 0.74, h * 0.20)
      ..lineTo(w * 0.67, h * 0.31)
      ..lineTo(w * 0.61, h * 0.42)
      ..quadraticBezierTo(w * 0.75, h * 0.58, w * 0.72, h * 0.88)
      ..quadraticBezierTo(w * 0.50, h * 0.92, w * 0.28, h * 0.88)
      ..quadraticBezierTo(w * 0.25, h * 0.58, w * 0.39, h * 0.42)
      ..lineTo(w * 0.33, h * 0.31)
      ..lineTo(w * 0.26, h * 0.20)
      ..close();
    _fillAndStroke(canvas, dress, _slatePurple, stroke);

    final sash = Path()
      ..moveTo(w * 0.39, h * 0.42)
      ..lineTo(w * 0.61, h * 0.42)
      ..lineTo(w * 0.60, h * 0.48)
      ..lineTo(w * 0.40, h * 0.48)
      ..close();
    _fillAndStroke(canvas, sash, _gold, stroke);
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
      Offset(w * 0.32, h * 0.20),
      Offset(w * 0.68, h * 0.20),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.20),
      Offset(w * 0.50, h * 0.38),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.41, h * 0.25),
      Offset(w * 0.41, h * 0.88),
      stroke..strokeWidth = 1.0,
    );
    canvas.drawLine(
      Offset(w * 0.59, h * 0.25),
      Offset(w * 0.59, h * 0.88),
      stroke..strokeWidth = 1.0,
    );
  }

  void _drawConverseSneaker(Canvas canvas, double w, double h, Paint stroke) {
    final shoe = Path()
      ..moveTo(w * 0.20, h * 0.38)
      ..lineTo(w * 0.44, h * 0.38)
      ..lineTo(w * 0.58, h * 0.52)
      ..lineTo(w * 0.82, h * 0.64)
      ..quadraticBezierTo(w * 0.90, h * 0.72, w * 0.82, h * 0.78)
      ..lineTo(w * 0.18, h * 0.78)
      ..lineTo(w * 0.16, h * 0.50)
      ..close();
    _fillAndStroke(canvas, shoe, _terracotta, stroke);

    final sole = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.76, w * 0.72, h * 0.09),
      const Radius.circular(3.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(sole), Colors.white, stroke);
    canvas.drawLine(
      Offset(w * 0.15, h * 0.80),
      Offset(w * 0.84, h * 0.80),
      stroke,
    );

    final toe = Path()
      ..moveTo(w * 0.72, h * 0.64)
      ..quadraticBezierTo(w * 0.86, h * 0.68, w * 0.86, h * 0.76)
      ..lineTo(w * 0.70, h * 0.76)
      ..close();
    _fillAndStroke(canvas, toe, Colors.white, stroke);

    canvas.drawCircle(
      Offset(w * 0.28, h * 0.50),
      w * 0.055,
      _fill(Colors.white),
    );
    canvas.drawCircle(Offset(w * 0.28, h * 0.50), w * 0.055, stroke);
  }

  void _drawTies(Canvas canvas, double w, double h, Paint stroke) {
    final knot = Path()
      ..moveTo(w * 0.32, h * 0.15)
      ..lineTo(w * 0.42, h * 0.15)
      ..lineTo(w * 0.39, h * 0.23)
      ..lineTo(w * 0.35, h * 0.23)
      ..close();
    _fillAndStroke(canvas, knot, _coral, stroke);

    final tieBody = Path()
      ..moveTo(w * 0.35, h * 0.23)
      ..lineTo(w * 0.39, h * 0.23)
      ..lineTo(w * 0.44, h * 0.75)
      ..lineTo(w * 0.37, h * 0.88)
      ..lineTo(w * 0.30, h * 0.75)
      ..close();
    _fillAndStroke(canvas, tieBody, _steelBlue, stroke);
    canvas.drawLine(
      Offset(w * 0.33, h * 0.42),
      Offset(w * 0.40, h * 0.50),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.58),
      Offset(w * 0.42, h * 0.68),
      stroke,
    );

    final leftWing = Path()
      ..moveTo(w * 0.68, h * 0.46)
      ..lineTo(w * 0.55, h * 0.38)
      ..lineTo(w * 0.55, h * 0.54)
      ..close();
    _fillAndStroke(canvas, leftWing, _terracotta, stroke);

    final rightWing = Path()
      ..moveTo(w * 0.72, h * 0.46)
      ..lineTo(w * 0.85, h * 0.38)
      ..lineTo(w * 0.85, h * 0.54)
      ..close();
    _fillAndStroke(canvas, rightWing, _terracotta, stroke);

    final bowKnot = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.68, h * 0.42, w * 0.05, h * 0.08),
      const Radius.circular(2.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(bowKnot), _gold, stroke);
  }

  void _drawBedSheetIroning(Canvas canvas, double w, double h, Paint stroke) {
    final sheet = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.40, w * 0.68, h * 0.46),
      const Radius.circular(6.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(sheet), _iceBlue, stroke);
    canvas.drawLine(
      Offset(w * 0.22, h * 0.55),
      Offset(w * 0.78, h * 0.55),
      stroke,
    );

    _drawMiniIron(canvas, w * 0.50, h * 0.26, w * 0.34, stroke);
  }

  void _drawLeatherJacket(Canvas canvas, double w, double h, Paint stroke) {
    final body = Path()
      ..moveTo(w * 0.34, h * 0.14)
      ..lineTo(w * 0.16, h * 0.28)
      ..lineTo(w * 0.24, h * 0.78)
      ..lineTo(w * 0.30, h * 0.72)
      ..lineTo(w * 0.30, h * 0.84)
      ..lineTo(w * 0.70, h * 0.84)
      ..lineTo(w * 0.70, h * 0.72)
      ..lineTo(w * 0.76, h * 0.78)
      ..lineTo(w * 0.84, h * 0.28)
      ..lineTo(w * 0.66, h * 0.14)
      ..close();
    _fillAndStroke(canvas, body, const Color(0xFF334155), stroke);

    final leftLapel = Path()
      ..moveTo(w * 0.34, h * 0.14)
      ..lineTo(w * 0.28, h * 0.32)
      ..lineTo(w * 0.42, h * 0.44)
      ..lineTo(w * 0.42, h * 0.20)
      ..close();
    _fillAndStroke(canvas, leftLapel, const Color(0xFF1E293B), stroke);

    final rightLapel = Path()
      ..moveTo(w * 0.66, h * 0.14)
      ..lineTo(w * 0.72, h * 0.32)
      ..lineTo(w * 0.44, h * 0.48)
      ..lineTo(w * 0.56, h * 0.18)
      ..close();
    _fillAndStroke(canvas, rightLapel, const Color(0xFF1E293B), stroke);

    canvas.drawLine(
      Offset(w * 0.42, h * 0.44),
      Offset(w * 0.56, h * 0.84),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.34, h * 0.60),
      Offset(w * 0.44, h * 0.65),
      stroke,
    );
  }

  void _drawShirtDress(Canvas canvas, double w, double h, Paint stroke) {
    final dress = Path()
      ..moveTo(w * 0.38, h * 0.12)
      ..lineTo(w * 0.20, h * 0.24)
      ..lineTo(w * 0.25, h * 0.44)
      ..lineTo(w * 0.31, h * 0.40)
      ..lineTo(w * 0.30, h * 0.88)
      ..lineTo(w * 0.70, h * 0.88)
      ..lineTo(w * 0.69, h * 0.40)
      ..lineTo(w * 0.75, h * 0.44)
      ..lineTo(w * 0.80, h * 0.24)
      ..lineTo(w * 0.62, h * 0.12)
      ..close();
    _fillAndStroke(canvas, dress, _mint, stroke);

    final collar = Path()
      ..moveTo(w * 0.38, h * 0.12)
      ..lineTo(w * 0.34, h * 0.22)
      ..lineTo(w * 0.50, h * 0.26)
      ..lineTo(w * 0.66, h * 0.22)
      ..lineTo(w * 0.62, h * 0.12)
      ..close();
    _fillAndStroke(canvas, collar, _sageTeal, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.26),
      Offset(w * 0.50, h * 0.88),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.30, h * 0.52),
      Offset(w * 0.70, h * 0.52),
      stroke,
    );
  }

  void _drawSkirtIroning(Canvas canvas, double w, double h, Paint stroke) {
    final skirt = Path()
      ..moveTo(w * 0.34, h * 0.42)
      ..lineTo(w * 0.66, h * 0.42)
      ..lineTo(w * 0.78, h * 0.86)
      ..quadraticBezierTo(w * 0.50, h * 0.90, w * 0.22, h * 0.86)
      ..close();
    _fillAndStroke(canvas, skirt, _coral, stroke);
    canvas.drawLine(
      Offset(w * 0.40, h * 0.42),
      Offset(w * 0.36, h * 0.87),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.42),
      Offset(w * 0.50, h * 0.89),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.60, h * 0.42),
      Offset(w * 0.64, h * 0.87),
      stroke,
    );

    _drawMiniIron(canvas, w * 0.50, h * 0.26, w * 0.34, stroke);
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

    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.08, _fill(_terracotta));
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.08, stroke);
  }

  void _drawTrousersIroning(Canvas canvas, double w, double h, Paint stroke) {
    final pants = Path()
      ..moveTo(w * 0.33, h * 0.36)
      ..lineTo(w * 0.67, h * 0.36)
      ..lineTo(w * 0.68, h * 0.88)
      ..lineTo(w * 0.54, h * 0.88)
      ..lineTo(w * 0.50, h * 0.52)
      ..lineTo(w * 0.46, h * 0.88)
      ..lineTo(w * 0.32, h * 0.88)
      ..close();
    _fillAndStroke(canvas, pants, _slatePurple, stroke);
    canvas.drawLine(
      Offset(w * 0.40, h * 0.40),
      Offset(w * 0.39, h * 0.88),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.60, h * 0.40),
      Offset(w * 0.61, h * 0.88),
      stroke,
    );

    _drawMiniIron(canvas, w * 0.50, h * 0.22, w * 0.34, stroke);
  }

  void _drawSneakersCaps(Canvas canvas, double w, double h, Paint stroke) {
    final crown = Path()
      ..moveTo(w * 0.22, h * 0.62)
      ..cubicTo(w * 0.24, h * 0.26, w * 0.72, h * 0.26, w * 0.74, h * 0.62)
      ..close();
    _fillAndStroke(canvas, crown, _terracotta, stroke);

    canvas.drawCircle(Offset(w * 0.48, h * 0.26), w * 0.035, _fill(_tanDark));
    canvas.drawCircle(Offset(w * 0.48, h * 0.26), w * 0.035, stroke);

    canvas.drawLine(
      Offset(w * 0.48, h * 0.26),
      Offset(w * 0.48, h * 0.62),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.48, h * 0.26),
      Offset(w * 0.33, h * 0.62),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.48, h * 0.26),
      Offset(w * 0.63, h * 0.62),
      stroke,
    );

    final visor = Path()
      ..moveTo(w * 0.22, h * 0.62)
      ..quadraticBezierTo(w * 0.48, h * 0.60, w * 0.74, h * 0.62)
      ..lineTo(w * 0.90, h * 0.70)
      ..quadraticBezierTo(w * 0.48, h * 0.76, w * 0.16, h * 0.68)
      ..close();
    _fillAndStroke(canvas, visor, _tanDark, stroke);
  }

  void _drawHeavyCardigan(Canvas canvas, double w, double h, Paint stroke) {
    final body = Path()
      ..moveTo(w * 0.36, h * 0.14)
      ..lineTo(w * 0.16, h * 0.26)
      ..lineTo(w * 0.22, h * 0.78)
      ..lineTo(w * 0.28, h * 0.72)
      ..lineTo(w * 0.28, h * 0.86)
      ..lineTo(w * 0.72, h * 0.86)
      ..lineTo(w * 0.72, h * 0.72)
      ..lineTo(w * 0.78, h * 0.78)
      ..lineTo(w * 0.84, h * 0.26)
      ..lineTo(w * 0.64, h * 0.14)
      ..close();
    _fillAndStroke(canvas, body, _taupePurple, stroke);

    final vNeck = Path()
      ..moveTo(w * 0.36, h * 0.14)
      ..lineTo(w * 0.50, h * 0.42)
      ..lineTo(w * 0.64, h * 0.14);
    canvas.drawPath(vNeck, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.42),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.018, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.64), w * 0.018, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.76), w * 0.018, stroke);

    canvas.drawRect(
      Rect.fromLTWH(w * 0.32, h * 0.66, w * 0.12, h * 0.10),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.56, h * 0.66, w * 0.12, h * 0.10),
      stroke,
    );
  }

  void _drawBlueSuitJacket(Canvas canvas, double w, double h, Paint stroke) {
    final shirt = Path()
      ..moveTo(w * 0.42, h * 0.13)
      ..lineTo(w * 0.58, h * 0.13)
      ..lineTo(w * 0.50, h * 0.48)
      ..close();
    _fillAndStroke(canvas, shirt, Colors.white, stroke);

    final tie = Path()
      ..moveTo(w * 0.48, h * 0.24)
      ..lineTo(w * 0.52, h * 0.24)
      ..lineTo(w * 0.53, h * 0.46)
      ..lineTo(w * 0.50, h * 0.50)
      ..lineTo(w * 0.47, h * 0.46)
      ..close();
    _fillAndStroke(canvas, tie, _coral, stroke);

    final jacket = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.18, h * 0.22)
      ..lineTo(w * 0.16, h * 0.84)
      ..lineTo(w * 0.28, h * 0.84)
      ..lineTo(w * 0.30, h * 0.40)
      ..lineTo(w * 0.30, h * 0.86)
      ..lineTo(w * 0.70, h * 0.86)
      ..lineTo(w * 0.70, h * 0.40)
      ..lineTo(w * 0.72, h * 0.84)
      ..lineTo(w * 0.84, h * 0.84)
      ..lineTo(w * 0.82, h * 0.22)
      ..lineTo(w * 0.64, h * 0.12)
      ..lineTo(w * 0.50, h * 0.50)
      ..close();
    _fillAndStroke(canvas, jacket, _steelBlue, stroke);

    final lapels = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.30, h * 0.32)
      ..lineTo(w * 0.50, h * 0.50)
      ..lineTo(w * 0.70, h * 0.32)
      ..lineTo(w * 0.64, h * 0.12);
    canvas.drawPath(lapels, stroke);
    canvas.drawLine(
      Offset(w * 0.50, h * 0.50),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );
  }

  void _drawDressShirt(Canvas canvas, double w, double h, Paint stroke) {
    final body = Path()
      ..moveTo(w * 0.35, h * 0.14)
      ..lineTo(w * 0.16, h * 0.28)
      ..lineTo(w * 0.24, h * 0.84)
      ..lineTo(w * 0.30, h * 0.78)
      ..lineTo(w * 0.28, h * 0.88)
      ..lineTo(w * 0.72, h * 0.88)
      ..lineTo(w * 0.70, h * 0.78)
      ..lineTo(w * 0.76, h * 0.84)
      ..lineTo(w * 0.84, h * 0.28)
      ..lineTo(w * 0.65, h * 0.14)
      ..close();
    _fillAndStroke(canvas, body, _lightBlue, stroke);

    final collar = Path()
      ..moveTo(w * 0.35, h * 0.14)
      ..lineTo(w * 0.30, h * 0.26)
      ..lineTo(w * 0.50, h * 0.28)
      ..lineTo(w * 0.70, h * 0.26)
      ..lineTo(w * 0.65, h * 0.14)
      ..close();
    _fillAndStroke(canvas, collar, Colors.white, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.50, h * 0.88),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.38), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.62), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.74), w * 0.015, stroke);
  }

  void _drawShirtsIroning(Canvas canvas, double w, double h, Paint stroke) {
    final hanger = Path()
      ..moveTo(w * 0.50, h * 0.32)
      ..lineTo(w * 0.28, h * 0.45)
      ..lineTo(w * 0.72, h * 0.45)
      ..close();
    canvas.drawPath(hanger, stroke);

    final shirt = Path()
      ..moveTo(w * 0.32, h * 0.45)
      ..lineTo(w * 0.18, h * 0.54)
      ..lineTo(w * 0.24, h * 0.72)
      ..lineTo(w * 0.30, h * 0.68)
      ..lineTo(w * 0.28, h * 0.88)
      ..lineTo(w * 0.72, h * 0.88)
      ..lineTo(w * 0.70, h * 0.68)
      ..lineTo(w * 0.76, h * 0.72)
      ..lineTo(w * 0.82, h * 0.54)
      ..lineTo(w * 0.68, h * 0.45)
      ..close();
    _fillAndStroke(canvas, shirt, _lightBlue, stroke);
    canvas.drawLine(
      Offset(w * 0.50, h * 0.45),
      Offset(w * 0.50, h * 0.88),
      stroke,
    );

    _drawMiniIron(canvas, w * 0.50, h * 0.22, w * 0.34, stroke);
  }

  void _drawWrapSkirt(Canvas canvas, double w, double h, Paint stroke) {
    final skirt = Path()
      ..moveTo(w * 0.32, h * 0.24)
      ..lineTo(w * 0.68, h * 0.24)
      ..lineTo(w * 0.78, h * 0.84)
      ..quadraticBezierTo(w * 0.55, h * 0.88, w * 0.40, h * 0.80)
      ..quadraticBezierTo(w * 0.30, h * 0.84, w * 0.22, h * 0.80)
      ..close();
    _fillAndStroke(canvas, skirt, _coral, stroke);

    final overlap = Path()
      ..moveTo(w * 0.46, h * 0.24)
      ..quadraticBezierTo(w * 0.65, h * 0.54, w * 0.40, h * 0.80);
    canvas.drawPath(overlap, stroke);

    canvas.drawCircle(Offset(w * 0.46, h * 0.26), w * 0.03, _fill(_tanDark));
    canvas.drawCircle(Offset(w * 0.46, h * 0.26), w * 0.03, stroke);
  }

  void _drawSuitIroning(Canvas canvas, double w, double h, Paint stroke) {
    final blazer = Path()
      ..moveTo(w * 0.36, h * 0.38)
      ..lineTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.22, h * 0.78)
      ..lineTo(w * 0.28, h * 0.74)
      ..lineTo(w * 0.28, h * 0.88)
      ..lineTo(w * 0.72, h * 0.88)
      ..lineTo(w * 0.72, h * 0.74)
      ..lineTo(w * 0.78, h * 0.78)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.64, h * 0.38)
      ..close();
    _fillAndStroke(canvas, blazer, _steelBlue, stroke);

    final lapel = Path()
      ..moveTo(w * 0.36, h * 0.38)
      ..lineTo(w * 0.30, h * 0.56)
      ..lineTo(w * 0.50, h * 0.68)
      ..lineTo(w * 0.70, h * 0.56)
      ..lineTo(w * 0.64, h * 0.38);
    canvas.drawPath(lapel, stroke);

    _drawMiniIron(canvas, w * 0.50, h * 0.22, w * 0.34, stroke);
  }

  void _drawGeneralLaundry(Canvas canvas, double w, double h, Paint stroke) {
    final cabinet = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.16, w * 0.64, h * 0.72),
      const Radius.circular(8.0),
    );
    _fillAndStroke(
      canvas,
      Path()..addRRect(cabinet),
      const Color(0xFFF8FAFC),
      stroke,
    );

    canvas.drawLine(
      Offset(w * 0.18, h * 0.32),
      Offset(w * 0.82, h * 0.32),
      stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.20, w * 0.18, h * 0.08),
        const Radius.circular(3.0),
      ),
      stroke,
    );

    canvas.drawCircle(Offset(w * 0.68, h * 0.24), w * 0.04, _fill(_steelBlue));
    canvas.drawCircle(Offset(w * 0.68, h * 0.24), w * 0.04, stroke);
    canvas.drawCircle(
      Offset(w * 0.56, h * 0.24),
      w * 0.015,
      _fill(const Color(0xFF22C55E)),
    );

    final center = Offset(w * 0.50, h * 0.60);
    canvas.drawCircle(center, w * 0.20, _fill(const Color(0xFFE2E8F0)));
    canvas.drawCircle(center, w * 0.20, stroke);
    canvas.drawCircle(center, w * 0.15, _fill(_iceBlue));
    canvas.drawCircle(center, w * 0.15, stroke);

    final wave = Path()
      ..moveTo(w * 0.38, h * 0.64)
      ..quadraticBezierTo(w * 0.44, h * 0.60, w * 0.50, h * 0.64)
      ..quadraticBezierTo(w * 0.56, h * 0.68, w * 0.62, h * 0.64);
    canvas.drawPath(wave, stroke);
    canvas.drawCircle(Offset(w * 0.45, h * 0.54), w * 0.02, stroke);
    canvas.drawCircle(Offset(w * 0.54, h * 0.52), w * 0.015, stroke);
  }

  void _drawCurtains(Canvas canvas, double w, double h, Paint stroke) {
    canvas.drawLine(
      Offset(w * 0.10, h * 0.16),
      Offset(w * 0.90, h * 0.16),
      stroke..strokeWidth = 2.4,
    );
    canvas.drawCircle(Offset(w * 0.09, h * 0.16), w * 0.03, _fill(_gold));
    canvas.drawCircle(Offset(w * 0.09, h * 0.16), w * 0.03, stroke);
    canvas.drawCircle(Offset(w * 0.91, h * 0.16), w * 0.03, _fill(_gold));
    canvas.drawCircle(Offset(w * 0.91, h * 0.16), w * 0.03, stroke);

    final leftCurtain = Path()
      ..moveTo(w * 0.16, h * 0.17)
      ..lineTo(w * 0.46, h * 0.17)
      ..quadraticBezierTo(w * 0.38, h * 0.52, w * 0.28, h * 0.54)
      ..quadraticBezierTo(w * 0.38, h * 0.68, w * 0.42, h * 0.86)
      ..lineTo(w * 0.16, h * 0.86)
      ..close();
    _fillAndStroke(canvas, leftCurtain, _iceBlue, stroke);

    final rightCurtain = Path()
      ..moveTo(w * 0.54, h * 0.17)
      ..lineTo(w * 0.84, h * 0.17)
      ..lineTo(w * 0.84, h * 0.86)
      ..lineTo(w * 0.58, h * 0.86)
      ..quadraticBezierTo(w * 0.62, h * 0.68, w * 0.72, h * 0.54)
      ..quadraticBezierTo(w * 0.62, h * 0.52, w * 0.54, h * 0.17)
      ..close();
    _fillAndStroke(canvas, rightCurtain, _iceBlue, stroke);

    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.52, w * 0.14, h * 0.04),
      _fill(_gold),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.52, w * 0.14, h * 0.04),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.71, h * 0.52, w * 0.14, h * 0.04),
      _fill(_gold),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.71, h * 0.52, w * 0.14, h * 0.04),
      stroke,
    );
  }

  void _drawTableclothsTowels(Canvas canvas, double w, double h, Paint stroke) {
    final colors = [_lightBlue, _mint, _tan];
    for (var i = 0; i < 3; i++) {
      final y = 0.64 - i * 0.18;
      final towel = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * y, w * 0.64, h * 0.17),
        const Radius.circular(5.0),
      );
      _fillAndStroke(canvas, Path()..addRRect(towel), colors[i], stroke);
      canvas.drawLine(
        Offset(w * 0.28, h * y),
        Offset(w * 0.28, h * (y + 0.17)),
        stroke,
      );
      canvas.drawLine(
        Offset(w * 0.32, h * y),
        Offset(w * 0.32, h * (y + 0.17)),
        stroke,
      );
    }
  }

  void _drawThreePieceSuit(Canvas canvas, double w, double h, Paint stroke) {
    final shirt = Path()
      ..moveTo(w * 0.40, h * 0.12)
      ..lineTo(w * 0.60, h * 0.12)
      ..lineTo(w * 0.50, h * 0.32)
      ..close();
    _fillAndStroke(canvas, shirt, Colors.white, stroke);

    final tie = Path()
      ..moveTo(w * 0.48, h * 0.18)
      ..lineTo(w * 0.52, h * 0.18)
      ..lineTo(w * 0.53, h * 0.38)
      ..lineTo(w * 0.50, h * 0.43)
      ..lineTo(w * 0.47, h * 0.38)
      ..close();
    _fillAndStroke(canvas, tie, _coral, stroke);

    final vest = Path()
      ..moveTo(w * 0.38, h * 0.26)
      ..lineTo(w * 0.50, h * 0.40)
      ..lineTo(w * 0.62, h * 0.26)
      ..lineTo(w * 0.64, h * 0.72)
      ..lineTo(w * 0.50, h * 0.78)
      ..lineTo(w * 0.36, h * 0.72)
      ..close();
    _fillAndStroke(canvas, vest, _slatePurple, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.012, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.56), w * 0.012, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.64), w * 0.012, stroke);

    final blazer = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..lineTo(w * 0.16, h * 0.24)
      ..lineTo(w * 0.14, h * 0.84)
      ..lineTo(w * 0.26, h * 0.84)
      ..lineTo(w * 0.28, h * 0.42)
      ..lineTo(w * 0.28, h * 0.86)
      ..lineTo(w * 0.72, h * 0.86)
      ..lineTo(w * 0.72, h * 0.42)
      ..lineTo(w * 0.74, h * 0.84)
      ..lineTo(w * 0.86, h * 0.84)
      ..lineTo(w * 0.84, h * 0.24)
      ..lineTo(w * 0.65, h * 0.12)
      ..lineTo(w * 0.50, h * 0.46)
      ..close();
    _fillAndStroke(canvas, blazer, _steelBlue, stroke);

    final lapels = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..lineTo(w * 0.28, h * 0.30)
      ..lineTo(w * 0.50, h * 0.48)
      ..lineTo(w * 0.72, h * 0.30)
      ..lineTo(w * 0.65, h * 0.12);
    canvas.drawPath(lapels, stroke);
  }

  void _drawKaundaSuit(Canvas canvas, double w, double h, Paint stroke) {
    final body = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..lineTo(w * 0.18, h * 0.24)
      ..lineTo(w * 0.22, h * 0.46)
      ..lineTo(w * 0.30, h * 0.42)
      ..lineTo(w * 0.28, h * 0.86)
      ..lineTo(w * 0.72, h * 0.86)
      ..lineTo(w * 0.70, h * 0.42)
      ..lineTo(w * 0.78, h * 0.46)
      ..lineTo(w * 0.82, h * 0.24)
      ..lineTo(w * 0.65, h * 0.12)
      ..close();
    _fillAndStroke(canvas, body, _sageTeal, stroke);

    final collar = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..lineTo(w * 0.28, h * 0.25)
      ..lineTo(w * 0.50, h * 0.28)
      ..lineTo(w * 0.72, h * 0.25)
      ..lineTo(w * 0.65, h * 0.12)
      ..close();
    _fillAndStroke(canvas, collar, _mint, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.50, h * 0.86),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.36), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.60), w * 0.015, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.72), w * 0.015, stroke);

    for (final pt in [
      Offset(w * 0.32, h * 0.34),
      Offset(w * 0.56, h * 0.34),
      Offset(w * 0.31, h * 0.64),
      Offset(w * 0.55, h * 0.64),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pt.dx, pt.dy, w * 0.14, h * 0.12),
          const Radius.circular(2.0),
        ),
        stroke,
      );
      final flap = Path()
        ..moveTo(pt.dx, pt.dy)
        ..lineTo(pt.dx + w * 0.07, pt.dy + h * 0.04)
        ..lineTo(pt.dx + w * 0.14, pt.dy);
      canvas.drawPath(flap, stroke);
      canvas.drawCircle(
        Offset(pt.dx + w * 0.07, pt.dy + h * 0.04),
        w * 0.01,
        stroke,
      );
    }
  }

  void _drawKitengeSuit(Canvas canvas, double w, double h, Paint stroke) {
    final body = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..lineTo(w * 0.15, h * 0.28)
      ..lineTo(w * 0.22, h * 0.46)
      ..lineTo(w * 0.29, h * 0.42)
      ..lineTo(w * 0.27, h * 0.88)
      ..lineTo(w * 0.73, h * 0.88)
      ..lineTo(w * 0.71, h * 0.42)
      ..lineTo(w * 0.78, h * 0.46)
      ..lineTo(w * 0.85, h * 0.28)
      ..lineTo(w * 0.65, h * 0.12)
      ..close();
    _fillAndStroke(canvas, body, _mustard, stroke);

    final yoke = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..lineTo(w * 0.30, h * 0.32)
      ..lineTo(w * 0.50, h * 0.46)
      ..lineTo(w * 0.70, h * 0.32)
      ..lineTo(w * 0.65, h * 0.12)
      ..close();
    _fillAndStroke(canvas, yoke, _terracotta, stroke);

    final collar = Path()
      ..moveTo(w * 0.38, h * 0.12)
      ..lineTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.62, h * 0.12);
    canvas.drawPath(collar, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.20),
      Offset(w * 0.50, h * 0.46),
      stroke,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.30),
        width: w * 0.10,
        height: h * 0.08,
      ),
      _fill(_gold),
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.30),
        width: w * 0.10,
        height: h * 0.08,
      ),
      stroke,
    );
  }

  void _drawSkirtSuit(Canvas canvas, double w, double h, Paint stroke) {
    final blazer = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.18, h * 0.22)
      ..lineTo(w * 0.22, h * 0.54)
      ..lineTo(w * 0.28, h * 0.50)
      ..lineTo(w * 0.28, h * 0.58)
      ..lineTo(w * 0.72, h * 0.58)
      ..lineTo(w * 0.72, h * 0.50)
      ..lineTo(w * 0.78, h * 0.54)
      ..lineTo(w * 0.82, h * 0.22)
      ..lineTo(w * 0.64, h * 0.12)
      ..close();
    _fillAndStroke(canvas, blazer, _slatePurple, stroke);

    final lapel = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.32, h * 0.26)
      ..lineTo(w * 0.50, h * 0.38)
      ..lineTo(w * 0.68, h * 0.26)
      ..lineTo(w * 0.64, h * 0.12);
    canvas.drawPath(lapel, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.46), w * 0.015, stroke);

    final skirt = Path()
      ..moveTo(w * 0.30, h * 0.58)
      ..lineTo(w * 0.70, h * 0.58)
      ..lineTo(w * 0.68, h * 0.88)
      ..lineTo(w * 0.32, h * 0.88)
      ..close();
    _fillAndStroke(canvas, skirt, _taupePurple, stroke);
  }

  void _drawDuvetFluffy(Canvas canvas, double w, double h, Paint stroke) {
    final duvet = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.22, w * 0.68, h * 0.62),
      const Radius.circular(10.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(duvet), _iceBlue, stroke);

    final roll = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.18, w * 0.72, h * 0.15),
      const Radius.circular(7.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(roll), Colors.white, stroke);

    for (final x in [0.32, 0.50, 0.68]) {
      canvas.drawLine(Offset(w * x, h * 0.34), Offset(w * x, h * 0.84), stroke);
    }
    for (final y in [0.48, 0.65]) {
      canvas.drawLine(Offset(w * 0.16, h * y), Offset(w * 0.84, h * y), stroke);
    }
    for (final x in [0.32, 0.50, 0.68]) {
      for (final y in [0.48, 0.65]) {
        canvas.drawCircle(Offset(w * x, h * y), w * 0.016, _fill(_steelBlue));
      }
    }
  }

  void _drawDuvetStandard(Canvas canvas, double w, double h, Paint stroke) {
    final duvet = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.26, w * 0.64, h * 0.56),
      const Radius.circular(8.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(duvet), _lightBlue, stroke);

    canvas.drawLine(
      Offset(w * 0.38, h * 0.26),
      Offset(w * 0.38, h * 0.82),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.62, h * 0.26),
      Offset(w * 0.62, h * 0.82),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.18, h * 0.54),
      Offset(w * 0.82, h * 0.54),
      stroke,
    );
  }

  void _drawWoollenBlanket(Canvas canvas, double w, double h, Paint stroke) {
    final blanket = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.28, w * 0.64, h * 0.50),
      const Radius.circular(6.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(blanket), _tan, stroke);

    canvas.drawLine(
      Offset(w * 0.18, h * 0.70),
      Offset(w * 0.82, h * 0.70),
      stroke,
    );

    for (var x = 0.20; x <= 0.80; x += 0.06) {
      canvas.drawLine(
        Offset(w * x, h * 0.78),
        Offset(w * x, h * 0.85),
        stroke..strokeWidth = 2.0,
      );
    }
  }

  void _drawComfortVelvet(Canvas canvas, double w, double h, Paint stroke) {
    final quilt = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.22, w * 0.68, h * 0.62),
      const Radius.circular(10.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(quilt), _slatePurple, stroke);

    for (final pt in [
      Offset(w * 0.34, h * 0.38),
      Offset(w * 0.66, h * 0.38),
      Offset(w * 0.50, h * 0.53),
      Offset(w * 0.34, h * 0.68),
      Offset(w * 0.66, h * 0.68),
    ]) {
      canvas.drawCircle(pt, w * 0.022, _fill(_taupePurple));
      canvas.drawCircle(pt, w * 0.022, stroke);
    }
  }

  void _drawBabyBlanketSheers(Canvas canvas, double w, double h, Paint stroke) {
    final blanket = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.26, w * 0.60, h * 0.54),
      const Radius.circular(8.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(blanket), _mint, stroke);

    final border = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, h * 0.31, w * 0.50, h * 0.44),
      const Radius.circular(4.0),
    );
    canvas.drawRRect(border, stroke);

    canvas.drawCircle(Offset(w * 0.50, h * 0.53), w * 0.05, _fill(_mustard));
    canvas.drawCircle(Offset(w * 0.50, h * 0.53), w * 0.05, stroke);
  }

  void _drawBedCoverLarge(Canvas canvas, double w, double h, Paint stroke) {
    final headboard = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.16, w * 0.60, h * 0.20),
      const Radius.circular(4.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(headboard), _tanDark, stroke);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.28, w * 0.22, h * 0.12),
        const Radius.circular(3.0),
      ),
      _fill(Colors.white),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.28, w * 0.22, h * 0.12),
        const Radius.circular(3.0),
      ),
      stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.28, w * 0.22, h * 0.12),
        const Radius.circular(3.0),
      ),
      _fill(Colors.white),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.28, w * 0.22, h * 0.12),
        const Radius.circular(3.0),
      ),
      stroke,
    );

    final coverlet = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.42, w * 0.64, h * 0.46),
      const Radius.circular(6.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(coverlet), _steelBlue, stroke);
  }

  void _drawBedCoverSmall(Canvas canvas, double w, double h, Paint stroke) {
    final bed = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.20, w * 0.52, h * 0.68),
      const Radius.circular(6.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(bed), _lightBlue, stroke);

    final pillow = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.24, w * 0.36, h * 0.14),
      const Radius.circular(3.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(pillow), Colors.white, stroke);
    canvas.drawLine(
      Offset(w * 0.24, h * 0.46),
      Offset(w * 0.76, h * 0.46),
      stroke,
    );
  }

  void _drawBedsheets(Canvas canvas, double w, double h, Paint stroke) {
    final colors = [const Color(0xFFF8FAFC), _iceBlue, _mint];
    for (var i = 0; i < 3; i++) {
      final y = 0.65 - i * 0.16;
      final sheet = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * y, w * 0.60, h * 0.15),
        const Radius.circular(4.0),
      );
      _fillAndStroke(canvas, Path()..addRRect(sheet), colors[i], stroke);
      canvas.drawLine(
        Offset(w * 0.24, h * (y + 0.07)),
        Offset(w * 0.76, h * (y + 0.07)),
        stroke,
      );
    }
  }

  void _drawPillowcase(Canvas canvas, double w, double h, Paint stroke) {
    final pillow = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.26, w * 0.68, h * 0.52),
      const Radius.circular(8.0),
    );
    _fillAndStroke(canvas, Path()..addRRect(pillow), Colors.white, stroke);

    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.32, w * 0.56, h * 0.40),
      const Radius.circular(4.0),
    );
    canvas.drawRRect(inner, stroke);

    final crease = Path()
      ..moveTo(w * 0.50, h * 0.42)
      ..quadraticBezierTo(w * 0.52, h * 0.52, w * 0.50, h * 0.62);
    canvas.drawPath(crease, stroke);
  }

  void _drawDustTrenchBathrobe(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
  ) {
    final robe = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.18, h * 0.26)
      ..lineTo(w * 0.24, h * 0.70)
      ..lineTo(w * 0.30, h * 0.66)
      ..lineTo(w * 0.26, h * 0.88)
      ..lineTo(w * 0.74, h * 0.88)
      ..lineTo(w * 0.70, h * 0.66)
      ..lineTo(w * 0.76, h * 0.70)
      ..lineTo(w * 0.82, h * 0.26)
      ..lineTo(w * 0.64, h * 0.12)
      ..close();
    _fillAndStroke(canvas, robe, _tan, stroke);

    final shawl = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.58, h * 0.50)
      ..lineTo(w * 0.50, h * 0.88);
    canvas.drawPath(shawl, stroke);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.48, w * 0.50, h * 0.05),
        const Radius.circular(2.0),
      ),
      _fill(_tanDark),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.48, w * 0.50, h * 0.05),
        const Radius.circular(2.0),
      ),
      stroke,
    );

    final ribbon = Path()
      ..moveTo(w * 0.46, h * 0.53)
      ..lineTo(w * 0.44, h * 0.72)
      ..moveTo(w * 0.50, h * 0.53)
      ..lineTo(w * 0.52, h * 0.70);
    canvas.drawPath(ribbon, stroke);
  }

  void _drawReligiousClothes(Canvas canvas, double w, double h, Paint stroke) {
    final robe = Path()
      ..moveTo(w * 0.38, h * 0.12)
      ..lineTo(w * 0.16, h * 0.28)
      ..lineTo(w * 0.24, h * 0.68)
      ..lineTo(w * 0.30, h * 0.65)
      ..lineTo(w * 0.28, h * 0.90)
      ..lineTo(w * 0.72, h * 0.90)
      ..lineTo(w * 0.70, h * 0.65)
      ..lineTo(w * 0.76, h * 0.68)
      ..lineTo(w * 0.84, h * 0.28)
      ..lineTo(w * 0.62, h * 0.12)
      ..close();
    _fillAndStroke(canvas, robe, const Color(0xFFF8FAFC), stroke);

    final leftStole = Path()
      ..moveTo(w * 0.42, h * 0.14)
      ..lineTo(w * 0.40, h * 0.74)
      ..lineTo(w * 0.46, h * 0.74)
      ..lineTo(w * 0.46, h * 0.14)
      ..close();
    _fillAndStroke(canvas, leftStole, _gold, stroke);

    final rightStole = Path()
      ..moveTo(w * 0.54, h * 0.14)
      ..lineTo(w * 0.54, h * 0.74)
      ..lineTo(w * 0.60, h * 0.74)
      ..lineTo(w * 0.58, h * 0.14)
      ..close();
    _fillAndStroke(canvas, rightStole, _gold, stroke);

    canvas.drawLine(
      Offset(w * 0.43, h * 0.66),
      Offset(w * 0.43, h * 0.72),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.41, h * 0.68),
      Offset(w * 0.45, h * 0.68),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.57, h * 0.66),
      Offset(w * 0.57, h * 0.72),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.55, h * 0.68),
      Offset(w * 0.59, h * 0.68),
      stroke,
    );
  }

  void _drawGraduationGown(Canvas canvas, double w, double h, Paint stroke) {
    final cap = Path()
      ..moveTo(w * 0.50, h * 0.08)
      ..lineTo(w * 0.74, h * 0.16)
      ..lineTo(w * 0.50, h * 0.24)
      ..lineTo(w * 0.26, h * 0.16)
      ..close();
    _fillAndStroke(canvas, cap, const Color(0xFF1E293B), stroke);

    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.20, w * 0.12, h * 0.06),
      _fill(const Color(0xFF1E293B)),
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.16),
      Offset(w * 0.68, h * 0.26),
      stroke..strokeWidth = 2.0,
    );
    canvas.drawCircle(Offset(w * 0.68, h * 0.28), w * 0.02, _fill(_gold));

    final gown = Path()
      ..moveTo(w * 0.38, h * 0.26)
      ..lineTo(w * 0.14, h * 0.44)
      ..lineTo(w * 0.22, h * 0.74)
      ..lineTo(w * 0.30, h * 0.68)
      ..lineTo(w * 0.26, h * 0.90)
      ..lineTo(w * 0.74, h * 0.90)
      ..lineTo(w * 0.70, h * 0.68)
      ..lineTo(w * 0.78, h * 0.74)
      ..lineTo(w * 0.86, h * 0.44)
      ..lineTo(w * 0.62, h * 0.26)
      ..close();
    _fillAndStroke(canvas, gown, const Color(0xFF334155), stroke);

    final sash = Path()
      ..moveTo(w * 0.42, h * 0.26)
      ..lineTo(w * 0.50, h * 0.42)
      ..lineTo(w * 0.58, h * 0.26)
      ..lineTo(w * 0.50, h * 0.34)
      ..close();
    _fillAndStroke(canvas, sash, _gold, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.42),
      Offset(w * 0.50, h * 0.90),
      stroke,
    );
  }

  void _drawTraditionalAttire(Canvas canvas, double w, double h, Paint stroke) {
    final robe = Path()
      ..moveTo(w * 0.38, h * 0.12)
      ..lineTo(w * 0.10, h * 0.24)
      ..lineTo(w * 0.12, h * 0.88)
      ..lineTo(w * 0.88, h * 0.88)
      ..lineTo(w * 0.90, h * 0.24)
      ..lineTo(w * 0.62, h * 0.12)
      ..close();
    _fillAndStroke(canvas, robe, _gold, stroke);

    final panel = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.30, h * 0.46)
      ..lineTo(w * 0.50, h * 0.64)
      ..lineTo(w * 0.70, h * 0.46)
      ..lineTo(w * 0.64, h * 0.12)
      ..close();
    _fillAndStroke(canvas, panel, _terracotta, stroke);

    final neck = Path()
      ..moveTo(w * 0.42, h * 0.12)
      ..lineTo(w * 0.50, h * 0.30)
      ..lineTo(w * 0.58, h * 0.12);
    canvas.drawPath(neck, stroke);
    canvas.drawCircle(Offset(w * 0.50, h * 0.44), w * 0.05, stroke);
  }

  void _drawWeddingGown(Canvas canvas, double w, double h, Paint stroke) {
    final corset = Path()
      ..moveTo(w * 0.36, h * 0.22)
      ..quadraticBezierTo(w * 0.43, h * 0.18, w * 0.50, h * 0.24)
      ..quadraticBezierTo(w * 0.57, h * 0.18, w * 0.64, h * 0.22)
      ..lineTo(w * 0.60, h * 0.44)
      ..lineTo(w * 0.40, h * 0.44)
      ..close();
    _fillAndStroke(canvas, corset, Colors.white, stroke);

    final skirt = Path()
      ..moveTo(w * 0.40, h * 0.44)
      ..lineTo(w * 0.60, h * 0.44)
      ..cubicTo(w * 0.80, h * 0.58, w * 0.90, h * 0.82, w * 0.86, h * 0.90)
      ..quadraticBezierTo(w * 0.50, h * 0.95, w * 0.14, h * 0.90)
      ..cubicTo(w * 0.10, h * 0.82, w * 0.20, h * 0.58, w * 0.40, h * 0.44)
      ..close();
    _fillAndStroke(canvas, skirt, const Color(0xFFFDFEFE), stroke);

    final ruffle = Path()
      ..moveTo(w * 0.26, h * 0.72)
      ..quadraticBezierTo(w * 0.50, h * 0.80, w * 0.74, h * 0.72);
    canvas.drawPath(ruffle, stroke);

    final veil = Path()
      ..moveTo(w * 0.42, h * 0.10)
      ..lineTo(w * 0.58, h * 0.10)
      ..quadraticBezierTo(w * 0.76, h * 0.24, w * 0.72, h * 0.58)
      ..quadraticBezierTo(w * 0.24, h * 0.24, w * 0.42, h * 0.10);
    _fillAndStroke(canvas, veil, _iceBlue.withValues(alpha: 0.5), stroke);

    canvas.drawLine(
      Offset(w * 0.45, h * 0.10),
      Offset(w * 0.55, h * 0.10),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.08), w * 0.015, _fill(_gold));
  }

  void _drawBulkIroning(Canvas canvas, double w, double h, Paint stroke) {
    _drawMiniIron(canvas, w * 0.50, h * 0.46, w * 0.65, stroke);

    for (final pt in [
      Offset(w * 0.32, h * 0.80),
      Offset(w * 0.50, h * 0.80),
      Offset(w * 0.68, h * 0.80),
    ]) {
      canvas.drawCircle(pt, w * 0.025, _fill(_iceBlue));
      canvas.drawCircle(pt, w * 0.025, stroke);
    }
  }

  void _drawMiniIron(
    Canvas canvas,
    double cx,
    double cy,
    double width,
    Paint stroke,
  ) {
    final hw = width / 2;
    final hh = width * 0.38;

    final iron = Path()
      ..moveTo(cx - hw * 0.8, cy - hh * 0.1)
      ..lineTo(cx + hw * 0.3, cy - hh * 0.6)
      ..lineTo(cx + hw, cy + hh * 0.2)
      ..quadraticBezierTo(
        cx + hw * 0.9,
        cy + hh * 0.6,
        cx + hw * 0.6,
        cy + hh * 0.6,
      )
      ..lineTo(cx - hw * 0.8, cy + hh * 0.6)
      ..close();
    _fillAndStroke(canvas, iron, _steelBlue, stroke);

    canvas.drawLine(
      Offset(cx - hw * 0.85, cy + hh * 0.7),
      Offset(cx + hw * 0.95, cy + hh * 0.7),
      stroke..strokeWidth = 2.0,
    );

    final handle = Path()
      ..moveTo(cx - hw * 0.6, cy - hh * 0.1)
      ..cubicTo(
        cx - hw * 0.6,
        cy - hh * 1.1,
        cx + hw * 0.3,
        cy - hh * 1.1,
        cx + hw * 0.4,
        cy - hh * 0.2,
      );
    canvas.drawPath(handle, stroke..strokeWidth = 2.4);

    canvas.drawCircle(
      Offset(cx - hw * 0.1, cy + hh * 0.1),
      width * 0.06,
      _fill(_gold),
    );
    canvas.drawCircle(
      Offset(cx - hw * 0.1, cy + hh * 0.1),
      width * 0.06,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _GarmentIllustrationPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.outlineColor != outlineColor;
  }
}
