class OrderAddressModel {
  final int id;
  final String label;
  final String address;
  final bool isDefault;

  OrderAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.isDefault,
  });

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderAddressModel(
      id: json['id'] as int,
      label: json['label'] as String,
      address: json['address'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'is_default': isDefault,
      };
}

class OrderCustomerModel {
  final int id;
  final String name;
  final String mobileNumber;
  final List<OrderAddressModel> addresses;
  final bool isActive;

  OrderCustomerModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.addresses,
    required this.isActive,
  });

  factory OrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      mobileNumber: json['mobile_number'] as String,
      addresses: (json['addresses'] as List<dynamic>? ?? [])
          .map((address) => OrderAddressModel.fromJson(
                address as Map<String, dynamic>,
              ))
          .toList(),
      isActive: json['status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile_number': mobileNumber,
        'addresses': addresses.map((address) => address.toJson()).toList(),
        'status': isActive,
      };
}

/// One pending subscription assignment for one customer, date and meal.
class PendingOrderAssignmentModel {
  final int id;
  final int customerId;
  final int addressId;
  final DateTime deliveryDate;
  final String mealCategory;
  final String subCategory;
  final int quantity;

  const PendingOrderAssignmentModel({
    required this.id,
    required this.customerId,
    required this.addressId,
    required this.deliveryDate,
    required this.mealCategory,
    required this.subCategory,
    required this.quantity,
  });
}

class OrderItemModel {
  final int id;
  final String name;
  final String category;
  final String subCategory;
  final double price;
  final bool isActive;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.isActive,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'sub_category': subCategory,
        'price': price,
        'status': isActive,
      };
}

class OrderSelectionModel {
  final int assignmentId;
  final int customerId;
  final String customerName;
  final String mobileNumber;
  final String address;
  final String deliveryDate;
  final String mealCategory;
  final String subCategory;
  final List<OrderItemQuantityModel> items;

  OrderSelectionModel({
    required this.assignmentId,
    required this.customerId,
    required this.customerName,
    required this.mobileNumber,
    required this.address,
    required this.deliveryDate,
    required this.mealCategory,
    required this.subCategory,
    required this.items,
  });
}

class OrderItemQuantityModel {
  final int itemId;
  final String itemName;
  final int quantity;

  OrderItemQuantityModel({
    required this.itemId,
    required this.itemName,
    required this.quantity,
  });
}
