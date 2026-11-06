import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/features/dashboard/domain/dashboard_models.dart';

class OrderStatisticsChartCard extends StatelessWidget {
  const OrderStatisticsChartCard({
    super.key,
    required this.selectedFilter,
    required this.totalOrdersCount,
    required this.points,
    required this.onFilterChanged,
  });

  final String selectedFilter;
  final int totalOrdersCount;
  final List<OrderStatisticDayPoint> points;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22.0, 20.0, 22.0, 18.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order Statistics',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              _ChartDropdownPill(
                value: selectedFilter,
                options: const ['Weekly', 'Monthly', 'Quarterly'],
                onSelected: onFilterChanged,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 12.0,
                runSpacing: 6.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _LegendPillIndicator(
                    color: colors.freshSkyBlue,
                    label: 'Completed',
                  ),
                  _LegendPillIndicator(
                    color: colors.harborGold,
                    label: 'Pending',
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Text(
                  'Total Orders : $totalOrdersCount',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          SizedBox(
            height: 205.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      Text(
                        '3K',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        '2K',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        '1k',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          color: colors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          '0',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11.0,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _OrderStatisticsCustomPainter(
                            points: points,
                            primaryBarColor: colors.freshSkyBlue,
                            waveLineColor: colors.harborGold,
                            gridColor: colors.borderSubtle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: points
                            .map(
                              (point) => Expanded(
                                child: Text(
                                  point.dayLabel,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 10.0,
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RealtimeRevenueChartCard extends StatelessWidget {
  const RealtimeRevenueChartCard({
    super.key,
    required this.selectedFilter,
    required this.normalizedPoints,
    required this.onFilterChanged,
  });

  final String selectedFilter;
  final List<double> normalizedPoints;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    const timeLabels = ['10:00', '12:00', '14:00', '16:00', '18:00'];

    return Container(
      padding: const EdgeInsets.fromLTRB(22.0, 20.0, 22.0, 18.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Real Time Revenue',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              _ChartDropdownPill(
                value: selectedFilter,
                options: const ['Today', 'Yesterday', 'Last 7 Days'],
                onSelected: onFilterChanged,
              ),
            ],
          ),
          const SizedBox(height: 22.0),
          SizedBox(
            height: 233.0,
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _RealtimeRevenueCustomPainter(
                      points: normalizedPoints,
                      lineColor: colors.freshSkyBlue,
                      tooltipBgColor: colors.harborNavy,
                      gridColor: colors.borderSubtle,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: timeLabels
                      .map(
                        (label) => Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10.0,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendPillIndicator extends StatelessWidget {
  const _LegendPillIndicator({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99.0),
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12.0,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ChartDropdownPill extends StatelessWidget {
  const _ChartDropdownPill({
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map(
            (item) => PopupMenuItem<String>(
              value: item,
              child: Text(item, style: textTheme.bodySmall),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11.0,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4.0),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15.0,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatisticsCustomPainter extends CustomPainter {
  const _OrderStatisticsCustomPainter({
    required this.points,
    required this.primaryBarColor,
    required this.waveLineColor,
    required this.gridColor,
  });

  final List<OrderStatisticDayPoint> points;
  final Color primaryBarColor;
  final Color waveLineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;

    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.14 + i * 0.28);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slotWidth = size.width / points.length;
    final barWidth = (slotWidth * 0.44).clamp(24.0, 42.0);
    final waveCoords = <Offset>[];

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final centerX = slotWidth * i + slotWidth * 0.5;
      final barHeight = size.height * point.completedRatio;
      final topY = size.height - barHeight;

      final baseRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - barWidth / 2, topY, barWidth, barHeight),
        topLeft: const Radius.circular(8.0),
        topRight: const Radius.circular(8.0),
      );
      canvas.drawRRect(
        baseRect,
        Paint()..color = primaryBarColor.withValues(alpha: 0.16),
      );

      final midHeight = barHeight * 0.72;
      final midRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          centerX - barWidth / 2,
          size.height - midHeight,
          barWidth,
          midHeight * 0.45,
        ),
      );
      canvas.drawRRect(
        midRect,
        Paint()..color = primaryBarColor.withValues(alpha: 0.28),
      );

      final capHeight = (barHeight * 0.26).clamp(18.0, 32.0);
      final capRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - barWidth / 2, topY, barWidth, capHeight),
        topLeft: const Radius.circular(8.0),
        topRight: const Radius.circular(8.0),
      );
      canvas.drawRRect(capRect, Paint()..color = primaryBarColor);

      final waveY = size.height - (size.height * point.pendingRatio);
      waveCoords.add(Offset(centerX, waveY));
    }

    if (waveCoords.length >= 2) {
      final wavePath = Path()..moveTo(waveCoords.first.dx, waveCoords.first.dy);
      for (var i = 0; i < waveCoords.length - 1; i++) {
        final current = waveCoords[i];
        final next = waveCoords[i + 1];
        final controlX1 = current.dx + (next.dx - current.dx) * 0.5;
        final controlX2 = current.dx + (next.dx - current.dx) * 0.5;
        wavePath.cubicTo(
          controlX1,
          current.dy,
          controlX2,
          next.dy,
          next.dx,
          next.dy,
        );
      }

      final fillPath = Path.from(wavePath)
        ..lineTo(waveCoords.last.dx, size.height)
        ..lineTo(waveCoords.first.dx, size.height)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              waveLineColor.withValues(alpha: 0.28),
              waveLineColor.withValues(alpha: 0.02),
            ],
          ).createShader(Offset.zero & size),
      );

      canvas.drawPath(
        wavePath,
        Paint()
          ..color = waveLineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      for (var i = 0; i < waveCoords.length; i++) {
        if (i == 0 || i == 2) {
          canvas.drawCircle(waveCoords[i], 4.2, Paint()..color = Colors.white);
          canvas.drawCircle(waveCoords[i], 2.6, Paint()..color = waveLineColor);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrderStatisticsCustomPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _RealtimeRevenueCustomPainter extends CustomPainter {
  const _RealtimeRevenueCustomPainter({
    required this.points,
    required this.lineColor,
    required this.tooltipBgColor,
    required this.gridColor,
  });

  final List<double> points;
  final Color lineColor;
  final Color tooltipBgColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final stepX = size.width / (points.length - 1);
    final coords = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - (points[i] * (size.height * 0.82));
      coords.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(coords.first.dx, coords.first.dy);
    for (var i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(coords.last.dx, size.height)
      ..lineTo(coords.first.dx, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.25),
            lineColor.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final highlightIndex = 11.clamp(0, coords.length - 1);
    final highlightOffset = coords[highlightIndex];

    final dashPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.2;
    var dashY = highlightOffset.dy + 6.0;
    while (dashY < size.height) {
      canvas.drawLine(
        Offset(highlightOffset.dx, dashY),
        Offset(highlightOffset.dx, (dashY + 4.0).clamp(0.0, size.height)),
        dashPaint,
      );
      dashY += 8.0;
    }

    canvas.drawCircle(highlightOffset, 6.0, Paint()..color = Colors.white);
    canvas.drawCircle(highlightOffset, 4.0, Paint()..color = lineColor);

    const tooltipWidth = 74.0;
    const tooltipHeight = 26.0;
    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(highlightOffset.dx, highlightOffset.dy - 24.0),
        width: tooltipWidth,
        height: tooltipHeight,
      ),
      const Radius.circular(6.0),
    );
    canvas.drawRRect(tooltipRect, Paint()..color = tooltipBgColor);

    final pointerPath = Path()
      ..moveTo(highlightOffset.dx - 5.0, highlightOffset.dy - 11.0)
      ..lineTo(highlightOffset.dx + 5.0, highlightOffset.dy - 11.0)
      ..lineTo(highlightOffset.dx, highlightOffset.dy - 6.0)
      ..close();
    canvas.drawPath(pointerPath, Paint()..color = tooltipBgColor);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'KES 57.4k',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        highlightOffset.dx - textPainter.width / 2,
        highlightOffset.dy - 24.0 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _RealtimeRevenueCustomPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
