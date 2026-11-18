import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/app/app.dart';
import 'package:laundry_ridge/core/auth/auth_backend.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/auth/quick_pin_service.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test-only credentials. Never used outside the test suite.
const String kTestAdminEmail = 'admin@harborridge.test';
const String kTestAdminPassword = 'test-admin-pass';

/// In-memory stand-in for Supabase Auth + the staff table. It applies the
/// same rules the server does: a correct password is required, an account
/// needs an active staff profile, and only admins may create workers, reset
/// passwords or change menu rights.
class FakeAuthBackend implements AuthBackend {
  FakeAuthBackend() {
    _seed(
      const WorkerAccount(
        id: 'admin-1',
        fullName: 'Test Admin',
        email: kTestAdminEmail,
        phone: '',
        roleTitle: 'Super Admin',
        role: OperatorRole.admin,
        branch: 'Harbor Ridge Main',
        shiftLabel: '',
        isActive: true,
        exceptedModules: {},
      ),
      kTestAdminPassword,
    );
  }

  final Map<String, WorkerAccount> _workers = {};
  final Map<String, String> _passwords = {};
  final Map<String, String> _orphanLogins = {};
  final StreamController<void> _sessionEnded = StreamController.broadcast();
  String? _signedInId;
  int _nextId = 2;

  void _seed(WorkerAccount worker, String password) {
    _workers[worker.id] = worker;
    _passwords[worker.email] = password;
  }

  /// A login that exists in auth but has no staff profile.
  void addLoginWithoutProfile(String email, String password) {
    _orphanLogins[email] = password;
  }

  void deactivate(String email) {
    final worker = _workers.values.firstWhere((w) => w.email == email);
    _workers[worker.id] = WorkerAccount(
      id: worker.id,
      fullName: worker.fullName,
      email: worker.email,
      phone: worker.phone,
      roleTitle: worker.roleTitle,
      role: worker.role,
      branch: worker.branch,
      shiftLabel: worker.shiftLabel,
      isActive: false,
      exceptedModules: worker.exceptedModules,
    );
  }

  void endSessionRemotely() {
    _signedInId = null;
    _sessionEnded.add(null);
  }

  WorkerAccount? get _caller =>
      _signedInId == null ? null : _workers[_signedInId];

  void _requireAdmin() {
    final caller = _caller;
    if (caller == null || !caller.isActive || !caller.isAdmin) {
      throw const AuthFailure(
        'Only an active admin can manage worker accounts.',
      );
    }
  }

  @override
  String? get restoredUserId => _signedInId;

  @override
  Stream<void> get onSessionEnded => _sessionEnded.stream;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    if (_orphanLogins[email] == password) {
      _signedInId = 'orphan-$email';
      return _signedInId!;
    }
    if (_passwords[email] != password) {
      throw const AuthFailure('That email and password do not match.');
    }
    _signedInId = _workers.values.firstWhere((w) => w.email == email).id;
    return _signedInId!;
  }

  @override
  Future<void> signOut() async {
    _signedInId = null;
  }

  @override
  Future<WorkerAccount?> fetchWorker(String userId) async => _workers[userId];

  @override
  Future<List<WorkerAccount>> fetchWorkers() async => _workers.values.toList();

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_passwords[email] != currentPassword) {
      throw const AuthFailure('Your current password is not correct.');
    }
    _passwords[email] = newPassword;
  }

  @override
  Future<WorkerAccount> createWorker({
    required String fullName,
    required String email,
    required String phone,
    required String roleTitle,
    required OperatorRole role,
    required String branch,
    required Set<AppModuleKey> exceptedModules,
    required String initialPassword,
  }) async {
    _requireAdmin();
    if (_passwords.containsKey(email)) {
      throw AuthFailure('An account for $email already exists.');
    }
    final worker = WorkerAccount(
      id: 'worker-${_nextId++}',
      fullName: fullName,
      email: email,
      phone: phone,
      roleTitle: roleTitle,
      role: role,
      branch: branch,
      shiftLabel: '',
      isActive: true,
      exceptedModules: exceptedModules,
    );
    _seed(worker, initialPassword);
    return worker;
  }

  @override
  Future<void> setWorkerPassword({
    required String workerId,
    required String password,
  }) async {
    _requireAdmin();
    _passwords[_workers[workerId]!.email] = password;
  }

  @override
  Future<void> updateWorkerModules({
    required String workerId,
    required Set<AppModuleKey> exceptedModules,
  }) async {
    _requireAdmin();
    _workers[workerId] = _workers[workerId]!.copyWith(
      exceptedModules: exceptedModules,
    );
  }
}

ProviderContainer makeTestContainer([FakeAuthBackend? backend]) {
  return ProviderContainer(
    overrides: [
      authBackendProvider.overrideWithValue(backend ?? FakeAuthBackend()),
    ],
  );
}

Future<ProviderContainer> pumpTestApp(
  WidgetTester tester, {
  FakeAuthBackend? backend,
}) async {
  SharedPreferences.setMockInitialValues({});
  QuickPinService.resetMemoryCache();
  final container = makeTestContainer(backend);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const LaundryRidgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> signInThroughForm(
  WidgetTester tester, {
  String email = kTestAdminEmail,
  String password = kTestAdminPassword,
}) async {
  final switchBtn = find.byKey(const ValueKey('switch_to_email_login_button'));
  if (switchBtn.evaluate().isNotEmpty) {
    await tester.tap(switchBtn);
    await tester.pumpAndSettle();
  }
  await tester.enterText(
    find.byKey(const ValueKey('login_email_input')),
    email,
  );
  await tester.enterText(
    find.byKey(const ValueKey('login_password_input')),
    password,
  );
  await tester.ensureVisible(find.byKey(const ValueKey('login_submit_button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('login_submit_button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
