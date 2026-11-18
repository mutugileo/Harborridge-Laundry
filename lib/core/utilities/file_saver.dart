export 'file_saver_stub.dart' if (dart.library.html) 'file_saver_web.dart';

String csvEscape(dynamic value) {
  final str = value?.toString() ?? '';
  if (str.contains(',') ||
      str.contains('"') ||
      str.contains('\n') ||
      str.contains('\r')) {
    return '"${str.replaceAll('"', '""')}"';
  }
  return str;
}
