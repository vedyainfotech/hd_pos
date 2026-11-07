
class DashboardCustomer {
  final String id;
  final String name;
  final String phone;
  final String address;

  const DashboardCustomer({
    this.id = '',
    required this.name,
    required this.phone,
    required this.address,
  });

  DashboardCustomer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
  }) {
    return DashboardCustomer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

class DashboardOrderLine {
  final String id;
  final String itemName;
  final double price;
  final int quantity;
  final String meal;

  const DashboardOrderLine({
    required this.id,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.meal,
  });

  double get amount => price * quantity;

  DashboardOrderLine copyWith({
    String? id,
    String? itemName,
    double? price,
    int? quantity,
    String? meal,
  }) {
    return DashboardOrderLine(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      meal: meal ?? this.meal,
    );
  }
}

class DashboardMealSummary {
  final String meal;
  final Map<String, int> itemQuantities;
  final int specialPacking;
  final int totalCustomers;

  const DashboardMealSummary({
    required this.meal,
    this.itemQuantities = const {},
    this.specialPacking = 0,
    this.totalCustomers = 0,
  });

  int get totalItems =>
      itemQuantities.values.fold(0, (sum, quantity) => sum + quantity);
}

class DashboardMenuEntry {
  final DateTime date;
  final String meal;
  final String itemName;
  final double price;

  const DashboardMenuEntry({
    required this.date,
    required this.meal,
    required this.itemName,
    this.price = 0,
  });
}

class DashboardOrderDraft {
  final DashboardCustomer customer;
  final DateTime fromDate;
  final DateTime toDate;
  final String meal;
  final List<DashboardOrderLine> lines;
  final String remarks;

  const DashboardOrderDraft({
    required this.customer,
    required this.fromDate,
    required this.toDate,
    required this.meal,
    required this.lines,
    this.remarks = '',
  });

  double get foodAmount =>
      lines.fold(0, (total, line) => total + line.amount);

  double get estimatedAmount => foodAmount;
}
