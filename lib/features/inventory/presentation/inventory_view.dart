import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_state.dart';

class _InventoryStockItem {
  const _InventoryStockItem({
    required this.sku,
    required this.name,
    required this.category,
    required this.supplier,
    required this.unitLabel,
    required this.unitCostKes,
    required this.quantity,
    required this.maxCapacity,
    required this.reorderPoint,
    required this.daysRemaining,
    required this.linkedService,
  });

  final String sku;
  final String name;
  final String category;
  final String supplier;
  final String unitLabel;
  final int unitCostKes;
  final int quantity;
  final int maxCapacity;
  final int reorderPoint;
  final int daysRemaining;
  final String linkedService;

  double get stockRatio => (quantity / maxCapacity).clamp(0.0, 1.0);
  bool get isLowStock => quantity <= reorderPoint;
  int get totalValueKes => quantity * unitCostKes;

  _InventoryStockItem copyWith({int? quantity, int? daysRemaining}) {
    return _InventoryStockItem(
      sku: sku,
      name: name,
      category: category,
      supplier: supplier,
      unitLabel: unitLabel,
      unitCostKes: unitCostKes,
      quantity: quantity ?? this.quantity,
      maxCapacity: maxCapacity,
      reorderPoint: reorderPoint,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      linkedService: linkedService,
    );
  }
}

class _InventoryLogEntry {
  const _InventoryLogEntry({
    required this.timestampLabel,
    required this.sku,
    required this.itemName,
    required this.deltaLabel,
    required this.referenceLabel,
    required this.isRestock,
  });

  final String timestampLabel;
  final String sku;
  final String itemName;
  final String deltaLabel;
  final String referenceLabel;
  final bool isRestock;
}

