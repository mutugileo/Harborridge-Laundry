import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/app/app.dart';
import 'package:laundry_ridge/app/router/admin_nav_tab.dart';
import 'package:laundry_ridge/app/router/admin_shell_notifier.dart';

void main() {
  testWidgets(
    'Mobile Responsiveness: 390px (iPhone) renders all modules without overflow exceptions',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const LaundryRidgeApp(),
        ),
      );

      String currentTab = 'initial';
      final errors = <String>[];
      FlutterError.onError = (details) {
        final msg =
            '[$currentTab] ${details.summary}\n${details.informationCollector?.call().firstOrNull}\n';
        errors.add(msg);
        debugPrint('FLUTTER_OVERFLOW: $msg');
      };

      // Verify Auth Portal on 390px
      expect(find.text('Welcome to Harborridge Portal'), findsOneWidget);

      await tester.tap(find.text('Sign in with Email & PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify each module via shell notifier
      for (final tab in AdminNavTab.values) {
        currentTab = tab.name;
        container.read(adminShellNotifierProvider.notifier).switchTab(tab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(errors, isEmpty, reason: errors.join('\n'));
    },
  );

  testWidgets(
    'Mobile Responsiveness: 360px (Android) renders all modules without overflow exceptions',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const LaundryRidgeApp(),
        ),
      );

      String currentTab = 'initial';
      final errors = <String>[];
      FlutterError.onError = (details) {
        final msg =
            '[$currentTab] ${details.summary}\n${details.informationCollector?.call().firstOrNull}\n';
        errors.add(msg);
        debugPrint('FLUTTER_OVERFLOW_360: $msg');
      };

      await tester.tap(find.text('Sign in with Email & PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      for (final tab in AdminNavTab.values) {
        currentTab = tab.name;
        container.read(adminShellNotifierProvider.notifier).switchTab(tab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(errors, isEmpty, reason: errors.join('\n'));
    },
  );
}
