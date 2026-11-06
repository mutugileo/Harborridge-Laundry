class CurrencyFormatter {
  const CurrencyFormatter._();

  static String formatKes(double amount, {int decimals = 2}) {
    return 'KES ${amount.toStringAsFixed(decimals)}';
  }

  static String formatUsd(double amount, {int decimals = 2}) {
    return formatKes(amount, decimals: decimals);
  }
}
