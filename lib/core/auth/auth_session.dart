import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';

enum OperatorRole { admin, manager, productionLead, cashier, driver }

class WorkerAccount {
  const WorkerAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.pin,
    required this.phone,
    required this.roleTitle,
    required this.role,
    required this.branch,
    required this.shiftLabel,
    required this.isActive,
    required this.exceptedModules,
  });

  final String id;
  final String fullName;
  final String email;
  final String pin;
  final String phone;
  final String roleTitle;
  final OperatorRole role;
  final String branch;
  final String shiftLabel;
  final bool isActive;
  final Set<AppModuleKey> exceptedModules;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'HR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool canSeeModule(AppModuleKey module) => !exceptedModules.contains(module);

  int get allowedModulesCount =>
      AppModuleKey.values.length - exceptedModules.length;

  WorkerAccount copyWith({
    String? id,
    String? fullName,
    String? email,
    String? pin,
    String? phone,
    String? roleTitle,
    OperatorRole? role,
    String? branch,
    String? shiftLabel,
    bool? isActive,
    Set<AppModuleKey>? exceptedModules,
  }) {
    return WorkerAccount(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      pin: pin ?? this.pin,
      phone: phone ?? this.phone,
      roleTitle: roleTitle ?? this.roleTitle,
      role: role ?? this.role,
      branch: branch ?? this.branch,
      shiftLabel: shiftLabel ?? this.shiftLabel,
      isActive: isActive ?? this.isActive,
      exceptedModules: exceptedModules ?? this.exceptedModules,
    );
  }
}

