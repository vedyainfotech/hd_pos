import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class CategoryApiService {
  static const String baseUrl = 'http://192.168.0.12:8000';
  static const String endpoint = '/api/categories/';

  // Converts 12-hour AM/PM time to backend 24-hour time.
  //
  // Example:
  // 01:30 PM -> 13:30:00
  // 06:45 PM -> 18:45:00
  // 12:30 AM -> 00:30:00
  static String _toBackendTime(String time) {
    final parts = time.trim().split(' ');

    if (parts.length != 2) {
      return time;
    }

    final timePart = parts[0];
    final period = parts[1].toUpperCase();

    final timeParts = timePart.split(':');

    if (timeParts.length != 2) {
      return time;
    }

    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    if (period == 'AM') {
      if (hour == 12) {
        hour = 0;
      }
    } else if (period == 'PM') {
      if (hour != 12) {
        hour += 12;
      }
    }

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:00';
  }

  // Converts backend 24-hour time to 12-hour AM/PM time.
  //
  // Example:
  // 13:30:00 -> 01:30 PM
  // 18:45:00 -> 06:45 PM
  // 00:30:00 -> 12:30 AM
  static String _fromBackendTime(String time) {
    final parts = time.split(':');

    if (parts.length < 2) {
      return time;
    }

    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    final String period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} '
        '$period';
  }

  // GET ALL CATEGORIES
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

      return data.map((json) {
        final Map<String, dynamic> category =
            Map<String, dynamic>.from(json as Map);

        // Convert backend time to UI format.
        if (category['allotment_time'] != null) {
          category['allotment_time'] = _fromBackendTime(
            category['allotment_time'].toString(),
          );
        }

        return CategoryModel.fromJson(category);
      }).toList();
    }

    throw Exception(
      'Failed to load categories: ${response.statusCode}',
    );
  }

  // CREATE CATEGORY
  Future<CategoryModel> createCategory({
    required String name,
    required String allotmentTime,
    required bool status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'allotment_time': _toBackendTime(allotmentTime),
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> category =
          Map<String, dynamic>.from(
        jsonDecode(response.body),
      );

      // Convert backend time to UI format.
      if (category['allotment_time'] != null) {
        category['allotment_time'] = _fromBackendTime(
          category['allotment_time'].toString(),
        );
      }

      return CategoryModel.fromJson(category);
    }

    throw Exception(
      'Failed to create category: ${response.body}',
    );
  }

  // UPDATE CATEGORY
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String allotmentTime,
    required bool status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'allotment_time': _toBackendTime(allotmentTime),
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> category =
          Map<String, dynamic>.from(
        jsonDecode(response.body),
      );

      // Convert backend time to UI format.
      if (category['allotment_time'] != null) {
        category['allotment_time'] = _fromBackendTime(
          category['allotment_time'].toString(),
        );
      }

      return CategoryModel.fromJson(category);
    }

    throw Exception(
      'Failed to update category: ${response.body}',
    );
  }

  // UPDATE CATEGORY STATUS
  Future<void> updateCategoryStatus(
    int id,
    bool isActive,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint$id/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': isActive,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update category status: ${response.body}',
      );
    }
  }
}