import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sub_category_model.dart';

class SubCategoryService {
  static const String baseUrl =
      'http://127.0.0.1:8000';

  static const String endpoint =
      '/api/sub-categories/';

  Future<List<SubCategoryModel>> getSubCategories({
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
                SubCategoryModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load sub categories: ${response.body}',
    );
  }

  Future<SubCategoryModel>
      createSubCategory({
    required int categoryId,
    required String name,
    required double price,
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
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      return SubCategoryModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to create sub category: ${response.body}',
    );
  }

  Future<SubCategoryModel>
      updateSubCategory(
    SubCategoryModel subCategory,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl$endpoint${subCategory.id}',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'category_id':
            subCategory.categoryId,
        'name':
            subCategory.name.trim(),
        'price':
            subCategory.price,
        'status':
            subCategory.isActive,
      }),
    );

    if (response.statusCode == 200) {
      return SubCategoryModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update sub category: ${response.body}',
    );
  }

  Future<SubCategoryModel>
      updateSubCategoryStatus(
    int id,
    bool isActive,
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
        'status': isActive,
      }),
    );

    if (response.statusCode == 200) {
      return SubCategoryModel.fromJson(
        jsonDecode(response.body)
            as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update sub category status: ${response.body}',
    );
  }
}