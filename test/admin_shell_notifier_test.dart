import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/app/router/admin_nav_tab.dart';
import 'package:laundry_ridge/app/router/admin_shell_notifier.dart';

void main() {
  test('AdminShellNotifier switches active tabs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(adminShellNotifierProvider).currentTab,
      AdminNavTab.dashboard,
    );

    container
        .read(adminShellNotifierProvider.notifier)
        .switchTab(AdminNavTab.orders);

    expect(
      container.read(adminShellNotifierProvider).currentTab,
      AdminNavTab.orders,
    );

    container
        .read(adminShellNotifierProvider.notifier)
        .switchTab(AdminNavTab.orderStatus);

    expect(
      container.read(adminShellNotifierProvider).currentTab,
      AdminNavTab.orderStatus,
    );
  });
}
