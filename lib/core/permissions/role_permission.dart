enum AppModuleKey {
  dashboard('Dashboard'),
  orders('Orders'),
  orderStatus('Order Status Screen'),
  dispatch('Dispatch'),
  customers('Customers'),
  services('Services'),
  payments('Payments'),
  inventory('Inventory'),
  staff('Staff'),
  reports('Reports'),
  settings('Settings');

  const AppModuleKey(this.label);
  final String label;
}
