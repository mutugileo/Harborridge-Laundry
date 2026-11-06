import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/router/admin_nav_tab.dart';
import 'package:laundry_ridge/app/router/admin_shell_state.dart';

class AdminShellNotifier extends Notifier<AdminShellState> {
  @override
  AdminShellState build() {
    return AdminShellState.initial();
  }

  void switchTab(AdminNavTab tab) {
    if (tab == state.currentTab) return;
    state = state.copyWith(previousTab: state.currentTab, currentTab: tab);
  }

  void updateLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }
}

final adminShellNotifierProvider =
    NotifierProvider<AdminShellNotifier, AdminShellState>(
      AdminShellNotifier.new,
    );
