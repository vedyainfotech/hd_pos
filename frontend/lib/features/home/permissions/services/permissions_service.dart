import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/permissions_model.dart';

class PermissionsService {
  // Windows/Web local development.
  // For an Android emulator, use: http://10.0.2.2:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<PermissionRole>> getRoles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/permissions/roles'),
    );

    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data =
        decoded is List ? decoded : (decoded['roles'] ?? []);

    return data
        .map(
          (item) => PermissionRole.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<PermissionScreen>> getScreens() async {
    final response = await http.get(
      Uri.parse('$baseUrl/permissions/screens'),
    );

    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data =
        decoded is List ? decoded : (decoded['screens'] ?? []);

    return data
        .map(
          (item) => PermissionScreen.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<ScreenPermission>> getRolePermissions(int roleId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/permissions/roles/$roleId'),
    );

    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data =
        decoded is List ? decoded : (decoded['permissions'] ?? []);

    return data
        .map(
          (item) => ScreenPermission.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> saveRolePermissions(
    int roleId,
    List<ScreenPermission> permissions,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/permissions/roles/$roleId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'permissions': permissions.map((item) => item.toJson()).toList(),
      }),
    );

    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Request failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}