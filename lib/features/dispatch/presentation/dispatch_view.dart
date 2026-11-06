import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class _DispatchRunItem {
  const _DispatchRunItem({
    required this.runId,
    required this.orderId,
    required this.customerName,
    required this.zone,
    required this.branch,
    required this.riderName,
    required this.etaWindow,
    required this.stage,
    required this.bagCount,
  });

  final String runId;
  final String orderId;
  final String customerName;
  final String zone;
  final String branch;
  final String riderName;
  final String etaWindow;
  final String stage;
  final String bagCount;

  _DispatchRunItem copyWith({
    String? stage,
    String? riderName,
    String? branch,
    String? etaWindow,
  }) {
    return _DispatchRunItem(
      runId: runId,
      orderId: orderId,
      customerName: customerName,
      zone: zone,
      branch: branch ?? this.branch,
      riderName: riderName ?? this.riderName,
      etaWindow: etaWindow ?? this.etaWindow,
      stage: stage ?? this.stage,
      bagCount: bagCount,
    );
  }
}

class DispatchView extends ConsumerStatefulWidget {
  const DispatchView({
    super.key,
    this.onOpenOrderDetails,
    this.onFilterOrdersByBranch,
  });

  final ValueChanged<String>? onOpenOrderDetails;
  final ValueChanged<String>? onFilterOrdersByBranch;

  @override
  ConsumerState<DispatchView> createState() => _DispatchViewState();
}

class _DispatchViewState extends ConsumerState<DispatchView> {
  static const List<String> _validStages = [
    'Pickup assigned',
    'In Transit',
    'Out for Delivery',
    'Delivered',
  ];

  static const List<String> _branches = [
    'All Branches',
    'LaundryGo Nairobi',
    'LaundryGo Westlands',
    'Harborridge Main',
  ];

  String _selectedStageFilter = 'All Runs';
  String _selectedBranchFilter = 'All Branches';
  String _searchQuery = '';
  String? _feedbackBanner;
  bool _showSchedulePanel = false;
  String _newRunRider = 'Peter Mwangi';
  String _newRunBranch = 'LaundryGo Nairobi';

  late final TextEditingController _orderIdController;
  late final TextEditingController _customerController;
  late final TextEditingController _zoneController;
  late final TextEditingController _searchController;

  late List<_DispatchRunItem> _runs = const [];

  @override
  void initState() {
    super.initState();
    _orderIdController = TextEditingController(text: 'LG-2026-00129');
    _customerController = TextEditingController(text: 'Liam O\'Connor');
    _zoneController = TextEditingController(
      text: 'Upper Hill • Hospital Rd Tower',
    );
    _searchController = TextEditingController();
    _loadSupabaseDispatch();
  }

