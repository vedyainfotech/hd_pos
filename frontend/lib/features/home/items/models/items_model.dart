
class ItemSubCategoryModel {
  final int id;
  final int subCategoryId;
  final double price;
  final bool status;
  final bool sameAsSubCategory;

  const ItemSubCategoryModel({
    required this.id,
    required this.subCategoryId,
    required this.price,
    required this.status,
    required this.sameAsSubCategory,
  });

  factory ItemSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemSubCategoryModel(
      id: json['id'] as int,
      subCategoryId: json['sub_category_id'] as int,
      price: double.parse(json['price'].toString()),
      status: json['status'] as bool,
      sameAsSubCategory: json['same_as_sub_category'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sub_category_id': subCategoryId,
        'price': price,
        'status': status,
        'same_as_sub_category': sameAsSubCategory,
      };

  ItemSubCategoryModel copyWith({
    int? id,
    int? subCategoryId,
    double? price,
    bool? status,
    bool? sameAsSubCategory,
  }) {
    return ItemSubCategoryModel(
      id: id ?? this.id,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      price: price ?? this.price,
      status: status ?? this.status,
      sameAsSubCategory:
          sameAsSubCategory ?? this.sameAsSubCategory,
    );
  }
}

class ItemModel {
  final int id;
  final int categoryId;
  final String itemName;
  final bool status;
  final List<ItemSubCategoryModel> subCategories;

  const ItemModel({
    required this.id,
    required this.categoryId,
    required this.itemName,
    required this.status,
    required this.subCategories,
  });

  bool get isActive => status;

  String get name => itemName;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final mappings = json['sub_categories'] as List<dynamic>? ?? [];

    return ItemModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      itemName: json['item_name'] as String,
      status: json['status'] as bool,
      subCategories: mappings
          .map(
            (entry) => ItemSubCategoryModel.fromJson(
              entry as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'item_name': itemName,
        'status': status,
        'sub_categories':
            subCategories.map((entry) => entry.toJson()).toList(),
      };

  ItemModel copyWith({
    int? id,
    int? categoryId,
    String? itemName,
    bool? status,
    List<ItemSubCategoryModel>? subCategories,
  }) {
    return ItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      itemName: itemName ?? this.itemName,
      status: status ?? this.status,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}
