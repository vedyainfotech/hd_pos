class ItemModel {
  final int id;
  final int categoryId;
  final int subCategoryId;
  final String name;
  final double price;
  final bool sameAsCategory;
  final bool isActive;

  const ItemModel({
    required this.id,
    required this.categoryId,
    required this.subCategoryId,
    required this.name,
    required this.price,
    required this.sameAsCategory,
    required this.isActive,
  });

  factory ItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ItemModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      subCategoryId: json['sub_category_id'] as int,
      name: json['name'] as String,
      price: double.parse(
        json['price'].toString(),
      ),
      sameAsCategory:
          json['same_as_category'] as bool,
      isActive: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'name': name,
      'price': price,
      'same_as_category': sameAsCategory,
      'status': isActive,
    };
  }

  ItemModel copyWith({
    int? id,
    int? categoryId,
    int? subCategoryId,
    String? name,
    double? price,
    bool? sameAsCategory,
    bool? isActive,
  }) {
    return ItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId:
          subCategoryId ?? this.subCategoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      sameAsCategory:
          sameAsCategory ?? this.sameAsCategory,
      isActive: isActive ?? this.isActive,
    );
  }
}