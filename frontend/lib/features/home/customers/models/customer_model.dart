class CustomerAddress {
  final String id;
  final String addressCode;

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
    this.addressCode = '',
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

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: (json['id'] ?? '').toString(),
      addressCode: (json['address_code'] ?? '').toString(),
      contactName: (json['contact_name'] ?? '').toString(),
      contactNumber: (json['contact_number'] ?? '').toString(),
      houseName: (json['house_name'] ?? '').toString(),
      houseFlatNumber: (json['house_flat_number'] ?? '').toString(),
      addressType: (json['address_type'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      street: (json['street'] ?? '').toString(),
      landmark: (json['landmark'] ?? '').toString(),
      pincode: (json['pincode'] ?? '').toString(),
      locationLink: (json['location_link'] ?? '').toString(),
      monthlyFoodOrder: json['monthly_food_order'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_code': addressCode.isNotEmpty
          ? addressCode
          : 'ADDR-$id',
      'contact_name': contactName,
      'contact_number': contactNumber,
      'house_name': houseName.isEmpty ? null : houseName,
      'house_flat_number':
          houseFlatNumber.isEmpty ? null : houseFlatNumber,
      'address_type': addressType,
      'country': country,
      'state': state,
      'district': district,
      'area': area,
      'street': street.isEmpty ? null : street,
      'landmark': landmark.isEmpty ? null : landmark,
      'pincode': pincode,
      'location_link':
          locationLink.isEmpty ? null : locationLink,
      'monthly_food_order': monthlyFoodOrder,
    };
  }
}

class Customer {
  final String id;
  final String customerCode;

  String name;
  List<String> phoneNumbers;
  String email;

  List<CustomerAddress> addresses;

  Customer({
    required this.id,
    this.customerCode = '',
    required this.name,
    required this.phoneNumbers,
    required this.email,
    required this.addresses,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    final phones = json['phone_numbers'] as List? ?? [];
    final addressList = json['addresses'] as List? ?? [];

    return Customer(
      id: (json['id'] ?? '').toString(),
      customerCode: (json['customer_code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phoneNumbers: phones.map((phone) => phone.toString()).toList(),
      email: (json['email'] ?? '').toString(),
      addresses: addressList
          .whereType<Map<String, dynamic>>()
          .map(CustomerAddress.fromJson)
          .toList(),
    );
  }

  // Request body for creating or updating a customer.
  // The database generates the customer ID.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_numbers': phoneNumbers,
      'email': email.isEmpty ? null : email,
      'addresses': addresses.map((address) => address.toJson()).toList(),
    };
  }
}