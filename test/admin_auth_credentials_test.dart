import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';

void main() {
  group('Admin Auth Credentials (codzuresolutions@gmail.com)', () {
    test(
      'Default initial worker is codzuresolutions@gmail.com with PIN 1234',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final state = container.read(authSessionNotifierProvider);
        final admin = state.workers.first;

        expect(admin.email, 'codzuresolutions@gmail.com');
        expect(admin.pin, '1234');
        expect(admin.roleTitle, 'Super Admin');
        expect(admin.role, OperatorRole.admin);
        expect(admin.exceptedModules, isEmpty);
        expect(admin.allowedModulesCount, AppModuleKey.values.length);
      },
    );

    test('Signs in successfully using full email and PIN 1234', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authSessionNotifierProvider.notifier);
      final result = notifier.signInWithEmailAndPin(
        email: 'codzuresolutions@gmail.com',
        pin: '1234',
      );

      expect(result, isTrue);
      final state = container.read(authSessionNotifierProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.currentWorker.email, 'codzuresolutions@gmail.com');
      expect(state.currentWorker.roleTitle, 'Super Admin');
      expect(state.currentWorker.canSeeModule(AppModuleKey.dashboard), isTrue);
      expect(state.currentWorker.canSeeModule(AppModuleKey.settings), isTrue);
    });

    test(
      'Signs in successfully using username (codzuresolutions) and PIN 1234',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(authSessionNotifierProvider.notifier);
        final result = notifier.signInWithEmailAndPin(
          email: 'codzuresolutions',
          pin: '1234',
        );

        expect(result, isTrue);
        final state = container.read(authSessionNotifierProvider);
        expect(state.isAuthenticated, isTrue);
        expect(state.currentWorker.email, 'codzuresolutions@gmail.com');
      },
    );

    test('Rejects invalid PIN for codzuresolutions@gmail.com', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authSessionNotifierProvider.notifier);
      final result = notifier.signInWithEmailAndPin(
        email: 'codzuresolutions@gmail.com',
        pin: '9999',
      );

      expect(result, isFalse);
      final state = container.read(authSessionNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, contains('Incorrect PIN'));
    });
  });
}
