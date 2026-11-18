import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/errors/app_failure.dart';
import 'package:laundry_ridge/core/utilities/client_ref.dart';
import 'package:laundry_ridge/core/utilities/document_templates.dart';
import 'package:laundry_ridge/core/utilities/file_saver.dart';
import 'package:laundry_ridge/features/orders/data/orders_repository.dart';
import 'package:laundry_ridge/features/orders/domain/order_payment.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
import 'package:laundry_ridge/core/widgets/app_pagination_bar.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/core/widgets/shared_axis_page_transition.dart';

enum PaymentStatusFilter {
  all('All Statuses'),
  paid('Paid'),
  partial('Partial'),
  unpaid('Unpaid');

  const PaymentStatusFilter(this.label);
  final String label;
}

enum PaymentPeriodFilter {
  all('All Periods'),
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month');

  const PaymentPeriodFilter(this.label);
  final String label;
}

class _PaymentLedgerRow {
  const _PaymentLedgerRow({
    required this.txId,
    required this.orderId,
    required this.customerName,
    required this.channel,
    required this.referenceCode,
    required this.amountKes,
    required this.balanceDueKes,
    required this.status,
    required this.timestamp,
    required this.periodScope,
    this.customerPhone = '+254 712 000 000',
  });

  final String txId;
  final String orderId;
  final String customerName;
  final String channel;
  final String referenceCode;
  final int amountKes;
  final int balanceDueKes;
  final String status;
  final String timestamp;
  final PaymentPeriodFilter periodScope;
  final String customerPhone;

  String get amountLabel => 'KES ${_formatAmount(amountKes)}';
  String get balanceLabel => balanceDueKes == 0
      ? 'Cleared • KES 0 Due'
      : 'KES ${_formatAmount(balanceDueKes)} Due';

  _PaymentLedgerRow copyWith({
    String? status,
    int? balanceDueKes,
    String? timestamp,
  }) {
    return _PaymentLedgerRow(
      txId: txId,
      orderId: orderId,
      customerName: customerName,
      channel: channel,
      referenceCode: referenceCode,
      amountKes: amountKes,
      balanceDueKes: balanceDueKes ?? this.balanceDueKes,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      periodScope: periodScope,
      customerPhone: customerPhone,
    );
  }

