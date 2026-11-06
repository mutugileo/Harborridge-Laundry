import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/features/services/domain/laundry_service.dart';
import 'package:laundry_ridge/features/services/presentation/home_notifier.dart';
import 'package:laundry_ridge/features/services/presentation/home_state.dart';

void main() {
  test('HomeNotifier loads services and updates category filter', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(homeNotifierProvider).status, HomeUiStatus.loading);

    await container.read(homeNotifierProvider.notifier).loadServicesCatalog();

    final state = container.read(homeNotifierProvider);
    expect(state.status, HomeUiStatus.success);
    expect(state.services.isNotEmpty, isTrue);

    container
        .read(homeNotifierProvider.notifier)
        .filterServicesByCategory(ServiceCategory.dryCleaning);

    final filteredState = container.read(homeNotifierProvider);
    expect(filteredState.selectedCategory, ServiceCategory.dryCleaning);
    expect(
      filteredState.filteredServices.every(
        (s) => s.category == ServiceCategory.dryCleaning,
      ),
      isTrue,
    );
  });

  test('HomeNotifier increments active order count on new pickup', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialCount = container.read(homeNotifierProvider).activeOrderCount;
    container.read(homeNotifierProvider.notifier).scheduleNewPickupRequest();

    expect(
      container.read(homeNotifierProvider).activeOrderCount,
      initialCount + 1,
    );
  });
}
