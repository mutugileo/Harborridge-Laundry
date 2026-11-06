import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/core/widgets/garment_catalog_grid.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

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
}

class AdminServicesCatalogView extends StatefulWidget {
  const AdminServicesCatalogView({
    super.key,
    required this.quantities,
    required this.onIncrementGarment,
    required this.onDecrementGarment,
    this.onClearGarments,
    this.onAddCustomItem,
    this.onScanBarcode,
    this.onSubmitNewOrder,
  });

  final Map<GarmentType, int> quantities;
  final ValueChanged<GarmentType> onIncrementGarment;
  final ValueChanged<GarmentType> onDecrementGarment;
  final VoidCallback? onClearGarments;
  final VoidCallback? onAddCustomItem;
  final VoidCallback? onScanBarcode;
  final ValueChanged<PosOrderSubmission>? onSubmitNewOrder;

  @override
  State<AdminServicesCatalogView> createState() =>
      _AdminServicesCatalogViewState();
}

class _AdminServicesCatalogViewState extends State<AdminServicesCatalogView> {
  static const List<({String name, String phone, String branch})>
  _customerPresets = [
    (
      name: 'John Kamau',
      phone: '+254 712 345 678',
      branch: 'LaundryGo Nairobi',
    ),
    (
      name: 'Moncy James',
      phone: '+254 720 234 891',
      branch: 'Harborridge Main',
    ),
    (
      name: 'Anastasia Yesenenko',
      phone: '+254 722 901 442',
      branch: 'LaundryGo Westlands',
    ),
    (
      name: 'Grace Wanjiku',
      phone: '+254 733 118 290',
      branch: 'LaundryGo Kilimani',
    ),
  ];

  static const List<String> _serviceTypes = [
    'Wash & Iron',
    'Wash & Fold',
    'Dry Cleaning',
    'Wet Wash',
    'Express Iron',
  ];

  static const List<String> _branches = [
    'LaundryGo Nairobi',
    'Harborridge Main',
    'LaundryGo Westlands',
    'LaundryGo Kilimani',
  ];

  static const List<String> _deliveryMethods = [
    'Pickup assigned',
    'Home delivery',
    'Branch walk-in',
    'Express rider',
  ];

  static const List<String> _riders = [
    'Peter Mwangi',
    'David Otieno',
    'Samuel Karanja',
    'Counter Desk',
  ];

  late final TextEditingController _customerNameController;
  late final TextEditingController _customerPhoneController;

