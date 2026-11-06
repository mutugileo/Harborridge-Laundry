enum ProductionStage {
  toDo('In Queue'),
  cleaning('Cleaning'),
  drying('Drying'),
  fold('Fold');

  const ProductionStage(this.label);
  final String label;
}

enum OrderPriority {
  urgent('Urgent'),
  high('High'),
  standard('Standard');

  const OrderPriority(this.label);
  final String label;
}

enum BoardWorkflowTab {
  newOrder('New Order'),
  clean('Clean'),
  ready('Ready'),
  pickups('Pickups');

  const BoardWorkflowTab(this.label);
  final String label;
}

class ProductionOrderCard {
  const ProductionOrderCard({
    required this.orderNumber,
    required this.customerName,
    required this.itemCountOrWeight,
    required this.serviceType,
    required this.priority,
    required this.stationNumber,
    required this.timeReceived,
    required this.dueTime,
    required this.assignedStaff,
    required this.stage,
    required this.progress,
    required this.statusNote,
    this.isStageComplete = false,
  });

  final String orderNumber;
  final String customerName;
  final String itemCountOrWeight;
  final String serviceType;
  final OrderPriority priority;
  final String stationNumber;
  final String timeReceived;
  final String dueTime;
  final String assignedStaff;
  final ProductionStage stage;
  final double progress;
  final String statusNote;
  final bool isStageComplete;

  ProductionOrderCard copyWith({
    String? orderNumber,
    String? customerName,
    String? itemCountOrWeight,
    String? serviceType,
    OrderPriority? priority,
    String? stationNumber,
    String? timeReceived,
    String? dueTime,
    String? assignedStaff,
    ProductionStage? stage,
    double? progress,
    String? statusNote,
    bool? isStageComplete,
  }) {
    return ProductionOrderCard(
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      itemCountOrWeight: itemCountOrWeight ?? this.itemCountOrWeight,
      serviceType: serviceType ?? this.serviceType,
      priority: priority ?? this.priority,
      stationNumber: stationNumber ?? this.stationNumber,
      timeReceived: timeReceived ?? this.timeReceived,
      dueTime: dueTime ?? this.dueTime,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      statusNote: statusNote ?? this.statusNote,
      isStageComplete: isStageComplete ?? this.isStageComplete,
    );
  }
}
