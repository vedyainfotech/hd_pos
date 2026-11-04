class InventoryItemModel {
  final int id;
  final String name;
  final String? itemCode;
  final int categoryId;
  final int? subCategoryId;
  final int unitId;
  final double minimumStockLevel;
  final double tax;
  final String hsnCode;
  final double openingStock;
  final bool isActive;
  final bool isProduced;

  InventoryItemModel({
    required this.id,
    required this.name,
    this.itemCode,
    required this.categoryId,
    this.subCategoryId,
    required this.unitId,
    required this.minimumStockLevel,
    required this.tax,
    required this.hsnCode,
    required this.openingStock,
    required this.isActive,
    required this.isProduced,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      itemCode: json['item_code'] as String?,
      categoryId: json['category_id'] as int,
      subCategoryId: json['sub_category_id'] as int?,
      unitId: json['unit_id'] as int,
      minimumStockLevel:
          (json['minimum_stock_level'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      hsnCode: json['hsn_code'] as String,
      openingStock:
          (json['opening_stock'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      isProduced: json['is_produced'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'item_code': itemCode,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'unit_id': unitId,
      'minimum_stock_level': minimumStockLevel,
      'tax': tax,
      'hsn_code': hsnCode,
      'opening_stock': openingStock,
      'is_active': isActive,
      'is_produced': isProduced,
    };
  }
}