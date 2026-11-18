import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/auth/auth_backend.dart';
import 'package:laundry_ridge/core/auth/quick_pin_service.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';

enum OperatorRole { admin, manager, productionLead, cashier, driver }

OperatorRole operatorRoleFromName(String? name) {
  return OperatorRole.values.firstWhere(
    (role) => role.name == name,
    orElse: () => OperatorRole.manager,
  );
}

/// The role a role-template title maps to when an admin creates a worker.
OperatorRole operatorRoleForTitle(String roleTitle) {
  switch (roleTitle) {
    case 'Super Admin':
      return OperatorRole.admin;
    case 'Production Lead':
      return OperatorRole.productionLead;
    case 'POS Counter Attendant':
      return OperatorRole.cashier;
    case 'Dispatch & Fleet Rider':
      return OperatorRole.driver;
    default:
      return OperatorRole.manager;
  }
}

class WorkerAccount {
  const WorkerAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.roleTitle,
    required this.role,
    required this.branch,
    required this.shiftLabel,
    required this.isActive,
    required this.exceptedModules,
  });

  factory WorkerAccount.fromRow(Map<String, dynamic> row) {
    final excepted = <AppModuleKey>{};
    for (final name in (row['excepted_modules'] as List?) ?? const []) {
      for (final module in AppModuleKey.values) {
        if (module.name == name) excepted.add(module);
      }
    }
    return WorkerAccount(
      id: row['id'] as String,
      fullName: row['full_name'] as String? ?? '',
      email: row['email'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      roleTitle: row['role_title'] as String? ?? 'Staff',
      role: operatorRoleFromName(row['role'] as String?),
      branch: row['branch'] as String? ?? '',
      shiftLabel: row['shift_label'] as String? ?? '',
      isActive: row['is_active'] as bool? ?? false,
      exceptedModules: excepted,
    );
  }

  /// Placeholder while nobody is signed in. Sees no modules.
  static final WorkerAccount signedOut = WorkerAccount(
    id: '',
    fullName: '',
    email: '',
    phone: '',
    roleTitle: '',
    role: OperatorRole.driver,
    branch: '',
    shiftLabel: '',
    isActive: false,
    exceptedModules: AppModuleKey.values.toSet(),
  );

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String roleTitle;
  final OperatorRole role;
  final String branch;
  final String shiftLabel;
  final bool isActive;
  final Set<AppModuleKey> exceptedModules;

  bool get isAdmin => role == OperatorRole.admin;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'HR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Matches public.staff_can() on the server: admins see every module.
  bool canSeeModule(AppModuleKey module) =>
      isAdmin || !exceptedModules.contains(module);

  /// Menus hidden from this worker. Admins have none.
  Set<AppModuleKey> get effectiveExceptedModules =>
      isAdmin ? const {} : exceptedModules;

  int get allowedModulesCount =>
      AppModuleKey.values.length - effectiveExceptedModules.length;

  WorkerAccount copyWith({Set<AppModuleKey>? exceptedModules}) {
    return WorkerAccount(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      roleTitle: roleTitle,
      role: role,
      branch: branch,
      shiftLabel: shiftLabel,
      isActive: isActive,
      exceptedModules: exceptedModules ?? this.exceptedModules,
    );
  }
}

class AuthPortalState {
  const AuthPortalState({
    required this.isAuthenticated,
    required this.isBusy,
    required this.isRestoring,
    required this.currentWorker,
    required this.workers,
    this.statusMessage,
    this.errorMessage,
  });

  final bool isAuthenticated;

  /// A sign-in or account change is in flight; disable submit buttons.
  final bool isBusy;

  /// Checking for a saved session at startup.
  final bool isRestoring;
  final WorkerAccount currentWorker;
  final List<WorkerAccount> workers;
  final String? statusMessage;
  final String? errorMessage;

