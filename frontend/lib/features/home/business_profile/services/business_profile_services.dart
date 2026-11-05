
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../models/business_profile_models.dart';

class BusinessProfileService {
  // Backend URL
  static const String baseUrl = 'http://127.0.0.1:8000';

  // API endpoints
  static const String profileEndpoint = '/api/business-profile/';
  static const String branchesEndpoint =
      '/api/business-profile/branches/';

  static Uri _url(String path) {
    return Uri.parse('$baseUrl$path');
  }

  // --------------------------------------------------
  // GET BUSINESS PROFILE
  // --------------------------------------------------

  static Future<BusinessProfileModel?> getProfile() async {
    final response = await http.get(
      _url(profileEndpoint),
      headers: {
        'Accept': 'application/json',
      },
    );

    // No profile created yet
    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Profile load failed (${response.statusCode}): '
        '${response.body}',
      );
    }

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid Business Profile response.',
      );
    }

    return BusinessProfileModel.fromJson(body);
  }

  // --------------------------------------------------
  // GET REGISTERED BRANCHES
  // --------------------------------------------------

  static Future<List<BusinessBranchModel>> getBranches() async {
    final response = await http.get(
      _url(branchesEndpoint),
      headers: {
        'Accept': 'application/json',
      },
    );

    // No branch endpoint or no branches available
    if (response.statusCode == 404) {
      return <BusinessBranchModel>[];
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Branch list unavailable (${response.statusCode}).',
      );
    }

    final dynamic body = jsonDecode(response.body);

    final dynamic rows = body is List
        ? body
        : body is Map<String, dynamic>
            ? body['items']
            : null;

    if (rows is! List) {
      throw const FormatException(
        'Invalid branches response.',
      );
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(BusinessBranchModel.fromJson)
        .toList();
  }

  // --------------------------------------------------
  // SAVE BUSINESS PROFILE
  // --------------------------------------------------

  static Future<BusinessProfileModel> saveProfile(
    BusinessProfileModel profile, {
    PlatformFile? logo,
    PlatformFile? fssaiDocument,
    PlatformFile? gstDocument,
    PlatformFile? panDocument,
    PlatformFile? aadhaarDocument,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      _url(profileEndpoint),
    );

    request.headers['Accept'] = 'application/json';

    // Add profile details
    request.fields['profile'] = jsonEncode(
      profile.toJson(),
    );

    // Add selected documents as actual file bytes
   Future<void> addFile(
  String fieldName,
  PlatformFile? file,
) async {
  if (file == null) return;

  final bytes = await file.xFile.readAsBytes();

  if (bytes.isEmpty) {
    throw Exception(
      'The selected file "${file.name}" is empty '
      'or could not be read. Please select it again.',
    );
  }

  request.files.add(
    http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: file.name,
    ),
  );
}

    await addFile('logo', logo);
    await addFile('fssai_document', fssaiDocument);
    await addFile('gst_document', gstDocument);
    await addFile('pan_document', panDocument);

    // Kept for compatibility with the existing service method signature.
    // The updated screen should pass null because Aadhaar upload is removed.
    await addFile('aadhaar_document', aadhaarDocument);

    // Send request
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      final detail = response.body.trim();

      throw Exception(
        'Profile save failed (${response.statusCode})'
        '${detail.isEmpty ? '.' : ': $detail'}',
      );
    }

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid Business Profile save response.',
      );
    }

    return BusinessProfileModel.fromJson(body);
  }
}
