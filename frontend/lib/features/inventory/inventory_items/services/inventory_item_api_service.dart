
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/inventory_item_model.dart';

class InventoryItemApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _endpoint = '/api/inventory/items';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<InventoryItemModel>> getItems({
    bool includeInactive = true,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$_endpoint?include_inactive=$includeInactive',
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load inventory items: '
        '${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected inventory items response.');
    }

    return decoded
        .map(
          (json) => InventoryItemModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<InventoryItemModel> createItem({
    required String name,
    String? itemCode,
    required int categoryId,
    int? subCategoryId,
    required int unitId,
    required double minimumStockLevel,
    required double tax,
    required String hsnCode,
    required double openingStock,
    required bool isActive,
    required bool isProduced,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_endpoint'),
      headers: _headers,
      body: jsonEncode({
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
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to create inventory item: '
        '${response.statusCode} ${response.body}',
      );
    }

    return InventoryItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<InventoryItemModel> updateItem({
    required int id,
    required String name,
    String? itemCode,
    required int categoryId,
    int? subCategoryId,
    required int unitId,
    required double minimumStockLevel,
    required double tax,
    required String hsnCode,
    required double openingStock,
    required bool isActive,
    required bool isProduced,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$_endpoint/$id'),
      headers: _headers,
      body: jsonEncode({
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
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update inventory item: '
        '${response.statusCode} ${response.body}',
      );
    }

    return InventoryItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<InventoryItemModel> updateItemStatus({
    required int id,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl$_endpoint/$id/status'),
      headers: _headers,
      body: jsonEncode({'is_active': isActive}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update inventory item status: '
        '${response.statusCode} ${response.body}',
      );
    }

    return InventoryItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
