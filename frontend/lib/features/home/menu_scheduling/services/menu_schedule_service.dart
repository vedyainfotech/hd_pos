
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/menu_schedule_model.dart';

class MenuScheduleApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const String endpoint = '/api/menu-scheduling';

  // ---------------------------------
  // GET Available Menu Items
  // ---------------------------------

  Future<AvailableMenuResponse> getAvailableItems({
    required int categoryId,
    String? search,
  }) async {
    final queryParameters = <String, String>{
      'category_id': categoryId.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final uri = Uri.parse(
      '$baseUrl$endpoint/available-items',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(uri);

    print('GET available menu items: ${response.statusCode}');
    print('GET available menu response: ${response.body}');

    if (response.statusCode == 200) {
      return AvailableMenuResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to load available menu items: ${response.body}',
    );
  }

  // ---------------------------------
  // GET Scheduled Menu by Date
  // ---------------------------------

  Future<MenuScheduleDateResponse> getMenuByDate({
    required DateTime deliveryDate,
  }) async {
    final formattedDate =
        '${deliveryDate.year.toString().padLeft(4, '0')}-'
        '${deliveryDate.month.toString().padLeft(2, '0')}-'
        '${deliveryDate.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
      '$baseUrl$endpoint/date/$formattedDate',
    );

    final response = await http.get(uri);

    print('GET scheduled menu: ${response.statusCode}');
    print('GET scheduled menu response: ${response.body}');

    if (response.statusCode == 200) {
      return MenuScheduleDateResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to load scheduled menu: ${response.body}',
    );
  }

  // ---------------------------------
  // SAVE or UPDATE Menu Schedule
  // ---------------------------------

  Future<Map<String, dynamic>> saveMenuSchedule({
    required DateTime deliveryDate,
    required int categoryId,
    required List<int> itemIds,
  }) async {
    final request = MenuScheduleSaveRequest(
      deliveryDate: deliveryDate,
      categoryId: categoryId,
      itemIds: itemIds,
    );

    final uri = Uri.parse(
      '$baseUrl$endpoint/save',
    );

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print('SAVE menu schedule: ${response.statusCode}');
    print('SAVE menu schedule response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to save menu schedule: ${response.body}',
    );
  }
}
