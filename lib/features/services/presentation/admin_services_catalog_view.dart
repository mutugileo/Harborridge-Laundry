import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/core/widgets/garment_catalog_grid.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';

class PosOrderSubmission {
  const PosOrderSubmission({
    required this.customerName,
    required this.customerPhone,
    required this.primaryService,
    required this.vendorBranch,
    required this.deliveryMethod,
    required this.assignedRider,
    required this.paymentStatusLabel,
    required this.paymentMethod,
    required this.includeStainRemoval,
    required this.includeExtraFragrance,
    this.customItems,
    this.initialPaymentAmount,
    this.paymentReference,
  });

  final String customerName;
  final String customerPhone;
  final String primaryService;
  final String vendorBranch;
  final String deliveryMethod;
  final String assignedRider;
  final String paymentStatusLabel;
  final String paymentMethod;
  final bool includeStainRemoval;
  final bool includeExtraFragrance;
  final List<OrderItem>? customItems;
  final double? initialPaymentAmount;
  final String? paymentReference;
}

class AdminServicesCatalogView extends ConsumerStatefulWidget {
  const AdminServicesCatalogView({
    super.key,
    required this.quantities,
    required this.onIncrementGarment,
    required this.onDecrementGarment,
    this.onClearGarments,
    this.onAddCustomItem,
    this.onSubmitNewOrder,
  });

  final Map<GarmentType, int> quantities;
  final ValueChanged<GarmentType> onIncrementGarment;
  final ValueChanged<GarmentType> onDecrementGarment;
  final VoidCallback? onClearGarments;
  final VoidCallback? onAddCustomItem;
  final ValueChanged<PosOrderSubmission>? onSubmitNewOrder;

  @override
  ConsumerState<AdminServicesCatalogView> createState() =>
      _AdminServicesCatalogViewState();
}

