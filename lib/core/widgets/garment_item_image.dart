import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';

class GarmentItemImage extends StatelessWidget {
  const GarmentItemImage({
    super.key,
    required this.garmentType,
    this.size = 36.0,
    this.imageUrl,
    this.imageBytes,
    this.borderRadius = 8.0,
  });

  final GarmentType garmentType;
  final double size;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double borderRadius;

  static Uint8List? _tryDecodeDataUrl(String? dataUrl) {
    if (dataUrl == null || !dataUrl.startsWith('data:image/')) return null;
    final comma = dataUrl.indexOf(',');
    if (comma == -1) return null;
    try {
      return base64Decode(dataUrl.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          imageBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    final decodedFromDataUrl = _tryDecodeDataUrl(imageUrl);
    if (decodedFromDataUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          decodedFromDataUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              GarmentLineIcon(type: garmentType, size: size),
        ),
      );
    }

    return GarmentLineIcon(type: garmentType, size: size);
  }
}
