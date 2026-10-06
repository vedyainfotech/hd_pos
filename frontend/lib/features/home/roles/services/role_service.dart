import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/role_model.dart';

class RoleApiService {
  static const String baseUrl = 'http://192.168.0.12:8000';
  static const String endpoint = '/api/roles/';

  // GET ALL ROLES
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
      'Failed to load roles: ${response.statusCode}',
    );
  }

  // GET ROLE BY ID
  Future<RoleModel> getRole(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint$id'),
    );

    if (response.statusCode == 200) {
      return RoleModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      'Failed to load role: ${response.body}',
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
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      'Failed to create role: ${response.body}',
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
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      'Failed to update role: ${response.body}',
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
        'Failed to update role status: ${response.body}',
      );
    }
  }
}