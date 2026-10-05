import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationApiService {
  static const String _baseUrl =
      'https://api.countrystatecity.in/v1';

  static const String _apiKey = 'YOUR_API_KEY';

  static final Map<String, String> _headers = {
    'X-CSCAPI-KEY': _apiKey,
  };

  /// Get states of a country
  static Future<List<LocationItem>> getStates(
    String countryCode,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/countries/$countryCode/states'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load states: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (item) => LocationItem(
            id: item['iso2']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
          ),
        )
        .toList();
  }

  /// Get cities of a state
  static Future<List<LocationItem>> getCities(
    String countryCode,
    String stateCode,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/countries/$countryCode/states/$stateCode/cities',
      ),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load cities: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (item) => LocationItem(
            id: item['id']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
          ),
        )
        .toList();
  }

  /// Get districts of an Indian state
  static Future<List<LocationItem>> getDistricts(
    String stateSlug,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://aniket-thapa.github.io/india-pincode-api/states/$stateSlug.json',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load districts: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    final districts = data['districts'];

    if (districts is! List) {
      return [];
    }

    return districts.map<LocationItem>((district) {
      return LocationItem(
        id: district['slug']?.toString() ?? '',
        name: district['name']?.toString() ?? '',
      );
    }).toList();
  }

  /// Get areas/localities using an Indian pincode
static Future<List<LocationItem>> getAreasByPincode(
  String pincode,
) async {
  final response = await http.get(
    Uri.parse(
      'https://api.postalpincode.in/pincode/$pincode',
    ),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load areas: ${response.statusCode}',
    );
  }

  final List<dynamic> data = jsonDecode(response.body);

  if (data.isEmpty) {
    return [];
  }

  final postOffice = data[0]['PostOffice'];

  if (postOffice is! List) {
    return [];
  }

  return postOffice.map<LocationItem>((item) {
    return LocationItem(
      id: item['Name']?.toString() ?? '',
      name: item['Name']?.toString() ?? '',
    );
  }).toList();
}
}

class LocationItem {
  final String id;
  final String name;

  LocationItem({
    required this.id,
    required this.name,
  });
}