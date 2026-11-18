import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';

import 'support/fake_auth_backend.dart';

void main() {
  group('AuthSessionNotifier', () {
    test('starts signed out with no worker or roster loaded', () {
      final container = makeTestContainer();
      addTearDown(container.dispose);

      final state = container.read(authSessionNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.workers, isEmpty);
      expect(state.currentWorker.id, isEmpty);
      for (final module in AppModuleKey.values) {
        expect(state.currentWorker.canSeeModule(module), isFalse);
      }
    });

    test('signs in with the correct email and password', () async {
      final container = makeTestContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authSessionNotifierProvider.notifier);

      final ok = await notifier.signIn(
        email: '  ADMIN@harborridge.test ',
        password: kTestAdminPassword,
      );

      final state = container.read(authSessionNotifierProvider);
      expect(ok, isTrue);
      expect(state.isAuthenticated, isTrue);
      expect(state.currentWorker.isAdmin, isTrue);
      expect(state.workers, isNotEmpty);
    });

    test('rejects a wrong password', () async {
      final container = makeTestContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authSessionNotifierProvider.notifier);

      final ok = await notifier.signIn(
        email: kTestAdminEmail,
        password: 'wrong-password',
      );

      final state = container.read(authSessionNotifierProvider);
      expect(ok, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, contains('do not match'));
    });

    test('rejects a valid login that has no staff profile', () async {
      final backend = FakeAuthBackend()
        ..addLoginWithoutProfile('stranger@example.com', 'some-password');
      final container = makeTestContainer(backend);
      addTearDown(container.dispose);
      final notifier = container.read(authSessionNotifierProvider.notifier);

      final ok = await notifier.signIn(
        email: 'stranger@example.com',
        password: 'some-password',
      );

      expect(ok, isFalse);
      final state = container.read(authSessionNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, contains('no staff profile'));
      expect(backend.restoredUserId, isNull, reason: 'signed back out');
    });

    test('rejects a deactivated worker', () async {
      final backend = FakeAuthBackend()..deactivate(kTestAdminEmail);
      final container = makeTestContainer(backend);
      addTearDown(container.dispose);

      final ok = await container
          .read(authSessionNotifierProvider.notifier)
          .signIn(email: kTestAdminEmail, password: kTestAdminPassword);

      expect(ok, isFalse);
      expect(
        container.read(authSessionNotifierProvider).errorMessage,
        contains('deactivated'),
      );
    });

    test('non-admin cannot change menu rights or add workers', () async {
      final backend = FakeAuthBackend();
      final container = makeTestContainer(backend);
      addTearDown(container.dispose);
      final notifier = container.read(authSessionNotifierProvider.notifier);

      await notifier.signIn(
        email: kTestAdminEmail,
        password: kTestAdminPassword,
      );
      final cashier = await notifier.addWorker(
        fullName: 'Cashier One',
        email: 'cashier@harborridge.test',
        phone: '',
        roleTitle: 'POS Counter Attendant',
        branch: 'Harbor Ridge Main',
        exceptedModules: {AppModuleKey.staff, AppModuleKey.reports},
        initialPassword: 'cashier-pass-1',
      );
      expect(cashier, isNotNull);
      expect(cashier!.role, OperatorRole.cashier);
      await notifier.signOut();

      await notifier.signIn(
        email: 'cashier@harborridge.test',
        password: 'cashier-pass-1',
      );
      expect(
        container
            .read(authSessionNotifierProvider)
            .currentWorker
            .canSeeModule(AppModuleKey.reports),
        isFalse,
      );

      await notifier.toggleWorkerModuleException(
        cashier.id,
        AppModuleKey.reports,
      );
      var state = container.read(authSessionNotifierProvider);
      expect(state.errorMessage, contains('Only an active admin'));
      expect(
        state.currentWorker.canSeeModule(AppModuleKey.reports),
        isFalse,
        reason: 'roster only changes after the server accepts it',
      );

      final created = await notifier.addWorker(
        fullName: 'Sneaky',
        email: 'sneaky@harborridge.test',
        phone: '',
        roleTitle: 'Super Admin',
        branch: 'Harbor Ridge Main',
        exceptedModules: {},
        initialPassword: 'sneaky-pass-1',
      );
      state = container.read(authSessionNotifierProvider);
      expect(created, isNull);
      expect(state.errorMessage, contains('Only an active admin'));
    });

    test('rejects short passwords before calling the server', () async {
      final container = makeTestContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authSessionNotifierProvider.notifier);
      await notifier.signIn(
        email: kTestAdminEmail,
        password: kTestAdminPassword,
      );

      final created = await notifier.addWorker(
        fullName: 'Short Pass',
        email: 'short@harborridge.test',
        phone: '',
        roleTitle: 'Production Lead',
        branch: 'Harbor Ridge Main',
        exceptedModules: {},
        initialPassword: '1234',
      );
      expect(created, isNull);

      final (ok, message) = await notifier.changeOwnPassword(
        currentPassword: kTestAdminPassword,
        newPassword: '1234',
      );
      expect(ok, isFalse);
      expect(message, contains('at least'));
    });

    test('returns to sign-in when the session ends remotely', () async {
      final backend = FakeAuthBackend();
      final container = makeTestContainer(backend);
      addTearDown(container.dispose);
      final notifier = container.read(authSessionNotifierProvider.notifier);
      await notifier.signIn(
        email: kTestAdminEmail,
        password: kTestAdminPassword,
      );

      backend.endSessionRemotely();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authSessionNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, contains('session ended'));
    });
  });
}
