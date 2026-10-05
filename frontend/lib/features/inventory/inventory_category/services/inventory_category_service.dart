import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/inventory_category_model.dart';

class InventoryCategoryApiService {
  static const String baseUrl = 'http://192.168.0.4:8000';
  static const String endpoint = '/api/inventory-categories/';

  // ============================================================
  // GET ALL INVENTORY CATEGORIES
  // ============================================================

  Future<List<InventoryCategoryModel>> getCategories({
    bool includeInactive = true,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl$endpoint?include_inactive=$includeInactive',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data.map((json) {
        return InventoryCategoryModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      }).toList();
    }

    throw Exception(
      'Failed to load inventory categories: '
      '${response.statusCode}',
    );
  }

  // ============================================================
  // CREATE INVENTORY CATEGORY
  // ============================================================

  Future<InventoryCategoryModel> createCategory({
    required String name,
    required bool status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      return InventoryCategoryModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      'Failed to create inventory category: '
      '${response.body}',
    );
  }

  // ============================================================
  // UPDATE INVENTORY CATEGORY
  // ============================================================

  Future<InventoryCategoryModel> updateCategory({
    required int id,
    required String name,
    required bool status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return InventoryCategoryModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      'Failed to update inventory category: '
      '${response.body}',
    );
  }

  // ============================================================
  // UPDATE INVENTORY CATEGORY STATUS
  // ============================================================

  Future<void> updateCategoryStatus(
    int id,
    bool status,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint$id/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update inventory category status: '
        '${response.body}',
      );
    }
  }
}