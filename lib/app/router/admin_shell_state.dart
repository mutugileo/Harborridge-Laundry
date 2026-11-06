import 'package:laundry_ridge/app/router/admin_nav_tab.dart';

class AdminShellState {
  const AdminShellState({
    required this.currentTab,
    required this.selectedLanguage,
    this.previousTab = AdminNavTab.dashboard,
  });

  final AdminNavTab currentTab;
  final AdminNavTab previousTab;
  final String selectedLanguage;

  int get transitionDirection => currentTab.index >= previousTab.index ? 1 : -1;

  factory AdminShellState.initial() {
    return const AdminShellState(
      currentTab: AdminNavTab.dashboard,
      previousTab: AdminNavTab.dashboard,
      selectedLanguage: 'English',
    );
  }

  AdminShellState copyWith({
    AdminNavTab? currentTab,
    AdminNavTab? previousTab,
    String? selectedLanguage,
  }) {
    return AdminShellState(
      currentTab: currentTab ?? this.currentTab,
      previousTab: previousTab ?? this.previousTab,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
