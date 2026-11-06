import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class _CustomerProfileRecord {
  const _CustomerProfileRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.branch,
    required this.tier,
    required this.totalSpend,
    required this.ordersCount,
    required this.recentOrderIds,
    required this.preferredService,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String branch;
  final String tier;
  final String totalSpend;
  final int ordersCount;
  final List<String> recentOrderIds;
  final String preferredService;
}

class CustomersView extends ConsumerStatefulWidget {
  const CustomersView({
    super.key,
    this.onOpenOrderDetails,
    this.onStartPosOrder,
  });

  final ValueChanged<String>? onOpenOrderDetails;
  final VoidCallback? onStartPosOrder;

  @override
  ConsumerState<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends ConsumerState<CustomersView> {
  String _selectedTier = 'All';
  int _selectedIndex = 0;

  late final TextEditingController _newNameController;
  late final TextEditingController _newPhoneController;

  late List<_CustomerProfileRecord> _customers = const [];

  @override
  void initState() {
    super.initState();
    _newNameController = TextEditingController();
    _newPhoneController = TextEditingController();
    _loadSupabaseCustomers();
  }

  Future<void> _loadSupabaseCustomers() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      final response = await client
          .from('orders')
          .select(
            'customer_name, customer_phone, vendor_branch, order_id, display_amount',
          )
          .order('created_at', ascending: false);
      if (!mounted) return;
      final seen = <String>{};
      final loaded = <_CustomerProfileRecord>[];
      for (final raw in (response as List)) {
        final map = raw as Map<String, dynamic>;
        final name = map['customer_name'] as String? ?? 'Customer';
        if (seen.contains(name)) continue;
        seen.add(name);
        loaded.add(
          _CustomerProfileRecord(
            id: 'CUS-00${loaded.length + 1}',
            name: name,
            phone: map['customer_phone'] as String? ?? '',
            email: '${name.toLowerCase().replaceAll(' ', '.')}@client.com',
            branch: map['vendor_branch'] as String? ?? 'Harborridge Main',
            tier: 'Regular',
            totalSpend: map['display_amount'] as String? ?? 'KES 0',
            ordersCount: 1,
            recentOrderIds: [map['order_id'] as String? ?? ''],
            preferredService: 'Wash & Fold',
          ),
        );
      }
      setState(() {
        _customers = loaded;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _newNameController.dispose();
    _newPhoneController.dispose();
    super.dispose();
  }

  void _addNewCustomer() {
    final name = _newNameController.text.trim();
    if (name.isEmpty) return;
    final phone = _newPhoneController.text.trim().isEmpty
        ? '+254 719 800 321'
        : _newPhoneController.text.trim();
    final newRecord = _CustomerProfileRecord(
      id: 'CUS-00${_customers.length + 1}',
      name: name,
      phone: phone,
      email: '${name.toLowerCase().replaceAll(' ', '.')}@client.com',
      branch: 'Harborridge Main',
      tier: 'Regular',
      totalSpend: 'KES 0',
      ordersCount: 1,
      recentOrderIds: const ['LG-2026-00125'],
      preferredService: 'Wash & Iron',
    );
    setState(() {
      _customers = [newRecord, ..._customers];
      _selectedIndex = 0;
      _newNameController.clear();
      _newPhoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    const tiers = ['All', 'VIP Gold', 'Corporate', 'Regular'];
    final filtered = _selectedTier == 'All'
        ? _customers
        : _customers.where((c) => c.tier == _selectedTier).toList();
    final activeCustomer = filtered.isEmpty
        ? (_customers.isNotEmpty ? _customers.first : null)
        : filtered[_selectedIndex.clamp(0, filtered.length - 1)];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 920.0;

          final directoryCard = Container(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Directory & Loyalty Accounts',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Select any customer to inspect preferences, linked invoices, or start a new POS order.',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12.0,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6.0,
                      children: tiers.map((tier) {
                        final isSelected = _selectedTier == tier;
                        return InteractivePressScale(
                          onTap: () => setState(() {
                            _selectedTier = tier;
                            _selectedIndex = 0;
                          }),
                          child: AnimatedContainer(
                            duration: motion.shortDuration,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.harborNavy
                                  : colors.background,
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: Text(
                              tier,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : colors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (filtered.isEmpty)
                  AppEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'Customer Directory Empty',
                    description:
                        'No customer profiles found for the selected tier. Enroll a new customer profile or reset active filters.',
                    actionLabel: 'Reset Filters',
                    actionIcon: Icons.refresh_rounded,
                    onAction: () => setState(() => _selectedTier = 'All'),
                  )
                else
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10.0),
                    InteractivePressScale(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: AnimatedContainer(
                        duration: motion.shortDuration,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: filtered[i].id == activeCustomer?.id
                              ? colors.freshSkyBlue.withValues(alpha: 0.08)
                              : colors.background.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: filtered[i].id == activeCustomer?.id
                                ? colors.freshSkyBlue
                                : colors.borderSubtle,
                            width: filtered[i].id == activeCustomer?.id
                                ? 1.5
                                : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: colors.harborNavy,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              filtered[i].name.substring(0, 1),
                              style: textTheme.labelMedium?.copyWith(
                                color: colors.harborGold,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${filtered[i].name} • ${filtered[i].id}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelMedium?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${filtered[i].phone} • ${filtered[i].branch}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 11.0,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  filtered[i].totalSpend,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelMedium?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${filtered[i].ordersCount} Ords • ${filtered[i].tier}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 11.0,
                                    color: colors.freshSkyBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

          final spotlightCard = Container(
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
            child: activeCustomer == null
                ? const AppEmptyState(
                    icon: Icons.person_outline_rounded,
                    title: 'No Profile Selected',
                    description:
                        'Select a customer to view loyalty status, recent invoices, and preferences.',
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Customer Profile',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.freshSkyBlue,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        activeCustomer.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        '${activeCustomer.email} • ${activeCustomer.phone}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          color: colors.textSecondary,
                        ),
                      ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Care Preference: ${activeCustomer.preferredService}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Primary Branch: ${activeCustomer.branch}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(
                  'Linked Orders (Click to open invoice):',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: activeCustomer.recentOrderIds.map((orderId) {
                    return InteractivePressScale(
                      onTap: () => widget.onOpenOrderDetails?.call(orderId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.freshSkyBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: colors.freshSkyBlue),
                        ),
                        child: Text(
                          'View $orderId →',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.harborNavy,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14.0),
                if (widget.onStartPosOrder != null)
                  SizedBox(
                    width: double.infinity,
                    child: InteractivePressScale(
                      onTap: widget.onStartPosOrder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11.0),
                        decoration: BoxDecoration(
                          color: colors.harborNavy,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+ Create New POS Order for ${activeCustomer.name}',
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18.0),
                Divider(color: colors.borderSubtle),
                const SizedBox(height: 10.0),
                Text(
                  'Quick Register Walk-in Customer',
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _newNameController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Enter customer full name',
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
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _newPhoneController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Use customer mobile number',
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
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  child: InteractivePressScale(
                    onTap: _addNewCustomer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: colors.accentGreen,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Save Customer Profile',
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 60, child: directoryCard),
                const SizedBox(width: 18.0),
                Expanded(flex: 40, child: spotlightCard),
              ],
            );
          }

          return Column(
            children: [
              directoryCard,
              const SizedBox(height: 18.0),
              spotlightCard,
            ],
          );
        },
      ),
    );
  }
}
