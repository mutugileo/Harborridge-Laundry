import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class _VendorBranchRecord {
  const _VendorBranchRecord({
    required this.code,
    required this.branchName,
    required this.managerName,
    required this.location,
    required this.activeOrders,
    required this.utilizationRatio,
    required this.commissionRate,
    required this.isOnline,
    required this.assignedWorkersCount,
  });

  final String code;
  final String branchName;
  final String managerName;
  final String location;
  final int activeOrders;
  final double utilizationRatio;
  final String commissionRate;
  final bool isOnline;
  final int assignedWorkersCount;

  _VendorBranchRecord copyWith({bool? isOnline}) {
    return _VendorBranchRecord(
      code: code,
      branchName: branchName,
      managerName: managerName,
      location: location,
      activeOrders: activeOrders,
      utilizationRatio: utilizationRatio,
      commissionRate: commissionRate,
      isOnline: isOnline ?? this.isOnline,
      assignedWorkersCount: assignedWorkersCount,
    );
  }
}

class VendorsView extends ConsumerStatefulWidget {
  const VendorsView({super.key, this.onFilterOrdersByBranch});

  final ValueChanged<String>? onFilterOrdersByBranch;

  @override
  ConsumerState<VendorsView> createState() => _VendorsViewState();
}

class _VendorsViewState extends ConsumerState<VendorsView> {
  String? _statusMessage;
  bool _showOnboardPanel = false;
  String _selectedStatusFilter = 'All Vendors';
  bool _onlyUserBranch = false;
  String _searchQuery = '';

  late final TextEditingController _branchNameController;
  late final TextEditingController _managerController;
  late final TextEditingController _locationController;
  late final TextEditingController _commissionController;
  late final TextEditingController _searchController;

  late List<_VendorBranchRecord> _branches = const [];

  @override
  void initState() {
    super.initState();
    _branchNameController = TextEditingController();
    _managerController = TextEditingController();
    _locationController = TextEditingController();
    _commissionController = TextEditingController(text: '15% Partner Split');
    _searchController = TextEditingController();
    _loadSupabaseVendors();
  }

  Future<void> _loadSupabaseVendors() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      final response = await client
          .from('partner_vendors')
          .select('*')
          .order('created_at', ascending: false);
      if (!mounted) return;
      final loaded =
          (response as List).map((row) {
            final map = row as Map<String, dynamic>;
            return _VendorBranchRecord(
              code: map['code'] as String? ?? 'VND-00',
              branchName: map['branch_name'] as String? ?? 'Branch',
              managerName: map['manager_name'] as String? ?? 'Manager',
              location: map['location'] as String? ?? 'Location',
              activeOrders: (map['active_orders'] as num?)?.toInt() ?? 0,
              utilizationRatio:
                  (map['utilization_ratio'] as num?)?.toDouble() ?? 0.8,
              commissionRate:
                  map['commission_rate'] as String? ?? '15% Split',
              isOnline: map['is_online'] as bool? ?? true,
              assignedWorkersCount:
                  (map['assigned_workers_count'] as num?)?.toInt() ?? 1,
            );
          }).toList();
      setState(() {
        _branches = loaded;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _managerController.dispose();
    _locationController.dispose();
    _commissionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onboardNewBranch() {
    final name = _branchNameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _statusMessage = 'Enter a partner branch name before onboarding.';
      });
      return;
    }
    final manager = _managerController.text.trim().isEmpty
        ? 'Branch Lead'
        : _managerController.text.trim();
    final location = _locationController.text.trim().isEmpty
        ? 'Nairobi Metro Dropoff Hub'
        : _locationController.text.trim();
    final commission = _commissionController.text.trim().isEmpty
        ? '15% Partner Split'
        : _commissionController.text.trim();
    final code = 'VND-0${_branches.length + 1}';

    final newBranch = _VendorBranchRecord(
      code: code,
      branchName: name,
      managerName: manager,
      location: location,
      activeOrders: 4,
      utilizationRatio: 0.65,
      commissionRate: commission,
      isOnline: true,
      assignedWorkersCount: 2,
    );

