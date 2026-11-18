import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';

class AddCustomItemDialog extends StatefulWidget {
  const AddCustomItemDialog({
    super.key,
    required this.serviceType,
    required this.serviceTypes,
  });

  final String serviceType;
  final List<String> serviceTypes;

  @override
  State<AddCustomItemDialog> createState() => _AddCustomItemDialogState();
}

class _AddCustomItemDialogState extends State<AddCustomItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late final TextEditingController _weightController;
  late String _selectedCategory;
  bool _isWeightBased = false;
  int _quantity = 1;
  GarmentType _selectedPreset = GarmentType.tanBlazer;
  Uint8List? _pickedImageBytes;
  String? _pickedImageDataUrl;

  static const _presetGarments = <GarmentType>[
    GarmentType.tanBlazer,
    GarmentType.womensDress,
    GarmentType.threePieceSuit,
    GarmentType.traditionalAttire,
    GarmentType.curtains,
    GarmentType.leatherJacket,
    GarmentType.duvetStandard,
    GarmentType.bedsheets,
    GarmentType.dustTrenchBathrobe,
    GarmentType.shirt,
    GarmentType.trousers,
    GarmentType.hoodie,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _rateController = TextEditingController(text: '350');
    _weightController = TextEditingController(text: '1.0');
    _selectedCategory = widget.serviceType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        if (mounted) {
          setState(() {
            _pickedImageBytes = bytes;
            _pickedImageDataUrl = 'data:image/jpeg;base64,$base64String';
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final parsedRate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final parsedWeight = double.tryParse(_weightController.text.trim()) ?? 1.0;
    final canSubmit = _nameController.text.trim().isNotEmpty && parsedRate > 0;

    return AlertDialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: colors.freshSkyBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              color: colors.freshSkyBlue,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Custom Item',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Enter custom garment details with photo',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11.0,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440.0,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90.0,
                      height: 90.0,
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: colors.freshSkyBlue.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: _pickedImageBytes != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  _pickedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _pickedImageBytes = null;
                                        _pickedImageDataUrl = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 14.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : GarmentLineIcon(type: _selectedPreset, size: 54.0),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 6.0,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.gallery),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            side: BorderSide(color: colors.freshSkyBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: Icon(
                            Icons.file_upload_outlined,
                            size: 16.0,
                            color: colors.freshSkyBlue,
                          ),
                          label: Text(
                            'Upload Image',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.freshSkyBlue,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.camera),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            side: BorderSide(color: colors.freshSkyBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: Icon(
                            Icons.photo_camera_outlined,
                            size: 16.0,
                            color: colors.freshSkyBlue,
                          ),
                          label: Text(
                            'Take Photo',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.freshSkyBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              Text(
                'Or choose icon matching garment:',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                  fontSize: 11.0,
                ),
              ),
              const SizedBox(height: 6.0),
              SizedBox(
                height: 52.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetGarments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8.0),
                  itemBuilder: (context, index) {
                    final preset = _presetGarments[index];
                    final isSelected =
                        _selectedPreset == preset && _pickedImageBytes == null;
                    return InteractivePressScale(
                      onTap: () {
                        setState(() {
                          _selectedPreset = preset;
                          _pickedImageBytes = null;
                          _pickedImageDataUrl = null;
                        });
                      },
                      child: Container(
                        width: 48.0,
                        height: 48.0,
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.freshSkyBlue.withValues(alpha: 0.15)
                              : colors.background,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: isSelected
                                ? colors.freshSkyBlue
                                : colors.borderSubtle,
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: GarmentLineIcon(type: preset, size: 26.0),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14.0),
              TextField(
                key: const ValueKey('custom_item_name_input'),
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'Work overalls, silk gown, curtains',
                  prefixIcon: const Icon(
                    Icons.label_outline_rounded,
                    size: 18.0,
                  ),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                key: const ValueKey('custom_item_category_input'),
                initialValue: _selectedCategory,
                items: widget.serviceTypes.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      cat,
                      style: textTheme.bodySmall?.copyWith(fontSize: 12.0),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: InputDecoration(
                  labelText: 'Service Category',
                  prefixIcon: const Icon(Icons.category_outlined, size: 18.0),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('custom_item_rate_input'),
                      controller: _rateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: _isWeightBased
                            ? 'Rate / kg *'
                            : 'Unit Rate *',
                        prefixText: 'KES ',
                        filled: true,
                        fillColor: colors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: colors.borderSubtle),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _isWeightBased
                        ? TextField(
                            key: const ValueKey('custom_item_weight_input'),
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Weight (kg)',
                              suffixText: 'kg',
                              filled: true,
                              fillColor: colors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: colors.borderSubtle,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                              ),
                              Text(
                                '$_quantity pcs',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Checkbox(
                    value: _isWeightBased,
                    onChanged: (val) {
                      setState(() {
                        _isWeightBased = val ?? false;
                        if (_isWeightBased && _rateController.text == '350') {
                          _rateController.text = '120';
                        }
                      });
                    },
                  ),
                  Text(
                    'Charge by weight (KES / kg)',
                    style: textTheme.bodySmall?.copyWith(fontSize: 12.0),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Calculated Line Total:',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'KES ${(_isWeightBased ? parsedRate * parsedWeight : parsedRate * _quantity).toStringAsFixed(0)}',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.freshSkyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
        ),
        ElevatedButton(
          key: const ValueKey('submit_custom_item_button'),
          onPressed: canSubmit
              ? () {
                  final item = OrderItem(
                    index: 0,
                    serviceName: _nameController.text.trim(),
                    serviceType: _selectedCategory,
                    rate: parsedRate,
                    quantity: _isWeightBased ? 1 : _quantity,
                    icon: _isWeightBased
                        ? Icons.wash_rounded
                        : Icons.checkroom_rounded,
                    garmentType: _selectedPreset,
                    imageBytes: _pickedImageBytes,
                    imageUrl: _pickedImageDataUrl,
                    weightKg: _isWeightBased ? parsedWeight : null,
                  );
                  Navigator.of(context).pop(item);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.freshSkyBlue,
            disabledBackgroundColor: colors.textTertiary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Add to Ticket'),
        ),
      ],
    );
  }
}
