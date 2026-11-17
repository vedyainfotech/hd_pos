
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/order_selection_model.dart';

class OrderSelectionService {
  final String baseUrl;

  OrderSelectionService({
    required this.baseUrl,
  });

  final Map<int, OrderCustomerModel> _customers = {};
  final Map<int, List<OrderSubCategoryModel>> _subCategories = {};

  // Convert date to YYYY-MM-DD.
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // Handle API errors.
  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = 'Something went wrong';

    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        message = body['detail']?.toString() ?? message;
      }
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : message;
    }

    throw Exception(message);
  }

  // 1. Fetch pending assignments for selected date.
  Future<List<PendingOrderAssignmentModel>> getPendingAssignments(
    DateTime date,
  ) async {
    final uri = Uri.parse('$baseUrl/order-selection/pending').replace(
      queryParameters: {
        'delivery_date': _formatDate(date),
      },
    );

    final response = await http.get(uri);

    _checkResponse(response);

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (json) => PendingOrderAssignmentModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // 2. Fetch customer details and addresses.
  Future<OrderCustomerModel?> getCustomer(int customerId) async {
    final cachedCustomer = _customers[customerId];

    if (cachedCustomer != null) {
      return cachedCustomer;
    }

    // Find an assignment belonging to this customer first.
    // The customer endpoint requires an assignment ID.
    throw Exception(
      'Use getCustomerForAssignment() to fetch customer details.',
    );
  }

  Future<OrderCustomerModel> getCustomerForAssignment(
    int assignmentId,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/order-selection/assignments/$assignmentId/customer',
    );

    final response = await http.get(uri);

    _checkResponse(response);

    final customer = OrderCustomerModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    _customers[customer.id] = customer;

    return customer;
  }

  // 3. Get address from the already fetched customer.
  OrderAddressModel? getAddress(
    OrderCustomerModel customer,
    int addressId,
  ) {
    for (final address in customer.addresses) {
      if (address.id == addressId) {
        return address;
      }
    }

    return null;
  }

  // 4. Fetch subcategories for an assignment.
  Future<List<OrderSubCategoryModel>> getSubCategories(
    int assignmentId,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/order-selection/assignments/$assignmentId/subcategories',
    );

    final response = await http.get(uri);

    _checkResponse(response);

    final List<dynamic> data = jsonDecode(response.body);

    final subCategories = data
        .map(
          (json) => OrderSubCategoryModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();

    _subCategories[assignmentId] = subCategories;

    return subCategories;
  }

  // 5. Fetch daily menu items for selected subcategory.
  Future<List<OrderItemModel>> getItems(
    int assignmentId,
    int subCategoryId,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/order-selection/assignments/$assignmentId/items',
    ).replace(
      queryParameters: {
        'sub_category_id': subCategoryId.toString(),
      },
    );

    final response = await http.get(uri);

    _checkResponse(response);

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (json) => OrderItemModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // 6. Save selected item and resolve the assignment.
  // This does not create a restaurant order.
  Future<void> saveOrderSelection({
    required int assignmentId,
    required int selectedSubCategoryId,
    required int selectedItemId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/order-selection/assignments/$assignmentId/resolve',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'selected_sub_category_id': selectedSubCategoryId,
        'selected_item_id': selectedItemId,
      }),
    );

    _checkResponse(response);

    // Remove cached customer/subcategory data for this assignment
    // only after the backend confirms that it was saved.
    _subCategories.remove(assignmentId);
  }
}
