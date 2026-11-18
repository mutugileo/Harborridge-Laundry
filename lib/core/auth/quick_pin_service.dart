import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberedWorkerProfile {
  const RememberedWorkerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleTitle,
    required this.branch,
  });

  final String id;
  final String fullName;
  final String email;
  final String roleTitle;
  final String branch;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'HR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class QuickPinService {
  QuickPinService([SharedPreferences? prefs]) : _injectedPrefs = prefs;

  final SharedPreferences? _injectedPrefs;
  static const _keyWorkerId = 'hr_remembered_worker_id';
  static const _keyWorkerName = 'hr_remembered_worker_name';
  static const _keyWorkerEmail = 'hr_remembered_worker_email';
  static const _keyWorkerRole = 'hr_remembered_worker_role';
  static const _keyWorkerBranch = 'hr_remembered_worker_branch';
  static const _keyWorkerPassword = 'hr_remembered_worker_password';
  static const _keyWorkerPin = 'hr_remembered_worker_pin';

  // In-memory fallback if SharedPreferences is unavailable or during early test bootstrap
  static final Map<String, String> _memoryCache = {};

  static void resetMemoryCache() {
    _memoryCache.clear();
  }

  Future<SharedPreferences?> _getPrefs() async {
    if (_injectedPrefs != null) return _injectedPrefs;
    try {
      return await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 150),
      );
    } catch (_) {
      return null;
    }
  }

  Future<RememberedWorkerProfile?> getRememberedWorker() async {
    final prefs = await _getPrefs();
    final id = prefs?.getString(_keyWorkerId) ?? _memoryCache[_keyWorkerId];
    final name =
        prefs?.getString(_keyWorkerName) ?? _memoryCache[_keyWorkerName];
    final email =
        prefs?.getString(_keyWorkerEmail) ?? _memoryCache[_keyWorkerEmail];
    final role =
        prefs?.getString(_keyWorkerRole) ?? _memoryCache[_keyWorkerRole];
    final branch =
        prefs?.getString(_keyWorkerBranch) ?? _memoryCache[_keyWorkerBranch];

    if (id == null || id.isEmpty || name == null || email == null) {
      return null;
    }

    return RememberedWorkerProfile(
      id: id,
      fullName: name,
      email: email,
      roleTitle: role ?? 'Staff',
      branch: branch ?? 'Harborridge Main',
    );
  }

  Future<void> saveWorkerSession({
    required WorkerAccount worker,
    required String password,
    String pin = '1234',
  }) async {
    final cleanPin = pin.trim().isEmpty ? '1234' : pin.trim();
    _memoryCache[_keyWorkerId] = worker.id;
    _memoryCache[_keyWorkerName] = worker.fullName;
    _memoryCache[_keyWorkerEmail] = worker.email;
    _memoryCache[_keyWorkerRole] = worker.roleTitle;
    _memoryCache[_keyWorkerBranch] = worker.branch;
    _memoryCache[_keyWorkerPassword] = password;
    _memoryCache[_keyWorkerPin] = cleanPin;

    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.setString(_keyWorkerId, worker.id);
      await prefs.setString(_keyWorkerName, worker.fullName);
      await prefs.setString(_keyWorkerEmail, worker.email);
      await prefs.setString(_keyWorkerRole, worker.roleTitle);
      await prefs.setString(_keyWorkerBranch, worker.branch);
      await prefs.setString(_keyWorkerPassword, password);
      await prefs.setString(_keyWorkerPin, cleanPin);
    }
  }

  Future<String?> getSavedPassword() async {
    final prefs = await _getPrefs();
    return prefs?.getString(_keyWorkerPassword) ??
        _memoryCache[_keyWorkerPassword];
  }

  Future<String> getQuickPin() async {
    final prefs = await _getPrefs();
    return prefs?.getString(_keyWorkerPin) ??
        _memoryCache[_keyWorkerPin] ??
        '1234';
  }

  Future<bool> verifyPin(String enteredPin) async {
    final currentPin = await getQuickPin();
    return enteredPin.trim() == currentPin.trim();
  }

  Future<void> updatePin(String newPin) async {
    final cleanPin = newPin.trim();
    _memoryCache[_keyWorkerPin] = cleanPin;
    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.setString(_keyWorkerPin, cleanPin);
    }
  }

  Future<void> clearRememberedWorker() async {
    _memoryCache.remove(_keyWorkerId);
    _memoryCache.remove(_keyWorkerName);
    _memoryCache.remove(_keyWorkerEmail);
    _memoryCache.remove(_keyWorkerRole);
    _memoryCache.remove(_keyWorkerBranch);
    _memoryCache.remove(_keyWorkerPassword);
    _memoryCache.remove(_keyWorkerPin);

    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.remove(_keyWorkerId);
      await prefs.remove(_keyWorkerName);
      await prefs.remove(_keyWorkerEmail);
      await prefs.remove(_keyWorkerRole);
      await prefs.remove(_keyWorkerBranch);
      await prefs.remove(_keyWorkerPassword);
      await prefs.remove(_keyWorkerPin);
    }
  }
}

final quickPinServiceProvider = Provider<QuickPinService>((ref) {
  return QuickPinService();
});
