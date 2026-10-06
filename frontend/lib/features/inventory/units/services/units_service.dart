import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/units_model.dart';

class UnitApiService {
  static const String baseUrl = 'http://192.168.0.12:8000';
  static const String endpoint = '/api/units/';

  // GET ALL UNITS
  Future<List<UnitModel>> getUnits({
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
        return UnitModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      }).toList();
    }

    throw Exception(
      'Failed to load units: ${response.statusCode}',
    );
  }

  // CREATE UNIT
  Future<UnitModel> createUnit({
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
      return UnitModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      'Failed to create unit: ${response.body}',
    );
  }

  // UPDATE UNIT
  Future<UnitModel> updateUnit({
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
      return UnitModel.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body),
        ),
      );
    }

    throw Exception(
      'Failed to update unit: ${response.body}',
    );
  }

  // UPDATE UNIT STATUS
  Future<void> updateUnitStatus(
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
        'Failed to update unit status: ${response.body}',
      );
    }
  }
}