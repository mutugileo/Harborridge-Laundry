import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/app/app.dart';

void main() {
  testWidgets(
    'AdminShellScreen renders Order List with all 9 columns & filters, drills into Order Details, and switches to Kanban board',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: LaundryRidgeApp()));

      expect(find.text('HARBORRIDGE'), findsWidgets);
      expect(find.text('Welcome to Harborridge Portal'), findsOneWidget);
      expect(find.text('Sign in with Email & PIN'), findsOneWidget);

      await tester.tap(find.text('Sign in with Email & PIN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Operations Overview'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('Active Wash Queue'), findsOneWidget);
      expect(find.text('Quick Links'), findsOneWidget);
      expect(find.text('Top Customers'), findsOneWidget);
      expect(find.text('Order Statistics'), findsOneWidget);
      expect(find.text('Real Time Revenue'), findsOneWidget);

      await tester.tap(find.text('Orders').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('All Laundry Orders'), findsOneWidget);
      expect(find.text('LG-2026-00125'), findsOneWidget);
      expect(find.text('John Kamau'), findsOneWidget);
      expect(find.text('Wash & Fold'), findsWidgets);
      expect(find.text('LaundryGo Nairobi'), findsWidgets);
      expect(find.text('KES 1,500'), findsOneWidget);
      expect(find.text('Paid'), findsWidgets);
      expect(find.text('Washing'), findsWidgets);
      expect(find.text('Pickup assigned'), findsWidgets);
      expect(find.text('05 Nov 2026'), findsWidgets);
      expect(find.text('#ORD-0006'), findsOneWidget);

      await tester.tap(find.text('#ORD-0006'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Baby Cloths'), findsOneWidget);
      expect(find.text('[Wet Wash]'), findsOneWidget);
      expect(find.text('ADD PAYMENT'), findsOneWidget);
      expect(find.text('Print Invoice'), findsOneWidget);
      expect(find.text('Service Addons'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('All Laundry Orders'), findsOneWidget);

      await tester.tap(find.text('Order Status Screen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('In Queue'), findsWidgets);
      expect(find.text('Cleaning'), findsWidgets);
      expect(find.text('Drying'), findsWidgets);
      expect(find.text('Fold'), findsWidgets);
      expect(find.text('#561'), findsOneWidget);
      expect(find.text('Polly Matthews'), findsOneWidget);
      expect(find.text('16 items • 12.8 lbs'), findsOneWidget);
      expect(find.text('Staff: Elena Rostova'), findsWidgets);
    },
  );
}
