class InvSubCategoryModel {
  final int id;
  final int categoryId;
  final String name;
  final bool status;

  const InvSubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.status,
  });

  factory InvSubCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvSubCategoryModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      status: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'status': status,
    };
  }

  InvSubCategoryModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    bool? status,
  }) {
    return InvSubCategoryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}