  Future<void> _loadSupabaseDispatch() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      final response = await client
          .from('dispatch_runs')
          .select('*')
          .order('created_at', ascending: false);
      if (!mounted) return;
      final loaded = (response as List).map((row) {
        final map = row as Map<String, dynamic>;
        return _DispatchRunItem(
          runId: map['run_id'] as String? ?? 'DSP-00',
          orderId: map['order_id'] as String? ?? '',
          customerName: map['customer_name'] as String? ?? 'Customer',
          zone: map['zone'] as String? ?? '',
          branch: map['branch'] as String? ?? 'Harborridge Main',
          riderName: map['rider_name'] as String? ?? 'Rider',
          etaWindow: map['eta_window'] as String? ?? '',
          stage: map['stage'] as String? ?? 'Pickup assigned',
          bagCount: map['bag_count'] as String? ?? '1 Bag',
        );
      }).toList();
      setState(() {
        _runs = loaded;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _customerController.dispose();
    _zoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleNewRun() {
    final orderId = _orderIdController.text.trim().isEmpty
        ? 'LG-2026-00129'
        : _orderIdController.text.trim();
    final customer = _customerController.text.trim().isEmpty
        ? 'Walk-in Pickup'
        : _customerController.text.trim();
    final zone = _zoneController.text.trim().isEmpty
        ? 'Kilimani • Ring Rd'
        : _zoneController.text.trim();
    final runCode = 'DSP-${104 + _runs.length}';

    final newRun = _DispatchRunItem(
      runId: runCode,
      orderId: orderId,
      customerName: customer,
      zone: zone,
      branch: _newRunBranch,
      riderName: _newRunRider,
      etaWindow: '16:15 – 16:45',
      stage: 'Pickup assigned',
      bagCount: '2 Bags • Scheduled Pickup',
    );

    setState(() {
      _runs = [newRun, ..._runs];
      _showSchedulePanel = false;
      _feedbackBanner =
          'Dispatched $runCode ($orderId • $customer) to rider $_newRunRider';
    });
  }

  void _updateRunStage(int index, String newStage) {
    if (index < 0 || index >= _runs.length) return;
    final current = _runs[index];
    if (current.stage == newStage) return;

    setState(() {
      _runs = [
        for (var i = 0; i < _runs.length; i++)
          if (i == index) current.copyWith(stage: newStage) else _runs[i],
      ];
      _feedbackBanner =
          'Updated ${current.runId} (${current.orderId}) status to "$newStage"';
    });
  }

  void _reassignRider(int index, String newRider) {
    if (index < 0 || index >= _runs.length) return;
    final current = _runs[index];

    setState(() {
      _runs = [
        for (var i = 0; i < _runs.length; i++)
          if (i == index) current.copyWith(riderName: newRider) else _runs[i],
      ];
      _feedbackBanner =
          'Reassigned ${current.runId} to fleet courier $newRider';
    });
  }

  List<_DispatchRunItem> get _filteredRuns {
    return _runs.where((run) {
      final matchesStage =
          _selectedStageFilter == 'All Runs' ||
          run.stage == _selectedStageFilter;
      final matchesBranch =
          _selectedBranchFilter == 'All Branches' ||
          run.branch == _selectedBranchFilter;

      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          run.runId.toLowerCase().contains(query) ||
          run.orderId.toLowerCase().contains(query) ||
          run.customerName.toLowerCase().contains(query) ||
          run.riderName.toLowerCase().contains(query) ||
          run.zone.toLowerCase().contains(query) ||
          run.branch.toLowerCase().contains(query);

      return matchesStage && matchesBranch && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    final filteredRuns = _filteredRuns;
    final totalRuns = _runs.length;
    final activeRuns = _runs.where((r) => r.stage != 'Delivered').length;
    final inTransitCount = _runs.where((r) => r.stage == 'In Transit').length;
    final deliveredCount = _runs.where((r) => r.stage == 'Delivered').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Toolbar with Title & Action Controls
          _buildHeaderToolbar(context, textTheme, colors, motion),

          const SizedBox(height: 14.0),

          // 2. Feedback Notification Banner
          AnimatedSwitcher(
            duration: motion.shortDuration,
            child: _feedbackBanner == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(_feedbackBanner),
                    margin: const EdgeInsets.only(bottom: 14.0),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16.0,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _feedbackBanner!,
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF065F46),
                              fontSize: AppTypography.captionSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 14.0,
                            color: Color(0xFF059669),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setState(() => _feedbackBanner = null),
                        ),
                      ],
                    ),
                  ),
          ),

          // 3. New Run Scheduling Drawer (Slide-Down)
          if (_showSchedulePanel) ...[
            _buildScheduleRunPanel(context, textTheme, colors),
            const SizedBox(height: 14.0),
          ],

          // 4. Streamlined Dispatch Telemetry Strip (No Cardview Overuse)
          _buildTelemetryStrip(
            context,
            textTheme,
            colors,
            totalRuns: totalRuns,
            activeRuns: activeRuns,
            inTransitCount: inTransitCount,
            deliveredCount: deliveredCount,
          ),

          const SizedBox(height: 14.0),

          // 5. Multi-Criteria Filter Bar (Stage & Branch & Live Search)
          _buildFilterBar(
            context,
            textTheme,
            colors,
            motion,
            filteredCount: filteredRuns.length,
            totalCount: totalRuns,
          ),

          const SizedBox(height: 14.0),

