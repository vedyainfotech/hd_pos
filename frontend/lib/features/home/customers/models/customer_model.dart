class CustomerAddress {
  final String id;

  String contactName;
  String contactNumber;

  String houseName;
  String houseFlatNumber;

  String addressType;

  String country;
  String state;
  String district;
  String area;

  String street;
  String landmark;
  String pincode;
  String locationLink;

  bool monthlyFoodOrder;

  CustomerAddress({
    required this.id,
    required this.contactName,
    required this.contactNumber,
    required this.houseName,
    required this.houseFlatNumber,
    required this.addressType,
    required this.country,
    required this.state,
    required this.district,
    required this.area,
    required this.street,
    required this.landmark,
    required this.pincode,
    required this.locationLink,
    required this.monthlyFoodOrder,
  });
}

class Customer {
  final String id;

  String name;
  List<String> phoneNumbers;
  String email;

  List<CustomerAddress> addresses;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumbers,
    required this.email,
    required this.addresses,
  });
}