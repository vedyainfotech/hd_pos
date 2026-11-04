
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/items_model.dart';

class ItemSubCategoryRequest {
  final int subCategoryId;
  final double price;
  final bool sameAsSubCategory;
  final bool status;

  const ItemSubCategoryRequest({
    required this.subCategoryId,
    required this.price,
    this.sameAsSubCategory = false,
    this.status = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'sub_category_id': subCategoryId,
      'price': price,
      'same_as_sub_category': sameAsSubCategory,
      'status': status,
    };
  }
}

class ItemApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/api/items/';

  Future<List<ItemModel>> getItems({
    bool includeInactive = true,
    int? categoryId,
    int? subCategoryId,
    String? search,
  }) async {
    final queryParameters = <String, String>{
      'include_inactive': includeInactive.toString(),
    };

    if (categoryId != null) {
      queryParameters['category_id'] = categoryId.toString();
    }

    if (subCategoryId != null) {
      queryParameters['sub_category_id'] = subCategoryId.toString();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (json) => ItemModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load items (${response.statusCode}): ${response.body}',
    );
  }

  Future<ItemModel> getItem(int id) async {
    final uri = Uri.parse('$baseUrl$endpoint$id');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ItemModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to load item (${response.statusCode}): ${response.body}',
    );
  }

  Future<ItemModel> createItem({
    required int categoryId,
    required String itemName,
    required List<ItemSubCategoryRequest> subCategories,
    bool status = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final body = {
      'category_id': categoryId,
      'item_name': itemName.trim(),
      'sub_categories': subCategories
          .map((subCategory) => subCategory.toJson())
          .toList(),
      'status': status,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ItemModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to create item (${response.statusCode}): ${response.body}',
    );
  }

  Future<ItemModel> updateItem({
    required int id,
    required int categoryId,
    required String itemName,
    required List<ItemSubCategoryRequest> subCategories,
    required bool status,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint$id');

    final body = {
      'category_id': categoryId,
      'item_name': itemName.trim(),
      'sub_categories': subCategories
          .map((subCategory) => subCategory.toJson())
          .toList(),
      'status': status,
    };

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return ItemModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update item (${response.statusCode}): ${response.body}',
    );
  }

  Future<ItemModel> updateItemStatus(
    int id,
    bool isActive,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint$id/status');

    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': isActive}),
    );

    if (response.statusCode == 200) {
      return ItemModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update item status '
      '(${response.statusCode}): ${response.body}',
    );
  }
}