  AuthPortalState copyWith({
    bool? isAuthenticated,
    bool? isBusy,
    bool? isRestoring,
    WorkerAccount? currentWorker,
    List<WorkerAccount>? workers,
    String? statusMessage,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return AuthPortalState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isBusy: isBusy ?? this.isBusy,
      isRestoring: isRestoring ?? this.isRestoring,
      currentWorker: currentWorker ?? this.currentWorker,
      workers: workers ?? this.workers,
      statusMessage: clearMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthSessionNotifier extends Notifier<AuthPortalState> {
  AuthBackend get _backend => ref.read(authBackendProvider);
  QuickPinService get _quickPinService => ref.read(quickPinServiceProvider);

  @override
  AuthPortalState build() {
    final backend = ref.read(authBackendProvider);
    final subscription = backend.onSessionEnded.listen((_) {
      if (!state.isAuthenticated) return;
      state = state.copyWith(
        isAuthenticated: false,
        isBusy: false,
        currentWorker: WorkerAccount.signedOut,
        workers: const [],
        clearMessage: true,
        errorMessage: 'Your session ended. Sign in again.',
      );
    });
    ref.onDispose(subscription.cancel);

    final restoredId = backend.restoredUserId;
    if (restoredId != null) {
      Future.microtask(() => _openSession(restoredId, restoring: true));
    }
    return AuthPortalState(
      isAuthenticated: false,
      isBusy: false,
      isRestoring: restoredId != null,
      currentWorker: WorkerAccount.signedOut,
      workers: const [],
    );
  }

  /// Loads the staff profile for [userId]. Accounts without an active staff
  /// profile are signed straight back out: a Supabase login alone grants
  /// nothing, because every table policy checks public.staff.
  Future<bool> _openSession(String userId, {bool restoring = false}) async {
    try {
      final worker = await _backend.fetchWorker(userId);
      if (worker == null || !worker.isActive) {
        await _backend.signOut();
        state = state.copyWith(
          isAuthenticated: false,
          isBusy: false,
          isRestoring: false,
          currentWorker: WorkerAccount.signedOut,
          workers: const [],
          clearMessage: true,
          errorMessage: worker == null
              ? 'This login has no staff profile. Ask an admin to register you.'
              : 'Your staff account is deactivated. Ask an admin to reactivate it.',
        );
        return false;
      }
      final workers = worker.canSeeModule(AppModuleKey.staff)
          ? await _backend.fetchWorkers()
          : [worker];
      state = state.copyWith(
        isAuthenticated: true,
        isBusy: false,
        isRestoring: false,
        currentWorker: worker,
        workers: workers,
        clearError: true,
        statusMessage: restoring
            ? null
            : 'Signed in as ${worker.fullName} (${worker.roleTitle})',
        clearMessage: restoring,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isAuthenticated: false,
        isBusy: false,
        isRestoring: false,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
    String pin = '1234',
  }) async {
    if (state.isBusy) return false;
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter both your work email and password.',
      );
      return false;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      state = state.copyWith(errorMessage: 'Enter a valid email address.');
      return false;
    }

    state = state.copyWith(isBusy: true, clearError: true, clearMessage: true);
    try {
      final userId = await _backend.signIn(
        email: normalizedEmail,
        password: password,
      );
      final ok = await _openSession(userId);
      if (ok && state.currentWorker.id.isNotEmpty) {
        await _quickPinService.saveWorkerSession(
          worker: state.currentWorker,
          password: password,
          pin: pin,
        );
      }
      return ok;
    } on Object catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: _messageFor(error));
      return false;
    }
  }

  Future<bool> signInWithQuickPin(String pin) async {
    if (state.isBusy) return false;
    final cleanPin = pin.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(cleanPin)) {
      state = state.copyWith(errorMessage: 'PIN must be exactly 4 digits.');
      return false;
    }

    final remembered = await _quickPinService.getRememberedWorker();
    if (remembered == null) {
      state = state.copyWith(
        errorMessage: 'No remembered staff account. Sign in with email.',
      );
      return false;
    }

    final isPinValid = await _quickPinService.verifyPin(cleanPin);
    if (!isPinValid) {
      state = state.copyWith(errorMessage: 'Incorrect 4-digit PIN. Try again.');
      return false;
    }

