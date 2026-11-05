
class BusinessProfileModel {
  final int? id;
  final String restaurantName;
  final String businessType;
  final String email;
  final String phoneNumber;
  final String telephoneNumber;
  final String ownerFullName;
  final String address;
  final String country;
  final String state;
  final String city;
  final String pinCode;
  final bool hasBranches;
  final int? selectedBranchId;
  final String openingTime;
  final String closingTime;
  final String fssaiNumber;
  final String fssaiExpiryDate;
  final bool gstRegistered;
  final String gstin;
  final String panNumber;
  final String aadhaarNumber;
  final String? logoFileName;
  final String? fssaiDocumentName;
  final String? gstDocumentName;
  final String? panDocumentName;
  final String? aadhaarDocumentName;

  const BusinessProfileModel({
    this.id,
    required this.restaurantName,
    required this.businessType,
    required this.email,
    required this.phoneNumber,
    required this.telephoneNumber,
    required this.ownerFullName,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.hasBranches,
    this.selectedBranchId,
    required this.openingTime,
    required this.closingTime,
    required this.fssaiNumber,
    required this.fssaiExpiryDate,
    required this.gstRegistered,
    required this.gstin,
    required this.panNumber,
    required this.aadhaarNumber,
    this.logoFileName,
    this.fssaiDocumentName,
    this.gstDocumentName,
    this.panDocumentName,
    this.aadhaarDocumentName,
  });

  static String _string(dynamic value, [String fallback = '']) {
    return value == null ? fallback : value.toString();
  }

  static int? _int(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      id: _int(json['id']),
      restaurantName: _string(json['restaurant_name']),
      businessType: _string(json['business_type']),
      email: _string(json['email']),
      phoneNumber: _string(json['phone_number']),
      telephoneNumber: _string(json['telephone_number']),
      ownerFullName: _string(json['owner_full_name']),
      address: _string(json['address']),
      country: _string(json['country'], 'India'),
      state: _string(json['state']),
      city: _string(json['city']),
      pinCode: _string(json['pin_code']),
      hasBranches: _bool(json['has_branches']),
      selectedBranchId: _int(json['selected_branch_id']),
      openingTime: _string(json['opening_time']),
      closingTime: _string(json['closing_time']),
      fssaiNumber: _string(json['fssai_number']),
      fssaiExpiryDate: _string(json['fssai_expiry_date']),
      gstRegistered: _bool(json['gst_registered']),
      gstin: _string(json['gstin']),
      panNumber: _string(json['pan_number']),
      aadhaarNumber: _string(json['aadhaar_number']),
      logoFileName: json['logo_file_name']?.toString(),
      fssaiDocumentName: json['fssai_document_name']?.toString(),
      gstDocumentName: json['gst_document_name']?.toString(),
      panDocumentName: json['pan_document_name']?.toString(),
      aadhaarDocumentName: json['aadhaar_document_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'restaurant_name': restaurantName.trim(),
      'business_type': businessType.trim(),
      'email': email.trim(),
      'phone_number': phoneNumber.trim(),
      'telephone_number': telephoneNumber.trim(),
      'owner_full_name': ownerFullName.trim(),
      'address': address.trim(),
      'country': country.trim(),
      'state': state.trim(),
      'city': city.trim(),
      'pin_code': pinCode.trim(),
      'has_branches': hasBranches,
      'selected_branch_id': hasBranches ? selectedBranchId : null,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'fssai_number': fssaiNumber.trim(),
      'fssai_expiry_date': fssaiExpiryDate,
      'gst_registered': gstRegistered,
      'gstin': gstRegistered ? gstin.trim().toUpperCase() : '',
      'pan_number': panNumber.trim().toUpperCase(),
      'aadhaar_number': aadhaarNumber.trim(),
      'logo_file_name': logoFileName,
      'fssai_document_name': fssaiDocumentName,
      'gst_document_name': gstDocumentName,
      'pan_document_name': panDocumentName,
      'aadhaar_document_name': aadhaarDocumentName,
    };
  }
}

class BusinessBranchModel {
  final int id;
  final String name;
  final String? address;

  const BusinessBranchModel({
    required this.id,
    required this.name,
    this.address,
  });

  factory BusinessBranchModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    if (parsedId == null) {
      throw const FormatException(
        'Branch response is missing a valid integer id.',
      );
    }

    final branchName =
        (json['name'] ?? json['branch_name'] ?? '').toString().trim();

    if (branchName.isEmpty) {
      throw const FormatException(
        'Branch response is missing its name.',
      );
    }

    return BusinessBranchModel(
      id: parsedId,
      name: branchName,
      address: json['address']?.toString(),
    );
  }
}
