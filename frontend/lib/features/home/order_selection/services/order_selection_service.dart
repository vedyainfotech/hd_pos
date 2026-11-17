import '../models/order_selection_model.dart';

class OrderSelectionService {
  // TEMPORARY FRONTEND DEMO DATA.
  // Replace these lists with API responses when backend integration is done.
  final List<OrderCustomerModel> _customers = [
    OrderCustomerModel(
      id: 1,
      name: 'Abdul Mujahid',
      mobileNumber: '9876543210',
      isActive: true,
      addresses: [
        OrderAddressModel(
          id: 1,
          label: 'Home',
          address: 'MVP Colony, Visakhapatnam',
          isDefault: true,
        ),
        OrderAddressModel(
          id: 2,
          label: 'Office',
          address: 'Dwaraka Nagar, Visakhapatnam',
          isDefault: false,
        ),
      ],
    ),
    OrderCustomerModel(
      id: 2,
      name: 'Rahul Kumar',
      mobileNumber: '9876543211',
      isActive: true,
      addresses: [
        OrderAddressModel(
          id: 3,
          label: 'Home',
          address: 'Seethammadhara, Visakhapatnam',
          isDefault: true,
        ),
        OrderAddressModel(
          id: 4,
          label: 'Other',
          address: 'Madhurawada, Visakhapatnam',
          isDefault: false,
        ),
      ],
    ),
    OrderCustomerModel(
      id: 3,
      name: 'Mohammed Sameer',
      mobileNumber: '9876543212',
      isActive: true,
      addresses: [
        OrderAddressModel(
          id: 5,
          label: 'Home',
          address: 'Gajuwaka, Visakhapatnam',
          isDefault: true,
        ),
      ],
    ),
  ];

  final List<PendingOrderAssignmentModel> _pendingAssignments = [
    PendingOrderAssignmentModel(
      id: 101,
      customerId: 1,
      addressId: 1,
      deliveryDate: DateTime(2026, 11, 7),
      mealCategory: 'Lunch',
      subCategory: 'Tiffins',
      quantity: 3,
    ),
    PendingOrderAssignmentModel(
      id: 102,
      customerId: 2,
      addressId: 3,
      deliveryDate: DateTime(2026, 11, 7),
      mealCategory: 'Breakfast',
      subCategory: 'Tiffins',
      quantity: 1,
    ),
    PendingOrderAssignmentModel(
      id: 103,
      customerId: 3,
      addressId: 5,
      deliveryDate: DateTime(2026, 11, 7),
      mealCategory: 'Lunch',
      subCategory: 'Tiffins',
      quantity: 2,
    ),
  ];

  final Map<String, List<String>> _subCategories = {
    'Breakfast': ['Tiffins', 'Breakfast Combos'],
    'Lunch': ['Tiffins', 'Meals', 'Biryani', 'Lunch Combos'],
    'Dinner': ['Tiffins', 'Meals', 'Dinner Combos'],
  };

  // Sample items representing the owner's scheduled items for demo.
  final List<OrderItemModel> _items = [
    OrderItemModel(
      id: 11,
      name: 'Idli',
      category: 'Breakfast',
      subCategory: 'Tiffins',
      price: 30,
      isActive: true,
    ),
    OrderItemModel(
      id: 12,
      name: 'Dosa',
      category: 'Breakfast',
      subCategory: 'Tiffins',
      price: 40,
      isActive: true,
    ),
    OrderItemModel(
      id: 13,
      name: 'Poori',
      category: 'Breakfast',
      subCategory: 'Tiffins',
      price: 45,
      isActive: true,
    ),
    OrderItemModel(
      id: 21,
      name: 'Chicken Curry',
      category: 'Lunch',
      subCategory: 'Tiffins',
      price: 120,
      isActive: true,
    ),
    OrderItemModel(
      id: 22,
      name: 'Mutton Curry',
      category: 'Lunch',
      subCategory: 'Tiffins',
      price: 180,
      isActive: true,
    ),
    OrderItemModel(
      id: 23,
      name: 'Paneer Curry',
      category: 'Lunch',
      subCategory: 'Tiffins',
      price: 130,
      isActive: true,
    ),
    OrderItemModel(
      id: 24,
      name: 'Mixed Veg Curry',
      category: 'Lunch',
      subCategory: 'Tiffins',
      price: 100,
      isActive: true,
    ),
  ];

  final List<OrderSelectionModel> _savedOrders = [];

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<PendingOrderAssignmentModel> getPendingAssignments(DateTime date) {
    final selectedDate = _dateOnly(date);
    return _pendingAssignments.where((assignment) {
      return _dateOnly(assignment.deliveryDate) == selectedDate &&
          _customers.any(
            (customer) =>
                customer.id == assignment.customerId && customer.isActive,
          );
    }).toList();
  }

  OrderCustomerModel? getCustomer(int customerId) {
    for (final customer in _customers) {
      if (customer.id == customerId && customer.isActive) return customer;
    }
    return null;
  }

  OrderAddressModel? getAddress(
    OrderCustomerModel customer,
    int addressId,
  ) {
    for (final address in customer.addresses) {
      if (address.id == addressId) return address;
    }
    return null;
  }

  List<String> getSubCategories(String mealCategory) =>
      _subCategories[mealCategory] ?? [];

  List<OrderItemModel> getItems(
    String mealCategory,
    String subCategory,
  ) {
    return _items.where((item) {
      return item.isActive &&
          item.category == mealCategory &&
          item.subCategory == subCategory;
    }).toList();
  }

  void saveOrder(OrderSelectionModel order) {
    _savedOrders.add(order);
    _pendingAssignments.removeWhere(
      (assignment) => assignment.id == order.assignmentId,
    );
  }

  List<OrderSelectionModel> getSavedOrders() =>
      List.unmodifiable(_savedOrders);
}
