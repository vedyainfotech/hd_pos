import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/customer_model.dart';

class CustomerApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/customers/';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail is String) return detail;

        if (detail is List) {
          return detail
              .map((item) =>
                  item is Map ? item['msg'] ?? item.toString() : item)
              .join('\n');
        }

        if (detail != null) return detail.toString();
      }
    } catch (_) {
      // Use the HTTP status if the response is not JSON.
    }

    return 'Request failed (${response.statusCode}).';
  }

  static dynamic _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) return null;
    return jsonDecode(response.body);
  }

  // GET: Fetch all customers.
  static Future<List<Customer>> getCustomers() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final decoded = _decodeResponse(response);

      final List<dynamic> data = decoded is List
          ? decoded
          : decoded is Map<String, dynamic>
              ? (decoded['items'] as List? ?? [])
              : [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(Customer.fromJson)
          .toList();
    }

    throw Exception(_errorMessage(response));
  }

  // GET: Fetch one customer by database ID.
  static Future<Customer> getCustomerById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(
        _decodeResponse(response) as Map<String, dynamic>,
      );
    }

    throw Exception(_errorMessage(response));
  }

  // POST: Create a customer.
  static Future<Customer> createCustomer(Customer customer) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Customer.fromJson(
        _decodeResponse(response) as Map<String, dynamic>,
      );
    }

    throw Exception(_errorMessage(response));
  }

  // PUT: Update a customer.
  static Future<Customer> updateCustomer(Customer customer) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint${customer.id}'),
      headers: _headers,
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(
        _decodeResponse(response) as Map<String, dynamic>,
      );
    }

    throw Exception(_errorMessage(response));
  }

  // DELETE: Delete a customer.
  static Future<void> deleteCustomer(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint$id'),
      headers: _headers,
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw Exception(_errorMessage(response));
  }
}