    state = state.copyWith(isBusy: true, clearError: true, clearMessage: true);
    try {
      if (_backend.restoredUserId != null) {
        return await _openSession(_backend.restoredUserId!);
      }
      final savedPassword = await _quickPinService.getSavedPassword();
      if (savedPassword != null && savedPassword.isNotEmpty) {
        final userId = await _backend.signIn(
          email: remembered.email,
          password: savedPassword,
        );
        return await _openSession(userId);
      }
      return await _openSession(remembered.id);
    } on Object catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: _messageFor(error));
      return false;
    }
  }

  Future<void> switchAccount() async {
    await _quickPinService.clearRememberedWorker();
    await signOut();
  }

  Future<void> signOut() async {
    try {
      await _backend.signOut();
    } finally {
      state = state.copyWith(
        isAuthenticated: false,
        isBusy: false,
        currentWorker: WorkerAccount.signedOut,
        workers: const [],
        clearError: true,
        statusMessage: 'Signed out.',
      );
    }
  }

  Future<(bool, String)> changeOwnPin({
    required String currentPin,
    required String newPin,
  }) async {
    final cleanPin = newPin.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(cleanPin)) {
      return (false, 'New PIN must be exactly 4 digits.');
    }
    final isCurrentValid = await _quickPinService.verifyPin(currentPin);
    if (!isCurrentValid) {
      return (false, 'Current 4-digit PIN is incorrect.');
    }
    await _quickPinService.updatePin(cleanPin);
    return (true, '4-Digit PIN updated successfully.');
  }

  /// Returns (ok, message) for the change-password dialog.
  Future<(bool, String)> changeOwnPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < kMinStaffPasswordLength) {
      return (
        false,
        'New password must be at least $kMinStaffPasswordLength characters.',
      );
    }
    if (newPassword == currentPassword) {
      return (false, 'New password must be different from the current one.');
    }
    try {
      await _backend.changePassword(
        email: state.currentWorker.email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _quickPinService.saveWorkerSession(
        worker: state.currentWorker,
        password: newPassword,
      );
      return (true, 'Password updated. Use it next time you sign in.');
    } on Object catch (error) {
      return (false, _messageFor(error));
    }
  }

  /// Admin only (enforced by the staff-admin Edge Function).
  Future<WorkerAccount?> addWorker({
    required String fullName,
    required String email,
    required String phone,
    required String roleTitle,
    required String branch,
    required Set<AppModuleKey> exceptedModules,
    required String initialPassword,
  }) async {
    final cleanName = fullName.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    if (cleanName.isEmpty) {
      state = state.copyWith(
        clearMessage: true,
        errorMessage: 'Enter the worker’s full name.',
      );
      return null;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(cleanEmail)) {
      state = state.copyWith(
        clearMessage: true,
        errorMessage:
            'Enter a valid work email address (name@harborridge.co.ke).',
      );
      return null;
    }
    if (cleanPhone.isNotEmpty &&
        cleanPhone.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      state = state.copyWith(
        clearMessage: true,
        errorMessage: 'Enter a valid contact phone number (at least 9 digits).',
      );
      return null;
    }
    if (initialPassword.length < kMinStaffPasswordLength) {
      state = state.copyWith(
        clearMessage: true,
        errorMessage:
            'Initial password must be at least $kMinStaffPasswordLength characters.',
      );
      return null;
    }
    state = state.copyWith(isBusy: true, clearError: true, clearMessage: true);
    try {
      final created = await _backend.createWorker(
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        roleTitle: roleTitle,
        role: operatorRoleForTitle(roleTitle),
        branch: branch,
        exceptedModules: exceptedModules,
        initialPassword: initialPassword,
      );
      final workers = await _backend.fetchWorkers();
      state = state.copyWith(
        isBusy: false,
        workers: workers,
        statusMessage:
            'Added ${created.fullName}. Share the initial password with them privately; they can change it after signing in.',
      );
      return created;
    } on Object catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: _messageFor(error));
      return null;
    }
  }

  /// Admin only (enforced by the staff-admin Edge Function).
  Future<bool> adminSetWorkerPassword({
    required String workerId,
    required String newPassword,
  }) async {
    if (newPassword.length < kMinStaffPasswordLength) {
      state = state.copyWith(
        clearMessage: true,
        errorMessage:
            'Password must be at least $kMinStaffPasswordLength characters.',
      );
      return false;
    }
    try {
      await _backend.setWorkerPassword(
        workerId: workerId,
        password: newPassword,
      );
      state = state.copyWith(
        clearError: true,
        statusMessage: 'Password reset. Share it with the worker privately.',
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        clearMessage: true,
        errorMessage: _messageFor(error),
      );
      return false;
    }
  }

  /// Admin only (enforced by the staff UPDATE policy). The roster updates only
  /// after the server confirms the change.
  Future<void> toggleWorkerModuleException(
    String workerId,
    AppModuleKey module,
  ) async {
    if (module == AppModuleKey.dashboard) return;
    final worker = state.workers.firstWhere(
      (w) => w.id == workerId,
      orElse: () => WorkerAccount.signedOut,
    );
    if (worker.id.isEmpty) return;

    final updatedExcepted = Set<AppModuleKey>.from(worker.exceptedModules);
    if (!updatedExcepted.remove(module)) updatedExcepted.add(module);

    try {
      await _backend.updateWorkerModules(
        workerId: workerId,
        exceptedModules: updatedExcepted,
      );
    } on Object catch (error) {
      state = state.copyWith(
        clearMessage: true,
        errorMessage: _messageFor(error),
      );
      return;
    }

    final updatedWorker = worker.copyWith(exceptedModules: updatedExcepted);
    state = state.copyWith(
      workers: [
        for (final w in state.workers) w.id == workerId ? updatedWorker : w,
      ],
      currentWorker: state.currentWorker.id == workerId
          ? updatedWorker
          : state.currentWorker,
      clearError: true,
      statusMessage: 'Updated menu rights for ${worker.fullName}',
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearMessage: true);
  }

  static String _messageFor(Object error) {
    if (error is AuthFailure) return error.message;
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup')) {
      return 'Cannot reach the server. Check your connection.';
    }
    return 'Something went wrong: $text';
  }
}

final authSessionNotifierProvider =
    NotifierProvider<AuthSessionNotifier, AuthPortalState>(
      AuthSessionNotifier.new,
    );
