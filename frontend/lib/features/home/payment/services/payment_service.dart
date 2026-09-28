import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/payment_model.dart';

class PaymentService {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _endpoint = '/api/payment-modes';

  // ============================================================
  // GET PAYMENT MODES
  // ============================================================

  Future<List<PaymentModel>> getPayments({
    bool includeInactive = true,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl$_endpoint?include_inactive=$includeInactive',
      ),
    );

    print('GET payment modes: ${response.statusCode}');
    print('GET response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load payment modes: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (json) => PaymentModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // ============================================================
  // CREATE PAYMENT MODE
  // ============================================================

  Future<PaymentModel> createPayment({
    required String name,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'is_active': isActive,
      }),
    );

    print('CREATE payment mode: ${response.statusCode}');
    print('CREATE response: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create payment mode: ${response.body}',
      );
    }

    return PaymentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ============================================================
  // UPDATE PAYMENT MODE
  // ============================================================

  Future<PaymentModel> updatePayment({
    required int id,
    required String name,
    required bool isActive,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$_endpoint/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'is_active': isActive,
      }),
    );

    print('UPDATE payment mode: ${response.statusCode}');
    print('UPDATE response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update payment mode: ${response.body}',
      );
    }

    return PaymentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<PaymentModel> updatePaymentStatus({
    required int id,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl$_endpoint/$id/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'is_active': isActive,
      }),
    );

    print('STATUS UPDATE: ${response.statusCode}');
    print('STATUS UPDATE RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update payment mode status: ${response.body}',
      );
    }

    return PaymentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}