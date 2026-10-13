import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/delivery_person_model.dart';

class DeliveryPersonApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/api/delivery-persons/';

  Future<List<DeliveryPersonModel>> getDeliveryPersons({
    bool includeInactive = true,
    String? search,
  }) async {
    final queryParameters = <String, String>{
      'include_inactive': includeInactive.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (json) => DeliveryPersonModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load delivery persons: ${response.body}',
    );
  }

  Future<DeliveryPersonModel> createDeliveryPerson({
    required String name,
    required String contactNumber,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? aadhaarNumber,
    String? panCardNumber,
    String? drivingLicense,
    required PlatformFile identityProofFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    _addTextFields(
      request,
      name: name,
      contactNumber: contactNumber,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      aadhaarNumber: aadhaarNumber,
      panCardNumber: panCardNumber,
      drivingLicense: drivingLicense,
    );

    request.files.add(
      await _buildMultipartFile(identityProofFile),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 201) {
      return DeliveryPersonModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to create delivery person: ${response.body}',
    );
  }

  Future<DeliveryPersonModel> updateDeliveryPerson({
    required int id,
    required String name,
    required String contactNumber,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? aadhaarNumber,
    String? panCardNumber,
    String? drivingLicense,
    required bool status,
    PlatformFile? identityProofFile,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl$endpoint$id'),
    );

    _addTextFields(
      request,
      name: name,
      contactNumber: contactNumber,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      aadhaarNumber: aadhaarNumber,
      panCardNumber: panCardNumber,
      drivingLicense: drivingLicense,
      status: status,
    );

    if (identityProofFile != null) {
      request.files.add(
        await _buildMultipartFile(identityProofFile),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 200) {
      return DeliveryPersonModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update delivery person: ${response.body}',
    );
  }

  Future<DeliveryPersonModel> updateDeliveryPersonStatus(
    int id,
    bool isActive,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint$id/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': isActive,
      }),
    );

    if (response.statusCode == 200) {
      return DeliveryPersonModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to update delivery person status: ${response.body}',
    );
  }

  void _addTextFields(
    http.MultipartRequest request, {
    required String name,
    required String contactNumber,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? aadhaarNumber,
    String? panCardNumber,
    String? drivingLicense,
    bool? status,
  }) {
    request.fields['name'] = name.trim();
    request.fields['contact_number'] = contactNumber.trim();

    _addOptionalField(
      request,
      'bank_name',
      bankName,
    );

    _addOptionalField(
      request,
      'account_number',
      accountNumber,
    );

    _addOptionalField(
      request,
      'ifsc_code',
      ifscCode,
    );

    _addOptionalField(
      request,
      'aadhaar_number',
      aadhaarNumber,
    );

    _addOptionalField(
      request,
      'pan_card_number',
      panCardNumber,
    );

    _addOptionalField(
      request,
      'driving_license',
      drivingLicense,
    );

    if (status != null) {
      request.fields['status'] = status.toString();
    }
  }

  void _addOptionalField(
    http.MultipartRequest request,
    String key,
    String? value,
  ) {
    final trimmed = value?.trim();

    if (trimmed != null && trimmed.isNotEmpty) {
      request.fields[key] = trimmed;
    }
  }

  Future<http.MultipartFile> _buildMultipartFile(
    PlatformFile file,
  ) async {
    final bytes = await file.readAsBytes();

    return http.MultipartFile.fromBytes(
      'identity_proof',
      bytes,
      filename: file.name,
      contentType: _contentTypeForFile(file.name),
    );
  }

  MediaType _contentTypeForFile(String filename) {
    final extension = filename
        .split('.')
        .last
        .toLowerCase();

    switch (extension) {
      case 'pdf':
        return MediaType('application', 'pdf');

      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');

      case 'png':
        return MediaType('image', 'png');

      default:
        return MediaType(
          'application',
          'octet-stream',
        );
    }
  }
}