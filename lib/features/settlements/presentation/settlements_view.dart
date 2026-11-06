import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

enum SettlementStatusFilter {
  all('All Statuses'),
  readyForPayout('Ready for Payout'),
  settled('Settled');

  const SettlementStatusFilter(this.label);
  final String label;
}

enum SettlementCycleFilter {
  all('All Cycles'),
  week46('Week 46 (Current)'),
  week45('Week 45'),
  week44('Week 44');

  const SettlementCycleFilter(this.label);
  final String label;
}

class _SettlementBatchRecord {
  const _SettlementBatchRecord({
    required this.batchCode,
    required this.vendorName,
    required this.ordersCovered,
    required this.grossVolumeKes,
    required this.commissionRatePercent,
    required this.commissionFeeKes,
    required this.netPayoutKes,
    required this.status,
    required this.cycle,
    required this.disbursalMethod,
    required this.accountNumber,
    required this.reconciledTimestamp,
  });

  final String batchCode;
  final String vendorName;
  final String ordersCovered;
  final int grossVolumeKes;
  final int commissionRatePercent;
  final int commissionFeeKes;
  final int netPayoutKes;
  final String status;
  final SettlementCycleFilter cycle;
  final String disbursalMethod; // 'M-Pesa B2B', 'KCB EFT', 'Stanbic Bank'
  final String accountNumber;
  final String reconciledTimestamp;

  String get grossVolume => 'KES ${_formatNumber(grossVolumeKes)}';
  String get commissionFee =>
      'KES ${_formatNumber(commissionFeeKes)} ($commissionRatePercent%)';
  String get netPayout => 'KES ${_formatNumber(netPayoutKes)}';

  _SettlementBatchRecord copyWith({
    String? status,
    String? reconciledTimestamp,
  }) {
    return _SettlementBatchRecord(
      batchCode: batchCode,
      vendorName: vendorName,
      ordersCovered: ordersCovered,
      grossVolumeKes: grossVolumeKes,
      commissionRatePercent: commissionRatePercent,
      commissionFeeKes: commissionFeeKes,
      netPayoutKes: netPayoutKes,
      status: status ?? this.status,
      cycle: cycle,
      disbursalMethod: disbursalMethod,
      accountNumber: accountNumber,
      reconciledTimestamp: reconciledTimestamp ?? this.reconciledTimestamp,
    );
  }

  static String _formatNumber(int amount) {
    final s = amount.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}

class SettlementsView extends ConsumerStatefulWidget {
  const SettlementsView({super.key, this.onFilterOrdersByBranch});

  final ValueChanged<String>? onFilterOrdersByBranch;

  @override
  ConsumerState<SettlementsView> createState() => _SettlementsViewState();
}

class _SettlementsViewState extends ConsumerState<SettlementsView> {
  String _searchQuery = '';
  SettlementStatusFilter _selectedStatus = SettlementStatusFilter.all;
  String _selectedBranch = 'All Branches';
  SettlementCycleFilter _selectedCycle = SettlementCycleFilter.all;
  String? _statusMessage;
  bool _showCreateBatchPanel = false;

  String _newBatchBranch = 'LaundryGo Nairobi';
  int _newBatchCommissionRate = 15;
  String _newBatchDisbursal = 'M-Pesa B2B';

  late final TextEditingController _searchController;
  late final TextEditingController _grossKesController;
  late final TextEditingController _ordersCoveredController;
  late final TextEditingController _accountNumberController;

  static const List<String> _branchOptions = [
    'All Branches',
    'LaundryGo Nairobi',
    'LaundryGo Westlands',
    'LaundryGo Kilimani',
    'Harborridge Central Hub',
  ];

  late List<_SettlementBatchRecord> _batches = const [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _grossKesController = TextEditingController(text: '92000');
    _ordersCoveredController = TextEditingController(
      text: '84 Completed Orders • 760 lbs',
    );
    _accountNumberController = TextEditingController(text: 'Till 994820');
    _loadSupabaseSettlements();
  }

