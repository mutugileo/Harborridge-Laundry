import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/core/utilities/document_templates.dart';
import 'package:laundry_ridge/core/utilities/file_saver.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/dashboard/presentation/admin_dashboard_view.dart';
import 'package:laundry_ridge/features/orders/domain/order_addon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/orders/domain/order_payment.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';
import 'package:laundry_ridge/features/payments/presentation/payments_view.dart';
import 'package:laundry_ridge/features/reports/presentation/reports_view.dart';

void main() {
  group('Export and Print Utilities & Templates', () {
    test('csvEscape properly escapes commas, quotes, and newlines', () {
      expect(csvEscape('Normal Text'), 'Normal Text');
      expect(csvEscape('Contains, Comma'), '"Contains, Comma"');
      expect(csvEscape('Contains "Quotes"'), '"Contains ""Quotes"""');
      expect(csvEscape('Contains\nNewline'), '"Contains\nNewline"');
      expect(csvEscape(null), '');
      expect(csvEscape(1500), '1500');
    });

    test('DocumentTemplates.generatePaymentReceiptHtml formats correctly', () {
      final html = DocumentTemplates.generatePaymentReceiptHtml(
        txId: 'TX-2026-999',
        orderId: 'ORD-2026-888',
        customerName: 'Wanjiku Kamau',
        date: '18/11/2026 14:00',
        method: 'M-Pesa (QA89XYZ23)',
        amountKes: 2500,
        status: 'Paid',
      );

      expect(html, contains('HARBOR RIDGE LAUNDRY'));
      expect(html, contains('<svg'));
      expect(html, contains('LAUNDRY SERVICE'));
      expect(html, contains('FRESH, FOLDED, DELIVERED'));
      expect(html, contains('OFFICIAL PAYMENT RECEIPT'));
      expect(html, contains('TX-2026-999'));
      expect(html, contains('ORD-2026-888'));
      expect(html, contains('Wanjiku Kamau'));
      expect(html, contains('KES 2500'));
      expect(html, contains('M-Pesa (QA89XYZ23)'));
    });

    test(
      'DocumentTemplates.generateInvoiceHtml formats tax invoice correctly',
      () {
        const order = OrderDetail(
          orderId: 'ORD-7001',
          storeName: 'HARBOR RIDGE LAUNDRY',
          storeCode: 'HR-MAIN',
          storeEmail: 'admin@harborridgelaundry.co.ke',
          storeAddress: 'Getathuru Road, opp. NG-CDF Kabete Plaza',
          taxIdentifier: 'P051289471A',
          orderDate: '18/11/2026',
          deliveryDate: '19/11/2026',
          status: OrderProcessStatus.washing,
          customerName: 'Brian Otieno',
          customerPhone: '+254 722 111 222',
          primaryService: 'Premium Dry Clean',
          vendorBranch: 'Harbor Ridge Main',
          items: [
            OrderItem(
              index: 0,
              serviceName: 'Suit 2-Piece',
              serviceType: 'Dry Clean',
              rate: 1200.0,
              quantity: 1,
              icon: Icons.checkroom,
              garmentType: GarmentType.tanBlazer,
            ),
          ],
          addons: [OrderAddon(name: 'Fabric Protector', amount: 300.0)],
          payments: [
            OrderPayment(
              amount: 1500.0,
              date: '18/11/2026',
              method: 'M-Pesa',
              reference: 'QK123984',
            ),
          ],
        );

        final html = DocumentTemplates.generateInvoiceHtml(order);

        expect(html, contains('TAX INVOICE'));
        expect(html, contains('<svg'));
        expect(html, contains('LAUNDRY SERVICE'));
        expect(html, contains('ORD-7001'));
        expect(html, contains('Brian Otieno'));
        expect(html, contains('Suit 2-Piece'));
        expect(html, contains('Fabric Protector'));
        expect(html, contains('PAID IN FULL'));
        expect(html, contains('KES 1500'));
      },
    );
  });

  group('Interactive UI Export & Print Widgets', () {
    testWidgets('ReportsView Export PDF/CSV triggers download and feedback', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: ReportsView())),
        ),
      );
      await tester.pumpAndSettle();

      final exportButton = find.text('Export PDF / CSV');
      expect(exportButton, findsOneWidget);

      await tester.tap(exportButton);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Downloaded harbor_ridge_financial_report'),
        findsOneWidget,
      );
    });

    testWidgets('Dashboard View Export triggers download and feedback', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: AdminDashboardView())),
        ),
      );
      await tester.pumpAndSettle();

      final exportBtn = find.text('Export');
      expect(exportBtn, findsOneWidget);

      await tester.tap(exportBtn);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Downloaded harbor_ridge_dashboard_report'),
        findsOneWidget,
      );
      // Verify dummy Upgrade button is gone
      expect(find.text('Upgrade'), findsNothing);
    });

    testWidgets(
      'PaymentsView Download Statement triggers download and feedback',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: PaymentsView())),
          ),
        );
        await tester.pumpAndSettle();

        final downloadBtn = find.text('Download Statement');
        expect(downloadBtn, findsOneWidget);

        await tester.tap(downloadBtn);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Downloaded harbor_ridge_payments_statement'),
          findsOneWidget,
        );
      },
    );

    test('OrderDetailsNotifier triggerPrintInvoice and triggerPrintReceipt update state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(orderDetailsNotifierProvider.notifier);
      await notifier.loadOrderDetails('#ORD-0006');
      final order = container.read(orderDetailsNotifierProvider).order;
      expect(order, isNotNull);

      final receiptHtml = DocumentTemplates.generateOrderReceiptHtml(order!);
      expect(receiptHtml, contains('CUSTOMER RECEIPT'));
      expect(receiptHtml, contains(order.orderId));
      expect(receiptHtml, contains(order.customerName));

      notifier.triggerPrintInvoice();
      expect(
        container.read(orderDetailsNotifierProvider).actionFeedbackMessage,
        contains('Printed tax invoice for'),
      );

      notifier.triggerPrintReceipt();
      expect(
        container.read(orderDetailsNotifierProvider).actionFeedbackMessage,
        contains('Printed customer receipt for'),
      );
    });
  });
}
