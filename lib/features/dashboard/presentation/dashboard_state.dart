import 'package:laundry_ridge/features/dashboard/domain/dashboard_models.dart';

class DashboardUiState {
  const DashboardUiState({
    required this.selectedDateFilter,
    required this.selectedStatsFilter,
    required this.selectedRevenueFilter,
    required this.selectedCustomerIndex,
    required this.activeOrdersCount,
    required this.totalOrdersCount,
    required this.kpiMetrics,
    required this.topCustomers,
    required this.weeklyStatistics,
    required this.realtimeRevenueNormalized,
    this.feedbackMessage,
  });

  final String selectedDateFilter;
  final String selectedStatsFilter;
  final String selectedRevenueFilter;
  final int selectedCustomerIndex;
  final int activeOrdersCount;
  final int totalOrdersCount;
  final List<DashboardKpiMetric> kpiMetrics;
  final List<DashboardTopCustomer> topCustomers;
  final List<OrderStatisticDayPoint> weeklyStatistics;
  final List<double> realtimeRevenueNormalized;
  final String? feedbackMessage;

  DashboardTopCustomer get activeTopCustomer =>
      topCustomers[selectedCustomerIndex.clamp(0, topCustomers.length - 1)];

  DashboardUiState copyWith({
    String? selectedDateFilter,
    String? selectedStatsFilter,
    String? selectedRevenueFilter,
    int? selectedCustomerIndex,
    int? activeOrdersCount,
    int? totalOrdersCount,
    List<DashboardKpiMetric>? kpiMetrics,
    List<DashboardTopCustomer>? topCustomers,
    List<OrderStatisticDayPoint>? weeklyStatistics,
    List<double>? realtimeRevenueNormalized,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return DashboardUiState(
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      selectedStatsFilter: selectedStatsFilter ?? this.selectedStatsFilter,
      selectedRevenueFilter:
          selectedRevenueFilter ?? this.selectedRevenueFilter,
      selectedCustomerIndex:
          selectedCustomerIndex ?? this.selectedCustomerIndex,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      totalOrdersCount: totalOrdersCount ?? this.totalOrdersCount,
      kpiMetrics: kpiMetrics ?? this.kpiMetrics,
      topCustomers: topCustomers ?? this.topCustomers,
      weeklyStatistics: weeklyStatistics ?? this.weeklyStatistics,
      realtimeRevenueNormalized:
          realtimeRevenueNormalized ?? this.realtimeRevenueNormalized,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
    );
  }
}
