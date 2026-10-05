class InventoryCategoryModel {
  final int id;
  final String name;
  final bool status;

  const InventoryCategoryModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory InventoryCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventoryCategoryModel(
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

  InventoryCategoryModel copyWith({
    int? id,
    String? name,
    bool? status,
  }) {
    return InventoryCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}