  static String _formatAmount(int amount) {
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

class PaymentsView extends ConsumerStatefulWidget {
  const PaymentsView({super.key, this.onOpenOrderDetails});

  final ValueChanged<String>? onOpenOrderDetails;

  @override
  ConsumerState<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends ConsumerState<PaymentsView> {
  String _searchQuery = '';
  PaymentStatusFilter _selectedStatusFilter = PaymentStatusFilter.all;
  String _selectedChannel = 'All Channels';
  PaymentPeriodFilter _selectedPeriod = PaymentPeriodFilter.all;
  String? _statusBanner;
  bool _showAddPaymentPanel = false;
  String _newPaymentChannel = 'M-Pesa';
  int _currentPage = 0;

  late final TextEditingController _searchController;
  late final TextEditingController _orderIdController;
  late final TextEditingController _customerController;
  late final TextEditingController _amountKesController;
  late final TextEditingController _referenceController;

  static const List<String> _channels = [
    'All Channels',
    'M-Pesa',
    'Cash',
    'Card',
    'Bank Transfer',
  ];

  late List<_PaymentLedgerRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _orderIdController = TextEditingController();
    _customerController = TextEditingController();
    _amountKesController = TextEditingController();
    _referenceController = TextEditingController();
    _loadSupabasePayments();
  }

  Future<void> _loadSupabasePayments() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      final response = await client
          .from('payment_transactions')
          .select('*')
          .isFilter('voided_at', null)
          .order('created_at', ascending: false);
      if (!mounted) return;
      final loaded = (response as List).map((row) {
        final map = row as Map<String, dynamic>;
        final billed = (map['total_billed_kes'] as num?)?.toInt() ?? 0;
        final paid =
            (map['amount_paid_kes'] ?? map['amount_kes'] as num?)?.toInt() ?? 0;
        final amount = paid > 0 ? paid : billed;
        return _PaymentLedgerRow(
          txId: map['tx_id'] as String? ?? 'TXN-00',
          orderId: map['order_id'] as String? ?? '',
          customerName: map['customer_name'] as String? ?? 'Customer',
          channel: map['channel'] as String? ?? 'M-Pesa',
          referenceCode: map['reference_code'] as String? ?? '',
          amountKes: amount,
          balanceDueKes: (map['balance_due_kes'] as num?)?.toInt() ?? 0,
          status: map['status'] as String? ?? 'Paid',
          timestamp: map['created_at'] != null
              ? '${map['created_at']}'.split('T').first
              : 'Live Entry',
          periodScope: PaymentPeriodFilter.today,
          customerPhone: map['customer_phone'] as String? ?? '',
        );
      }).toList();
      setState(() {
        _rows = loaded;
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _statusBanner = 'Could not load payments from the server.',
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _orderIdController.dispose();
    _customerController.dispose();
    _amountKesController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  bool _isSavingPayment = false;

  /// Records a receipt against an existing order through the same
  /// server-side check the order screen uses (balance, duplicate reference).
  Future<void> _recordNewReceipt() async {
    if (_isSavingPayment) return;
    final orderId = _orderIdController.text.trim().toUpperCase();
    final parsedAmount = double.tryParse(
      _amountKesController.text.trim().replaceAll(',', ''),
    );
    final reference = _referenceController.text.trim();
    if (orderId.isEmpty) {
      setState(
        () => _statusBanner = 'Enter the order number the payment is for.',
      );
      return;
    }
    if (parsedAmount == null || parsedAmount <= 0) {
      setState(() => _statusBanner = 'Enter the amount received.');
      return;
    }
    if (_newPaymentChannel == 'M-Pesa' && reference.isEmpty) {
      setState(() => _statusBanner = 'Enter the M-Pesa confirmation code.');
      return;
    }
    final failure = await _submitPayment(
      orderId: orderId,
      amount: parsedAmount,
      channel: _newPaymentChannel,
      reference: reference,
    );
    if (!mounted) return;
    setState(() {
      if (failure == null) {
        _showAddPaymentPanel = false;
        _orderIdController.clear();
        _customerController.clear();
        _amountKesController.clear();
        _referenceController.clear();
        _statusBanner =
            'Recorded KES ${_PaymentLedgerRow._formatAmount(parsedAmount.round())} via $_newPaymentChannel for $orderId.';
      } else {
        _statusBanner = 'Payment not recorded: $failure';
      }
    });
  }

  /// Collects the outstanding balance on a ledger row's order.
  Future<void> _settleRow(int index) async {
    final row = _rows[index];
    if (row.balanceDueKes <= 0) return;
    final failure = await _submitPayment(
      orderId: row.orderId,
      amount: row.balanceDueKes.toDouble(),
      channel: row.channel,
      reference: null,
    );
    if (!mounted) return;
    setState(() {
      _statusBanner = failure == null
          ? 'Collected KES ${_PaymentLedgerRow._formatAmount(row.balanceDueKes)} balance for ${row.orderId}.'
          : 'Balance not collected: $failure';
    });
  }

  Future<String?> _submitPayment({
    required String orderId,
    required double amount,
    required String channel,
    required String? reference,
  }) async {
    setState(() => _isSavingPayment = true);
    try {
      await ref
          .read(ordersRepositoryProvider)
          .recordPayment(
            orderId,
            OrderPayment(
              amount: amount,
              date: '',
              method: channel,
              reference: (reference?.isEmpty ?? true) ? null : reference,
            ),
            clientRef: newClientRef(),
          );
    } on AppFailure catch (error) {
      return error.message;
    } on Object catch (error) {
      return error.toString();
    } finally {
      if (mounted) setState(() => _isSavingPayment = false);
    }
    await _loadSupabasePayments();
    return null;
  }

  void _exportStatement() {
    final totalKes = _filteredRows.fold<int>(0, (sum, r) => sum + r.amountKes);
    final buffer = StringBuffer();
    buffer.writeln('HARBOR RIDGE LAUNDRY - PAYMENT LEDGER STATEMENT');
    buffer.writeln('Period Filter,${_selectedPeriod.label}');
    buffer.writeln('Channel Filter,$_selectedChannel');
    buffer.writeln('Status Filter,${_selectedStatusFilter.label}');
    buffer.writeln('Exported At,${DateTime.now().toIso8601String()}');
    buffer.writeln('Branch,Harbor Ridge Main');
    buffer.writeln('');
    buffer.writeln(
      'Transaction Ref,Order ID,Timestamp,Customer Name,Customer Phone,Channel,Reference Code,Status,Amount (KES),Balance Due (KES)',
    );
    for (final r in _filteredRows) {
      buffer.writeln(
        [
          csvEscape(r.txId),
          csvEscape(r.orderId),
          csvEscape(r.timestamp),
          csvEscape(r.customerName),
          csvEscape(r.customerPhone),
          csvEscape(r.channel),
          csvEscape(r.referenceCode),
          csvEscape(r.status),
          r.amountKes,
          r.balanceDueKes,
        ].join(','),
      );
    }
    buffer.writeln('');
    buffer.writeln('SUMMARY');
    buffer.writeln('Total Transactions,${_filteredRows.length}');
    buffer.writeln('Total Reconciled (KES),$totalKes');

    final periodSlug = _selectedPeriod.label.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '_',
    );
    final filename = 'harbor_ridge_payments_statement_$periodSlug.csv';
    downloadCsvFile(filename, buffer.toString());

    setState(() {
      _statusBanner =
          'Downloaded $filename • KES ${_PaymentLedgerRow._formatAmount(totalKes)} across ${_filteredRows.length} entries';
    });
  }

  void _printReceipt(_PaymentLedgerRow row) {
    final htmlContent = DocumentTemplates.generatePaymentReceiptHtml(
      txId: row.txId,
      orderId: row.orderId,
      customerName: row.customerName,
      date: row.timestamp,
      method: '${row.channel} (${row.referenceCode})',
      amountKes: row.amountKes,
      status: row.status,
    );
    printHtmlDocument('Receipt - ${row.txId}', htmlContent);
    setState(() {
      _statusBanner =
          'Printed official payment receipt for ${row.txId} (${row.orderId})';
    });
  }

  List<_PaymentLedgerRow> get _filteredRows {
    return _rows.where((row) {
      if (_selectedStatusFilter != PaymentStatusFilter.all &&
          row.status != _selectedStatusFilter.label) {
        return false;
      }
      if (_selectedChannel != 'All Channels' &&
          row.channel != _selectedChannel) {
        return false;
      }
      if (_selectedPeriod != PaymentPeriodFilter.all &&
          row.periodScope != _selectedPeriod) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesQuery =
            row.txId.toLowerCase().contains(q) ||
            row.orderId.toLowerCase().contains(q) ||
            row.customerName.toLowerCase().contains(q) ||
            row.referenceCode.toLowerCase().contains(q) ||
            row.customerPhone.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filteredRows;
    final pagedRows = AppPaginationBar.paginate(
      filtered,
      _currentPage,
      pageSize: 6,
    );

    final totalInvoicedKes = _rows.fold<int>(
      0,
      (sum, r) => sum + r.amountKes + r.balanceDueKes,
    );
    final totalCollectedKes = _rows.fold<int>(0, (sum, r) => sum + r.amountKes);
    final totalOutstandingKes = _rows.fold<int>(
      0,
      (sum, r) => sum + r.balanceDueKes,
    );
    final collectionRate = totalInvoicedKes == 0
        ? 100.0
        : (totalCollectedKes / totalInvoicedKes * 100.0);

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
            totalInvoicedKes: totalInvoicedKes,
            totalCollectedKes: totalCollectedKes,
            totalOutstandingKes: totalOutstandingKes,
            collectionRate: collectionRate,
          ),
          const SizedBox(height: 14.0),

          // Section 3: Slide-down Add Payment Panel (when toggled)
          AnimatedSwitcher(
            duration: motion.shortDuration,
            child: _showAddPaymentPanel
                ? _buildAddPaymentDrawer(
                    context: context,
                    colors: colors,
                    textTheme: textTheme,
                  )
                : const SizedBox.shrink(),
          ),

          // Section 4: Live Feedback / Status Banner
          AnimatedSwitcher(
            duration: motion.shortDuration,
            child: _statusBanner == null
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
                              _statusBanner!,
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
                                setState(() => _statusBanner = null),
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

          // Section 6: Official Statement Table / Ledger
          SharedAxisPageTransition.componentSwitch(
            child: KeyedSubtree(
              key: ValueKey(
                'payments_page_${_currentPage}_${_selectedStatusFilter.name}_${_selectedChannel}_${_selectedPeriod.name}',
              ),
              child: _buildStatementLedgerTable(
                context: context,
                colors: colors,
                motion: motion,
                textTheme: textTheme,
                rows: pagedRows,
              ),
            ),
          ),
          if (filtered.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            AppPaginationBar(
              currentPage: _currentPage,
              totalItems: filtered.length,
              pageSize: 6,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
          ],
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? (screenWidth - 68.0).clamp(200.0, 500.0)
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
                    Icons.account_balance_wallet_outlined,
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
                        'Invoices & Payment Ledger',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: AppTypography.pageTitleSize,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Official statement of accounts, M-Pesa reconciliations & receivables ledger',
                        maxLines: isMobile ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
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
                onTap: _exportStatement,
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
                        Icons.download_rounded,
                        size: 14.0,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Download Statement',
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
                  () => _showAddPaymentPanel = !_showAddPaymentPanel,
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
                        _showAddPaymentPanel
                            ? Icons.close_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 14.0,
                        color: colors.harborGold,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        _showAddPaymentPanel
                            ? 'Close Form'
                            : '+ Record Payment (KES)',
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
      ),
    );
  }

  Widget _buildIntegratedSummaryStrip({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required int totalInvoicedKes,
    required int totalCollectedKes,
    required int totalOutstandingKes,
    required double collectionRate,
  }) {
    final metrics = [
      (
        icon: Icons.receipt_long_outlined,
        iconBg: colors.freshSkyBlue,
        title: 'TOTAL INVOICED',
        value: 'KES ${_PaymentLedgerRow._formatAmount(totalInvoicedKes)}',
        meta: '${_rows.length} Billed Orders',
        metaColor: colors.textSecondary,
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        iconBg: colors.accentGreen,
        title: 'COLLECTED RECEIPTS',
        value: 'KES ${_PaymentLedgerRow._formatAmount(totalCollectedKes)}',
        meta: '${collectionRate.toStringAsFixed(1)}% Reconciled Cleared',
        metaColor: colors.accentGreen,
      ),
      (
        icon: Icons.pending_actions_rounded,
        iconBg: colors.accentOrange,
        title: 'OUTSTANDING DUE',
        value: 'KES ${_PaymentLedgerRow._formatAmount(totalOutstandingKes)}',
        meta: totalOutstandingKes == 0
            ? 'All accounts cleared'
            : 'Receivables requiring follow-up',
        metaColor: totalOutstandingKes > 0
            ? colors.accentOrange
            : colors.accentGreen,
      ),
      (
        icon: Icons.phone_android_rounded,
        iconBg: colors.harborGold,
        title: 'PRIMARY CHANNEL',
        value: 'M-Pesa (64%)',
        meta: 'KES 16,400 via Daraja Till',
        metaColor: colors.freshSkyBlue,
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
                    Expanded(child: _PaymentMetricStripTile(data: metrics[i])),
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
                _PaymentMetricStripTile(data: metrics[i]),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddPaymentDrawer({
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
                Icons.add_card_rounded,
                size: 16.0,
                color: colors.freshSkyBlue,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Record Payment Receipt to Ledger',
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
              SizedBox(
                width: 160.0,
                height: 38.0,
                child: TextField(
                  controller: _orderIdController,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Order ID',
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
                width: 180.0,
                height: 38.0,
                child: TextField(
                  controller: _customerController,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
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
                width: 140.0,
                height: 38.0,
                child: TextField(
                  controller: _amountKesController,
                  keyboardType: TextInputType.number,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount (KES)',
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
                width: 170.0,
                height: 38.0,
                child: TextField(
                  controller: _referenceController,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Ref / M-Pesa Code',
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
                  for (final ch in [
                    'M-Pesa',
                    'Cash',
                    'Card',
                    'Bank Transfer',
                  ]) ...[
                    InteractivePressScale(
                      onTap: () => setState(() => _newPaymentChannel = ch),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: _newPaymentChannel == ch
                              ? colors.harborNavy
                              : colors.background,
                          borderRadius: BorderRadius.circular(99.0),
                          border: Border.all(
                            color: _newPaymentChannel == ch
                                ? colors.harborNavy
                                : colors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          ch,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w600,
                            color: _newPaymentChannel == ch
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
                onTap: _recordNewReceipt,
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
                    'Save to Statement',
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
                      hintText: 'Search by TXN ref, order #, client, phone, or M-Pesa code...',
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
                  '$filteredCount / ${_rows.length} Ledger Rows',
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

          // Row 2: Status Filters + Channel Filters + Period Scope Filters
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Status Filter Pills
              for (final status in PaymentStatusFilter.values) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedStatusFilter = status),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedStatusFilter == status
                          ? colors.harborNavy
                          : colors.background,
                      borderRadius: BorderRadius.circular(99.0),
                      border: Border.all(
                        color: _selectedStatusFilter == status
                            ? colors.harborNavy
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      status.label,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w600,
                        color: _selectedStatusFilter == status
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

              // Channel Filter Pills
              for (final ch in _channels) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedChannel = ch),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedChannel == ch
                          ? colors.freshSkyBlue
                          : colors.background,
                      borderRadius: BorderRadius.circular(99.0),
                      border: Border.all(
                        color: _selectedChannel == ch
                            ? colors.freshSkyBlue
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      ch,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w600,
                        color: _selectedChannel == ch
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

              // Period Scope Pills
              for (final period in PaymentPeriodFilter.values) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPeriod == period
                          ? colors.harborGold.withValues(alpha: 0.16)
                          : colors.background,
                      borderRadius: BorderRadius.circular(99.0),
                      border: Border.all(
                        color: _selectedPeriod == period
                            ? colors.harborGold
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      period.label,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: _selectedPeriod == period
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

  Widget _buildStatementLedgerTable({
    required BuildContext context,
    required AppColors colors,
    required AppMotion motion,
    required TextTheme textTheme,
    required List<_PaymentLedgerRow> rows,
  }) {
    if (rows.isEmpty) {
      return AppEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Payment Ledger Empty',
        description: 'No matching payment transactions found. Record an intake payment receipt or reset search criteria.',
        actionLabel: '+ Record Payment',
        actionIcon: Icons.add_card_rounded,
        onAction: () => setState(() => _showAddPaymentPanel = true),
        secondaryActionLabel: 'Reset Filters',
        onSecondaryAction: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
            _selectedStatusFilter = PaymentStatusFilter.all;
            _selectedChannel = 'All Channels';
            _selectedPeriod = PaymentPeriodFilter.all;
          });
        },
      );
    }

    final totalFilterAmount = rows.fold<int>(0, (sum, r) => sum + r.amountKes);
    final totalFilterBalance = rows.fold<int>(
      0,
      (sum, r) => sum + r.balanceDueKes,
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
                          'HARBOR RIDGE STATEMENT OF ACCOUNT • BILLING LEDGER',
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
                  'Currency: KES • Statement Verified with M-Pesa Daraja & Cashier Till',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Layout Builder: Responsive Statement Table on Desktop, Compact Rows on Mobile
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 780.0;
              if (isDesktop) {
                return _buildDesktopLedgerView(
                  context: context,
                  colors: colors,
                  textTheme: textTheme,
                  rows: rows,
                );
              }

              return _buildMobileLedgerView(
                context: context,
                colors: colors,
                textTheme: textTheme,
                rows: rows,
              );
            },
          ),

          // Footer: Statement Reconciliation Totals
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
                  'Showing ${rows.length} of ${_rows.length} Transactions',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                Wrap(
                  spacing: 14.0,
                  runSpacing: 6.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Total Billed: KES ${_PaymentLedgerRow._formatAmount(totalFilterAmount + totalFilterBalance)}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Cleared: KES ${_PaymentLedgerRow._formatAmount(totalFilterAmount)}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w800,
                        color: colors.accentGreen,
                      ),
                    ),
                    Text(
                      'Balance Due: KES ${_PaymentLedgerRow._formatAmount(totalFilterBalance)}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w800,
                        color: totalFilterBalance > 0
                            ? colors.accentOrange
                            : colors.accentGreen,
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

  Widget _buildDesktopLedgerView({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required List<_PaymentLedgerRow> rows,
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
                width: 140.0,
                child: Text(
                  'DATE & TIME',
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
                width: 150.0,
                child: Text(
                  'TXN & ORDER REF',
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
                  'CUSTOMER / ACCOUNT',
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
                  'PAYMENT CHANNEL & REF',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 120.0,
                child: Text(
                  'RECEIPT (KES)',
                  textAlign: TextAlign.right,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 120.0,
                child: Text(
                  'BALANCE DUE',
                  textAlign: TextAlign.right,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 90.0,
                child: Text(
                  'STATUS',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 140.0,
                child: Text(
                  'ACTIONS',
                  textAlign: TextAlign.right,
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
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Divider(height: 1.0, thickness: 1.0, color: colors.borderSubtle),
          _buildDesktopRow(
            context: context,
            colors: colors,
            textTheme: textTheme,
            row: rows[i],
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopRow({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required _PaymentLedgerRow row,
  }) {
    final statusColor = row.status == 'Paid'
        ? colors.accentGreen
        : row.status == 'Partial'
        ? colors.accentOrange
        : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Column 1: Date & Time
          SizedBox(
            width: 140.0,
            child: Text(
              row.timestamp,
              style: textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.captionSize,
                color: colors.textSecondary,
              ),
            ),
          ),

          // Column 2: TXN & Order Ref
          SizedBox(
            width: 150.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => widget.onOpenOrderDetails?.call(row.orderId),
                  child: Text(
                    row.orderId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.freshSkyBlue,
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.harborNavy,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    row.txId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.microSize,
                      fontWeight: FontWeight.w800,
                      color: colors.harborGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column 3: Customer / Account
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  row.customerName,
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: AppTypography.bodySmallSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  row.customerPhone,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Column 4: Payment Channel & Ref
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildChannelBadge(row.channel, colors, textTheme),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    row.referenceCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column 5: Amount (KES)
          SizedBox(
            width: 120.0,
            child: Text(
              row.amountLabel,
              textAlign: TextAlign.right,
              style: textTheme.labelMedium?.copyWith(
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
          ),

          // Column 6: Balance Due
          SizedBox(
            width: 120.0,
            child: Text(
              row.balanceLabel,
              textAlign: TextAlign.right,
              style: textTheme.labelSmall?.copyWith(
                fontSize: AppTypography.captionSize,
                fontWeight: FontWeight.w600,
                color: row.balanceDueKes == 0
                    ? colors.accentGreen
                    : colors.accentOrange,
              ),
            ),
          ),

          // Column 7: Status Pill
          SizedBox(
            width: 90.0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Text(
                  row.status,
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
            width: 140.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (row.amountKes > 0)
                    IconButton(
                      icon: Icon(
                        Icons.print_outlined,
                        size: 16.0,
                        color: colors.textSecondary,
                      ),
                      tooltip: 'Print Receipt',
                      onPressed: () => _printReceipt(row),
                    ),
                  if (row.status != 'Paid')
                    InteractivePressScale(
                      onTap: () {
                        final idx = _rows.indexWhere((r) => r.txId == row.txId);
                        if (idx >= 0) _settleRow(idx);
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
                          'Collect KES',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: AppTypography.microSize,
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
      ),
    );
  }

  Widget _buildMobileLedgerView({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required List<_PaymentLedgerRow> rows,
  }) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
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
                              rows[i].txId,
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
                              onTap: () => widget.onOpenOrderDetails?.call(
                                rows[i].orderId,
                              ),
                              child: Text(
                                rows[i].orderId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelMedium?.copyWith(
                                  color: colors.freshSkyBlue,
                                  fontSize: AppTypography.captionSize,
                                  fontWeight: FontWeight.w700,
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
                        rows[i].amountLabel,
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
                        '${rows[i].customerName} • ${rows[i].customerPhone}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        rows[i].balanceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w600,
                          color: rows[i].balanceDueKes == 0
                              ? colors.accentGreen
                              : colors.accentOrange,
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
                          _buildChannelBadge(
                            rows[i].channel,
                            colors,
                            textTheme,
                          ),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Text(
                              rows[i].referenceCode,
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
                    if (rows[i].amountKes > 0) ...[
                      const SizedBox(width: 4.0),
                      IconButton(
                        icon: Icon(
                          Icons.print_outlined,
                          size: 16.0,
                          color: colors.textSecondary,
                        ),
                        tooltip: 'Print Receipt',
                        onPressed: () => _printReceipt(rows[i]),
                      ),
                    ],
                    if (rows[i].status != 'Paid') ...[
                      const SizedBox(width: 6.0),
                      InteractivePressScale(
                        onTap: () {
                          final idx = _rows.indexWhere(
                            (r) => r.txId == rows[i].txId,
                          );
                          if (idx >= 0) _settleRow(idx);
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
                            'Collect Balance',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: AppTypography.microSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChannelBadge(
    String channel,
    AppColors colors,
    TextTheme textTheme,
  ) {
    IconData icon;
    Color color;

    switch (channel) {
      case 'M-Pesa':
        icon = Icons.phone_android_rounded;
        color = colors.accentGreen;
      case 'Card':
        icon = Icons.credit_card_rounded;
        color = colors.freshSkyBlue;
      case 'Cash':
        icon = Icons.payments_outlined;
        color = colors.harborGold;
      default:
        icon = Icons.account_balance_outlined;
        color = colors.harborNavy;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.0, color: color),
          const SizedBox(width: 4.0),
          Text(
            channel,
            style: textTheme.labelSmall?.copyWith(
              fontSize: AppTypography.microSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMetricStripTile extends StatelessWidget {
  const _PaymentMetricStripTile({required this.data});

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
                    fontSize: AppTypography.microSize,
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
                    fontSize: AppTypography.bodySize,
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
                    fontSize: AppTypography.microSize,
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
