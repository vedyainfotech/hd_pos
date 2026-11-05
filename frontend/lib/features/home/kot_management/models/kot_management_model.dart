class KotItem {
  final String name;
  final int quantity;

  const KotItem({required this.name, required this.quantity});
}

class KotManagementModel {
  final int id;
  final String kotNumber;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String foodType;
  final List<KotItem> items;
  final String? deliveryPerson;
  final String? deliveryPersonContact;
  final bool isPrinted;

  const KotManagementModel({
    required this.id,
    required this.kotNumber,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.foodType,
    required this.items,
    this.deliveryPerson,
    this.deliveryPersonContact,
    this.isPrinted = false,
  });

  int get totalQuantity =>
      items.fold<int>(0, (total, item) => total + item.quantity);

  KotManagementModel copyWith({
    String? deliveryPerson,
    String? deliveryPersonContact,
    bool? isPrinted,
    bool clearDeliveryPerson = false,
  }) {
    return KotManagementModel(
      id: id,
      kotNumber: kotNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      foodType: foodType,
      items: items,
      deliveryPerson:
          clearDeliveryPerson ? null : (deliveryPerson ?? this.deliveryPerson),
      deliveryPersonContact: clearDeliveryPerson
          ? null
          : (deliveryPersonContact ?? this.deliveryPersonContact),
      isPrinted: isPrinted ?? this.isPrinted,
    );
  }
}
