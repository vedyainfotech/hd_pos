import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class CategoryApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/api/categories';

  Future<List<CategoryModel>> getCategories({
    bool includeInactive = true,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl$endpoint?include_inactive=$includeInactive',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (json) => CategoryModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load categories: ${response.statusCode}',
    );
  }

  Future<CategoryModel> createCategory(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      return CategoryModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create category: ${response.body}',
    );
  }

  Future<CategoryModel> updateCategory(
    int id,
    String name,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return CategoryModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update category: ${response.body}',
    );
  }

  Future<void> updateCategoryStatus(
    int id,
    bool isActive,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint/$id/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'is_active': isActive,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update category status: ${response.body}',
      );
    }
  }
}