class AuthPortalState {
  const AuthPortalState({
    required this.isAuthenticated,
    required this.isRegisterMode,
    required this.currentWorker,
    required this.selectedPreviewWorkerId,
    required this.workers,
    this.statusMessage,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final bool isRegisterMode;
  final WorkerAccount currentWorker;
  final String selectedPreviewWorkerId;
  final List<WorkerAccount> workers;
  final String? statusMessage;
  final String? errorMessage;

  WorkerAccount get previewWorker => workers.firstWhere(
    (w) => w.id == selectedPreviewWorkerId,
    orElse: () => currentWorker,
  );

  AuthPortalState copyWith({
    bool? isAuthenticated,
    bool? isRegisterMode,
    WorkerAccount? currentWorker,
    String? selectedPreviewWorkerId,
    List<WorkerAccount>? workers,
    String? statusMessage,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return AuthPortalState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isRegisterMode: isRegisterMode ?? this.isRegisterMode,
      currentWorker: currentWorker ?? this.currentWorker,
      selectedPreviewWorkerId:
          selectedPreviewWorkerId ?? this.selectedPreviewWorkerId,
      workers: workers ?? this.workers,
      statusMessage: clearMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthSessionNotifier extends Notifier<AuthPortalState> {
  static const List<WorkerAccount> initialWorkers = [
    WorkerAccount(
      id: 'WRK-001',
      fullName: 'Codzure Admin',
      email: 'codzuresolutions@gmail.com',
      pin: '1234',
      phone: '+254 700 000 001',
      roleTitle: 'Super Admin',
      role: OperatorRole.admin,
      branch: 'Harborridge Main',
      shiftLabel: 'All Day • Full Access',
      isActive: true,
      exceptedModules: {},
    ),
    WorkerAccount(
      id: 'WRK-002',
      fullName: 'Elena Rostova',
      email: 'elena.rostova@harborridgelaundry.com',
      pin: '1234',
      phone: '+254 711 200 101',
      roleTitle: 'Super Admin',
      role: OperatorRole.admin,
      branch: 'Harborridge Main',
      shiftLabel: 'All Day • Full Access',
      isActive: true,
      exceptedModules: {},
    ),
    WorkerAccount(
      id: 'WRK-003',
      fullName: 'Sarah Jenkins',
      email: 'sarah.jenkins@harborridgelaundry.com',
      pin: '2222',
      phone: '+254 722 310 442',
      roleTitle: 'POS Counter Attendant',
      role: OperatorRole.cashier,
      branch: 'LaundryGo Nairobi',
      shiftLabel: 'Morning • 07:00–15:30',
      isActive: true,
      exceptedModules: {
        AppModuleKey.settlements,
        AppModuleKey.staff,
        AppModuleKey.settings,
      },
    ),
    WorkerAccount(
      id: 'WRK-004',
      fullName: 'Marcus Vance',
      email: 'marcus.vance@harborridgelaundry.com',
      pin: '3333',
      phone: '+254 733 490 881',
      roleTitle: 'Production Lead',
      role: OperatorRole.productionLead,
      branch: 'Harborridge Main',
      shiftLabel: 'Day Shift • 08:00–17:00',
      isActive: true,
      exceptedModules: {
        AppModuleKey.payments,
        AppModuleKey.settlements,
        AppModuleKey.staff,
        AppModuleKey.settings,
      },
    ),
    WorkerAccount(
      id: 'WRK-005',
      fullName: 'Peter Mwangi',
      email: 'peter.mwangi@harborridgelaundry.com',
      pin: '4444',
      phone: '+254 701 882 910',
      roleTitle: 'Dispatch & Fleet Rider',
      role: OperatorRole.driver,
      branch: 'LaundryGo Westlands',
      shiftLabel: 'Route A • 08:30–18:00',
      isActive: true,
      exceptedModules: {
        AppModuleKey.vendors,
        AppModuleKey.payments,
        AppModuleKey.settlements,
        AppModuleKey.inventory,
        AppModuleKey.staff,
        AppModuleKey.reports,
        AppModuleKey.settings,
      },
    ),
    WorkerAccount(
      id: 'WRK-006',
      fullName: 'David Ochieng',
      email: 'david.ochieng@harborridgelaundry.com',
      pin: '5555',
      phone: '+254 790 551 320',
      roleTitle: 'Finance & Settlements Officer',
      role: OperatorRole.manager,
      branch: 'Harborridge Main',
      shiftLabel: 'Corporate • 08:00–17:00',
      isActive: true,
      exceptedModules: {
        AppModuleKey.inventory,
        AppModuleKey.staff,
        AppModuleKey.settings,
      },
    ),
  ];

  @override
  AuthPortalState build() {
    return AuthPortalState(
      isAuthenticated: false,
      isRegisterMode: false,
      currentWorker: initialWorkers.first,
      selectedPreviewWorkerId: initialWorkers.first.id,
      workers: initialWorkers,
    );
  }

  void selectPreviewWorker(String workerId) {
    state = state.copyWith(
      selectedPreviewWorkerId: workerId,
      clearMessage: true,
      clearError: true,
    );
  }

  void toggleAuthMode(bool registerMode) {
    state = state.copyWith(
      isRegisterMode: registerMode,
      clearMessage: true,
      clearError: true,
    );
  }

  bool signInWithEmailAndPin({required String email, required String pin}) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPin = pin.trim();

    if (normalizedEmail.isEmpty || normalizedPin.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter both your work email and security PIN to sign in.',
      );
      return false;
    }

    final matchedIndex = state.workers.indexWhere((w) {
      final workerEmail = w.email.toLowerCase();
      final workerUsername = workerEmail.split('@').first;
      final workerName = w.fullName.toLowerCase();
      return workerEmail == normalizedEmail ||
          workerUsername == normalizedEmail ||
          workerName == normalizedEmail;
    });
    if (matchedIndex == -1) {
      state = state.copyWith(
        errorMessage:
            'No registered worker found for $email. Ask an Admin to register your account.',
      );
      return false;
    }

    final matchedWorker = state.workers[matchedIndex];
    if (matchedWorker.pin != normalizedPin) {
      state = state.copyWith(
        errorMessage:
            'Incorrect PIN for ${matchedWorker.fullName}. Check your 4-digit PIN or ask an Admin to reset it.',
      );
      return false;
    }

    state = state.copyWith(
      isAuthenticated: true,
      currentWorker: matchedWorker,
      selectedPreviewWorkerId: matchedWorker.id,
      clearError: true,
      statusMessage:
          'Signed in as ${matchedWorker.fullName} (${matchedWorker.roleTitle})',
    );
    return true;
  }

  void signInInstant([WorkerAccount? worker]) {
    final chosen = worker ?? state.previewWorker;
    state = state.copyWith(
      isAuthenticated: true,
      currentWorker: chosen,
      selectedPreviewWorkerId: chosen.id,
      clearError: true,
      statusMessage: 'Signed in as ${chosen.fullName} (${chosen.roleTitle})',
    );
  }

  void registerWorkerAndSignIn({
    required String fullName,
    required String roleTitle,
    required String branch,
    String initialPin = '1234',
    Set<AppModuleKey> exceptedModules = const {},
  }) {
    final trimmedName = fullName.trim().isEmpty
        ? 'Grace Njeri'
        : fullName.trim();
    final sanitizedPin = initialPin.trim().isEmpty ? '1234' : initialPin.trim();
    final newId = 'WRK-00${state.workers.length + 1}';
    final emailSlug = trimmedName.toLowerCase().replaceAll(' ', '.');
    final newWorker = WorkerAccount(
      id: newId,
      fullName: trimmedName,
      email: '$emailSlug@harborridgelaundry.com',
      pin: sanitizedPin,
      phone: '+254 715 900 ${100 + state.workers.length}',
      roleTitle: roleTitle,
      role: OperatorRole.manager,
      branch: branch,
      shiftLabel: 'Full Day • 08:00–17:00',
      isActive: true,
      exceptedModules: exceptedModules,
    );
    final updated = [newWorker, ...state.workers];
    state = state.copyWith(
      workers: updated,
      currentWorker: newWorker,
      selectedPreviewWorkerId: newWorker.id,
      isAuthenticated: true,
      isRegisterMode: false,
      clearError: true,
      statusMessage: 'Registered and signed in as ${newWorker.fullName}',
    );
  }

  WorkerAccount addWorkerFromAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String roleTitle,
    required String branch,
    required Set<AppModuleKey> exceptedModules,
    String initialPin = '1234',
  }) {
    final trimmedName = fullName.trim().isEmpty
        ? 'New Staff Member'
        : fullName.trim();
    final sanitizedPin = initialPin.trim().isEmpty ? '1234' : initialPin.trim();
    final newId = 'WRK-00${state.workers.length + 1}';
    final emailSlug = trimmedName.toLowerCase().replaceAll(' ', '.');
    final newWorker = WorkerAccount(
      id: newId,
      fullName: trimmedName,
      email: email.trim().isEmpty
          ? '$emailSlug@harborridgelaundry.com'
          : email.trim(),
      pin: sanitizedPin,
      phone: phone.trim().isEmpty ? '+254 718 400 219' : phone.trim(),
      roleTitle: roleTitle,
      role: OperatorRole.manager,
      branch: branch,
      shiftLabel: 'Assigned Shift • 08:00–17:00',
      isActive: true,
      exceptedModules: exceptedModules,
    );
    final updated = [newWorker, ...state.workers];
    state = state.copyWith(
      workers: updated,
      clearError: true,
      statusMessage:
          'Added worker ${newWorker.fullName} with initial PIN ${newWorker.pin} (${newWorker.allowedModulesCount}/${AppModuleKey.values.length} menus enabled)',
    );
    return newWorker;
  }

  (bool, String) changeCurrentWorkerPin({
    required String currentPin,
    required String newPin,
  }) {
    final trimmedCurrent = currentPin.trim();
    final trimmedNew = newPin.trim();

    if (trimmedCurrent != state.currentWorker.pin) {
      return (false, 'Current PIN does not match your active security PIN.');
    }
    if (trimmedNew.length < 4) {
      return (false, 'New security PIN must be at least 4 digits.');
    }

    final updatedWorker = state.currentWorker.copyWith(pin: trimmedNew);
    final updatedWorkers = state.workers
        .map((w) => w.id == updatedWorker.id ? updatedWorker : w)
        .toList();

    state = state.copyWith(
      workers: updatedWorkers,
      currentWorker: updatedWorker,
      clearError: true,
      statusMessage:
          'Security PIN updated for ${updatedWorker.fullName}. Use your new PIN on next login.',
    );
    return (
      true,
      'Your security PIN has been updated. Use it next time you sign in.',
    );
  }

  void adminSetWorkerPin({required String workerId, required String newPin}) {
    final trimmedNew = newPin.trim();
    if (trimmedNew.length < 4) return;

    final updatedWorkers = state.workers.map((worker) {
      if (worker.id != workerId) return worker;
      return worker.copyWith(pin: trimmedNew);
    }).toList();

    final updatedCurrent = updatedWorkers.firstWhere(
      (w) => w.id == state.currentWorker.id,
      orElse: () => state.currentWorker,
    );

    state = state.copyWith(
      workers: updatedWorkers,
      currentWorker: updatedCurrent,
      clearError: true,
      statusMessage: 'Updated security PIN for worker $workerId',
    );
  }

  void toggleWorkerModuleException(String workerId, AppModuleKey module) {
    if (module == AppModuleKey.dashboard) {
      return;
    }
    final updatedWorkers = state.workers.map((worker) {
      if (worker.id != workerId) return worker;
      final updatedExcepted = Set<AppModuleKey>.from(worker.exceptedModules);
      if (updatedExcepted.contains(module)) {
        updatedExcepted.remove(module);
      } else {
        updatedExcepted.add(module);
      }
      return worker.copyWith(exceptedModules: updatedExcepted);
    }).toList();

    final updatedCurrent = updatedWorkers.firstWhere(
      (w) => w.id == state.currentWorker.id,
      orElse: () => state.currentWorker,
    );

    state = state.copyWith(
      workers: updatedWorkers,
      currentWorker: updatedCurrent,
      statusMessage: 'Updated menu permissions for worker $workerId',
    );
  }

  void switchActiveWorker(WorkerAccount worker) {
    state = state.copyWith(
      currentWorker: worker,
      selectedPreviewWorkerId: worker.id,
      isAuthenticated: true,
      statusMessage:
          'Switched active session to ${worker.fullName} (${worker.roleTitle})',
    );
  }

  void signOutToPortal() {
    state = state.copyWith(
      isAuthenticated: false,
      statusMessage:
          'Select any worker profile or click Sign in for instant access',
    );
  }
}

final authSessionNotifierProvider =
    NotifierProvider<AuthSessionNotifier, AuthPortalState>(
      AuthSessionNotifier.new,
    );
