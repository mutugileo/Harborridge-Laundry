import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/app/theme/app_theme.dart';
import 'package:laundry_ridge/core/widgets/garment_catalog_grid.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/services/presentation/admin_services_catalog_view.dart';

void main() {
  group('Custom Item Intake and Garment Catalog Tests', () {
    testWidgets('GarmentCatalogGrid displays "Add Item" but NOT "by Barcode"', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.createLightTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: GarmentCatalogGrid(
                quantities: const {},
                onIncrementGarment: (_) {},
                onDecrementGarment: (_) {},
                onAddCustomItem: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.text('by Barcode'), findsNothing);
    });

    testWidgets(
      'AdminServicesCatalogView allows adding custom item with name, category, price, and preset picture',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        PosOrderSubmission? capturedSubmission;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.createLightTheme(),
              home: Scaffold(
                body: AdminServicesCatalogView(
                  quantities: const {},
                  onIncrementGarment: (_) {},
                  onDecrementGarment: (_) {},
                  onSubmitNewOrder: (sub) => capturedSubmission = sub,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Confirm "by Barcode" does not exist
        expect(find.text('by Barcode'), findsNothing);

        // 2. Scroll to and tap "Add Item"
        final addItemFinder = find.text('Add Item');
        expect(addItemFinder, findsOneWidget);
        await tester.scrollUntilVisible(
          addItemFinder,
          300.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(addItemFinder);
        await tester.pumpAndSettle();

        // 3. Verify dialog opened
        expect(find.text('Add Custom Item'), findsOneWidget);
        expect(
          find.text('Enter custom garment details with photo'),
          findsOneWidget,
        );
        expect(find.text('Upload Image'), findsOneWidget);
        expect(find.text('Take Photo'), findsOneWidget);

        // 4. Enter item details
        final nameInputFinder = find.byKey(
          const ValueKey('custom_item_name_input'),
        );
        expect(nameInputFinder, findsOneWidget);
        await tester.enterText(nameInputFinder, 'Velvet Kaftan');

        final rateInputFinder = find.byKey(
          const ValueKey('custom_item_rate_input'),
        );
        expect(rateInputFinder, findsOneWidget);
        await tester.enterText(rateInputFinder, '1250');
        await tester.pumpAndSettle();

        // 5. Submit custom item dialog
        final addBtnFinder = find.text('Add to Ticket');
        expect(addBtnFinder, findsOneWidget);
        await tester.tap(addBtnFinder);
        await tester.pumpAndSettle();

        // 6. Verify custom item appears in Selected Items
        expect(find.text('Velvet Kaftan'), findsOneWidget);
        expect(find.text('Selected Items (1)'), findsOneWidget);
        expect(find.text('KES 1250'), findsWidgets);

        // 7. Complete order submission (blocked without customer details)
        final createOrderBtn = find.text('Create Order & View Invoice');
        expect(createOrderBtn, findsOneWidget);
        await tester.scrollUntilVisible(
          createOrderBtn,
          300.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(createOrderBtn);
        await tester.pumpAndSettle();
        expect(capturedSubmission, isNull);

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
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          createOrderBtn,
          300.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(createOrderBtn);
        await tester.pumpAndSettle();

        expect(capturedSubmission, isNotNull);
        expect(capturedSubmission!.customItems?.length, 1);
        expect(
          capturedSubmission!.customItems!.first.serviceName,
          'Velvet Kaftan',
        );
        expect(capturedSubmission!.customItems!.first.rate, 1250.0);
      },
    );

    test(
      'OrderItem correctly models picture data (imageBytes and imageUrl)',
      () {
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final item = OrderItem(
          index: 1,
          serviceName: 'Silk Scarf',
          serviceType: '[Dry Cleaning]',
          rate: 650.0,
          quantity: 2,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.tanBlazer,
          imageBytes: bytes,
          imageUrl: 'data:image/jpeg;base64,AQIDBAU=',
        );

        expect(item.imageBytes, bytes);
        expect(item.imageUrl, 'data:image/jpeg;base64,AQIDBAU=');
        expect(item.total, 1300.0);

        final updated = item.copyWith(quantity: 3);
        expect(updated.quantity, 3);
        expect(updated.imageBytes, bytes);
        expect(updated.imageUrl, 'data:image/jpeg;base64,AQIDBAU=');
        expect(updated.total, 1950.0);
      },
    );
  });
}
