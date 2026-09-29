import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/items_model.dart';

class ItemApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000';

  static const String endpoint =
      '/api/items/';

  Future<List<ItemModel>> getItems({
    bool includeInactive = true,
    int? categoryId,
    int? subCategoryId,
    String? search,
  }) async {
    final queryParameters = <String, String>{
      'include_inactive':
          includeInactive.toString(),
    };

    if (categoryId != null) {
      queryParameters['category_id'] =
          categoryId.toString();
    }

    if (subCategoryId != null) {
      queryParameters['sub_category_id'] =
          subCategoryId.toString();
    }

    if (search != null &&
        search.trim().isNotEmpty) {
      queryParameters['search'] =
          search.trim();
    }

    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(uri);

    print(
      'GET items: ${response.statusCode}',
    );
    print(
      'GET items response: ${response.body}',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data
          .map(
            (json) => ItemModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load items: ${response.body}',
    );
  }

  Future<ItemModel> createItem({
    required int categoryId,
    required int subCategoryId,
    required String name,
    required double price,
    required bool sameAsCategory,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'name': name.trim(),
        'price': price,
        'same_as_category':
            sameAsCategory,
      }),
    );

    print(
      'CREATE item: ${response.statusCode}',
    );
    print(
      'CREATE item response: ${response.body}',
    );

    if (response.statusCode == 201) {
      return ItemModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to create item: ${response.body}',
    );
  }

  Future<ItemModel> updateItem({
    required int id,
    required int categoryId,
    required int subCategoryId,
    required String name,
    required double price,
    required bool sameAsCategory,
    required bool status,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl$endpoint$id',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'name': name.trim(),
        'price': price,
        'same_as_category':
            sameAsCategory,
        'status': status,
      }),
    );

    print(
      'UPDATE item: ${response.statusCode}',
    );
    print(
      'UPDATE item response: ${response.body}',
    );

    if (response.statusCode == 200) {
      return ItemModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update item: ${response.body}',
    );
  }

  Future<ItemModel> updateItemStatus(
    int id,
    bool isActive,
  ) async {
    final response = await http.patch(
      Uri.parse(
        '$baseUrl$endpoint$id/status',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': isActive,
      }),
    );

    print(
      'UPDATE item status: ${response.statusCode}',
    );
    print(
      'UPDATE item status response: ${response.body}',
    );

    if (response.statusCode == 200) {
      return ItemModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update item status: ${response.body}',
    );
  }
}