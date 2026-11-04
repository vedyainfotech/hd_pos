import 'dart:convert';
import 'package:http/http.dart' as http;

class PermissionApi {
  // Windows/Web: use 127.0.0.1.
  // Android emulator: change this to http://10.0.2.2:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<dynamic>> getRoles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/permissions/roles'),
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load roles: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getRolePermissions(
    int roleId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/permissions/roles/$roleId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load permissions: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> saveRolePermissions({
    required int roleId,
    required List<Map<String, dynamic>> permissions,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/permissions/roles/$roleId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'permissions': permissions}),
    );

    if (response.statusCode != 200) {
      throw Exception('Could not save permissions: ${response.body}');
    }
  }
}