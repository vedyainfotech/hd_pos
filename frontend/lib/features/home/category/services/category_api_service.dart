import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class CategoryApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/api/categories/';

  // Normalize backend error messages so duplicate errors are shown clearly.
  String _errorMessage(http.Response response, String fallback) {
    String detail = response.body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        detail = (decoded['detail'] ?? decoded['message'] ?? response.body).toString();
      }
    } catch (_) {
      // Keep the original response body if it is not JSON.
    }

    final normalized = detail.toLowerCase();
    if (response.statusCode == 409 ||
        normalized.contains('already exists') ||
        normalized.contains('duplicate') ||
        normalized.contains('unique constraint')) {
      return 'Category already exists';
    }
    return '$fallback: $detail';
  }

  // Converts 12-hour AM/PM time to backend 24-hour time.
  static String _toBackendTime(String time) {
    final parts = time.trim().split(' ');
    if (parts.length != 2) return time;
    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return time;

    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    final period = parts[1].toUpperCase();
    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else if (period == 'PM' && hour != 12) {
      hour += 12;
    }
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }

  // Converts backend 24-hour time to 12-hour AM/PM time.
  static String _fromBackendTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    final String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // GET ALL CATEGORIES
  Future<List<CategoryModel>> getCategories({bool includeInactive = true}) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint?include_inactive=$includeInactive'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) {
        final Map<String, dynamic> category = Map<String, dynamic>.from(json as Map);
        if (category['allotment_time'] != null) {
          category['allotment_time'] = _fromBackendTime(category['allotment_time'].toString());
        }
        return CategoryModel.fromJson(category);
      }).toList();
    }
    throw Exception(_errorMessage(response, 'Failed to load categories'));
  }

  // CREATE CATEGORY
  Future<CategoryModel> createCategory({required String name, required String allotmentTime, required bool status}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim().replaceAll(RegExp(r'\s+'), ' '),
        'allotment_time': _toBackendTime(allotmentTime),
        'status': status,
      }),
    );
    if (response.statusCode == 201) {
      final Map<String, dynamic> category = Map<String, dynamic>.from(jsonDecode(response.body));
      if (category['allotment_time'] != null) {
        category['allotment_time'] = _fromBackendTime(category['allotment_time'].toString());
      }
      return CategoryModel.fromJson(category);
    }
    throw Exception(_errorMessage(response, 'Failed to add category'));
  }

  // UPDATE CATEGORY
  Future<CategoryModel> updateCategory({required int id, required String name, required String allotmentTime, required bool status}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim().replaceAll(RegExp(r'\s+'), ' '),
        'allotment_time': _toBackendTime(allotmentTime),
        'status': status,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> category = Map<String, dynamic>.from(jsonDecode(response.body));
      if (category['allotment_time'] != null) {
        category['allotment_time'] = _fromBackendTime(category['allotment_time'].toString());
      }
      return CategoryModel.fromJson(category);
    }
    throw Exception(_errorMessage(response, 'Failed to update category'));
  }

  // UPDATE CATEGORY STATUS
  Future<void> updateCategoryStatus(int id, bool isActive) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': isActive}),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Failed to update category status'));
    }
  }
}
