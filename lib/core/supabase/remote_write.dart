import 'package:supabase_flutter/supabase_flutter.dart';

/// Runs a Supabase insert/update and returns null when the server applied it,
/// or a message staff can read when it did not.
///
/// The query must end in `.select(...)`: an UPDATE that row level security
/// filters out succeeds with zero rows instead of raising an error, so an
/// empty result is treated as "not allowed".
Future<String?> runRemoteWrite(Future<List<Map<String, dynamic>>> query) async {
  try {
    final rows = await query;
    if (rows.isEmpty) {
      return 'Your account cannot make this change, or the record no longer exists.';
    }
    return null;
  } on PostgrestException catch (error) {
    if (error.code == '42501') {
      return 'Your account cannot make this change.';
    }
    if (error.code == '23505') {
      return 'That record already exists.';
    }
    return error.message;
  } on Object {
    return 'Could not reach the server. Check your connection.';
  }
}
