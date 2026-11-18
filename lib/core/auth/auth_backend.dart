import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimum length for staff passwords. Mirrors the staff-admin Edge Function.
const int kMinStaffPasswordLength = 8;

/// A failure the UI can show as-is.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Everything the app needs from the identity provider. The real
/// implementation talks to Supabase; tests swap in an in-memory fake.
abstract class AuthBackend {
  /// The signed-in user id from a persisted session, if any.
  String? get restoredUserId;

  /// Fires when the session ends outside the app's control (expired refresh
  /// token, sign-out in another tab).
  Stream<void> get onSessionEnded;

  /// Signs in and returns the user id. Throws [AuthFailure].
  Future<String> signIn({required String email, required String password});

  Future<void> signOut();

  /// The staff profile for [userId], or null when the account has none.
  Future<WorkerAccount?> fetchWorker(String userId);

  /// Every staff profile the current user is allowed to read.
  Future<List<WorkerAccount>> fetchWorkers();

  /// Re-checks [currentPassword] for [email], then sets [newPassword].
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  });

  /// Admin only: creates a login and staff profile in one step.
  Future<WorkerAccount> createWorker({
    required String fullName,
    required String email,
    required String phone,
    required String roleTitle,
    required OperatorRole role,
    required String branch,
    required Set<AppModuleKey> exceptedModules,
    required String initialPassword,
  });

  /// Admin only.
  Future<void> setWorkerPassword({
    required String workerId,
    required String password,
  });

  /// Admin only.
  Future<void> updateWorkerModules({
    required String workerId,
    required Set<AppModuleKey> exceptedModules,
  });
}

class SupabaseAuthBackend implements AuthBackend {
  SupabaseAuthBackend(this._client);

  final SupabaseClient _client;

  @override
  String? get restoredUserId => _client.auth.currentUser?.id;

  @override
  Stream<void> get onSessionEnded => _client.auth.onAuthStateChange
      .where((change) => change.event == AuthChangeEvent.signedOut)
      .map((_) {});

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Sign-in failed. Try again.');
      }
      return user.id;
    } on AuthException catch (error) {
      final lower = error.message.toLowerCase();
      if (lower.contains('invalid login') ||
          lower.contains('invalid credentials')) {
        throw const AuthFailure('That email and password do not match.');
      }
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<WorkerAccount?> fetchWorker(String userId) async {
    final row = await _client
        .from('staff')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : WorkerAccount.fromRow(row);
  }

  @override
  Future<List<WorkerAccount>> fetchWorkers() async {
    final rows = await _client
        .from('staff')
        .select()
        .order('created_at', ascending: true);
    return [
      for (final row in rows as List)
        WorkerAccount.fromRow(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException {
      throw const AuthFailure('Your current password is not correct.');
    }
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  Future<Map<String, dynamic>> _invokeStaffAdmin(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'staff-admin',
        body: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      throw const AuthFailure('Unexpected response from the server.');
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw AuthFailure(details['error'] as String);
      }
      throw AuthFailure('Request failed (${error.status}).');
    }
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
    final data = await _invokeStaffAdmin({
      'action': 'create',
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'roleTitle': roleTitle,
      'role': role.name,
      'branch': branch,
      'exceptedModules': [for (final m in exceptedModules) m.name],
      'password': initialPassword,
    });
    return WorkerAccount.fromRow(data['worker'] as Map<String, dynamic>);
  }

  @override
  Future<void> setWorkerPassword({
    required String workerId,
    required String password,
  }) async {
    await _invokeStaffAdmin({
      'action': 'set_password',
      'workerId': workerId,
      'password': password,
    });
  }

  @override
  Future<void> updateWorkerModules({
    required String workerId,
    required Set<AppModuleKey> exceptedModules,
  }) async {
    final updated = await _client
        .from('staff')
        .update({
          'excepted_modules': [for (final m in exceptedModules) m.name],
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', workerId)
        .select('id');
    if ((updated as List).isEmpty) {
      throw const AuthFailure('Only an admin can change menu rights.');
    }
  }
}

/// Used when the Supabase client could not start (e.g. offline at launch).
class UnavailableAuthBackend implements AuthBackend {
  const UnavailableAuthBackend();

  static const _failure = AuthFailure(
    'Cannot reach the Harbor Ridge server. Check your connection and reload.',
  );

  @override
  String? get restoredUserId => null;

  @override
  Stream<void> get onSessionEnded => const Stream.empty();

  @override
  Future<String> signIn({required String email, required String password}) =>
      Future.error(_failure);

  @override
  Future<void> signOut() async {}

  @override
  Future<WorkerAccount?> fetchWorker(String userId) => Future.error(_failure);

  @override
  Future<List<WorkerAccount>> fetchWorkers() => Future.error(_failure);

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) => Future.error(_failure);

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
  }) => Future.error(_failure);

  @override
  Future<void> setWorkerPassword({
    required String workerId,
    required String password,
  }) => Future.error(_failure);

  @override
  Future<void> updateWorkerModules({
    required String workerId,
    required Set<AppModuleKey> exceptedModules,
  }) => Future.error(_failure);
}

final authBackendProvider = Provider<AuthBackend>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const UnavailableAuthBackend();
  return SupabaseAuthBackend(client);
});