class _AdminServicesCatalogViewState
    extends ConsumerState<AdminServicesCatalogView> {
  static const List<String> _serviceTypes = [
    'Wash & Iron',
    'Wash & Fold',
    'Laundry by Weight',
    'Dry Cleaning',
    'Apparel & Special',
    'Ironing Only',
    'Wet Wash',
    'Express Iron',
  ];

  static const List<String> _branches = [
    'Harbor Ridge • Getathuru Road',
    'Harborridge Main',
    'LaundryGo Nairobi',
    'LaundryGo Westlands',
    'LaundryGo Kilimani',
  ];

  static const List<String> _deliveryMethods = [
    'Branch walk-in',
    'Pickup assigned',
    'Home delivery',
    'Express rider',
  ];

  static const List<String> _riders = [
    'Unassigned',
    'Express Courier',
    'Counter Pickup',
    'Field Dispatch',
  ];

  late final TextEditingController _customerNameController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _searchController;
  late final TextEditingController _paymentRefController;
  late final TextEditingController _depositAmountController;

  final Map<GarmentType, double> _weightSelections = {};

  GarmentServiceSection _selectedSection = GarmentServiceSection.all;
  String _selectedServiceType = 'Wash & Iron';
  String _selectedBranch = 'Harbor Ridge • Getathuru Road';
  String _selectedDeliveryMethod = 'Branch walk-in';
  String _selectedRider = 'Unassigned';
  String _selectedPaymentStatus = 'Paid';
  String _selectedPaymentMethod = 'M-Pesa';
  bool _includeStainRemoval = true;
  bool _includeExtraFragrance = false;
  String? _posActionBanner;
  final List<OrderItem> _customPosItems = [];

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _customerPhoneController = TextEditingController();
    _searchController = TextEditingController();
    _paymentRefController = TextEditingController();
    _depositAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _searchController.dispose();
    _paymentRefController.dispose();
    _depositAmountController.dispose();
    super.dispose();
  }

  void _showWeightInputDialog(GarmentType garment) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final initialWeight = _weightSelections[garment] ?? 5.0;
    final controller = TextEditingController(
      text: initialWeight.toStringAsFixed(1),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final parsedWeight = double.tryParse(controller.text) ?? 0.0;
            final computed = math.max(
              parsedWeight * garment.defaultRate,
              garment.minimumChargeKes,
            );
            final minApplied =
                parsedWeight > 0 &&
                (parsedWeight * garment.defaultRate) < garment.minimumChargeKes;

            return AlertDialog(
              backgroundColor: colors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Row(
                children: [
                  GarmentLineIcon(type: garment, size: 32.0),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          garment.displayName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Rate: KES ${garment.defaultRate.toStringAsFixed(0)}/kg • Min: KES ${garment.minimumChargeKes.toStringAsFixed(0)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.freshSkyBlue,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter laundry weight in kilograms (kg):',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            autofocus: true,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              isDense: true,
                              suffixText: 'kg',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 12.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: colors.borderSubtle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: [3.0, 4.0, 5.0, 7.0, 10.0].map((preset) {
                        return InkWell(
                          onTap: () {
                            controller.text = preset.toStringAsFixed(1);
                            setDialogState(() {});
                          },
                          borderRadius: BorderRadius.circular(6.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(color: colors.borderSubtle),
                            ),
                            child: Text(
                              '${preset.toStringAsFixed(0)} kg',
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Calculated Subtotal:',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 12.0,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'KES ${computed.toStringAsFixed(2)}',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.freshSkyBlue,
                                ),
                              ),
                            ],
                          ),
                          if (minApplied) ...[
                            const SizedBox(height: 4.0),
                            Text(
                              'Minimum service guarantee charge applied.',
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFD97706),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final weight = double.tryParse(controller.text) ?? 1.0;
                    if (weight <= 0) return;
                    setState(() {
                      _weightSelections[garment] = weight;
                    });
                    widget.onIncrementGarment(garment);
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Add to POS Ticket'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddCustomItemDialog(BuildContext context) async {
    final newItem = await showDialog<OrderItem>(
      context: context,
      builder: (dialogContext) => _AddCustomItemDialog(
        serviceType: _selectedServiceType,
        serviceTypes: _serviceTypes,
      ),
    );

    if (newItem != null && mounted) {
      setState(() {
        _customPosItems.add(
          newItem.copyWith(index: _customPosItems.length + 1),
        );
        _posActionBanner =
            'Added Custom Item "${newItem.serviceName}" (KES ${newItem.rate.toStringAsFixed(0)}) to POS Ticket';
      });
      widget.onAddCustomItem?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktopSplit = constraints.maxWidth >= 960.0;

          final catalogSection = _buildGarmentCatalogSection(context, colors);
          final intakeFormSection = _buildOwnerAndTicketSection(
            context,
            colors,
          );

          if (isDesktopSplit) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 58, child: catalogSection),
                const SizedBox(width: 18.0),
                Expanded(flex: 42, child: intakeFormSection),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              intakeFormSection,
              const SizedBox(height: 18.0),
              catalogSection,
            ],
          );
        },
      ),
    );
  }

  Widget _buildGarmentCatalogSection(BuildContext context, AppColors colors) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  'STEP 1 • SELECT SERVICES',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.freshSkyBlue,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (widget.onClearGarments != null &&
                  (widget.quantities.values.any((qty) => qty > 0) ||
                      _customPosItems.isNotEmpty))
                InteractivePressScale(
                  onTap: () {
                    setState(() {
                      _weightSelections.clear();
                      _customPosItems.clear();
                    });
                    widget.onClearGarments?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 7.0,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Text(
                      'Reset Selection',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'POS Garment & Service Intake',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            'Select services or tap garments below to add items to customer ticket.',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.0,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 40.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18.0,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.5,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Search catalog by garment or service (suit, duvet, curtains, ironing)',
                      hintStyle: textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 16.0,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: GarmentServiceSection.values.map((sec) {
                final isSelected = _selectedSection == sec;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InteractivePressScale(
                    onTap: () => setState(() => _selectedSection = sec),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.harborNavy
                            : colors.background,
                        borderRadius: BorderRadius.circular(99.0),
                        border: Border.all(
                          color: isSelected
                              ? colors.harborNavy
                              : colors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        sec.label,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _serviceTypes.map((service) {
                final isSelected = _selectedServiceType == service;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InteractivePressScale(
                    onTap: () => setState(() => _selectedServiceType = service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.freshSkyBlue.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: isSelected
                              ? colors.freshSkyBlue
                              : colors.borderSubtle.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        service,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colors.freshSkyBlue
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14.0),
          if (_posActionBanner != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 9.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _posActionBanner!,
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF15803D),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          GarmentCatalogGrid(
            quantities: widget.quantities,
            weightQuantities: _weightSelections,
            selectedSection: _selectedSection,
            searchQuery: _searchController.text,
            onTapWeightGarment: _showWeightInputDialog,
            onIncrementGarment: widget.onIncrementGarment,
            onDecrementGarment: (garment) {
              if (garment.isWeightBased) {
                setState(() => _weightSelections.remove(garment));
              }
              widget.onDecrementGarment(garment);
            },
            onAddCustomItem: () => _showAddCustomItemDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerAndTicketSection(BuildContext context, AppColors colors) {
    final textTheme = Theme.of(context).textTheme;
    final liveOrders = ref.watch(orderDetailsNotifierProvider).orders;

    final selectedEntries = widget.quantities.entries
        .where((e) => e.value > 0)
        .toList();

    double itemsSubTotal = 0.0;
    int totalPieceCount = 0;
    final List<OrderItem> customOrderItems = [];

    for (var i = 0; i < selectedEntries.length; i++) {
      final entry = selectedEntries[i];
      final garment = entry.key;
      final qty = entry.value;

      if (garment.isWeightBased) {
        final weight = _weightSelections[garment] ?? 1.0;
        final lineRate = math.max(
          weight * garment.defaultRate,
          garment.minimumChargeKes,
        );
        itemsSubTotal += lineRate;
        totalPieceCount += 1;
        customOrderItems.add(
          OrderItem(
            index: i + 1,
            serviceName:
                '${garment.displayName} (${weight.toStringAsFixed(1)} kg)',
            serviceType: '[$_selectedServiceType]',
            rate: lineRate,
            quantity: 1,
            icon: Icons.wash_rounded,
            garmentType: garment,
          ),
        );
      } else {
        final lineTotal = garment.defaultRate * qty;
        itemsSubTotal += lineTotal;
        totalPieceCount += qty;
        customOrderItems.add(
          OrderItem(
            index: i + 1,
            serviceName: garment.displayName,
            serviceType: '[$_selectedServiceType]',
            rate: garment.defaultRate,
            quantity: qty,
            icon: Icons.checkroom_rounded,
            garmentType: garment,
          ),
        );
      }
    }

    for (var i = 0; i < _customPosItems.length; i++) {
      final custom = _customPosItems[i];
      itemsSubTotal += custom.total;
      totalPieceCount += custom.weightKg != null && custom.weightKg! > 0
          ? 1
          : custom.quantity;
      customOrderItems.add(custom.copyWith(index: customOrderItems.length + 1));
    }

    final addonsTotal =
        (_includeStainRemoval ? 30.0 : 0.0) +
        (_includeExtraFragrance ? 10.0 : 0.0);
    final grandTotal = itemsSubTotal + addonsTotal;

    final typedPhone = _customerPhoneController.text.trim();
    final matchedCustomer = typedPhone.length >= 3
        ? liveOrders.cast<dynamic>().firstWhere(
            (o) =>
                (o.customerPhone as String).contains(typedPhone) ||
                (o.customerName as String).toLowerCase().contains(
                  typedPhone.toLowerCase(),
                ),
            orElse: () => null,
          )
        : null;

    final isMobile = MediaQuery.sizeOf(context).width < 600.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: colors.harborGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  'STEP 2 • OWNER & ORDER TICKET',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.harborNavy,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: colors.harborNavy,
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Text(
                  '$totalPieceCount pcs / loads',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            'Customer / Owner Details',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12.0),
          _IntakeLabeledTextField(
            label: 'Phone Number',
            hintText: 'Enter mobile number for pickup SMS alerts',
            controller: _customerPhoneController,
            prefixIcon: Icons.phone_outlined,
            onChanged: (_) => setState(() {}),
          ),
          if (matchedCustomer != null &&
              _customerNameController.text.trim().isEmpty) ...[
            const SizedBox(height: 6.0),
            InkWell(
              onTap: () {
                setState(() {
                  _customerNameController.text =
                      matchedCustomer.customerName as String;
                  _customerPhoneController.text =
                      matchedCustomer.customerPhone as String;
                  _selectedBranch =
                      matchedCustomer.vendorBranch as String? ??
                      'Harbor Ridge • Getathuru Road';
                });
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_pin_rounded,
                      size: 15.0,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        'Found customer: ${matchedCustomer.customerName} (${matchedCustomer.customerPhone}) • Tap to auto-fill',
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF1D4ED8),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10.0),
          _IntakeLabeledTextField(
            label: 'Customer Full Name',
            hintText: 'Enter customer full name or leave for Walk-in',
            controller: _customerNameController,
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12.0),
          if (isMobile) ...[
            _IntakeDropdownField(
              label: 'Handover / Delivery',
              value: _selectedDeliveryMethod,
              options: _deliveryMethods,
              onChanged: (val) => setState(() => _selectedDeliveryMethod = val),
            ),
            const SizedBox(height: 10.0),
            _IntakeDropdownField(
              label: 'Assigned Rider / Staff',
              value: _selectedRider,
              options: _riders,
              onChanged: (val) => setState(() => _selectedRider = val),
            ),
            const SizedBox(height: 10.0),
            _IntakeDropdownField(
              label: 'Vendor / Branch',
              value: _selectedBranch,
              options: _branches,
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _IntakeDropdownField(
                    label: 'Handover / Delivery',
                    value: _selectedDeliveryMethod,
                    options: _deliveryMethods,
                    onChanged: (val) =>
                        setState(() => _selectedDeliveryMethod = val),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: _IntakeDropdownField(
                    label: 'Assigned Rider / Staff',
                    value: _selectedRider,
                    options: _riders,
                    onChanged: (val) => setState(() => _selectedRider = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            _IntakeDropdownField(
              label: 'Vendor / Branch',
              value: _selectedBranch,
              options: _branches,
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
          ],
          const SizedBox(height: 16.0),
          Divider(color: colors.borderSubtle, height: 1.0),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Selected Items (${selectedEntries.length + _customPosItems.length})',
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                'Service: [$_selectedServiceType]',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: colors.freshSkyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          if (selectedEntries.isEmpty && _customPosItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Text(
                'Tap any garment tile in the catalog or use Add Item to take in items.',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  color: colors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: [
                for (final entry in selectedEntries) ...[
                  Builder(
                    builder: (context) {
                      final garment = entry.key;
                      final count = entry.value;
                      final isWeight = garment.isWeightBased;
                      final weight = _weightSelections[garment] ?? 1.0;
                      final lineTotal = isWeight
                          ? math.max(
                              weight * garment.defaultRate,
                              garment.minimumChargeKes,
                            )
                          : garment.defaultRate * count;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.background.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: colors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              GarmentLineIcon(type: garment, size: 26.0),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isWeight
                                          ? '${garment.displayName} • ${weight.toStringAsFixed(1)} kg'
                                          : garment.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      isWeight
                                          ? 'KES ${garment.defaultRate.toStringAsFixed(0)}/kg (min ${garment.minimumChargeKes.toStringAsFixed(0)})'
                                          : 'KES ${garment.defaultRate.toStringAsFixed(0)} × $count',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.labelSmall?.copyWith(
                                        fontSize: 10.0,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isWeight) ...[
                                InkWell(
                                  onTap: () => _showWeightInputDialog(garment),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 3.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.freshSkyBlue.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      'Edit kg',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colors.freshSkyBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                              ],
                              InkWell(
                                onTap: () {
                                  if (isWeight) {
                                    setState(
                                      () => _weightSelections.remove(garment),
                                    );
                                  }
                                  widget.onDecrementGarment(garment);
                                },
                                child: Container(
                                  width: 22.0,
                                  height: 22.0,
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.borderSubtle,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 12.0,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              if (!isWeight) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Text(
                                    '$count',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () =>
                                      widget.onIncrementGarment(garment),
                                  child: Container(
                                    width: 22.0,
                                    height: 22.0,
                                    decoration: BoxDecoration(
                                      color: colors.freshSkyBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8.0),
                              Text(
                                'KES ${lineTotal.toStringAsFixed(0)}',
                                style: textTheme.labelMedium?.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
                for (var i = 0; i < _customPosItems.length; i++) ...[
                  Builder(
                    builder: (context) {
                      final item = _customPosItems[i];
                      final isWeight =
                          item.weightKg != null && item.weightKg! > 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.background.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: colors.freshSkyBlue.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (item.imageBytes != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.memory(
                                    item.imageBytes!,
                                    width: 28.0,
                                    height: 28.0,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else if (item.imageUrl != null &&
                                  item.imageUrl!.startsWith('http'))
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.network(
                                    item.imageUrl!,
                                    width: 28.0,
                                    height: 28.0,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            GarmentLineIcon(
                                              type: item.garmentType,
                                              size: 26.0,
                                            ),
                                  ),
                                )
                              else
                                GarmentLineIcon(
                                  type: item.garmentType,
                                  size: 26.0,
                                ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            isWeight
                                                ? '${item.serviceName} • ${item.weightKg!.toStringAsFixed(1)} kg'
                                                : item.serviceName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: colors.textPrimary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                            vertical: 1.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.freshSkyBlue
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              4.0,
                                            ),
                                          ),
                                          child: Text(
                                            'Custom',
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                                  fontSize: 9.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: colors.freshSkyBlue,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${item.serviceType} · KES ${item.rate.toStringAsFixed(0)} ${isWeight ? '/kg' : '× ${item.quantity}'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.labelSmall?.copyWith(
                                        fontSize: 10.0,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _customPosItems.removeAt(i);
                                  });
                                },
                                child: Container(
                                  width: 22.0,
                                  height: 22.0,
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.borderSubtle,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 13.0,
                                    color: colors.statusError,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'KES ${item.total.toStringAsFixed(0)}',
                                style: textTheme.labelMedium?.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _AddonToggleChip(
                label: 'Stain Removal (+KES 30)',
                isSelected: _includeStainRemoval,
                onTap: () => setState(
                  () => _includeStainRemoval = !_includeStainRemoval,
                ),
              ),
              _AddonToggleChip(
                label: 'Extra Fragrance (+KES 10)',
                isSelected: _includeExtraFragrance,
                onTap: () => setState(
                  () => _includeExtraFragrance = !_includeExtraFragrance,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Garments Sub Total:',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'KES ${itemsSubTotal.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Service Addons:',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'KES ${addonsTotal.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Divider(color: colors.borderSubtle, height: 1.0),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Total Amount:',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: colors.harborNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'KES ${grandTotal.toStringAsFixed(2)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: colors.freshSkyBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Payment & Settlement Terms',
            style: textTheme.labelMedium?.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children:
                [
                  ('Paid', 'M-Pesa', 'M-Pesa (Paid)'),
                  ('Paid', 'Cash', 'Cash (Paid)'),
                  ('Unpaid', 'Cash', 'Pay on Collection (Unpaid)'),
                  ('Partial', 'M-Pesa', 'Partial Deposit'),
                ].map((opt) {
                  final isSel =
                      _selectedPaymentStatus == opt.$1 &&
                      (_selectedPaymentStatus == 'Unpaid' ||
                          _selectedPaymentMethod == opt.$2);
                  return InteractivePressScale(
                    onTap: () {
                      setState(() {
                        _selectedPaymentStatus = opt.$1;
                        _selectedPaymentMethod = opt.$2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? colors.freshSkyBlue.withValues(alpha: 0.15)
                            : colors.background,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: isSel
                              ? colors.freshSkyBlue
                              : colors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        opt.$3,
                        style: textTheme.labelSmall?.copyWith(
                          color: isSel
                              ? colors.freshSkyBlue
                              : colors.textPrimary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          if (_selectedPaymentStatus == 'Paid' &&
              _selectedPaymentMethod == 'M-Pesa') ...[
            const SizedBox(height: 8.0),
            _IntakeLabeledTextField(
              label: 'M-Pesa Transaction Reference Code',
              hintText: 'Enter M-Pesa receipt code',
              controller: _paymentRefController,
              prefixIcon: Icons.receipt_long_rounded,
            ),
          ],
          if (_selectedPaymentStatus == 'Partial') ...[
            const SizedBox(height: 8.0),
            _IntakeLabeledTextField(
              label: 'Deposit Amount (KES)',
              hintText: 'Enter deposit amount paid at counter',
              controller: _depositAmountController,
              prefixIcon: Icons.payments_outlined,
            ),
          ],
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: InteractivePressScale(
              onTap: (selectedEntries.isEmpty && _customPosItems.isEmpty)
                  ? null
                  : () {
                      final parsedDeposit = double.tryParse(
                        _depositAmountController.text.trim(),
                      );
                      widget.onSubmitNewOrder?.call(
                        PosOrderSubmission(
                          customerName:
                              _customerNameController.text.trim().isEmpty
                              ? 'Walk-in Customer'
                              : _customerNameController.text.trim(),
                          customerPhone: _customerPhoneController.text.trim(),
                          primaryService: _selectedServiceType,
                          vendorBranch: _selectedBranch,
                          deliveryMethod: _selectedDeliveryMethod,
                          assignedRider: _selectedRider,
                          paymentStatusLabel: _selectedPaymentStatus,
                          paymentMethod: _selectedPaymentMethod,
                          includeStainRemoval: _includeStainRemoval,
                          includeExtraFragrance: _includeExtraFragrance,
                          customItems: customOrderItems,
                          initialPaymentAmount:
                              _selectedPaymentStatus == 'Partial'
                              ? parsedDeposit
                              : (_selectedPaymentStatus == 'Paid'
                                    ? grandTotal
                                    : null),
                          paymentReference:
                              _paymentRefController.text.trim().isNotEmpty
                              ? _paymentRefController.text.trim()
                              : null,
                        ),
                      );
                      setState(() {
                        _customPosItems.clear();
                      });
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 13.0,
                ),
                decoration: BoxDecoration(
                  color: (selectedEntries.isEmpty && _customPosItems.isEmpty)
                      ? colors.textTertiary
                      : colors.accentGreen,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 17.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        'Create Order & View Invoice',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntakeLabeledTextField extends StatelessWidget {
  const _IntakeLabeledTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.onChanged,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4.0),
        Container(
          height: 38.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(prefixIcon, size: 16.0, color: colors.textSecondary),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntakeDropdownField extends StatelessWidget {
  const _IntakeDropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4.0),
        PopupMenuButton<String>(
          initialValue: value,
          onSelected: onChanged,
          itemBuilder: (context) => options
              .map(
                (opt) => PopupMenuItem<String>(
                  value: opt,
                  child: Text(opt, style: textTheme.bodySmall),
                ),
              )
              .toList(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 9.0,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.0,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddonToggleChip extends StatelessWidget {
  const _AddonToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.freshSkyBlue.withValues(alpha: 0.12)
              : colors.background,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? colors.freshSkyBlue : colors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 14.0,
              color: isSelected ? colors.freshSkyBlue : colors.textSecondary,
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.harborNavy : colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCustomItemDialog extends StatefulWidget {
  const _AddCustomItemDialog({
    required this.serviceType,
    required this.serviceTypes,
  });

  final String serviceType;
  final List<String> serviceTypes;

  @override
  State<_AddCustomItemDialog> createState() => _AddCustomItemDialogState();
}

class _AddCustomItemDialogState extends State<_AddCustomItemDialog> {
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
                            side: BorderSide(color: colors.borderSubtle),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            size: 16.0,
                            color: colors.textPrimary,
                          ),
                          label: Text(
                            'Take Photo',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Select Garment Icon Preset',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final preset in _presetGarments)
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPreset = preset;
                            });
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color:
                                  _selectedPreset == preset &&
                                      _pickedImageBytes == null
                                  ? colors.freshSkyBlue.withValues(alpha: 0.15)
                                  : colors.background,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color:
                                    _selectedPreset == preset &&
                                        _pickedImageBytes == null
                                    ? colors.freshSkyBlue
                                    : colors.borderSubtle,
                              ),
                            ),
                            child: GarmentLineIcon(type: preset, size: 26.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              _IntakeLabeledTextField(
                label: 'Item Name',
                hintText: 'Enter garment or laundry item name',
                controller: _nameController,
                prefixIcon: Icons.local_laundry_service_outlined,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12.0),
              _IntakeDropdownField(
                label: 'Service Category',
                value: _selectedCategory,
                options: widget.serviceTypes,
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                    if (val == 'Laundry by Weight') {
                      _isWeightBased = true;
                    }
                  });
                },
              ),
              const SizedBox(height: 12.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _IntakeLabeledTextField(
                      label: _isWeightBased
                          ? 'Rate per kg (KES)'
                          : 'Unit Price (KES)',
                      hintText: 'Enter price per item or load',
                      controller: _rateController,
                      prefixIcon: Icons.payments_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWeightBased ? 'Weight (kg)' : 'Quantity',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        if (_isWeightBased)
                          TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter load weight in kilograms',
                              filled: true,
                              fillColor: colors.background,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 10.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: colors.borderSubtle,
                                ),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          )
                        else
                          Container(
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: colors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16.0),
                                  onPressed: _quantity > 1
                                      ? () => setState(() => _quantity--)
                                      : null,
                                ),
                                Text(
                                  '$_quantity',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16.0),
                                  onPressed: () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Checkbox(
                    value: _isWeightBased,
                    activeColor: colors.freshSkyBlue,
                    onChanged: (val) {
                      setState(() {
                        _isWeightBased = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isWeightBased = !_isWeightBased;
                        });
                      },
                      child: Text(
                        'Charged by Weight (kg) instead of per item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: textTheme.labelMedium?.copyWith(color: colors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: canSubmit
              ? () {
                  final item = OrderItem(
                    index: 0,
                    serviceName: _nameController.text.trim(),
                    serviceType: '[$_selectedCategory]',
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
