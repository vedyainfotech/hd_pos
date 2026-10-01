class DeliveryPersonModel {
  final int id;
  final String name;
  final String contactNumber;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? aadhaarNumber;
  final String? panCardNumber;
  final String? drivingLicense;
  final bool isActive;

  const DeliveryPersonModel({
    required this.id,
    required this.name,
    required this.contactNumber,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.aadhaarNumber,
    this.panCardNumber,
    this.drivingLicense,
    required this.isActive,
  });

  factory DeliveryPersonModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeliveryPersonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      contactNumber: json['contact_number'] as String,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      aadhaarNumber: json['aadhaar_number'] as String?,
      panCardNumber: json['pan_card_number'] as String?,
      drivingLicense: json['driving_license'] as String?,
      isActive: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_number': contactNumber,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'aadhaar_number': aadhaarNumber,
      'pan_card_number': panCardNumber,
      'driving_license': drivingLicense,
      'status': isActive,
    };
  }

  DeliveryPersonModel copyWith({
    int? id,
    String? name,
    String? contactNumber,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? aadhaarNumber,
    String? panCardNumber,
    String? drivingLicense,
    bool? isActive,
  }) {
    return DeliveryPersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panCardNumber: panCardNumber ?? this.panCardNumber,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      isActive: isActive ?? this.isActive,
    );
  }
}
