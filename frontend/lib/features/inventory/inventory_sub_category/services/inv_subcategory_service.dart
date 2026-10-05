import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/inv_subcategory_model.dart';

class InvSubCategoryApiService {
  static const String baseUrl =
      'http://192.168.0.4:8000';

  static const String endpoint =
      '/api/inventory-subcategories/';

  Future<List<InvSubCategoryModel>> getSubCategories({
    bool includeInactive = true,
    int? categoryId,
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

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data
          .map(
            (json) =>
                InvSubCategoryModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load inventory sub categories: '
      '${response.body}',
    );
  }

  Future<InvSubCategoryModel>
      createSubCategory({
    required int categoryId,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'name': name.trim(),
        'status': true,
      }),
    );

    if (response.statusCode == 201) {
      return InvSubCategoryModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to create inventory sub category: '
      '${response.body}',
    );
  }

  Future<InvSubCategoryModel>
      updateSubCategory({
    required int id,
    required int categoryId,
    required String name,
    required bool status,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl$endpoint$id',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'name': name.trim(),
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return InvSubCategoryModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update inventory sub category: '
      '${response.body}',
    );
  }

  Future<InvSubCategoryModel>
      updateSubCategoryStatus(
    int id,
    bool status,
  ) async {
    final response = await http.patch(
      Uri.parse(
        '$baseUrl$endpoint$id/status',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return InvSubCategoryModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update inventory sub category status: '
      '${response.body}',
    );
  }
}