          // 6. Dispatch Manifest Statement Ledger Table
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manifest Table Sub-Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(9.0),
                    ),
                    border: Border(
                      bottom: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 16.0,
                        color: colors.freshSkyBlue,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'LIVE FLEET RUNS & DISPATCH HANDOFF MANIFEST',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '${filteredRuns.length} Active Route Entries',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w700,
                          color: colors.harborNavy,
                        ),
                      ),
                    ],
                  ),
                ),

                // Manifest Rows
                if (filteredRuns.isEmpty)
                  AppEmptyState(
                    icon: Icons.near_me_outlined,
                    title: 'Dispatch Manifest Empty',
                    description: 'No active courier runs or pickup tickets found matching filters. Schedule a dispatch route.',
                    actionLabel: '+ Schedule Dispatch Run',
                    actionIcon: Icons.add_road_rounded,
                    onAction: () => setState(() => _showSchedulePanel = true),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 820.0;
                      if (isWide) {
                        return _buildDesktopManifestTable(
                          context,
                          textTheme,
                          colors,
                          filteredRuns,
                        );
                      }
                      return _buildMobileManifestList(
                        context,
                        textTheme,
                        colors,
                        filteredRuns,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Sub-Components ---

  Widget _buildHeaderToolbar(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    AppMotion motion,
  ) {
    final isMobile = MediaQuery.sizeOf(context).width < 768.0;

    return Container(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.near_me_outlined,
                  size: 20.0,
                  color: colors.freshSkyBlue,
                ),
              ),
              const SizedBox(width: 12.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pickup & Delivery Dispatch Command',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: AppTypography.pageTitleSize,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Live fleet courier routing, pickup manifests, and customer handover tracking.',
                      maxLines: 1,
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
          InteractivePressScale(
            onTap: () =>
                setState(() => _showSchedulePanel = !_showSchedulePanel),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: _showSchedulePanel
                    ? colors.harborNavy
                    : colors.freshSkyBlue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showSchedulePanel
                        ? Icons.keyboard_arrow_up
                        : Icons.add_rounded,
                    size: 15.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    _showSchedulePanel
                        ? (isMobile ? 'Close Form' : 'Close Dispatch Form')
                        : (isMobile
                              ? '+ Schedule Run'
                              : '+ Schedule Dispatch Run'),
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
    );
  }

  Widget _buildScheduleRunPanel(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.freshSkyBlue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_task_outlined,
                size: 16.0,
                color: colors.freshSkyBlue,
              ),
              const SizedBox(width: 8.0),
              Text(
                'SCHEDULE NEW PICKUP / DELIVERY RUN',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: AppTypography.captionSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colors.freshSkyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 150.0,
                height: 38.0,
                child: TextField(
                  controller: _orderIdController,
                  style: const TextStyle(fontSize: 12.0),
                  decoration: InputDecoration(
                    labelText: 'Order ID',
                    labelStyle: TextStyle(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 170.0,
                height: 38.0,
                child: TextField(
                  controller: _customerController,
                  style: const TextStyle(fontSize: 12.0),
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    labelStyle: TextStyle(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 220.0,
                height: 38.0,
                child: TextField(
                  controller: _zoneController,
                  style: const TextStyle(fontSize: 12.0),
                  decoration: InputDecoration(
                    labelText: 'Pickup / Delivery Zone',
                    labelStyle: TextStyle(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              Container(
                height: 38.0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _newRunBranch,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    items:
                        const [
                              'LaundryGo Nairobi',
                              'LaundryGo Westlands',
                              'Harborridge Main',
                            ]
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _newRunBranch = v);
                    },
                  ),
                ),
              ),
              for (final rider in [
                'Peter Mwangi',
                'David Otieno',
                'Samuel Karanja',
              ])
                InteractivePressScale(
                  onTap: () => setState(() => _newRunRider = rider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: _newRunRider == rider
                          ? colors.harborNavy
                          : colors.background,
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: _newRunRider == rider
                            ? colors.harborNavy
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      rider,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: _newRunRider == rider
                            ? Colors.white
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              InteractivePressScale(
                onTap: _scheduleNewRun,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 9.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accentGreen,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    'Assign Rider & Dispatch',
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

  Widget _buildTelemetryStrip(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors, {
    required int totalRuns,
    required int activeRuns,
    required int inTransitCount,
    required int deliveredCount,
  }) {
    final metrics = [
      (
        icon: Icons.directions_bike_outlined,
        color: colors.freshSkyBlue,
        title: 'FLEET RIDERS ACTIVE',
        value: '3 Online',
        sub: 'Peter, David & Samuel',
      ),
      (
        icon: Icons.local_shipping_outlined,
        color: colors.harborGold,
        title: 'ACTIVE MANIFESTS',
        value: '$activeRuns Runs',
        sub: 'Of $totalRuns total logged',
      ),
      (
        icon: Icons.near_me_outlined,
        color: const Color(0xFF4F46E5),
        title: 'EN ROUTE / IN TRANSIT',
        value: '$inTransitCount In Transit',
        sub: 'GPS geofencing live',
      ),
      (
        icon: Icons.verified_outlined,
        color: colors.accentGreen,
        title: 'DELIVERED & CLOSED',
        value: '$deliveredCount Handed Over',
        sub: '98.4% SLA compliance',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760.0;
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
                      child: _buildTelemetryCell(
                        context,
                        textTheme,
                        colors,
                        metrics[i],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          return Wrap(
            children: [
              for (var i = 0; i < metrics.length; i++)
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: _buildTelemetryCell(
                    context,
                    textTheme,
                    colors,
                    metrics[i],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTelemetryCell(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    ({IconData icon, Color color, String title, String value, String sub}) item,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Icon(item.icon, size: 17.0, color: item.color),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: AppTypography.sectionTitleSize,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  item.sub,
                  maxLines: 1,
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
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    AppMotion motion, {
    required int filteredCount,
    required int totalCount,
  }) {
    const stageFilters = [
      'All Runs',
      'Pickup assigned',
      'In Transit',
      'Out for Delivery',
      'Delivered',
    ];

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Search & Branch Selector
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280.0,
                height: 36.0,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 12.0),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by Run ID, Order, Rider, Zone...',
                    hintStyle: TextStyle(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 16.0,
                      color: colors.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 14.0),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                ),
              ),

              // Branch Selector
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Branch:',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                  for (final b in _branches)
                    InteractivePressScale(
                      onTap: () => setState(() => _selectedBranchFilter = b),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedBranchFilter == b
                              ? colors.harborNavy
                              : colors.background,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: _selectedBranchFilter == b
                                ? colors.harborNavy
                                : colors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          b,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w700,
                            color: _selectedBranchFilter == b
                                ? Colors.white
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Row 2: Stage Filter Pills
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Stage:',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: AppTypography.captionSize,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
              for (final stage in stageFilters) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedStageFilter = stage),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedStageFilter == stage
                          ? colors.freshSkyBlue
                          : colors.background,
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: _selectedStageFilter == stage
                            ? colors.freshSkyBlue
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      stage,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: _selectedStageFilter == stage
                            ? Colors.white
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              Text(
                '•  Showing $filteredCount of $totalCount runs',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: AppTypography.captionSize,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Desktop Table Manifest View ---

  Widget _buildDesktopManifestTable(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    List<_DispatchRunItem> runs,
  ) {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.3),
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 140.0,
                child: Text(
                  'MANIFEST REF',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'CUSTOMER & DESTINATION ROUTE',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'BRANCH & RIDER',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 190.0,
                child: Text(
                  'UPDATE STATUS',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 80.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ACTIONS',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Rows
        for (var i = 0; i < runs.length; i++)
          _buildDesktopManifestRow(context, textTheme, colors, runs[i]),
      ],
    );
  }

  Widget _buildDesktopManifestRow(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    _DispatchRunItem run,
  ) {
    final originalIndex = _runs.indexWhere((r) => r.runId == run.runId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          // 1. Manifest Ref
          SizedBox(
            width: 140.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.harborNavy,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    run.runId,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w800,
                      color: colors.harborGold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 3.0),
                InkWell(
                  onTap: () => widget.onOpenOrderDetails?.call(run.orderId),
                  child: Text(
                    run.orderId,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                      color: colors.freshSkyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Customer & Route
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  run.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  run.zone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  run.bagCount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    color: colors.freshSkyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3. Branch & Rider
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 13.0,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        run.branch,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_bike_outlined,
                      size: 13.0,
                      color: colors.freshSkyBlue,
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        run.riderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w700,
                          color: colors.harborNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'ETA: ${run.etaWindow}',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 4. Status Dropdown (Direct status picker)
          SizedBox(
            width: 190.0,
            child: _buildStatusDropdown(
              context,
              textTheme,
              colors,
              currentStage: run.stage,
              onChanged: (newStage) {
                if (newStage != null) {
                  _updateRunStage(originalIndex, newStage);
                }
              },
            ),
          ),

          // 5. Actions
          SizedBox(
            width: 80.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 18.0,
                  color: colors.textSecondary,
                ),
                tooltip: 'More Actions',
                onSelected: (val) {
                  if (val == 'view_order') {
                    widget.onOpenOrderDetails?.call(run.orderId);
                  } else if (val.startsWith('rider:')) {
                    final rider = val.substring('rider:'.length);
                    _reassignRider(originalIndex, rider);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'view_order',
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 15.0,
                          color: colors.freshSkyBlue,
                        ),
                        const SizedBox(width: 8.0),
                        const Text(
                          'View Order Details',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'Reassign Rider:',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  for (final r in [
                    'Peter Mwangi',
                    'David Otieno',
                    'Samuel Karanja',
                  ])
                    PopupMenuItem(
                      value: 'rider:$r',
                      child: Text(
                        r,
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: run.riderName == r
                              ? FontWeight.w700
                              : FontWeight.normal,
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

  // --- Mobile Compact Manifest View ---

  Widget _buildMobileManifestList(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    List<_DispatchRunItem> runs,
  ) {
    return Column(
      children: [
        for (var i = 0; i < runs.length; i++) ...[
          if (i > 0)
            Divider(height: 1.0, thickness: 1.0, color: colors.borderSubtle),
          _buildMobileManifestCard(context, textTheme, colors, runs[i]),
        ],
      ],
    );
  }

  Widget _buildMobileManifestCard(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    _DispatchRunItem run,
  ) {
    final originalIndex = _runs.indexWhere((r) => r.runId == run.runId);

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: colors.harborNavy,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  run.runId,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w800,
                    color: colors.harborGold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: InkWell(
                  onTap: () => widget.onOpenOrderDetails?.call(run.orderId),
                  child: Text(
                    run.orderId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                      color: colors.freshSkyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  'ETA: ${run.etaWindow}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            run.customerName,
            style: textTheme.labelMedium?.copyWith(
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '${run.zone} • ${run.bagCount}',
            style: textTheme.bodySmall?.copyWith(
              fontSize: AppTypography.captionSize,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Icon(
                Icons.directions_bike_outlined,
                size: 13.0,
                color: colors.freshSkyBlue,
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  '${run.riderName} • ${run.branch}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w600,
                    color: colors.harborNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _buildStatusDropdown(
                  context,
                  textTheme,
                  colors,
                  currentStage: run.stage,
                  onChanged: (newStage) {
                    if (newStage != null) {
                      _updateRunStage(originalIndex, newStage);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18.0),
                onPressed: () => widget.onOpenOrderDetails?.call(run.orderId),
                tooltip: 'Order details',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Status Dropdown Widget ---

  Widget _buildStatusDropdown(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors, {
    required String currentStage,
    required ValueChanged<String?> onChanged,
  }) {
    final config = _stageVisualConfig(currentStage, colors);

    return Container(
      height: 32.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: config.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _validStages.contains(currentStage)
              ? currentStage
              : _validStages.first,
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16.0,
            color: config.foreground,
          ),
          dropdownColor: colors.cardBackground,
          borderRadius: BorderRadius.circular(8.0),
          selectedItemBuilder: (ctx) {
            return _validStages.map((stage) {
              final itemConfig = _stageVisualConfig(stage, colors);
              return Row(
                children: [
                  Icon(
                    itemConfig.icon,
                    size: 13.0,
                    color: itemConfig.foreground,
                  ),
                  const SizedBox(width: 5.0),
                  Expanded(
                    child: Text(
                      stage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: itemConfig.foreground,
                      ),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: _validStages.map((stage) {
            final itemConfig = _stageVisualConfig(stage, colors);
            return DropdownMenuItem<String>(
              value: stage,
              child: Row(
                children: [
                  Icon(
                    itemConfig.icon,
                    size: 14.0,
                    color: itemConfig.foreground,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    stage,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: itemConfig.foreground,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  ({Color background, Color foreground, Color border, IconData icon})
  _stageVisualConfig(String stage, AppColors colors) {
    switch (stage) {
      case 'Pickup assigned':
        return (
          background: const Color(0xFFFFFBEB),
          foreground: const Color(0xFFB45309),
          border: const Color(0xFFFDE68A),
          icon: Icons.assignment_ind_outlined,
        );
      case 'In Transit':
        return (
          background: const Color(0xFFF0F9FF),
          foreground: const Color(0xFF0284C7),
          border: const Color(0xFFBAE6FD),
          icon: Icons.local_shipping_outlined,
        );
      case 'Out for Delivery':
        return (
          background: const Color(0xFFEEF2FF),
          foreground: const Color(0xFF4F46E5),
          border: const Color(0xFFC7D2FE),
          icon: Icons.near_me_outlined,
        );
      case 'Delivered':
      default:
        return (
          background: const Color(0xFFECFDF5),
          foreground: const Color(0xFF059669),
          border: const Color(0xFFA7F3D0),
          icon: Icons.check_circle_outline,
        );
    }
  }
}
