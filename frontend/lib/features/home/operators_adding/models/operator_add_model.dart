class OperatorModel {
  final int id;
  final String name;
  final String phoneNumber;
  final String email;
  final String role;
  final String address;
  final String aadhaarNumber;
  final String panCardNumber;
  final String drivingLicense;
  final String? identityProofFilename;
  final bool isActive;

  const OperatorModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.address,
    required this.aadhaarNumber,
    required this.panCardNumber,
    required this.drivingLicense,
    required this.identityProofFilename,
    required this.isActive,
  });

  OperatorModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? role,
    String? address,
    String? aadhaarNumber,
    String? panCardNumber,
    String? drivingLicense,
    String? identityProofFilename,
    bool? isActive,
  }) {
    return OperatorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panCardNumber: panCardNumber ?? this.panCardNumber,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      identityProofFilename:
          identityProofFilename ?? this.identityProofFilename,
      isActive: isActive ?? this.isActive,
    );
  }

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      address: json['address'] as String? ?? '',
      aadhaarNumber: json['aadhaar_number'] as String? ?? '',
      panCardNumber: json['pan_card_number'] as String? ?? '',
      drivingLicense: json['driving_license'] as String? ?? '',
      identityProofFilename:
          json['identity_proof_filename'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'role': role,
      'address': address,
      'aadhaar_number': aadhaarNumber,
      'pan_card_number': panCardNumber,
      'driving_license': drivingLicense,
      'identity_proof_filename': identityProofFilename,
      'is_active': isActive,
    };
  }
}