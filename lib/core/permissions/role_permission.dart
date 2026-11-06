enum AppModuleKey {
  dashboard('Dashboard'),
  orders('Orders'),
  orderStatus('Order Status Screen'),
  dispatch('Dispatch'),
  customers('Customers'),
  vendors('Vendors'),
  services('Services'),
  payments('Payments'),
  settlements('Settlements'),
  inventory('Inventory'),
  staff('Staff'),
  reports('Reports'),
  settings('Settings');

  const AppModuleKey(this.label);
  final String label;
}
