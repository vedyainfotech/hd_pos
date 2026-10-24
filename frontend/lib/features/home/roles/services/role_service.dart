
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/role_model.dart';

class RoleApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/api/roles/';

  String _getApiErrorMessage(
    http.Response response,
    String fallback,
  ) {
    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map) {
        final detail = decoded['detail'];

        if (detail is String && detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (detail is List) {
          return detail.map((item) {
            if (item is Map && item['msg'] != null) {
              return item['msg'].toString();
            }
            return item.toString();
          }).join(', ');
        }
      }
    } catch (_) {
      // Use fallback when the response is not JSON.
    }

    return fallback;
  }

  String _duplicateAwareMessage(
    http.Response response,
    String fallback,
  ) {
    final message = _getApiErrorMessage(response, fallback);
    final lower = message.toLowerCase();

    if (lower.contains('already exists') ||
        lower.contains('duplicate key') ||
        lower.contains('unique constraint')) {
      return 'Role already exists';
    }

    return message;
  }

  Future<List<RoleModel>> getRoles({
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
        return RoleModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      }).toList();
    }

    throw Exception(
      _getApiErrorMessage(response, 'Failed to load roles'),
    );
  }

  Future<RoleModel> getRole(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint$id'),
    );

    if (response.statusCode == 200) {
      return RoleModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception(
      _getApiErrorMessage(response, 'Failed to load role'),
    );
  }

  // CREATE ROLE
  Future<RoleModel> createRole({
    required String name,
  }) async {
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
      return RoleModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception(
      _duplicateAwareMessage(response, 'Failed to add role'),
    );
  }

  // UPDATE ROLE
  Future<RoleModel> updateRole({
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
      return RoleModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception(
      _duplicateAwareMessage(response, 'Failed to update role'),
    );
  }

  // UPDATE ROLE STATUS
  Future<void> updateRoleStatus(
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
        _getApiErrorMessage(
          response,
          'Failed to update role status',
        ),
      );
    }
  }
}
