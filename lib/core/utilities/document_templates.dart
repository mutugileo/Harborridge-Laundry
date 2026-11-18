import 'package:laundry_ridge/features/orders/domain/order_detail.dart';

class DocumentTemplates {
  static String generatePaymentReceiptHtml({
    required String txId,
    required String orderId,
    required String customerName,
    required String date,
    required String method,
    required int amountKes,
    required String status,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Receipt - $txId</title>
  <style>
    @page { size: 80mm 200mm; margin: 5mm; }
    body {
      font-family: 'Courier New', Courier, monospace;
      font-size: 13px;
      color: #111;
      line-height: 1.4;
      margin: 0;
      padding: 10px;
    }
    .text-center { text-align: center; }
    .bold { font-weight: bold; }
    .divider { border-top: 1px dashed #444; margin: 10px 0; }
    .title { font-size: 16px; font-weight: 800; letter-spacing: 1px; }
    .subtitle { font-size: 11px; color: #555; }
    .row { display: flex; justify-content: space-between; margin: 4px 0; }
    .badge {
      display: inline-block;
      padding: 2px 6px;
      background: #eee;
      border: 1px solid #ccc;
      font-size: 11px;
      font-weight: bold;
    }
    .barcode {
      font-family: monospace;
      letter-spacing: 4px;
      margin-top: 8px;
      font-size: 14px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="text-center">
    <div class="title">HARBOR RIDGE LAUNDRY</div>
    <div class="subtitle">Getathuru Road, opp. NG-CDF Kabete Plaza</div>
    <div class="subtitle">Nairobi, Kenya • PIN: P051289471A</div>
    <div class="divider"></div>
    <div class="bold">OFFICIAL PAYMENT RECEIPT</div>
  </div>
  <div class="divider"></div>
  <div class="row"><span>Receipt No:</span><span class="bold">$txId</span></div>
  <div class="row"><span>Order Ref:</span><span class="bold">$orderId</span></div>
  <div class="row"><span>Date:</span><span>$date</span></div>
  <div class="row"><span>Customer:</span><span class="bold">$customerName</span></div>
  <div class="row"><span>Channel:</span><span>$method</span></div>
  <div class="row"><span>Status:</span><span class="badge">$status</span></div>
  <div class="divider"></div>
  <div class="row" style="font-size: 15px;">
    <span class="bold">TOTAL PAID:</span>
    <span class="bold">KES $amountKes</span>
  </div>
  <div class="divider"></div>
  <div class="text-center" style="margin-top: 15px;">
    <div class="barcode">*${txId.replaceAll('-', '')}*</div>
    <p style="font-size: 11px; color: #555; margin-top: 6px;">Thank you for trusting Harbor Ridge Laundry.<br>Clean garments, crisp perfection.</p>
  </div>
</body>
</html>
''';
  }

  static String generateOrderReceiptHtml(OrderDetail order) {
    final isPaid = order.balanceDue <= 0;
    final itemsHtml = order.items
        .map((item) {
          final qtyLabel = item.weightKg != null && item.weightKg! > 0
              ? '${item.weightKg}kg'
              : '${item.quantity}x';
          return '''
      <div class="row">
        <span>$qtyLabel ${item.serviceName}</span>
        <span class="bold">KES ${item.total.round()}</span>
      </div>
      ''';
        })
        .join('\n');

    final addonsHtml = order.addons.isEmpty
        ? ''
        : order.addons
              .map((addon) {
                return '''
            <div class="row">
              <span>+ ${addon.name}</span>
              <span>KES ${addon.amount.round()}</span>
            </div>
            ''';
              })
              .join('\n');

    final paymentsHtml = order.payments.isEmpty
        ? '<div class="row"><span>Payment:</span><span>Pending</span></div>'
        : order.payments
              .map((p) {
                final ref = p.reference != null && p.reference!.isNotEmpty
                    ? ' (${p.reference})'
                    : '';
                return '<div class="row"><span>${p.method}$ref:</span><span>KES ${p.amount.round()}</span></div>';
              })
              .join('\n');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Receipt - ${order.orderId}</title>
  <style>
    @page { size: 80mm auto; margin: 4mm; }
    body {
      font-family: 'Courier New', Courier, monospace;
      font-size: 12.5px;
      color: #111;
      line-height: 1.4;
      margin: 0;
      padding: 8px;
    }
    .text-center { text-align: center; }
    .bold { font-weight: bold; }
    .divider { border-top: 1px dashed #444; margin: 8px 0; }
    .title { font-size: 15px; font-weight: 800; letter-spacing: 0.8px; }
    .subtitle { font-size: 10.5px; color: #555; }
    .row { display: flex; justify-content: space-between; gap: 8px; margin: 3px 0; }
    .badge {
      display: inline-block;
      padding: 2px 6px;
      background: #eee;
      border: 1px solid #bbb;
      font-size: 10.5px;
      font-weight: bold;
    }
    .barcode {
      font-family: monospace;
      letter-spacing: 3.5px;
      margin-top: 6px;
      font-size: 13px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="text-center">
    <div class="title">HARBOR RIDGE LAUNDRY</div>
    <div class="subtitle">Getathuru Road, opp. NG-CDF Kabete Plaza</div>
    <div class="subtitle">Harbor Ridge Main • ${order.taxIdentifier}</div>
    <div class="divider"></div>
    <div class="bold">CUSTOMER RECEIPT</div>
  </div>
  <div class="divider"></div>
  <div class="row"><span>Order #:</span><span class="bold">${order.orderId}</span></div>
  <div class="row"><span>Date:</span><span>${order.orderDate}</span></div>
  <div class="row"><span>Est. Ready:</span><span>${order.deliveryDate}</span></div>
  <div class="row"><span>Customer:</span><span class="bold">${order.customerName}</span></div>
  <div class="row"><span>Phone:</span><span>${order.customerPhone}</span></div>
  <div class="row"><span>Service:</span><span>${order.primaryService}</span></div>
  <div class="divider"></div>
  <div class="bold" style="margin-bottom: 4px;">ITEMS</div>
  $itemsHtml
  $addonsHtml
  <div class="divider"></div>
  <div class="row"><span>Subtotal:</span><span>KES ${order.itemsSubTotal.round()}</span></div>
  <div class="row bold" style="font-size: 14px;"><span>TOTAL:</span><span>KES ${order.totalAmount.round()}</span></div>
  <div class="row"><span>Paid:</span><span>KES ${order.paidAmount.round()}</span></div>
  <div class="row bold"><span>Balance Due:</span><span>KES ${order.balanceDue.round()}</span></div>
  <div class="row"><span>Status:</span><span class="badge">${isPaid ? 'PAID IN FULL' : 'BALANCE DUE'}</span></div>
  <div class="divider"></div>
  <div class="bold" style="margin-bottom: 4px;">PAYMENTS</div>
  $paymentsHtml
  <div class="divider"></div>
  <div class="text-center" style="margin-top: 10px;">
    <div class="barcode">*${order.orderId.replaceAll('-', '')}*</div>
    <p style="font-size: 10.5px; color: #555; margin-top: 5px;">Thank you for choosing Harbor Ridge Laundry.<br>Present this receipt upon garment collection.</p>
  </div>
</body>
</html>
''';
  }

  static String generateInvoiceHtml(OrderDetail order) {
    final itemsRows = order.items
        .map((item) {
          final qtyOrWeight = item.weightKg != null && item.weightKg! > 0
              ? '${item.weightKg} kg'
              : '${item.quantity} pcs';
          final rateLabel = 'KES ${item.rate.round()}';
          final totalLabel = 'KES ${item.total.round()}';
          return '''
      <tr>
        <td style="padding: 8px 4px; border-bottom: 1px solid #eee;">
          <strong>${item.serviceName}</strong><br>
          <span style="font-size: 11px; color: #666;">${item.serviceType}</span>
        </td>
        <td style="padding: 8px 4px; border-bottom: 1px solid #eee; text-align: center;">$qtyOrWeight</td>
        <td style="padding: 8px 4px; border-bottom: 1px solid #eee; text-align: right;">$rateLabel</td>
        <td style="padding: 8px 4px; border-bottom: 1px solid #eee; text-align: right; font-weight: bold;">$totalLabel</td>
      </tr>
      ''';
        })
        .join('\n');

    final addonsRows = order.addons.isEmpty
        ? ''
        : order.addons
              .map((addon) {
                return '''
            <tr>
              <td colspan="3" style="padding: 6px 4px; border-bottom: 1px solid #eee; color: #444;">
                + Add-on: ${addon.name}
              </td>
              <td style="padding: 6px 4px; border-bottom: 1px solid #eee; text-align: right; font-weight: 500;">
                KES ${addon.amount.round()}
              </td>
            </tr>
            ''';
              })
              .join('\n');

    final paymentsList = order.payments.isEmpty
        ? '<div style="font-size: 12px; color: #888;">No payments recorded yet</div>'
        : order.payments
              .map((p) {
                final ref = p.reference != null && p.reference!.isNotEmpty
                    ? ' (${p.reference})'
                    : '';
                return '<div style="font-size: 12px; margin-bottom: 2px;">• ${p.method}$ref: KES ${p.amount.round()} on ${p.date}</div>';
              })
              .join('');

    final isPaid = order.balanceDue <= 0;
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Invoice - ${order.orderId}</title>
  <style>
    @page { size: A4 portrait; margin: 15mm; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      font-size: 13px;
      color: #1e293b;
      margin: 0;
      padding: 20px;
    }
    .header-table { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
    .brand-title { font-size: 22px; font-weight: 800; color: #0284c7; letter-spacing: 0.5px; }
    .badge {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 700;
      text-transform: uppercase;
    }
    .badge-paid { background: #dcfce7; color: #15803d; }
    .badge-due { background: #fef3c7; color: #b45309; }
    .items-table { width: 100%; border-collapse: collapse; margin-top: 16px; margin-bottom: 20px; }
    .items-table th {
      background: #f8fafc;
      padding: 10px 4px;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      color: #64748b;
      border-bottom: 2px solid #e2e8f0;
    }
    .summary-box {
      width: 280px;
      margin-left: auto;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 12px;
      background: #f8fafc;
    }
    .summary-row { display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 13px; }
    .total-row { font-size: 16px; font-weight: 800; border-top: 1px solid #cbd5e1; padding-top: 6px; margin-top: 6px; }
  </style>
</head>
<body>
  <table class="header-table">
    <tr>
      <td style="vertical-align: top;">
        <div class="brand-title">HARBOR RIDGE LAUNDRY</div>
        <div style="font-size: 12px; color: #64748b; margin-top: 4px;">
          ${order.storeAddress}<br>
          Email: ${order.storeEmail} • Tax PIN: ${order.taxIdentifier}<br>
          Registered Branch: Harbor Ridge Main
        </div>
      </td>
      <td style="vertical-align: top; text-align: right;">
        <div style="font-size: 20px; font-weight: 800; color: #0f172a;">TAX INVOICE</div>
        <div style="font-size: 13px; font-weight: 600; color: #475569; margin-top: 4px;">Order #: ${order.orderId}</div>
        <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Date: ${order.orderDate}</div>
        <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Est. Ready: ${order.deliveryDate}</div>
        <div style="margin-top: 8px;">
          <span class="badge ${isPaid ? 'badge-paid' : 'badge-due'}">
            ${isPaid ? 'PAID IN FULL' : 'BALANCE DUE: KES ${order.balanceDue.round()}'}
          </span>
        </div>
      </td>
    </tr>
  </table>

  <div style="display: flex; justify-content: space-between; background: #f1f5f9; padding: 12px 16px; border-radius: 6px; margin-bottom: 20px;">
    <div>
      <div style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Customer Details</div>
      <div style="font-size: 14px; font-weight: 700; color: #0f172a; margin-top: 2px;">${order.customerName}</div>
      <div style="font-size: 12px; color: #475569;">Tel: ${order.customerPhone}</div>
    </div>
    <div style="text-align: right;">
      <div style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Service Type & Staff</div>
      <div style="font-size: 13px; font-weight: 600; color: #0f172a; margin-top: 2px;">${order.primaryService}</div>
      <div style="font-size: 12px; color: #475569;">Assigned: ${order.assignedStaff}</div>
    </div>
  </div>

  <table class="items-table">
    <thead>
      <tr>
        <th style="text-align: left;">Item Description</th>
        <th style="text-align: center;">Qty / Weight</th>
        <th style="text-align: right;">Unit Rate</th>
        <th style="text-align: right;">Total Amount</th>
      </tr>
    </thead>
    <tbody>
      $itemsRows
      $addonsRows
    </tbody>
  </table>

  <div style="display: flex; justify-content: space-between; align-items: flex-start;">
    <div style="max-width: 320px;">
      <div style="font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Payment Records:</div>
      $paymentsList
      <div style="margin-top: 16px; font-size: 11px; color: #94a3b8; line-height: 1.4;">
        Goods left uncollected for more than 30 days will attract storage charges. All laundry handled according to fabric care labels.
      </div>
    </div>
    <div class="summary-box">
      <div class="summary-row"><span>Subtotal:</span><span>KES ${order.itemsSubTotal.round()}</span></div>
      <div class="summary-row"><span>VAT (0% Inclusive):</span><span>KES 0</span></div>
      <div class="summary-row total-row"><span>Total:</span><span>KES ${order.totalAmount.round()}</span></div>
      <div class="summary-row" style="color: #15803d; margin-top: 6px;"><span>Amount Paid:</span><span>KES ${order.paidAmount.round()}</span></div>
      <div class="summary-row" style="font-weight: 700; color: ${order.balanceDue > 0 ? '#b45309' : '#0f172a'};"><span>Balance Due:</span><span>KES ${order.balanceDue.round()}</span></div>
    </div>
  </div>

  <div style="text-align: center; margin-top: 40px; border-top: 1px dashed #cbd5e1; padding-top: 15px;">
    <div style="font-family: monospace; letter-spacing: 5px; font-size: 15px; font-weight: bold;">*${order.orderId.replaceAll('-', '')}*</div>
    <div style="font-size: 11px; color: #64748b; margin-top: 4px;">Thank you for your business with HARBOR RIDGE LAUNDRY</div>
  </div>
</body>
</html>
''';
  }
}