class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key, this.onOpenOrderDetails});

  final ValueChanged<String>? onOpenOrderDetails;

  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  String _selectedCategory = 'All Stock';
  String _searchQuery = '';
  String? _statusBanner;
  bool _showAddSkuPanel = false;
  String _newSkuCategory = 'Detergents';

  late final TextEditingController _searchController;
  late final TextEditingController _newSkuNameController;
  late final TextEditingController _newSkuSupplierController;
  late final TextEditingController _newSkuUnitController;
  late final TextEditingController _newSkuCostController;
  late final TextEditingController _newSkuQtyController;

  late List<_InventoryStockItem> _items = const [];

  final List<_InventoryLogEntry> _sessionLogs = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _newSkuNameController = TextEditingController();
    _newSkuSupplierController = TextEditingController();
    _newSkuUnitController = TextEditingController();
    _newSkuCostController = TextEditingController();
    _newSkuQtyController = TextEditingController();
    _loadSupabaseInventory();
  }

  Future<void> _loadSupabaseInventory() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      final response = await client
          .from('inventory_items')
          .select('*')
          .order('created_at', ascending: true);
      if (!mounted) return;
      final loaded = (response as List).map((row) {
        final map = row as Map<String, dynamic>;
        return _InventoryStockItem(
          sku: map['sku'] as String? ?? 'INV-00',
          name: map['name'] as String? ?? 'Item',
          category: map['category'] as String? ?? 'Detergents',
          supplier: map['supplier'] as String? ?? 'Supplier',
          unitLabel: map['unit'] as String? ?? 'Units',
          unitCostKes: (map['unit_cost_kes'] as num?)?.toInt() ?? 0,
          quantity: (map['quantity'] as num?)?.toInt() ?? 0,
          maxCapacity: 25,
          reorderPoint: (map['min_threshold'] as num?)?.toInt() ?? 5,
          daysRemaining: 15,
          linkedService: map['linked_service'] as String? ?? '',
        );
      }).toList();
      setState(() {
        _items = loaded;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newSkuNameController.dispose();
    _newSkuSupplierController.dispose();
    _newSkuUnitController.dispose();
    _newSkuCostController.dispose();
    _newSkuQtyController.dispose();
    super.dispose();
  }

  void _registerNewSku() {
    final name = _newSkuNameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _statusBanner = 'Enter an inventory item name before saving the SKU.';
      });
      return;
    }
    final supplier = _newSkuSupplierController.text.trim().isEmpty
        ? 'Diversey East Africa'
        : _newSkuSupplierController.text.trim();
    final unit = _newSkuUnitController.text.trim().isEmpty
        ? 'Drums'
        : _newSkuUnitController.text.trim();
    final costKes = int.tryParse(_newSkuCostController.text.trim()) ?? 4500;
    final qty = (int.tryParse(_newSkuQtyController.text.trim()) ?? 12).clamp(
      1,
      200,
    );
    final maxCap = (qty + 8).clamp(15, 250);
    final nextSkuCode = 'INV-0${_items.length + 1}';

    final newItem = _InventoryStockItem(
      sku: nextSkuCode,
      name: name,
      category: _newSkuCategory,
      supplier: supplier,
      unitLabel: unit,
      unitCostKes: costKes,
      quantity: qty,
      maxCapacity: maxCap,
      reorderPoint: 5,
      daysRemaining: 24,
      linkedService: '$_newSkuCategory • Production Floor',
    );

    setState(() {
      _items = [newItem, ..._items];
      _sessionLogs.insert(
        0,
        _InventoryLogEntry(
          timestampLabel: 'Just now',
          sku: nextSkuCode,
          itemName: name,
          deltaLabel: '+$qty $unit',
          referenceLabel: 'New SKU Registered • $supplier',
          isRestock: true,
        ),
      );
      _newSkuNameController.clear();
      _showAddSkuPanel = false;
      _statusBanner =
          'Registered $nextSkuCode ($name) with $qty $unit at KES $costKes/$unit';
    });

    final client = ref.read(supabaseClientProvider);
    if (client != null) {
      client
          .from('inventory_items')
          .insert({
            'sku': newItem.sku,
            'name': newItem.name,
            'category': newItem.category,
            'supplier': newItem.supplier,
            'unit': newItem.unitLabel,
            'unit_cost_kes': newItem.unitCostKes,
            'quantity': newItem.quantity,
            'min_threshold': newItem.reorderPoint,
            'linked_service': newItem.linkedService,
          })
          .catchError((_) {});
    }
  }

  void _adjustStock(int index, int delta, {String? customReason}) {
    final item = _items[index];
    final nextQty = (item.quantity + delta).clamp(0, item.maxCapacity);
    if (nextQty == item.quantity) return;

    final nextDays = ((nextQty / item.maxCapacity) * 28).round().clamp(1, 45);
    setState(() {
      _items = [
        for (var i = 0; i < _items.length; i++)
          if (i == index)
            item.copyWith(quantity: nextQty, daysRemaining: nextDays)
          else
            _items[i],
      ];
      _sessionLogs.insert(
        0,
        _InventoryLogEntry(
          timestampLabel: 'Just now',
          sku: item.sku,
          itemName: item.name,
          deltaLabel: '${delta > 0 ? '+$delta' : '$delta'} ${item.unitLabel}',
          referenceLabel:
              customReason ??
              (delta > 0
                  ? 'PO Replenishment • ${item.supplier}'
                  : 'Production Floor Allocation'),
          isRestock: delta > 0,
        ),
      );
      _statusBanner =
          '${delta > 0 ? 'Restocked' : 'Allocated'} ${item.name} → $nextQty/${item.maxCapacity} ${item.unitLabel} in stock';
    });

    final client = ref.read(supabaseClientProvider);
    if (client != null) {
      client
          .from('inventory_items')
          .update({
            'quantity': nextQty,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('sku', item.sku)
          .catchError((_) {});
    }
  }

  void _replenishAllLowStock() {
    var replenishedCount = 0;
    setState(() {
      _items = _items.map((item) {
        if (!item.isLowStock) return item;
        replenishedCount++;
        final added = item.maxCapacity - item.quantity;
        _sessionLogs.insert(
          0,
          _InventoryLogEntry(
            timestampLabel: 'Just now',
            sku: item.sku,
            itemName: item.name,
            deltaLabel: '+$added ${item.unitLabel}',
            referenceLabel: 'Auto-PO Batch • ${item.supplier}',
            isRestock: true,
          ),
        );
        return item.copyWith(quantity: item.maxCapacity, daysRemaining: 28);
      }).toList();

      _statusBanner = replenishedCount > 0
          ? 'Approved purchase orders and replenished $replenishedCount low-stock SKUs to full capacity.'
          : 'All inventory SKUs are already above their reorder threshold.';
    });
  }

  String _formatKes(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    return 'KES $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(orderDetailsNotifierProvider);
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    const categories = [
      'All Stock',
      'Detergents',
      'Solvents',
      'Addons',
      'Packaging',
      'Low Stock',
    ];

    final filtered = _items.where((item) {
      final matchesCategory = switch (_selectedCategory) {
        'All Stock' => true,
        'Low Stock' => item.isLowStock,
        _ => item.category == _selectedCategory,
      };
      if (!matchesCategory) return false;
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(q) ||
          item.sku.toLowerCase().contains(q) ||
          item.supplier.toLowerCase().contains(q) ||
          item.linkedService.toLowerCase().contains(q);
    }).toList();

    final totalValuationKes = _items.fold<int>(
      0,
      (sum, item) => sum + item.totalValueKes,
    );
    final lowStockItems = _items.where((i) => i.isLowStock).toList();
    final activeWashOrders = ordersState.orders.length;
    final packagingUnits = _items
        .where((i) => i.category == 'Packaging')
        .fold<int>(0, (sum, i) => sum + i.quantity);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Toolbar & Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile
                            ? (screenWidth - 48.0).clamp(200.0, 500.0)
                            : 600.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: colors.freshSkyBlue.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 19.0,
                              color: colors.freshSkyBlue,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Consumables, Solvents & Packaging Inventory',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Detergents, dry-clean solvents, packaging rolls & auto-dosing ledger',
                                  maxLines: isMobile ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        InteractivePressScale(
                          onTap: () => setState(
                            () => _showAddSkuPanel = !_showAddSkuPanel,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13.0,
                              vertical: 7.0,
                            ),
                            decoration: BoxDecoration(
                              color: colors.freshSkyBlue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showAddSkuPanel
                                      ? Icons.close_rounded
                                      : Icons.add_circle_outline_rounded,
                                  size: 14.0,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5.0),
                                Text(
                                  _showAddSkuPanel
                                      ? 'Close Form'
                                      : '+ Add Inventory SKU',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InteractivePressScale(
                          onTap: _replenishAllLowStock,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13.0,
                              vertical: 7.0,
                            ),
                            decoration: BoxDecoration(
                              color: lowStockItems.isNotEmpty
                                  ? colors.harborNavy
                                  : colors.accentGreen,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  lowStockItems.isNotEmpty
                                      ? Icons.local_shipping_outlined
                                      : Icons.check_circle_outline_rounded,
                                  size: 14.0,
                                  color: lowStockItems.isNotEmpty
                                      ? colors.harborGold
                                      : Colors.white,
                                ),
                                const SizedBox(width: 5.0),
                                Text(
                                  lowStockItems.isNotEmpty
                                      ? (isMobile
                                            ? 'Replenish (${lowStockItems.length})'
                                            : 'Auto-Replenish Low Stock (${lowStockItems.length})')
                                      : 'Stock Healthy',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_showAddSkuPanel) ...[
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: colors.freshSkyBlue.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register New Consumable or Packaging SKU (KES)',
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children:
                              [
                                'Detergents',
                                'Solvents',
                                'Addons',
                                'Packaging',
                              ].map((cat) {
                                final isSelected = _newSkuCategory == cat;
                                return InteractivePressScale(
                                  onTap: () =>
                                      setState(() => _newSkuCategory = cat),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11.0,
                                      vertical: 6.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colors.harborNavy
                                          : colors.cardBackground,
                                      borderRadius: BorderRadius.circular(99.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.harborNavy
                                            : colors.borderSubtle,
                                      ),
                                    ),
                                    child: Text(
                                      cat,
                                      style: textTheme.labelSmall?.copyWith(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 12.0),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: [
                            SizedBox(
                              width: 240.0,
                              height: 38.0,
                              child: TextField(
                                controller: _newSkuNameController,
                                style: const TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                  hintText: 'SKU Name (fabric softener 20L)',
                                  filled: true,
                                  fillColor: colors.cardBackground,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
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
                            SizedBox(
                              width: 170.0,
                              height: 38.0,
                              child: TextField(
                                controller: _newSkuSupplierController,
                                style: const TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                  hintText: 'Supplier name',
                                  filled: true,
                                  fillColor: colors.cardBackground,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
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
                            SizedBox(
                              width: 110.0,
                              height: 38.0,
                              child: TextField(
                                controller: _newSkuCostController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                  hintText: 'Unit Cost KES',
                                  filled: true,
                                  fillColor: colors.cardBackground,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
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
                            SizedBox(
                              width: 90.0,
                              height: 38.0,
                              child: TextField(
                                controller: _newSkuQtyController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                  hintText: 'Initial Qty',
                                  filled: true,
                                  fillColor: colors.cardBackground,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
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
                            InteractivePressScale(
                              onTap: _registerNewSku,
                              child: Container(
                                height: 38.0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.accentGreen,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Save SKU to Inventory',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                AnimatedSwitcher(
                  duration: motion.shortDuration,
                  child: _statusBanner == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 9.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F8EF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              _statusBanner!,
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF15803D),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),

          // Unified Integrated Inventory Metrics Strip
          _buildIntegratedInventoryStrip(
            context: context,
            colors: colors,
            textTheme: textTheme,
            totalValuationKes: totalValuationKes,
            lowStockItemsCount: lowStockItems.length,
            activeWashOrders: activeWashOrders,
            packagingUnits: packagingUnits,
          ),
          const SizedBox(height: 14.0),

          // Split-Screen Main Content: Left = Stock Telemetry List, Right = Purchase Orders & Live Dosing Log
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960.0;

              final stockListCard = _buildStockCatalogCard(
                context,
                colors,
                textTheme,
                motion,
                categories,
                filtered,
              );

              final rightSideColumn = Column(
                children: [
                  _buildReorderQueueCard(
                    context,
                    colors,
                    textTheme,
                    lowStockItems,
                  ),
                  const SizedBox(height: 16.0),
                  _buildConsumptionFeedCard(
                    context,
                    colors,
                    textTheme,
                    ordersState,
                  ),
                ],
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 63, child: stockListCard),
                    const SizedBox(width: 16.0),
                    Expanded(flex: 37, child: rightSideColumn),
                  ],
                );
              }

              return Column(
                children: [
                  stockListCard,
                  const SizedBox(height: 16.0),
                  rightSideColumn,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStockCatalogCard(
    BuildContext context,
    AppColors colors,
    TextTheme textTheme,
    AppMotion motion,
    List<String> categories,
    List<_InventoryStockItem> filtered,
  ) {
    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
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
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Stock Items & Supplies (${filtered.length})',
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(
                width: 250.0,
                height: 36.0,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search SKU, chemical, or supplier',
                    hintStyle: textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      color: colors.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 16.0,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(99.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(99.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return InteractivePressScale(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: motion.shortDuration,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 7.0,
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
                  child: Text(
                    cat,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : colors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),
          if (filtered.isEmpty)
            AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Inventory Ledger Empty',
              description: 'No stock items match your search or filter. Add a stock SKU to track chemicals, solvents, and packaging.',
              actionLabel: '+ Add Stock SKU',
              actionIcon: Icons.add_box_rounded,
              onAction: () => setState(() => _showAddSkuPanel = true),
            )
          else
            for (var i = 0; i < filtered.length; i++) ...[
              if (i > 0) const SizedBox(height: 12.0),
              _buildStockItemTile(colors, textTheme, filtered[i]),
            ],
        ],
      ),
    );
  }

  Widget _buildStockItemTile(
    AppColors colors,
    TextTheme textTheme,
    _InventoryStockItem item,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: item.isLowStock
            ? const Color(0xFFFFF5F5)
            : colors.background.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: item.isLowStock
              ? const Color(0xFFFCA5A5)
              : colors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.harborNavy,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          item.sku,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.harborGold,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        item.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Supplier: ${item.supplier} • ${_formatKes(item.unitCostKes)}/${item.unitLabel} • ${item.linkedService}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: item.isLowStock
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(99.0),
                    ),
                    child: Text(
                      '${item.quantity}/${item.maxCapacity} ${item.unitLabel} • ~${item.daysRemaining}d left',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.0,
                        color: item.isLowStock
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF15803D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InteractivePressScale(
                    onTap: () {
                      final idx = _items.indexWhere((it) => it.sku == item.sku);
                      if (idx >= 0) _adjustStock(idx, -1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Text(
                        '-1 Use',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  InteractivePressScale(
                    onTap: () {
                      final idx = _items.indexWhere((it) => it.sku == item.sku);
                      if (idx >= 0) _adjustStock(idx, 3);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: colors.harborNavy,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '+3 Restock',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(99.0),
            child: LinearProgressIndicator(
              value: item.stockRatio,
              minHeight: 7.0,
              backgroundColor: colors.borderSubtle,
              color: item.isLowStock
                  ? const Color(0xFFDC2626)
                  : colors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderQueueCard(
    BuildContext context,
    AppColors colors,
    TextTheme textTheme,
    List<_InventoryStockItem> lowStockItems,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
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
          Row(
            children: [
              Icon(
                Icons.shopping_cart_checkout_rounded,
                size: 18.0,
                color: colors.harborNavy,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Supplier Reorder Queue',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: lowStockItems.isEmpty
                      ? const Color(0xFFE6F8EF)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Text(
                  lowStockItems.isEmpty
                      ? '0 Pending'
                      : '${lowStockItems.length} Low SKU',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: lowStockItems.isEmpty
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (lowStockItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'All chemical drums and packaging bundles are above their minimum reorder threshold.',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF15803D),
                ),
              ),
            )
          else
            for (final item in lowStockItems) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.sku} • ${item.name}',
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        '${item.supplier} • Order ${item.maxCapacity - item.quantity} ${item.unitLabel} (${_formatKes((item.maxCapacity - item.quantity) * item.unitCostKes)})',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.0,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      InteractivePressScale(
                        onTap: () {
                          final idx = _items.indexWhere(
                            (it) => it.sku == item.sku,
                          );
                          if (idx >= 0) {
                            _adjustStock(
                              idx,
                              item.maxCapacity - item.quantity,
                              customReason: 'Approved PO • ${item.supplier}',
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                          decoration: BoxDecoration(
                            color: colors.harborNavy,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Approve PO & Fill to ${item.maxCapacity} ${item.unitLabel}',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildConsumptionFeedCard(
    BuildContext context,
    AppColors colors,
    TextTheme textTheme,
    OrderDetailsUiState ordersState,
  ) {
    final liveOrders = ordersState.orders.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
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
          Row(
            children: [
              Icon(
                Icons.history_edu_rounded,
                size: 18.0,
                color: colors.freshSkyBlue,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Live Dosing & Stock Ledger',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          for (final log in _sessionLogs.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: log.isRestock
                      ? const Color(0xFFE6F8EF)
                      : colors.background,
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.sku} • ${log.itemName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            '${log.referenceLabel} • ${log.timestampLabel}',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 10.0,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      log.deltaLabel,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        color: log.isRestock
                            ? const Color(0xFF15803D)
                            : colors.harborNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          for (final order in liveOrders)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InteractivePressScale(
                onTap: () => widget.onOpenOrderDetails?.call(order.orderId),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(9.0),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.orderId} • ${order.customerName}',
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                color: colors.freshSkyBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              '${order.primaryService} • ${order.vendorBranch} • ${order.displayAmount}',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 10.0,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '-120ml Dosed →',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: colors.freshSkyBlue,
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

  Widget _buildIntegratedInventoryStrip({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required int totalValuationKes,
    required int lowStockItemsCount,
    required int activeWashOrders,
    required int packagingUnits,
  }) {
    final metrics = [
      (
        icon: Icons.inventory_2_outlined,
        iconBg: colors.freshSkyBlue,
        title: 'STOCK VALUATION',
        value: _formatKes(totalValuationKes),
        meta: '${_items.length} SKUs across 4 suppliers',
        metaColor: colors.accentGreen,
      ),
      (
        icon: Icons.warning_amber_rounded,
        iconBg: lowStockItemsCount > 0
            ? const Color(0xFFDC2626)
            : colors.accentGreen,
        title: 'LOW-STOCK ALERTS',
        value: '$lowStockItemsCount SKUs',
        meta: lowStockItemsCount == 0
            ? 'Optimal capacity'
            : 'Requires replenishment',
        metaColor: lowStockItemsCount > 0
            ? const Color(0xFFDC2626)
            : colors.accentGreen,
      ),
      (
        icon: Icons.science_outlined,
        iconBg: colors.harborNavy,
        title: 'FLOOR DOSING',
        value: '$activeWashOrders Loads',
        meta: '120ml / load automated',
        metaColor: colors.freshSkyBlue,
      ),
      (
        icon: Icons.dry_cleaning_outlined,
        iconBg: colors.accentGreen,
        title: 'PACKAGING ROLLS',
        value: '$packagingUnits Bundles',
        meta: '24-day operating reserve',
        metaColor: colors.accentGreen,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820.0;
          if (isWide) {
            return IntrinsicHeight(
              child: Row(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    if (i > 0)
                      VerticalDivider(
                        width: 1.0,
                        thickness: 1.0,
                        color: colors.borderSubtle,
                      ),
                    Expanded(
                      child: _InventoryMetricStripTile(data: metrics[i]),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: colors.borderSubtle,
                  ),
                _InventoryMetricStripTile(data: metrics[i]),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InventoryMetricStripTile extends StatelessWidget {
  const _InventoryMetricStripTile({required this.data});

  final ({
    IconData icon,
    Color iconBg,
    String title,
    String value,
    String meta,
    Color metaColor,
  })
  data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: data.iconBg.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(data.icon, size: 19.0, color: data.iconBg),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  data.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: data.metaColor,
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
