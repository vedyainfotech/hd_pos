class PaymentModel {
  final int id;
  final String name;
  final bool status;

  PaymentModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }

  PaymentModel copyWith({
    int? id,
    String? name,
    bool? status,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}