class OrderPayment {
  const OrderPayment({
    required this.amount,
    required this.date,
    required this.method,
    this.reference,
  });

  final double amount;
  final String date;
  final String method;

  /// M-Pesa / bank reference code, when the payment has one.
  final String? reference;
}
