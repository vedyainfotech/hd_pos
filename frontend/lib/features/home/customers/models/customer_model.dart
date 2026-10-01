class CustomerAddress {
  final String id;

  String contactName;
  String contactNumber;
  String houseFlatNumber;
  String street;
  String area;
  String landmark;
  String pincode;
  String locationLink;
  bool monthlyFoodOrder;
  bool status;

  CustomerAddress({
    required this.id,
    required this.contactName,
    required this.contactNumber,
    required this.houseFlatNumber,
    required this.street,
    required this.area,
    required this.landmark,
    required this.pincode,
    required this.locationLink,
    required this.monthlyFoodOrder,
    this.status = 'True' == 'True',
  });
}

class Customer {
  final String id;

  String name;
  List<String> phoneNumbers;
  String email;
  String? foodType;
  String instruction;

  List<CustomerAddress> addresses;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumbers,
    required this.email,
    required this.foodType,
    required this.instruction,
    required this.addresses,
  });
}