    setState(() {
      _branches = [newBranch, ..._branches];
      _branchNameController.clear();
      _managerController.clear();
      _locationController.clear();
      _showOnboardPanel = false;
      _statusMessage =
          'Onboarded partner branch $code ($name) under $commission';
    });
  }

  void _toggleBranchOnline(int index) {
    final current = _branches[index];
    final nextOnline = !current.isOnline;
    setState(() {
      _branches = [
        for (var i = 0; i < _branches.length; i++)
          if (i == index)
            current.copyWith(isOnline: nextOnline)
          else
            _branches[i],
      ];
      _statusMessage =
          '${current.branchName} intake status set to ${nextOnline ? 'Online • Accepting' : 'Maintenance Pause'}';
    });
  }

  List<_VendorBranchRecord> _getFilteredBranches(WorkerAccount user) {
    return _branches.where((branch) {
      // 1. User Branch scoping filter
      if (_onlyUserBranch) {
        final matchesUser =
            branch.branchName.toLowerCase() == user.branch.toLowerCase();
        if (!matchesUser) return false;
      }

      // 2. Status filter
      if (_selectedStatusFilter == 'Active Vendors' && !branch.isOnline) {
        return false;
      }
      if (_selectedStatusFilter == 'Maintenance / Paused' && branch.isOnline) {
        return false;
      }

      // 3. Search query filter
      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matches =
            branch.code.toLowerCase().contains(query) ||
            branch.branchName.toLowerCase().contains(query) ||
            branch.managerName.toLowerCase().contains(query) ||
            branch.location.toLowerCase().contains(query) ||
            branch.commissionRate.toLowerCase().contains(query);
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
    final authState = ref.watch(authSessionNotifierProvider);
    final currentWorker = authState.currentWorker;

    final filteredBranches = _getFilteredBranches(currentWorker);
    final activeVendorsCount = _branches.where((b) => b.isOnline).length;
    final pausedVendorsCount = _branches.where((b) => !b.isOnline).length;
    final totalActiveOrders = _branches.fold<int>(
      0,
      (sum, b) => sum + b.activeOrders,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Toolbar with Title & Action Controls
          _buildHeaderToolbar(
            context,
            textTheme,
            colors,
            motion,
            currentWorker,
          ),

          const SizedBox(height: 14.0),

          // 2. Feedback Notification Banner
          AnimatedSwitcher(
            duration: motion.shortDuration,
            child: _statusMessage == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(_statusMessage),
                    margin: const EdgeInsets.only(bottom: 14.0),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16.0,
                          color: colors.freshSkyBlue,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.harborNavy,
                              fontSize: AppTypography.captionSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 14.0,
                            color: colors.harborNavy,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setState(() => _statusMessage = null),
                        ),
                      ],
                    ),
                  ),
          ),

          // 3. Onboard New Branch Drawer (Slide-down)
          if (_showOnboardPanel) ...[
            _buildOnboardBranchPanel(context, textTheme, colors),
            const SizedBox(height: 14.0),
          ],

          // 4. Streamlined Vendor Telemetry Strip (Interactive "Active Vendors" Click)
          _buildTelemetryStrip(
            context,
            textTheme,
            colors,
            activeCount: activeVendorsCount,
            pausedCount: pausedVendorsCount,
            totalOrders: totalActiveOrders,
            userBranch: currentWorker.branch,
          ),

          const SizedBox(height: 14.0),

          // 5. Multi-Criteria Filter Bar (Active Vendors, Search & User Scoping)
          _buildFilterBar(
            context,
            textTheme,
            colors,
            motion,
            user: currentWorker,
            filteredCount: filteredBranches.length,
            totalCount: _branches.length,
            activeCount: activeVendorsCount,
            pausedCount: pausedVendorsCount,
          ),

          const SizedBox(height: 14.0),

          // 6. Vendor Ledger Statement Manifest Table
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manifest Sub-Header Banner
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
                        Icons.handshake_outlined,
                        size: 16.0,
                        color: colors.harborNavy,
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          _selectedStatusFilter == 'Active Vendors'
                              ? 'ACTIVE PROCESSING HUBS & PARTNER PLANTS FOR ${currentWorker.fullName.toUpperCase()}'
                              : 'AUTHORIZED PROCESSING HUBS & PARTNER VENDOR ROSTER',
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
                      const Spacer(),
                      Text(
                        '${filteredBranches.length} Processing Hubs',
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
                if (filteredBranches.isEmpty)
                  AppEmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'No Partner Vendors Enrolled',
                    description:
                        'No vendor hubs match the selected filters for ${currentWorker.fullName}. Onboard a partner branch to route wash loads.',
                    actionLabel: '+ Onboard Branch',
                    actionIcon: Icons.add_business_rounded,
                    onAction: () => setState(() => _showOnboardPanel = true),
                    secondaryActionLabel: 'Reset Filters',
                    onSecondaryAction: () => setState(() {
                      _selectedStatusFilter = 'All Vendors';
                      _onlyUserBranch = false;
                      _searchController.clear();
                      _searchQuery = '';
                    }),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 840.0;
                      if (isWide) {
                        return _buildDesktopVendorTable(
                          context,
                          textTheme,
                          colors,
                          filteredBranches,
                          currentWorker,
                        );
                      }
                      return _buildMobileVendorList(
                        context,
                        textTheme,
                        colors,
                        filteredBranches,
                        currentWorker,
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

  // --- Header Toolbar ---

  Widget _buildHeaderToolbar(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    AppMotion motion,
    WorkerAccount worker,
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
                  color: colors.harborNavy.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.handshake_outlined,
                  size: 20.0,
                  color: colors.harborNavy,
                ),
              ),
              const SizedBox(width: 12.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Vendor & Branch Processing Network',
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
                      'Partner plant capacity, commission agreements, and real-time intake routing for ${worker.fullName}.',
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
            onTap: () => setState(() => _showOnboardPanel = !_showOnboardPanel),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: _showOnboardPanel
                    ? colors.harborNavy
                    : colors.freshSkyBlue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showOnboardPanel
                        ? Icons.keyboard_arrow_up
                        : Icons.add_business_outlined,
                    size: 15.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    _showOnboardPanel
                        ? (isMobile ? 'Close Form' : 'Close Onboarding Form')
                        : (isMobile
                              ? '+ Onboard Branch'
                              : '+ Onboard Partner Branch'),
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

  // --- Onboard Partner Branch Panel ---

  Widget _buildOnboardBranchPanel(
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
                Icons.add_business_outlined,
                size: 16.0,
                color: colors.freshSkyBlue,
              ),
              const SizedBox(width: 8.0),
              Text(
                'ONBOARD NEW PROCESSING PARTNER / BRANCH',
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
                width: 180.0,
                height: 38.0,
                child: TextField(
                  controller: _branchNameController,
                  style: const TextStyle(fontSize: 12.0),
                  decoration: InputDecoration(
                    labelText: 'Branch Name',
                    hintText: 'LaundryGo Karen',
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
                  ),
                ),
              ),
              SizedBox(
                width: 160.0,
                height: 38.0,
                child: TextField(
                  controller: _managerController,
                  style: const TextStyle(fontSize: 12.0),
                  decoration: InputDecoration(
                    labelText: 'Plant Manager',
                    hintText: 'Plant Lead',
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
                  ),
                ),
              ),
              SizedBox(
                width: 220.0,
                height: 38.0,
                child: TextField(
                  controller: _locationController,
                  style: const TextStyle(fontSize: 12.0),
                  decoration: InputDecoration(
                    labelText: 'Hub Location',
                    hintText: 'Karen Hub • Shopping Centre',
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
                  ),
                ),
              ),
              SizedBox(
                width: 170.0,
                height: 38.0,
                child: TextField(
                  controller: _commissionController,
                  style: const TextStyle(fontSize: 12.0),
                  decoration: InputDecoration(
                    labelText: 'Commission Agreement',
                    hintText: '15% Partner Split',
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
                  ),
                ),
              ),
              InteractivePressScale(
                onTap: _onboardNewBranch,
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
                    'Save Partner Branch',
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

  // --- Telemetry Strip (Active Vendors Click Handler) ---

  Widget _buildTelemetryStrip(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors, {
    required int activeCount,
    required int pausedCount,
    required int totalOrders,
    required String userBranch,
  }) {
    final metrics = [
      (
        icon: Icons.storefront_outlined,
        color: const Color(0xFF059669),
        title: 'ACTIVE VENDORS',
        value: '$activeCount Online',
        sub: 'Tap to view active hubs',
        isInteractive: true,
        onTap: () {
          setState(() {
            _selectedStatusFilter = 'Active Vendors';
            _statusMessage =
                'Filtered to $activeCount active processing hubs for current user scope.';
          });
        },
      ),
      (
        icon: Icons.pause_circle_outline,
        color: colors.harborGold,
        title: 'PAUSED / MAINTENANCE',
        value: '$pausedCount Hubs',
        sub: 'Intake temporarily paused',
        isInteractive: true,
        onTap: () {
          setState(() {
            _selectedStatusFilter = 'Maintenance / Paused';
            _statusMessage = 'Filtered to hubs undergoing maintenance.';
          });
        },
      ),
      (
        icon: Icons.local_laundry_service_outlined,
        color: colors.freshSkyBlue,
        title: 'ACTIVE ORDERS IN FLIGHT',
        value: '$totalOrders Live Loads',
        sub: 'Across distributed network',
        isInteractive: false,
        onTap: null,
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF4F46E5),
        title: 'AVG TAKE-RATE COMMISSION',
        value: '14.5% Platform',
        sub: 'Verified partner splits',
        isInteractive: false,
        onTap: null,
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
    ({
      IconData icon,
      Color color,
      String title,
      String value,
      String sub,
      bool isInteractive,
      VoidCallback? onTap,
    })
    item,
  ) {
    final isSelected =
        (item.title == 'ACTIVE VENDORS' &&
            _selectedStatusFilter == 'Active Vendors') ||
        (item.title == 'PAUSED / MAINTENANCE' &&
            _selectedStatusFilter == 'Maintenance / Paused');

    return InteractivePressScale(
      onTap: item.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        color: isSelected
            ? item.color.withValues(alpha: 0.08)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34.0,
              height: 34.0,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Icon(item.icon, size: 18.0, color: item.color),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: isSelected
                                ? item.color
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                      if (item.isInteractive) ...[
                        const SizedBox(width: 4.0),
                        Icon(
                          Icons.touch_app_outlined,
                          size: 11.0,
                          color: isSelected ? item.color : colors.textSecondary,
                        ),
                      ],
                    ],
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
                      color: isSelected ? item.color : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter Bar with Live Search & User Branch Scoping ---

  Widget _buildFilterBar(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    AppMotion motion, {
    required WorkerAccount user,
    required int filteredCount,
    required int totalCount,
    required int activeCount,
    required int pausedCount,
  }) {
    final statusFilters = [
      ('All Vendors', totalCount),
      ('Active Vendors', activeCount),
      ('Maintenance / Paused', pausedCount),
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
          // Row 1: Search & User Scope Selector
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 290.0,
                height: 36.0,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 12.0),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search vendor, hub, manager, code...',
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

              // User Branch Scope Pill
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'User Scope:',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                  InteractivePressScale(
                    onTap: () => setState(() => _onlyUserBranch = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: !_onlyUserBranch
                            ? colors.harborNavy
                            : colors.background,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: !_onlyUserBranch
                              ? colors.harborNavy
                              : colors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        'All Network Hubs',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w700,
                          color: !_onlyUserBranch
                              ? Colors.white
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  InteractivePressScale(
                    onTap: () => setState(() => _onlyUserBranch = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: _onlyUserBranch
                            ? colors.freshSkyBlue
                            : colors.background,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: _onlyUserBranch
                              ? colors.freshSkyBlue
                              : colors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_pin_circle_outlined,
                            size: 13.0,
                            color: _onlyUserBranch
                                ? Colors.white
                                : colors.freshSkyBlue,
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              'My Branch (${user.branch})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: AppTypography.captionSize,
                                fontWeight: FontWeight.w700,
                                color: _onlyUserBranch
                                    ? Colors.white
                                    : colors.textPrimary,
                              ),
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

          const SizedBox(height: 10.0),

          // Row 2: Status Filter Segment Buttons
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Status:',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: AppTypography.captionSize,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
              for (final (label, count) in statusFilters) ...[
                InteractivePressScale(
                  onTap: () => setState(() => _selectedStatusFilter = label),
                  child: AnimatedContainer(
                    duration: motion.shortDuration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedStatusFilter == label
                          ? (label == 'Active Vendors'
                                ? const Color(0xFF059669)
                                : colors.harborNavy)
                          : colors.background,
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: _selectedStatusFilter == label
                            ? (label == 'Active Vendors'
                                  ? const Color(0xFF059669)
                                  : colors.harborNavy)
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      '$label ($count)',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: _selectedStatusFilter == label
                            ? Colors.white
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              Text(
                '•  Showing $filteredCount of $totalCount vendors for ${user.fullName}',
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

  Widget _buildDesktopVendorTable(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    List<_VendorBranchRecord> branches,
    WorkerAccount user,
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
                width: 130.0,
                child: Text(
                  'VENDOR CODE',
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
                  'PROCESSING HUB & PLANT LEAD',
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
                  'CAPACITY & UTILIZATION',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 140.0,
                child: Text(
                  'INTAKE STATUS',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 180.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ACTIVE ORDERS',
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
        for (var i = 0; i < branches.length; i++)
          _buildDesktopVendorRow(context, textTheme, colors, branches[i], user),
      ],
    );
  }

  Widget _buildDesktopVendorRow(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    _VendorBranchRecord branch,
    WorkerAccount user,
  ) {
    final originalIndex = _branches.indexWhere((b) => b.code == branch.code);
    final isUserBranch =
        branch.branchName.toLowerCase() == user.branch.toLowerCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isUserBranch
            ? colors.freshSkyBlue.withValues(alpha: 0.04)
            : Colors.transparent,
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          // 1. Code Badge
          SizedBox(
            width: 130.0,
            child: Row(
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
                    branch.code,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.harborGold,
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (isUserBranch) ...[
                  const SizedBox(width: 6.0),
                  Icon(Icons.star, size: 13.0, color: colors.harborGold),
                ],
              ],
            ),
          ),

          // 2. Hub Name & Location Lead
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        branch.branchName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (isUserBranch) ...[
                      const SizedBox(width: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.harborNavy.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          'Your Branch',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            color: colors.harborNavy,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${branch.location} • Lead: ${branch.managerName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  branch.commissionRate,
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

          // 3. Capacity & Utilization
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Load: ${(branch.utilizationRatio * 100).round()}%',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.captionSize,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        '• ${branch.assignedWorkersCount} Staff',
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
                const SizedBox(height: 4.0),
                SizedBox(
                  width: 140.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99.0),
                    child: LinearProgressIndicator(
                      value: branch.utilizationRatio,
                      minHeight: 6.0,
                      backgroundColor: colors.borderSubtle,
                      color: branch.utilizationRatio > 0.90
                          ? colors.harborGold
                          : colors.freshSkyBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Online / Intake Status Toggle
          SizedBox(
            width: 140.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InteractivePressScale(
                onTap: () => _toggleBranchOnline(originalIndex),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: branch.isOnline
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(99.0),
                    border: Border.all(
                      color: branch.isOnline
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.0,
                        height: 7.0,
                        decoration: BoxDecoration(
                          color: branch.isOnline
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        branch.isOnline ? 'Online' : 'Paused',
                        style: textTheme.labelSmall?.copyWith(
                          color: branch.isOnline
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. Active Orders Link Button (Safe drill-down without crash)
          SizedBox(
            width: 180.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: InteractivePressScale(
                onTap: () =>
                    widget.onFilterOrdersByBranch?.call(branch.branchName),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: colors.freshSkyBlue),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '${branch.activeOrders} Active Orders',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.harborNavy,
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13.0,
                        color: colors.harborNavy,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Mobile Compact List View ---

  Widget _buildMobileVendorList(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    List<_VendorBranchRecord> branches,
    WorkerAccount user,
  ) {
    return Column(
      children: [
        for (var i = 0; i < branches.length; i++) ...[
          if (i > 0)
            Divider(height: 1.0, thickness: 1.0, color: colors.borderSubtle),
          _buildMobileVendorCard(context, textTheme, colors, branches[i], user),
        ],
      ],
    );
  }

  Widget _buildMobileVendorCard(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    _VendorBranchRecord branch,
    WorkerAccount user,
  ) {
    final originalIndex = _branches.indexWhere((b) => b.code == branch.code);
    final isUserBranch =
        branch.branchName.toLowerCase() == user.branch.toLowerCase();

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
                  branch.code,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.harborGold,
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        branch.branchName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (isUserBranch) ...[
                      const SizedBox(width: 6.0),
                      Icon(Icons.star, size: 13.0, color: colors.harborGold),
                    ],
                  ],
                ),
              ),
              InteractivePressScale(
                onTap: () => _toggleBranchOnline(originalIndex),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: branch.isOnline
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(99.0),
                    border: Border.all(
                      color: branch.isOnline
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Text(
                    branch.isOnline ? 'Online' : 'Paused',
                    style: textTheme.labelSmall?.copyWith(
                      color: branch.isOnline
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                      fontSize: AppTypography.captionSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            '${branch.location} • Lead: ${branch.managerName}',
            style: textTheme.bodySmall?.copyWith(
              fontSize: AppTypography.captionSize,
              color: colors.textSecondary,
            ),
          ),
          Text(
            branch.commissionRate,
            style: textTheme.bodySmall?.copyWith(
              fontSize: AppTypography.captionSize,
              color: colors.freshSkyBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Load: ${(branch.utilizationRatio * 100).round()}%',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: AppTypography.captionSize,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              InteractivePressScale(
                onTap: () =>
                    widget.onFilterOrdersByBranch?.call(branch.branchName),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: colors.freshSkyBlue),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${branch.activeOrders} Active Orders',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.harborNavy,
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12.0,
                        color: colors.harborNavy,
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
}
