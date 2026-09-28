class PaymentModel {
  final int id;
  final String name;
  final bool isActive;

  PaymentModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
    };
  }

  PaymentModel copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}