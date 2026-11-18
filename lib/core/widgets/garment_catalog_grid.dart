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
    this.selectedSection,
    this.searchQuery,
    this.weightQuantities,
    this.onTapWeightGarment,
  });

  final Map<GarmentType, int> quantities;
  final ValueChanged<GarmentType> onIncrementGarment;
  final ValueChanged<GarmentType> onDecrementGarment;
  final VoidCallback? onAddCustomItem;
  final VoidCallback? onScanBarcode;
  final GarmentServiceSection? selectedSection;
  final String? searchQuery;
  final Map<GarmentType, double>? weightQuantities;
  final ValueChanged<GarmentType>? onTapWeightGarment;

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

        final cleanQuery = searchQuery?.trim().toLowerCase() ?? '';
        final activeSection = selectedSection ?? GarmentServiceSection.all;

        final garments = GarmentType.values.where((g) {
          final matchesSection =
              activeSection == GarmentServiceSection.all ||
              g.serviceSection == activeSection;
          final matchesQuery =
              cleanQuery.isEmpty ||
              g.displayName.toLowerCase().contains(cleanQuery) ||
              g.defaultServiceType.toLowerCase().contains(cleanQuery);
          return matchesSection && matchesQuery;
        }).toList();

        final showActionTiles =
            cleanQuery.isEmpty && activeSection == GarmentServiceSection.all;
        final totalTiles = garments.length + (showActionTiles ? 2 : 0);

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
                final weight = weightQuantities?[garment];
                return _GarmentTile(
                  garment: garment,
                  quantity: count,
                  weightKg: weight,
                  onTap: () {
                    if (garment.isWeightBased && onTapWeightGarment != null) {
                      onTapWeightGarment!(garment);
                    } else {
                      onIncrementGarment(garment);
                    }
                  },
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
    this.weightKg,
    required this.onTap,
    required this.onDecrement,
  });

  final GarmentType garment;
  final int quantity;
  final double? weightKg;
  final VoidCallback onTap;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSelected = quantity > 0 || (weightKg != null && weightKg! > 0);

    return Tooltip(
      message:
          '${garment.displayName} (${garment.defaultServiceType}) · KES ${garment.defaultRate.toStringAsFixed(0)} ${garment.unitBasisLabel}',
      child: InteractivePressScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: isSelected
                ? Border.all(color: const Color(0xFF159CE8), width: 1.5)
                : null,
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
                  padding: const EdgeInsets.all(10.0),
                  child: GarmentLineIcon(type: garment, size: 64.0),
                ),
              ),
              if (isSelected) ...[
                Positioned(
                  left: 6.0,
                  bottom: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF159CE8),
                      borderRadius: BorderRadius.circular(99.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      garment.isWeightBased && weightKg != null
                          ? '${weightKg!.toStringAsFixed(1)}kg'
                          : '$quantity',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6.0,
                  bottom: 6.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onDecrement,
                    child: Container(
                      width: 22.0,
                      height: 22.0,
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
