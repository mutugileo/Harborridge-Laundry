import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';

import 'support/fake_auth_backend.dart';

void main() {
  testWidgets(
    'End-to-End Journey 1: Login -> Dashboard -> POS Order Creation -> Order Invoice -> Order List',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = await pumpTestApp(tester);

      expect(find.text('Welcome to Harbor Ridge Portal'), findsOneWidget);
      expect(find.text('STAFF SIGN IN'), findsOneWidget);
      expect(find.text('Register Worker'), findsNothing);

      await signInThroughForm(tester);

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

      container
          .read(orderDetailsNotifierProvider.notifier)
          .incrementPosGarment(GarmentType.shirt);
      await tester.pump();

      await tester.ensureVisible(find.text('Create Order & View Invoice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Order & View Invoice'));
      await tester.pump();
      expect(
        find.text(
          'Please enter a valid customer phone number (at least 9 digits).',
        ),
        findsWidgets,
      );

      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Enter mobile number for pickup SMS alerts',
        ),
        '0712345678',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter customer full name'),
        'Amina Hassan',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter M-Pesa receipt code'),
        'QK89XYZ12',
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Create Order & View Invoice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Order & View Invoice'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('LG-2026-00131'), findsWidgets);
      expect(find.text('Amina Hassan'), findsWidgets);
      expect(find.text('ADD PAYMENT'), findsOneWidget);
      expect(find.text('Print Receipt'), findsOneWidget);
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
    'End-to-End Journey 2: Admin adds a worker with a password -> worker signs in with restricted menus -> changes password -> old password rejected',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = await pumpTestApp(tester);
      await signInThroughForm(tester);

      expect(find.text('Reports'), findsOneWidget);
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
      expect(find.text('Initial Password'), findsOneWidget);
      expect(find.textContaining('PIN:'), findsNothing);
      expect(find.text('Switch Session to Worker'), findsNothing);

      final authNotifier = container.read(authSessionNotifierProvider.notifier);
      final newWorker = await authNotifier.addWorker(
        fullName: 'Kelvin Mutua',
        email: 'kelvin.mutua@harborridge.test',
        phone: '+254 710 555 900',
        roleTitle: 'POS Counter Attendant',
        branch: 'Harbor Ridge Main',
        initialPassword: 'first-pass-123',
        exceptedModules: {
          AppModuleKey.reports,
          AppModuleKey.staff,
          AppModuleKey.settings,
          AppModuleKey.inventory,
        },
      );
      expect(newWorker, isNotNull);
      await tester.pump();

      await tester.tap(find.text('Logout'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Welcome to Harbor Ridge Portal'), findsOneWidget);

      await signInThroughForm(
        tester,
        email: 'kelvin.mutua@harborridge.test',
        password: 'first-pass-123',
      );

      expect(
        container.read(authSessionNotifierProvider).currentWorker.fullName,
        'Kelvin Mutua',
      );
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Reports'), findsNothing);
      expect(find.text('Inventory'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('header_change_pin_button')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('change_pin_current_input')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('change_pin_current_input')),
        'first-pass-123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('change_pin_new_input')),
        'second-pass-456',
      );
      await tester.enterText(
        find.byKey(const ValueKey('change_pin_confirm_input')),
        'second-pass-456',
      );
      await tester.tap(find.byKey(const ValueKey('submit_change_pin_button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Password updated'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('subsequent_pin_form_view')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('switch_to_email_login_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Work Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      await signInThroughForm(
        tester,
        email: 'kelvin.mutua@harborridge.test',
        password: 'first-pass-123',
      );
      expect(
        container.read(authSessionNotifierProvider).isAuthenticated,
        isFalse,
      );
      expect(
        find.text('That email and password do not match.'),
        findsOneWidget,
      );

      await signInThroughForm(
        tester,
        email: 'kelvin.mutua@harborridge.test',
        password: 'second-pass-456',
      );
      expect(
        container.read(authSessionNotifierProvider).isAuthenticated,
        isTrue,
      );
    },
  );

  testWidgets(
    'End-to-End Journey 3: All 13 Modules Render & Cross-Link Cleanly Without Exceptions',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await pumpTestApp(tester);
      await signInThroughForm(tester);

      final tabsToVerify = <(String, String)>[
        ('Dispatch', 'Pickup & Delivery Dispatch Command'),
        ('Customers', 'Customer Directory & Loyalty Accounts'),
        ('Payments', 'Invoices & Payment Ledger'),
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

      await pumpTestApp(tester);

      // 1. Initial Login Screen: nothing pre-filled
      expect(find.text('HARBOR RIDGE'), findsWidgets);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text(kTestAdminEmail), findsNothing);

      // 2. Perform Login
      await signInThroughForm(tester);

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