  Future<void> _loadSupabaseSettlements() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      final response = await client
          .from('settlement_batches')
          .select('*')
          .order('created_at', ascending: false);
      if (!mounted) return;
      final loaded = (response as List).map((row) {
        final map = row as Map<String, dynamic>;
        final gross = (map['gross_volume_kes'] as num?)?.toInt() ?? 0;
        final commRate =
            (map['commission_rate_percent'] as num?)?.toInt() ?? 15;
        final commFee = (gross * (commRate / 100.0)).round();
        return _SettlementBatchRecord(
          batchCode: map['batch_code'] as String? ?? 'STL-00',
          vendorName: map['vendor_name'] as String? ?? 'Partner Vendor',
          ordersCovered: map['orders_covered'] as String? ?? '0 Orders',
          grossVolumeKes: gross,
          commissionRatePercent: commRate,
          commissionFeeKes: commFee,
          netPayoutKes:
              (map['net_payout_kes'] as num?)?.toInt() ?? (gross - commFee),
          status: map['status'] as String? ?? 'Ready for Payout',
          cycle: SettlementCycleFilter.week46,
          disbursalMethod: map['disbursal_method'] as String? ?? 'M-Pesa B2B',
          accountNumber: map['account_number'] as String? ?? '',
          reconciledTimestamp:
              map['reconciled_timestamp'] as String? ?? 'Audited',
        );
      }).toList();
      setState(() {
        _batches = loaded;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _grossKesController.dispose();
    _ordersCoveredController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _generateSettlementBatch() {
    final grossKes = int.tryParse(_grossKesController.text.trim()) ?? 92000;
    final feeKes = (grossKes * (_newBatchCommissionRate / 100.0)).round();
    final netKes = grossKes - feeKes;
    final batchCode = 'STL-${401 + _batches.length}';
    final ordersCovered = _ordersCoveredController.text.trim().isEmpty
        ? '84 Completed Orders • 760 lbs'
        : _ordersCoveredController.text.trim();
    final acc = _accountNumberController.text.trim().isEmpty
        ? 'Till 994820'
        : _accountNumberController.text.trim();

    final newBatch = _SettlementBatchRecord(
      batchCode: batchCode,
      vendorName: _newBatchBranch,
      ordersCovered: ordersCovered,
      grossVolumeKes: grossKes,
      commissionRatePercent: _newBatchCommissionRate,
      commissionFeeKes: feeKes,
      netPayoutKes: netKes,
      status: 'Ready for Payout',
      cycle: SettlementCycleFilter.week46,
      disbursalMethod: _newBatchDisbursal,
      accountNumber: acc,
      reconciledTimestamp: 'Just now • Generated & Queued',
    );

    setState(() {
      _batches = [newBatch, ..._batches];
      _showCreateBatchPanel = false;
      _statusMessage =
          'Generated $batchCode for $_newBatchBranch (Net Payout: KES ${_SettlementBatchRecord._formatNumber(netKes)} via $_newBatchDisbursal)';
    });
  }

  void _disburseBatch(int index) {
    final batch = _batches[index];
    setState(() {
      _batches = [
        for (var i = 0; i < _batches.length; i++)
          if (i == index)
            batch.copyWith(
              status: 'Settled',
              reconciledTimestamp:
                  'Disbursed just now via ${batch.disbursalMethod}',
            )
          else
            _batches[i],
      ];
      _statusMessage =
          'Disbursed ${batch.netPayout} to ${batch.vendorName} (${batch.batchCode} • ${batch.disbursalMethod} ${batch.accountNumber})';
    });
  }

  void _exportRemittanceAdvice() {
    final totalDisbursed = _filteredBatches.fold<int>(
      0,
      (sum, b) => sum + b.netPayoutKes,
    );
    setState(() {
      _statusMessage =
          'Remittance Advice statement exported • Total Net Disbursals: KES ${_SettlementBatchRecord._formatNumber(totalDisbursed)} across ${_filteredBatches.length} partner batches.';
    });
  }

  List<_SettlementBatchRecord> get _filteredBatches {
    return _batches.where((batch) {
      if (_selectedStatus != SettlementStatusFilter.all &&
          batch.status != _selectedStatus.label) {
        return false;
      }
      if (_selectedBranch != 'All Branches' &&
          batch.vendorName != _selectedBranch) {
        return false;
      }
      if (_selectedCycle != SettlementCycleFilter.all &&
          batch.cycle != _selectedCycle) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches =
            batch.batchCode.toLowerCase().contains(q) ||
            batch.vendorName.toLowerCase().contains(q) ||
            batch.ordersCovered.toLowerCase().contains(q) ||
            batch.accountNumber.toLowerCase().contains(q) ||
            batch.disbursalMethod.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filteredBatches;

    final totalGrossKes = _batches.fold<int>(
      0,
      (sum, b) => sum + b.grossVolumeKes,
    );
    final totalCommissionKes = _batches.fold<int>(
      0,
      (sum, b) => sum + b.commissionFeeKes,
    );
    final totalNetPayoutKes = _batches.fold<int>(
      0,
      (sum, b) => sum + b.netPayoutKes,
    );
    final pendingPayoutKes = _batches
        .where((b) => b.status != 'Settled')
        .fold<int>(0, (sum, b) => sum + b.netPayoutKes);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Streamlined Header Toolbar (no bulky outer card container)
          _buildHeaderToolbar(
            context: context,
            colors: colors,
            motion: motion,
            textTheme: textTheme,
          ),
          const SizedBox(height: 14.0),

          // Section 2: Integrated Statement Summary Strip (single rounded surface, hairline dividers)
          _buildIntegratedSummaryStrip(
            context: context,
            colors: colors,
            textTheme: textTheme,
            totalGrossKes: totalGrossKes,
            totalCommissionKes: totalCommissionKes,
            totalNetPayoutKes: totalNetPayoutKes,
            pendingPayoutKes: pendingPayoutKes,
          ),
          const SizedBox(height: 14.0),

          // Section 3: Slide-down Create Batch Drawer (when toggled)
          AnimatedSwitcher(
            duration: motion.shortDuration,
            child: _showCreateBatchPanel
                ? _buildCreateBatchDrawer(
                    context: context,
                    colors: colors,
                    textTheme: textTheme,
                  )
                : const SizedBox.shrink(),
          ),

          // Section 4: Live Feedback / Status Message Banner
          AnimatedSwitcher(
            duration: motion.shortDuration,
            child: _statusMessage == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: colors.freshSkyBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: colors.freshSkyBlue.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16.0,
                            color: colors.harborNavy,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _statusMessage!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.harborNavy,
                                fontSize: AppTypography.bodySmallSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16.0),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: colors.harborNavy,
                            onPressed: () =>
                                setState(() => _statusMessage = null),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Section 5: Filter & Search Bar
          _buildFilterAndSearchBar(
            context: context,
            colors: colors,
            motion: motion,
            textTheme: textTheme,
            filteredCount: filtered.length,
          ),
          const SizedBox(height: 14.0),

          // Section 6: Official Settlement Statement Ledger Table
          _buildSettlementLedgerTable(
            context: context,
            colors: colors,
            motion: motion,
            textTheme: textTheme,
            batches: filtered,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderToolbar({
    required BuildContext context,
    required AppColors colors,
    required AppMotion motion,
    required TextTheme textTheme,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768.0;

    return Wrap(
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
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.balance_rounded,
                  size: 20.0,
                  color: colors.freshSkyBlue,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Payouts & Commission Settlements',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Automated commission split, escrow disbursements & partner payout statement',
                      maxLines: isMobile ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
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
              onTap: _exportRemittanceAdvice,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13.0,
                  vertical: 8.0,
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
                      Icons.description_outlined,
                      size: 14.0,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'Remittance Advice',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InteractivePressScale(
              onTap: () => setState(
                () => _showCreateBatchPanel = !_showCreateBatchPanel,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: colors.harborNavy,
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showCreateBatchPanel
                          ? Icons.close_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 14.0,
                      color: colors.harborGold,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      _showCreateBatchPanel
                          ? 'Close Form'
                          : '+ Generate Batch (KES)',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntegratedSummaryStrip({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required int totalGrossKes,
    required int totalCommissionKes,
    required int totalNetPayoutKes,
    required int pendingPayoutKes,
  }) {
    final effectiveTakeRate = totalGrossKes == 0
        ? 15.0
        : (totalCommissionKes / totalGrossKes * 100.0);

    final metrics = [
      (
        icon: Icons.account_balance_wallet_outlined,
        iconBg: colors.freshSkyBlue,
        title: 'GROSS VOLUME',
        value: 'KES ${_SettlementBatchRecord._formatNumber(totalGrossKes)}',
        meta: '${_batches.length} Batch Reconciliations',
        metaColor: colors.textSecondary,
      ),
      (
        icon: Icons.pie_chart_outline_rounded,
        iconBg: colors.harborGold,
        title: 'PLATFORM COMMISSION',
        value:
            'KES ${_SettlementBatchRecord._formatNumber(totalCommissionKes)}',
        meta: '${effectiveTakeRate.toStringAsFixed(1)}% Avg Take-Rate',
        metaColor: colors.freshSkyBlue,
      ),
      (
        icon: Icons.payments_outlined,
        iconBg: colors.accentGreen,
        title: 'NET VENDOR PAYOUTS',
        value: 'KES ${_SettlementBatchRecord._formatNumber(totalNetPayoutKes)}',
        meta: 'Verified Escrow Net Funds',
        metaColor: colors.accentGreen,
      ),
      (
        icon: Icons.pending_actions_rounded,
        iconBg: colors.accentOrange,
        title: 'AWAITING DISBURSAL',
        value: 'KES ${_SettlementBatchRecord._formatNumber(pendingPayoutKes)}',
        meta: pendingPayoutKes == 0
            ? 'All partner batches paid'
            : 'Pending authorization',
        metaColor: pendingPayoutKes > 0
            ? colors.accentOrange
            : colors.accentGreen,
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
                      child: _SettlementMetricStripTile(data: metrics[i]),
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
                _SettlementMetricStripTile(data: metrics[i]),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreateBatchDrawer({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: colors.freshSkyBlue.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_chart_rounded,
                size: 16.0,
                color: colors.freshSkyBlue,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Generate Branch Payout & Commission Batch',
                style: textTheme.titleSmall?.copyWith(
                  fontSize: AppTypography.subtitleSize,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Branch Picker
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final branch in [
                    'LaundryGo Nairobi',
                    'LaundryGo Westlands',
                    'LaundryGo Kilimani',
                  ]) ...[
                    InteractivePressScale(
                      onTap: () => setState(() => _newBatchBranch = branch),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: _newBatchBranch == branch
                              ? colors.harborNavy
                              : colors.background,
                          borderRadius: BorderRadius.circular(99.0),
                          border: Border.all(
                            color: _newBatchBranch == branch
                                ? colors.harborNavy
                                : colors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          branch,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w600,
                            color: _newBatchBranch == branch
                                ? Colors.white
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(
                width: 220.0,
                height: 38.0,
                child: TextField(
                  controller: _ordersCoveredController,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Orders & Period',
                    labelStyle: TextStyle(
                      fontSize: AppTypography.captionSize,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 150.0,
                height: 38.0,
                child: TextField(
                  controller: _grossKesController,
                  keyboardType: TextInputType.number,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Gross Volume (KES)',
                    labelStyle: TextStyle(
                      fontSize: AppTypography.captionSize,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              // Commission Rate Selector
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final rate in [12, 15, 18]) ...[
                    InteractivePressScale(
                      onTap: () =>
                          setState(() => _newBatchCommissionRate = rate),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: _newBatchCommissionRate == rate
                              ? colors.harborGold.withValues(alpha: 0.25)
                              : colors.background,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _newBatchCommissionRate == rate
                                ? colors.harborGold
                                : colors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          '$rate% Comm.',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w700,
                            color: colors.harborNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(
                width: 160.0,
                height: 38.0,
                child: TextField(
                  controller: _accountNumberController,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Payout Acc / Till',
                    labelStyle: TextStyle(
                      fontSize: AppTypography.captionSize,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final method in [
                    'M-Pesa B2B',
                    'KCB EFT',
                    'Stanbic Bank',
                  ]) ...[
                    InteractivePressScale(
                      onTap: () => setState(() => _newBatchDisbursal = method),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: _newBatchDisbursal == method
                              ? colors.harborNavy
                              : colors.background,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _newBatchDisbursal == method
                                ? colors.harborNavy
                                : colors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          method,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w600,
                            color: _newBatchDisbursal == method
                                ? Colors.white
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              InteractivePressScale(
                onTap: _generateSettlementBatch,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 9.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accentGreen,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Generate Batch',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar({
    required BuildContext context,
    required AppColors colors,
    required AppMotion motion,
    required TextTheme textTheme,
    required int filteredCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Search Field + Results Counter
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38.0,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: AppTypography.bodySmallSize,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by batch code (STL-401), branch, order count, or account...',
                      hintStyle: textTheme.bodySmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        color: colors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 16.0,
                        color: colors.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16.0),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 9.0,
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
                        borderSide: BorderSide(
                          color: colors.freshSkyBlue,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Text(
                  '$filteredCount / ${_batches.length} Batches',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Row 2: Status Filters + Branch Filters + Cycle Scope Filters
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Status Filter Pills
              for (final status in SettlementStatusFilter.values) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedStatus = status),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedStatus == status
                          ? colors.harborNavy
                          : colors.background,
                      borderRadius: BorderRadius.circular(99.0),
                      border: Border.all(
                        color: _selectedStatus == status
                            ? colors.harborNavy
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      status.label,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w600,
                        color: _selectedStatus == status
                            ? Colors.white
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              Container(
                width: 1.0,
                height: 20.0,
                color: colors.borderSubtle,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
              ),

              // Branch Picker Pills
              for (final branch in _branchOptions) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedBranch = branch),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedBranch == branch
                          ? colors.freshSkyBlue
                          : colors.background,
                      borderRadius: BorderRadius.circular(99.0),
                      border: Border.all(
                        color: _selectedBranch == branch
                            ? colors.freshSkyBlue
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      branch,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w600,
                        color: _selectedBranch == branch
                            ? Colors.white
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              Container(
                width: 1.0,
                height: 20.0,
                color: colors.borderSubtle,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
              ),

              // Cycle Filter Pills
              for (final cycle in SettlementCycleFilter.values) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedCycle = cycle),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedCycle == cycle
                          ? colors.harborGold.withValues(alpha: 0.16)
                          : colors.background,
                      borderRadius: BorderRadius.circular(99.0),
                      border: Border.all(
                        color: _selectedCycle == cycle
                            ? colors.harborGold
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      cycle.label,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: _selectedCycle == cycle
                            ? colors.harborNavy
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementLedgerTable({
    required BuildContext context,
    required AppColors colors,
    required AppMotion motion,
    required TextTheme textTheme,
    required List<_SettlementBatchRecord> batches,
  }) {
    if (batches.isEmpty) {
      return AppEmptyState(
        icon: Icons.balance_rounded,
        title: 'Settlement Ledger Empty',
        description: 'No matching settlement batches found. Create a payout batch or reset active filters.',
        actionLabel: '+ New Settlement Batch',
        actionIcon: Icons.post_add_rounded,
        onAction: () => setState(() => _showCreateBatchPanel = true),
        secondaryActionLabel: 'Reset Filters',
        onSecondaryAction: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
            _selectedStatus = SettlementStatusFilter.all;
            _selectedBranch = 'All Branches';
            _selectedCycle = SettlementCycleFilter.all;
          });
        },
      );
    }

    final totalFilterGross = batches.fold<int>(
      0,
      (sum, b) => sum + b.grossVolumeKes,
    );
    final totalFilterFee = batches.fold<int>(
      0,
      (sum, b) => sum + b.commissionFeeKes,
    );
    final totalFilterNet = batches.fold<int>(
      0,
      (sum, b) => sum + b.netPayoutKes,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subheader: Statement Identification Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 11.0,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13.0),
                topRight: Radius.circular(13.0),
              ),
              border: Border(bottom: BorderSide(color: colors.borderSubtle)),
            ),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 6.0,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 64.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 15.0,
                        color: colors.accentGreen,
                      ),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          'HARBORRIDGE SETTLEMENT STATEMENT & VENDOR REMITTANCE LEDGER',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.microSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: colors.harborNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Currency: KES • Authorized Commission Split via Central Escrow Pool',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Layout Builder: Responsive Desktop Table or Compact Mobile Rows
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 780.0;
              if (isDesktop) {
                return _buildDesktopSettlementView(
                  context: context,
                  colors: colors,
                  textTheme: textTheme,
                  batches: batches,
                );
              }

              return _buildMobileSettlementView(
                context: context,
                colors: colors,
                textTheme: textTheme,
                batches: batches,
              );
            },
          ),

          // Footer: Settlement Ledger Reconciliation Totals
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(13.0),
                bottomRight: Radius.circular(13.0),
              ),
              border: Border(top: BorderSide(color: colors.borderSubtle)),
            ),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Showing ${batches.length} of ${_batches.length} Settlement Batches',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                Wrap(
                  spacing: 14.0,
                  runSpacing: 4.0,
                  children: [
                    Text(
                      'Gross: KES ${_SettlementBatchRecord._formatNumber(totalFilterGross)}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Commission: KES ${_SettlementBatchRecord._formatNumber(totalFilterFee)}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w800,
                        color: colors.freshSkyBlue,
                      ),
                    ),
                    Text(
                      'Net Payout: KES ${_SettlementBatchRecord._formatNumber(totalFilterNet)}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w800,
                        color: colors.accentGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSettlementView({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required List<_SettlementBatchRecord> batches,
  }) {
    return Column(
      children: [
        // Table Columns Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: colors.tableHeader,
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 110.0,
                child: Text(
                  'BATCH REF',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'BRANCH / RECIPIENT ACCOUNT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'RECONCILED VOLUME',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 105.0,
                child: Text(
                  'GROSS (KES)',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 115.0,
                child: Text(
                  'COMMISSION',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 115.0,
                child: Text(
                  'NET PAYOUT',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 95.0,
                child: Text(
                  'STATUS',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 115.0,
                child: Text(
                  'ACTIONS',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Statement Rows
        for (var i = 0; i < batches.length; i++) ...[
          if (i > 0)
            Divider(height: 1.0, thickness: 1.0, color: colors.borderSubtle),
          _buildDesktopSettlementRow(
            context: context,
            colors: colors,
            textTheme: textTheme,
            batch: batches[i],
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopSettlementRow({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required _SettlementBatchRecord batch,
  }) {
    final statusColor = batch.status == 'Settled'
        ? colors.accentGreen
        : colors.freshSkyBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Column 1: Batch Ref & Cycle
          SizedBox(
            width: 110.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.harborNavy,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    batch.batchCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.microSize,
                      fontWeight: FontWeight.w800,
                      color: colors.harborGold,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  batch.cycle.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Column 2: Branch / Recipient Account
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () =>
                      widget.onFilterOrdersByBranch?.call(batch.vendorName),
                  child: Text(
                    '${batch.vendorName} →',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      fontSize: AppTypography.bodySmallSize,
                      fontWeight: FontWeight.w700,
                      color: colors.freshSkyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  '${batch.disbursalMethod} • ${batch.accountNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Column 3: Reconciled Volume
          Expanded(
            flex: 3,
            child: Text(
              batch.ordersCovered,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.captionSize,
                color: colors.textSecondary,
              ),
            ),
          ),

          // Column 4: Gross (KES)
          SizedBox(
            width: 105.0,
            child: Text(
              batch.grossVolume,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                fontSize: AppTypography.bodySmallSize,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),

          // Column 5: Commission (KES)
          SizedBox(
            width: 115.0,
            child: Text(
              batch.commissionFee,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                fontSize: AppTypography.captionSize,
                fontWeight: FontWeight.w700,
                color: colors.freshSkyBlue,
              ),
            ),
          ),

          // Column 6: Net Payout (KES)
          SizedBox(
            width: 115.0,
            child: Text(
              batch.netPayout,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),

          // Column 7: Status Pill
          SizedBox(
            width: 95.0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Text(
                  batch.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ),

          // Column 8: Actions
          SizedBox(
            width: 115.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: batch.status != 'Settled'
                  ? InteractivePressScale(
                      onTap: () {
                        final idx = _batches.indexWhere(
                          (b) => b.batchCode == batch.batchCode,
                        );
                        if (idx >= 0) _disburseBatch(idx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accentGreen,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'Disburse KES',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: AppTypography.microSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 17.0,
                        color: colors.accentGreen,
                      ),
                      tooltip: 'Settlement Confirmed',
                      onPressed: () {
                        setState(() {
                          _statusMessage =
                              '${batch.batchCode} settled • Net payout ${batch.netPayout} verified against bank audit trail.';
                        });
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSettlementView({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required List<_SettlementBatchRecord> batches,
  }) {
    return Column(
      children: [
        for (var i = 0; i < batches.length; i++) ...[
          if (i > 0)
            Divider(height: 1.0, thickness: 1.0, color: colors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: colors.harborNavy,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              batches[i].batchCode,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: AppTypography.microSize,
                                fontWeight: FontWeight.w800,
                                color: colors.harborGold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Flexible(
                            child: InkWell(
                              onTap: () => widget.onFilterOrdersByBranch?.call(
                                batches[i].vendorName,
                              ),
                              child: Text(
                                '${batches[i].vendorName} →',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelMedium?.copyWith(
                                  fontSize: AppTypography.captionSize,
                                  fontWeight: FontWeight.w700,
                                  color: colors.freshSkyBlue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        batches[i].netPayout,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        batches[i].ordersCovered,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        'Gross: ${batches[i].grossVolume}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_outlined,
                            size: 13.0,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              '${batches[i].disbursalMethod} • ${batches[i].accountNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: AppTypography.microSize,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    if (batches[i].status != 'Settled')
                      InteractivePressScale(
                        onTap: () {
                          final idx = _batches.indexWhere(
                            (b) => b.batchCode == batches[i].batchCode,
                          );
                          if (idx >= 0) _disburseBatch(idx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accentGreen,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            'Disburse KES',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: AppTypography.microSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accentGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: Text(
                          'Settled',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.microSize,
                            fontWeight: FontWeight.w700,
                            color: colors.accentGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SettlementMetricStripTile extends StatelessWidget {
  const _SettlementMetricStripTile({required this.data});

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: data.iconBg.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9.0),
            ),
            child: Icon(data.icon, size: 18.0, color: data.iconBg),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 15.0,
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
                    fontSize: AppTypography.captionSize,
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
