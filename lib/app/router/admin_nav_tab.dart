enum AdminNavTab {
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

  const AdminNavTab(this.title);
  final String title;
}
