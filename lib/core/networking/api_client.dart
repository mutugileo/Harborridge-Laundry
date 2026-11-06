import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  const ApiClient({this.simulatedLatency = const Duration(milliseconds: 120)});

  final Duration simulatedLatency;

  Future<T> simulateRequest<T>(T Function() builder) async {
    await Future<void>.delayed(simulatedLatency);
    return builder();
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return const ApiClient();
});
