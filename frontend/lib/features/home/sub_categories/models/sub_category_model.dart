class SubCategoryModel {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final bool isActive;

  const SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.isActive,
  });

  factory SubCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubCategoryModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,

      // Backend NUMERIC/Decimal may arrive as a JSON string.
      price: double.parse(json['price'].toString()),

      isActive: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'status': isActive,
    };
  }

  SubCategoryModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? price,
    bool? isActive,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
    );
  }
}