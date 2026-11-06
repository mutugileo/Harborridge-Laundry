import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/features/services/data/services_repository.dart';
import 'package:laundry_ridge/features/services/domain/laundry_service.dart';
import 'package:laundry_ridge/features/services/presentation/home_state.dart';

class HomeNotifier extends Notifier<HomeUiState> {
  bool _disposed = false;

  @override
  HomeUiState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(loadServicesCatalog);
    return HomeUiState.initial();
  }

  Future<void> loadServicesCatalog() async {
    if (_disposed) return;
    state = state.copyWith(status: HomeUiStatus.loading, errorMessage: null);

    try {
      final repository = ref.read(servicesRepositoryProvider);
      final services = await repository.fetchAvailableServices();
      if (_disposed) return;
      state = state.copyWith(status: HomeUiStatus.success, services: services);
    } catch (exception) {
      if (_disposed) return;
      state = state.copyWith(
        status: HomeUiStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  void filterServicesByCategory(ServiceCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void scheduleNewPickupRequest() {
    state = state.copyWith(activeOrderCount: state.activeOrderCount + 1);
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeUiState>(
  HomeNotifier.new,
);
