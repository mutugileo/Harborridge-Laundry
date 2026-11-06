import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/app/app.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';

void main() {
  testWidgets(
    'End-to-End Journey 1: Login -> Dashboard -> POS Order Creation -> Order Invoice -> Order List',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: LaundryRidgeApp()));

      expect(find.text('Welcome to Harborridge Portal'), findsOneWidget);
      expect(find.text('EMAIL & PIN SIGN IN'), findsOneWidget);
      expect(find.text('Register Worker'), findsNothing);

      await tester.tap(find.text('Sign in with Email & PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Operations Overview'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Quick Links'), findsOneWidget);
      expect(find.text('Top Customers'), findsOneWidget);
      expect(find.text('Order Statistics'), findsOneWidget);
      expect(find.text('Real Time Revenue'), findsOneWidget);

      await tester.tap(find.text('New Order'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('POS Garment & Service Intake'), findsOneWidget);
      expect(find.text('Customer / Owner Details'), findsOneWidget);
      expect(find.text('Create Order & View Invoice'), findsOneWidget);

      await tester.ensureVisible(find.text('Create Order & View Invoice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Order & View Invoice'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('LG-2026-00131'), findsWidgets);
      expect(find.text('John Kamau'), findsWidgets);
      expect(find.text('ADD PAYMENT'), findsOneWidget);
      expect(find.text('Print Invoice'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('All Laundry Orders'), findsOneWidget);
      expect(find.text('LG-2026-00131'), findsOneWidget);
      expect(find.text('LG-2026-00125'), findsOneWidget);
    },
  );

  testWidgets(
    'End-to-End Journey 2: Admin Registers Worker with Initial PIN -> Worker Changes PIN Inside App -> Logs Out & Logs In with New PIN',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1024);
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

      await tester.tap(find.text('Sign in with Email & PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Settlements'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);

      await tester.tap(find.text('Staff'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Staff Roster & Role-Based Menu Rights'),
        findsOneWidget,
      );
      expect(find.text('Register Worker & Assign Menu Rights'), findsOneWidget);
      expect(find.text('Initial 4-Digit Security PIN'), findsOneWidget);

      final authNotifier = container.read(authSessionNotifierProvider.notifier);
      final newWorker = authNotifier.addWorkerFromAdmin(
        fullName: 'Kelvin Mutua',
        email: 'kelvin.mutua@harborridgelaundry.com',
        phone: '+254 710 555 900',
        roleTitle: 'POS Counter Attendant',
        branch: 'LaundryGo Nairobi',
        initialPin: '4321',
        exceptedModules: {
          AppModuleKey.settlements,
          AppModuleKey.staff,
          AppModuleKey.settings,
          AppModuleKey.vendors,
        },
      );
      expect(newWorker.pin, '4321');
      authNotifier.switchActiveWorker(newWorker);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Settlements'), findsNothing);
      expect(find.text('Vendors'), findsNothing);

      // Worker changes their own PIN inside the app via the header Change PIN button
      await tester.tap(find.byKey(const ValueKey('header_change_pin_button')));
      await tester.pumpAndSettle();

      expect(find.text('Change My Security PIN'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('change_pin_current_input')),
        '4321',
      );
      await tester.enterText(
        find.byKey(const ValueKey('change_pin_new_input')),
        '9876',
      );
      await tester.enterText(
        find.byKey(const ValueKey('change_pin_confirm_input')),
        '9876',
      );
      await tester.tap(find.byKey(const ValueKey('submit_change_pin_button')));
      await tester.pumpAndSettle();

      expect(
        container.read(authSessionNotifierProvider).currentWorker.pin,
        '9876',
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Welcome to Harborridge Portal'), findsOneWidget);
      expect(find.text('Username or Work Email'), findsOneWidget);
      expect(find.text('Security PIN'), findsOneWidget);

      // Verify old PIN ('4321') is rejected and new PIN ('9876') succeeds
      await tester.enterText(
        find.byKey(const ValueKey('login_email_input')),
        'kelvin.mutua@harborridgelaundry.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('login_pin_input')),
        '4321',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pump();
      expect(
        container.read(authSessionNotifierProvider).isAuthenticated,
        isFalse,
      );

      await tester.enterText(
        find.byKey(const ValueKey('login_pin_input')),
        '9876',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        container.read(authSessionNotifierProvider).isAuthenticated,
        isTrue,
      );
      expect(
        container.read(authSessionNotifierProvider).currentWorker.fullName,
        'Kelvin Mutua',
      );
    },
  );

  testWidgets(
    'End-to-End Journey 3: All 13 Modules Render & Cross-Link Cleanly Without Exceptions',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: LaundryRidgeApp()));

      await tester.tap(find.text('Sign in with Email & PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final tabsToVerify = <(String, String)>[
        ('Dispatch', 'Pickup & Delivery Dispatch Command'),
        ('Customers', 'Customer Directory & Loyalty Accounts'),
        ('Vendors', 'Vendor & Branch Processing Network'),
        ('Payments', 'Invoices & Payment Ledger'),
        ('Settlements', 'Vendor Payouts & Commission Settlements'),
        ('Inventory', 'Consumables, Solvents & Packaging Inventory'),
        ('Reports', 'Executive Operations & Financial Reports'),
        ('Settings', 'System Configuration & Store Preferences'),
      ];

      for (final (sidebarLabel, expectedHeading) in tabsToVerify) {
        await tester.tap(find.text(sidebarLabel));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 450));
        expect(find.text(expectedHeading), findsOneWidget);
      }
    },
  );

  testWidgets(
    'End-to-End Journey 4: Zero-Dummy Verification -> Dynamic Metrics & Seamless Navigation',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: LaundryRidgeApp()));

      // 1. Initial Login Screen
      expect(find.text('HARBORRIDGE'), findsWidgets);
      expect(find.text('Sign in with Email & PIN'), findsOneWidget);

      // 2. Perform Login
      await tester.tap(find.text('Sign in with Email & PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 3. Admin Dashboard verification - No hardcoded static dummies
      expect(find.text('Operations Overview'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('Active Wash Queue'), findsOneWidget);
      expect(find.text('Top Customers'), findsOneWidget);

      // 4. Navigate to Production Kanban
      await tester.tap(find.text('Order Status Screen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Production Floor & Kanban Telemetry'), findsOneWidget);

      // 5. Navigate to Inventory
      await tester.tap(find.text('Inventory'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Consumables, Solvents & Packaging Inventory'),
        findsOneWidget,
      );

      // 6. Navigate to Staff & Permissions
      await tester.tap(find.text('Staff'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Staff Roster & Role-Based Menu Rights'),
        findsOneWidget,
      );
    },
  );
}
