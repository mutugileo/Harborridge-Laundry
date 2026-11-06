class OrderPayment {
  const OrderPayment({
    required this.amount,
    required this.date,
    required this.method,
  });

  final double amount;
  final String date;
  final String method;
}
