import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://cyjigxszbseqbchqfmuf.supabase.co';
  static const String publishableKey =
      'sb_publishable_Vd5cvOUHerGWtRnmqYCArg_7UvIpgxp';

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: publishableKey,
      );
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return SupabaseConfig.client;
});
