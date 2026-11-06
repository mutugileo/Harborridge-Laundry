import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/auth/change_pin_dialog.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class StaffView extends ConsumerStatefulWidget {
  const StaffView({super.key, this.onOpenLoginPortal});

  final VoidCallback? onOpenLoginPortal;

  @override
  ConsumerState<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends ConsumerState<StaffView> {
  static const List<String> _roleOptions = [
    'Branch Operations Coordinator',
    'POS Counter Attendant',
    'Production Lead',
    'Dispatch & Fleet Rider',
    'Finance & Settlements Officer',
    'Super Admin',
  ];

  static const List<String> _branchOptions = [
    'Harborridge Main',
    'LaundryGo Nairobi',
    'LaundryGo Westlands',
    'LaundryGo Kilimani',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _pinController;
  late final TextEditingController _phoneController;

  String _selectedRole = 'POS Counter Attendant';
  String _selectedBranch = 'LaundryGo Nairobi';
  String _roleFilter = 'All';
  final Set<AppModuleKey> _draftExceptedModules = {
    AppModuleKey.settlements,
    AppModuleKey.staff,
    AppModuleKey.settings,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _pinController = TextEditingController(text: '2026');
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _applyRolePreset(String roleTitle) {
    setState(() {
      _selectedRole = roleTitle;
      _draftExceptedModules.clear();
      if (roleTitle == 'POS Counter Attendant') {
        _draftExceptedModules.addAll([
          AppModuleKey.settlements,
          AppModuleKey.staff,
          AppModuleKey.settings,
        ]);
      } else if (roleTitle == 'Production Lead') {
        _draftExceptedModules.addAll([
          AppModuleKey.payments,
          AppModuleKey.settlements,
          AppModuleKey.staff,
          AppModuleKey.settings,
        ]);
      } else if (roleTitle == 'Dispatch & Fleet Rider') {
        _draftExceptedModules.addAll([
          AppModuleKey.vendors,
          AppModuleKey.payments,
          AppModuleKey.settlements,
          AppModuleKey.inventory,
          AppModuleKey.staff,
          AppModuleKey.reports,
          AppModuleKey.settings,
        ]);
      } else if (roleTitle != 'Super Admin') {
        _draftExceptedModules.addAll([
          AppModuleKey.staff,
          AppModuleKey.settings,
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final authNotifier = ref.read(authSessionNotifierProvider.notifier);
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    final filteredWorkers = _roleFilter == 'All'
        ? authState.workers
        : authState.workers.where((w) => w.roleTitle == _roleFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(22.0),
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
                  runSpacing: 10.0,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff Roster & Role-Based Menu Rights',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Add new workers, configure their allowed vs. excepted menus, and switch sessions with one click.',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12.0,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 7.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.freshSkyBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                          child: Text(
                            'Active Session: ${authState.currentWorker.fullName} (${authState.currentWorker.allowedModulesCount}/${AppModuleKey.values.length} menus)',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: colors.harborNavy,
                            ),
                          ),
                        ),
                        if (widget.onOpenLoginPortal != null) ...[
                          const SizedBox(width: 10.0),
                          InteractivePressScale(
                            onTap: widget.onOpenLoginPortal,
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
                                    Icons.login_rounded,
                                    size: 14.0,
                                    color: colors.harborGold,
                                  ),
                                  const SizedBox(width: 6.0),
                                  Text(
                                    'Open Login Screen',
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
                      ],
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: motion.shortDuration,
                  child: authState.statusMessage == null
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
                              authState.statusMessage!,
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
          const SizedBox(height: 18.0),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 940.0;
              final rosterColumn = _buildWorkersDirectoryCard(
                context,
                colors,
                textTheme,
                motion,
                authState,
                authNotifier,
                filteredWorkers,
              );
              final addWorkerColumn = _buildAddWorkerCard(
                context,
                colors,
                textTheme,
                authNotifier,
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 62, child: rosterColumn),
                    const SizedBox(width: 18.0),
                    Expanded(flex: 38, child: addWorkerColumn),
                  ],
                );
              }

              return Column(
                children: [
                  addWorkerColumn,
                  const SizedBox(height: 18.0),
                  rosterColumn,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersDirectoryCard(
    BuildContext context,
    AppColors colors,
    TextTheme textTheme,
    AppMotion motion,
    AuthPortalState authState,
    AuthSessionNotifier authNotifier,
    List<WorkerAccount> workers,
  ) {
    final filterOptions = ['All', ..._roleOptions];

    return Container(
      padding: const EdgeInsets.all(22.0),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((role) {
                final isSelected = _roleFilter == role;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InteractivePressScale(
                    onTap: () => setState(() => _roleFilter = role),
                    child: AnimatedContainer(
                      duration: motion.shortDuration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 7.0,
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
                        role,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16.0),
          for (var i = 0; i < workers.length; i++) ...[
            if (i > 0) const SizedBox(height: 12.0),
            _WorkerPermissionsCard(
              worker: workers[i],
              isCurrentSession: workers[i].id == authState.currentWorker.id,
              onToggleModule: (module) => authNotifier
                  .toggleWorkerModuleException(workers[i].id, module),
              onSwitchSession: () =>
                  authNotifier.switchActiveWorker(workers[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddWorkerCard(
    BuildContext context,
    AppColors colors,
    TextTheme textTheme,
    AuthSessionNotifier authNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(22.0),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: colors.harborGold.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              'ADMIN • REGISTER NEW WORKER',
              style: textTheme.labelSmall?.copyWith(
                color: colors.harborNavy,
                fontSize: 10.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Register Worker & Assign Menu Rights',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14.0),
          _StaffTextField(
            label: 'Worker Full Name',
            hintText: 'Enter worker full name',
            controller: _nameController,
          ),
          const SizedBox(height: 10.0),
          _StaffTextField(
            label: 'Work Email',
            hintText: 'Use staff work email address',
            controller: _emailController,
          ),
          const SizedBox(height: 10.0),
          _StaffTextField(
            label: 'Initial 4-Digit Security PIN',
            hintText: 'Set initial 4-digit login PIN for worker',
            controller: _pinController,
          ),
          const SizedBox(height: 10.0),
          _StaffTextField(
            label: 'Mobile Phone',
            hintText: 'Use active staff phone number',
            controller: _phoneController,
          ),
          const SizedBox(height: 12.0),
          Text(
            'Role Template (Auto-sets default rights):',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 6.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: _roleOptions.map((role) {
              final isSelected = _selectedRole == role;
              return InkWell(
                onTap: () => _applyRolePreset(role),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.harborNavy : colors.background,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? colors.harborNavy
                          : colors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    role,
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
          const SizedBox(height: 12.0),
          Text(
            'Branch Assignment:',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 6.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: _branchOptions.map((branch) {
              final isSelected = _selectedBranch == branch;
              return InkWell(
                onTap: () => setState(() => _selectedBranch = branch),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.freshSkyBlue.withValues(alpha: 0.14)
                        : colors.background,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? colors.freshSkyBlue
                          : colors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    branch,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colors.harborNavy
                          : colors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Allowed vs. Excepted Menus (Tap to toggle):',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: AppModuleKey.values.map((module) {
              final isAllowed = !_draftExceptedModules.contains(module);
              return InkWell(
                onTap: () {
                  if (module == AppModuleKey.dashboard) return;
                  setState(() {
                    if (_draftExceptedModules.contains(module)) {
                      _draftExceptedModules.remove(module);
                    } else {
                      _draftExceptedModules.add(module);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: isAllowed
                        ? const Color(0xFFE6F8EF)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    isAllowed
                        ? '✓ ${module.label}'
                        : '✕ ${module.label} (Excepted)',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: isAllowed
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB91C1C),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18.0),
          Row(
            children: [
              Expanded(
                child: InteractivePressScale(
                  onTap: () {
                    authNotifier.addWorkerFromAdmin(
                      fullName: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      roleTitle: _selectedRole,
                      branch: _selectedBranch,
                      initialPin: _pinController.text,
                      exceptedModules: Set<AppModuleKey>.from(
                        _draftExceptedModules,
                      ),
                    );
                    _nameController.clear();
                    _emailController.clear();
                    _pinController.text = '2026';
                    _phoneController.clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: colors.harborNavy,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Add Worker',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: InteractivePressScale(
                  onTap: () {
                    final created = authNotifier.addWorkerFromAdmin(
                      fullName: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      roleTitle: _selectedRole,
                      branch: _selectedBranch,
                      initialPin: _pinController.text,
                      exceptedModules: Set<AppModuleKey>.from(
                        _draftExceptedModules,
                      ),
                    );
                    authNotifier.switchActiveWorker(created);
                    _nameController.clear();
                    _emailController.clear();
                    _pinController.text = '2026';
                    _phoneController.clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: colors.accentGreen,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Add & Login as Worker',
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
        ],
      ),
    );
  }
}

class _WorkerPermissionsCard extends StatelessWidget {
  const _WorkerPermissionsCard({
    required this.worker,
    required this.isCurrentSession,
    required this.onToggleModule,
    required this.onSwitchSession,
  });

  final WorkerAccount worker;
  final bool isCurrentSession;
  final ValueChanged<AppModuleKey> onToggleModule;
  final VoidCallback onSwitchSession;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isCurrentSession
            ? colors.freshSkyBlue.withValues(alpha: 0.06)
            : colors.background.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isCurrentSession ? colors.freshSkyBlue : colors.borderSubtle,
          width: isCurrentSession ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: isCurrentSession
                          ? colors.harborNavy
                          : colors.freshSkyBlue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      worker.initials,
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              worker.fullName,
                              style: textTheme.titleSmall?.copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: colors.harborGold.withValues(
                                  alpha: 0.22,
                                ),
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: Text(
                                worker.id,
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700,
                                  color: colors.harborNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${worker.roleTitle} • ${worker.branch} • ${worker.email} • PIN: ${worker.pin}',
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
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (isCurrentSession)
                    InteractivePressScale(
                      onTap: () => showChangeWorkerPinDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.freshSkyBlue.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: colors.freshSkyBlue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Change My PIN',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: colors.harborNavy,
                          ),
                        ),
                      ),
                    ),
                  InteractivePressScale(
                    onTap: onSwitchSession,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 7.0,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentSession
                            ? const Color(0xFFE6F8EF)
                            : colors.harborNavy,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        isCurrentSession
                            ? 'Active Logged-In Worker'
                            : 'Switch Session to Worker',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: isCurrentSession
                              ? const Color(0xFF15803D)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: AppModuleKey.values.map((module) {
              final isAllowed = worker.canSeeModule(module);
              return InkWell(
                onTap: () => onToggleModule(module),
                borderRadius: BorderRadius.circular(6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: isAllowed
                        ? colors.cardBackground
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: isAllowed
                          ? colors.borderSubtle
                          : const Color(0xFFFCA5A5),
                    ),
                  ),
                  child: Text(
                    isAllowed
                        ? '✓ ${module.label}'
                        : '✕ ${module.label} (Excepted)',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      color: isAllowed
                          ? colors.textPrimary
                          : const Color(0xFFB91C1C),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StaffTextField extends StatelessWidget {
  const _StaffTextField({
    required this.label,
    required this.hintText,
    required this.controller,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;

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
          ),
        ),
      ],
    );
  }
}
