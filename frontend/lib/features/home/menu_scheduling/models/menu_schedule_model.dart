class AvailableMenuResponse {
  final int categoryId;
  final String categoryName;
  final List<AvailableSubCategory> subCategories;

  AvailableMenuResponse({
    required this.categoryId,
    required this.categoryName,
    required this.subCategories,
  });

  factory AvailableMenuResponse.fromJson(Map<String, dynamic> json) {
    return AvailableMenuResponse(
      categoryId: (json['category_id'] as num).toInt(),
      categoryName: json['category_name']?.toString() ?? '',
      subCategories: (json['sub_categories'] as List? ?? [])
          .map((e) => AvailableSubCategory.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class AvailableSubCategory {
  final int id;
  final String name;
  final List<AvailableMenuItem> items;

  AvailableSubCategory({required this.id, required this.name, required this.items});

  factory AvailableSubCategory.fromJson(Map<String, dynamic> json) {
    return AvailableSubCategory(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => AvailableMenuItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class AvailableMenuItem {
  final int id;
  final String name;
  final double price;
  final int? categoryId;
  final int? subCategoryId;
  final String? subCategoryName;

  AvailableMenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.categoryId,
    this.subCategoryId,
    this.subCategoryName,
  });

  factory AvailableMenuItem.fromJson(Map<String, dynamic> json) {
    return AvailableMenuItem(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? double.tryParse('${json['price']}') ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt(),
      subCategoryId: (json['sub_category_id'] as num?)?.toInt(),
      subCategoryName: json['sub_category_name']?.toString(),
    );
  }
}

class MenuScheduleDateResponse {
  final DateTime deliveryDate;
  final List<MenuSchedule> schedules;

  MenuScheduleDateResponse({required this.deliveryDate, required this.schedules});

  factory MenuScheduleDateResponse.fromJson(Map<String, dynamic> json) {
    return MenuScheduleDateResponse(
      deliveryDate: DateTime.parse(json['delivery_date'].toString()),
      schedules: (json['schedules'] as List? ?? [])
          .map((e) => MenuSchedule.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class MenuSchedule {
  final int id;
  final DateTime deliveryDate;
  final int categoryId;
  final String categoryName;
  final List<ScheduledMenuItem> items;

  MenuSchedule({
    required this.id,
    required this.deliveryDate,
    required this.categoryId,
    required this.categoryName,
    required this.items,
  });

  factory MenuSchedule.fromJson(Map<String, dynamic> json) {
    return MenuSchedule(
      id: (json['id'] as num).toInt(),
      deliveryDate: DateTime.parse(json['delivery_date'].toString()),
      categoryId: (json['category_id'] as num).toInt(),
      categoryName: json['category_name']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => ScheduledMenuItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class ScheduledMenuItem {
  final int id;
  final int itemId;
  final String itemName;
  final double price;
  final int? subCategoryId;
  final String? subCategoryName;

  ScheduledMenuItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.price,
    this.subCategoryId,
    this.subCategoryName,
  });

  factory ScheduledMenuItem.fromJson(Map<String, dynamic> json) {
    return ScheduledMenuItem(
      id: (json['id'] as num).toInt(),
      itemId: (json['item_id'] as num).toInt(),
      itemName: json['item_name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? double.tryParse('${json['price']}') ?? 0,
      subCategoryId: (json['sub_category_id'] as num?)?.toInt(),
      subCategoryName: json['sub_category_name']?.toString(),
    );
  }
}

class MenuScheduleSaveRequest {
  final DateTime deliveryDate;
  final int categoryId;
  final List<int> itemIds;

  MenuScheduleSaveRequest({
    required this.deliveryDate,
    required this.categoryId,
    required this.itemIds,
  });

  Map<String, dynamic> toJson() => {
        'delivery_date': '${deliveryDate.year.toString().padLeft(4, '0')}-'
            '${deliveryDate.month.toString().padLeft(2, '0')}-'
            '${deliveryDate.day.toString().padLeft(2, '0')}',
        'category_id': categoryId,
        'item_ids': itemIds,
      };
}
