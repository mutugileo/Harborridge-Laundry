import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class GarmentCatalogGrid extends StatelessWidget {
  const GarmentCatalogGrid({
    super.key,
    required this.quantities,
    required this.onIncrementGarment,
    required this.onDecrementGarment,
    this.onAddCustomItem,
    this.onScanBarcode,
  });

  final Map<GarmentType, int> quantities;
  final ValueChanged<GarmentType> onIncrementGarment;
  final ValueChanged<GarmentType> onDecrementGarment;
  final VoidCallback? onAddCustomItem;
  final VoidCallback? onScanBarcode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount;
        if (constraints.maxWidth >= 820.0) {
          crossAxisCount = 7;
        } else if (constraints.maxWidth >= 560.0) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth >= 380.0) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        const garments = GarmentType.values;
        final totalTiles = garments.length + 2;

        return Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F7),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalTiles,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.04,
            ),
            itemBuilder: (context, index) {
              if (index < garments.length) {
                final garment = garments[index];
                final count = quantities[garment] ?? 0;
                return _GarmentTile(
                  garment: garment,
                  quantity: count,
                  onTap: () => onIncrementGarment(garment),
                  onDecrement: () => onDecrementGarment(garment),
                );
              }

              if (index == garments.length) {
                return _ActionTile(
                  label: 'Add Item',
                  icon: const _CirclePlusGlyph(),
                  onTap: onAddCustomItem,
                );
              }

              return _ActionTile(
                label: 'by Barcode',
                icon: const _BarcodeGlyph(),
                onTap: onScanBarcode,
              );
            },
          ),
        );
      },
    );
  }
}

class _GarmentTile extends StatelessWidget {
  const _GarmentTile({
    required this.garment,
    required this.quantity,
    required this.onTap,
    required this.onDecrement,
  });

  final GarmentType garment;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Tooltip(
      message:
          '${garment.displayName} (${garment.defaultServiceType}) · KES ${garment.defaultRate.toStringAsFixed(0)}',
      child: InteractivePressScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 4.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GarmentLineIcon(type: garment, size: 68.0),
                ),
              ),
              if (quantity > 0) ...[
                Positioned(
                  left: 8.0,
                  bottom: 8.0,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF159CE8),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8.0,
                  bottom: 8.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onDecrement,
                    child: Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9ECEF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 9.0,
                        height: 1.8,
                        color: const Color(0xFF495057),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.label, required this.icon, this.onTap});

  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return InteractivePressScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 4.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 12.0),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CirclePlusGlyph extends StatelessWidget {
  const _CirclePlusGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.0,
      height: 26.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF212529), width: 1.8),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.add_rounded,
        size: 18.0,
        color: Color(0xFF212529),
      ),
    );
  }
}

class _BarcodeGlyph extends StatelessWidget {
  const _BarcodeGlyph();

  @override
  Widget build(BuildContext context) {
    const widths = <double>[2.2, 1.4, 3.0, 1.4, 2.2, 3.2];
    return SizedBox(
      height: 24.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widths.length; i++) ...[
            if (i > 0) const SizedBox(width: 2.2),
            Container(
              width: widths[i],
              height: 20.0,
              color: const Color(0xFF212529),
            ),
          ],
        ],
      ),
    );
  }
}
