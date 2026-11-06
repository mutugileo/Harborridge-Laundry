import 'package:laundry_ridge/features/services/domain/laundry_service.dart';

enum HomeUiStatus { loading, success, error }

class HomeUiState {
  const HomeUiState({
    required this.status,
    required this.services,
    required this.selectedCategory,
    required this.activeOrderCount,
    this.errorMessage,
  });

  final HomeUiStatus status;
  final List<LaundryService> services;
  final ServiceCategory selectedCategory;
  final int activeOrderCount;
  final String? errorMessage;

  factory HomeUiState.initial() {
    return const HomeUiState(
      status: HomeUiStatus.loading,
      services: [],
      selectedCategory: ServiceCategory.all,
      activeOrderCount: 1,
      errorMessage: null,
    );
  }

  List<LaundryService> get filteredServices {
    if (selectedCategory == ServiceCategory.all) {
      return services;
    }
    return services
        .where((service) => service.category == selectedCategory)
        .toList();
  }

  HomeUiState copyWith({
    HomeUiStatus? status,
    List<LaundryService>? services,
    ServiceCategory? selectedCategory,
    int? activeOrderCount,
    String? errorMessage,
  }) {
    return HomeUiState(
      status: status ?? this.status,
      services: services ?? this.services,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      activeOrderCount: activeOrderCount ?? this.activeOrderCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