  String _selectedServiceType = 'Wash & Iron';
  String _selectedBranch = 'LaundryGo Nairobi';
  String _selectedDeliveryMethod = 'Pickup assigned';
  String _selectedRider = 'Peter Mwangi';
  String _selectedPaymentStatus = 'Paid';
  final String _selectedPaymentMethod = 'M-Pesa';
  bool _includeStainRemoval = true;
  bool _includeExtraFragrance = false;
  String? _posActionBanner;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: 'John Kamau');
    _customerPhoneController = TextEditingController(text: '+254 712 345 678');
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _applyCustomerPreset(({String name, String phone, String branch}) item) {
    setState(() {
      _customerNameController.text = item.name;
      _customerPhoneController.text = item.phone;
      _selectedBranch = item.branch;
    });
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
                Expanded(flex: 60, child: catalogSection),
                const SizedBox(width: 20.0),
                Expanded(flex: 40, child: intakeFormSection),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              intakeFormSection,
              const SizedBox(height: 20.0),
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
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                          'STEP 1 • SELECT GARMENTS',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.freshSkyBlue,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
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
                    'Choose the active service mode below, then tap garments to build the customer order.',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (widget.onClearGarments != null &&
                  widget.quantities.values.any((qty) => qty > 0))
                InteractivePressScale(
                  onTap: widget.onClearGarments,
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
          const SizedBox(height: 14.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _serviceTypes.map((service) {
              final isSelected = _selectedServiceType == service;
              return InteractivePressScale(
                onTap: () => setState(() => _selectedServiceType = service),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.harborNavy : colors.background,
                    borderRadius: BorderRadius.circular(99.0),
                    border: Border.all(
                      color: isSelected
                          ? colors.harborNavy
                          : colors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_laundry_service_outlined,
                        size: 14.0,
                        color: isSelected
                            ? colors.harborGold
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        service,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18.0),
          if (_posActionBanner != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14.0),
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
            onIncrementGarment: widget.onIncrementGarment,
            onDecrementGarment: widget.onDecrementGarment,
            onAddCustomItem: () {
              widget.onIncrementGarment(GarmentType.tanBlazer);
              widget.onAddCustomItem?.call();
              setState(() {
                _posActionBanner =
                    'Added Custom Garment (${GarmentType.tanBlazer.displayName} • KES ${GarmentType.tanBlazer.defaultRate.toStringAsFixed(0)}) to POS Ticket';
              });
            },
            onScanBarcode: () {
              widget.onIncrementGarment(GarmentType.shirt);
              widget.onScanBarcode?.call();
              setState(() {
                _posActionBanner =
                    'Scanned Barcode Tag #TAG-8841 → Added ${GarmentType.shirt.displayName} (KES ${GarmentType.shirt.defaultRate.toStringAsFixed(0)}) to POS Ticket';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerAndTicketSection(BuildContext context, AppColors colors) {
    final textTheme = Theme.of(context).textTheme;
    final selectedEntries = widget.quantities.entries
        .where((e) => e.value > 0)
        .toList();

    final itemsSubTotal = selectedEntries.fold<double>(
      0.0,
      (sum, entry) => sum + (entry.key.defaultRate * entry.value),
    );
    final addonsTotal =
        (_includeStainRemoval ? 30.0 : 0.0) +
        (_includeExtraFragrance ? 10.0 : 0.0);
    final grandTotal = itemsSubTotal + addonsTotal;
    final totalPieceCount = selectedEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.value,
    );

    final isMobile = MediaQuery.sizeOf(context).width < 600.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
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
                  '$totalPieceCount pcs',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'Customer / Owner Details',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final preset in _customerPresets) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () => _applyCustomerPreset(preset),
                      borderRadius: BorderRadius.circular(99.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(99.0),
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 13.0,
                              color: colors.freshSkyBlue,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              preset.name,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14.0),
          _IntakeLabeledTextField(
            label: 'Customer Full Name',
            hintText: 'Enter customer full name',
            controller: _customerNameController,
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12.0),
          _IntakeLabeledTextField(
            label: 'Phone Number',
            hintText: 'Use active mobile number for pickup alerts',
            controller: _customerPhoneController,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12.0),
          if (isMobile) ...[
            _IntakeDropdownField(
              label: 'Vendor / Branch',
              value: _selectedBranch,
              options: _branches,
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
            const SizedBox(height: 12.0),
            _IntakeDropdownField(
              label: 'Delivery Method',
              value: _selectedDeliveryMethod,
              options: _deliveryMethods,
              onChanged: (val) => setState(() => _selectedDeliveryMethod = val),
            ),
            const SizedBox(height: 12.0),
            _IntakeDropdownField(
              label: 'Assigned Rider / Staff',
              value: _selectedRider,
              options: _riders,
              onChanged: (val) => setState(() => _selectedRider = val),
            ),
            const SizedBox(height: 12.0),
            _IntakeDropdownField(
              label: 'Payment Status',
              value: _selectedPaymentStatus,
              options: const ['Paid', 'Partial', 'Unpaid'],
              onChanged: (val) => setState(() => _selectedPaymentStatus = val),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _IntakeDropdownField(
                    label: 'Vendor / Branch',
                    value: _selectedBranch,
                    options: _branches,
                    onChanged: (val) => setState(() => _selectedBranch = val),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: _IntakeDropdownField(
                    label: 'Delivery Method',
                    value: _selectedDeliveryMethod,
                    options: _deliveryMethods,
                    onChanged: (val) =>
                        setState(() => _selectedDeliveryMethod = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: _IntakeDropdownField(
                    label: 'Assigned Rider / Staff',
                    value: _selectedRider,
                    options: _riders,
                    onChanged: (val) => setState(() => _selectedRider = val),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: _IntakeDropdownField(
                    label: 'Payment Status',
                    value: _selectedPaymentStatus,
                    options: const ['Paid', 'Partial', 'Unpaid'],
                    onChanged: (val) =>
                        setState(() => _selectedPaymentStatus = val),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16.0),
          Divider(color: colors.borderSubtle, height: 1.0),
          const SizedBox(height: 14.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Selected Garments (${selectedEntries.length})',
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
          if (selectedEntries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Text(
                'Tap any garment tile in the catalog to add items to this customer order.',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  color: colors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: [
                for (final entry in selectedEntries)
                  Padding(
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
                          GarmentLineIcon(type: entry.key, size: 30.0),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'KES ${entry.key.defaultRate.toStringAsFixed(0)} × ${entry.value} • [$_selectedServiceType]',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 11.0,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => widget.onDecrementGarment(entry.key),
                            child: Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.borderSubtle),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 13.0,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              '${entry.value}',
                              style: textTheme.labelMedium?.copyWith(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => widget.onIncrementGarment(entry.key),
                            child: Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                color: colors.freshSkyBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 13.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            'KES ${(entry.key.defaultRate * entry.value).toStringAsFixed(0)}',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8.0),
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
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.all(14.0),
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
                const SizedBox(height: 8.0),
                Divider(color: colors.borderSubtle, height: 1.0),
                const SizedBox(height: 8.0),
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
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: InteractivePressScale(
              onTap: selectedEntries.isEmpty
                  ? null
                  : () {
                      widget.onSubmitNewOrder?.call(
                        PosOrderSubmission(
                          customerName: _customerNameController.text,
                          customerPhone: _customerPhoneController.text,
                          primaryService: _selectedServiceType,
                          vendorBranch: _selectedBranch,
                          deliveryMethod: _selectedDeliveryMethod,
                          assignedRider: _selectedRider,
                          paymentStatusLabel: _selectedPaymentStatus,
                          paymentMethod: _selectedPaymentMethod,
                          includeStainRemoval: _includeStainRemoval,
                          includeExtraFragrance: _includeExtraFragrance,
                        ),
                      );
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                decoration: BoxDecoration(
                  color: selectedEntries.isEmpty
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
                        isMobile
                            ? 'Create Order & Invoice'
                            : 'Create Order & View Invoice',
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
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;

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
        const SizedBox(height: 5.0),
        TextField(
          controller: controller,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: textTheme.bodySmall?.copyWith(
              fontSize: 12.0,
              color: colors.textTertiary,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 16.0,
              color: colors.freshSkyBlue,
            ),
            filled: true,
            fillColor: colors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: colors.freshSkyBlue, width: 1.4),
            ),
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
        const SizedBox(height: 5.0),
        SizedBox(
          width: double.infinity,
          child: PopupMenuButton<String>(
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
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 15.0,
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
