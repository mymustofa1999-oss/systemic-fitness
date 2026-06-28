import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:workout/data/api_config.dart';
import 'package:workout/data/pref_data.dart';

class ApiService {
  // Keys whose values must never appear in debug logs.
  static const Set<String> _sensitiveKeys = {
    'password',
    'new_password',
    'old_password',
    'current_password',
    'confirm_password',
    'pin',
    'otp',
    'token',
    'access_token',
    'refresh_token',
    'id_token',
    'secret',
    'api_key',
    'authorization',
  };

  static dynamic _redactValue(dynamic v) {
    if (v is Map) {
      final out = <String, dynamic>{};
      v.forEach((k, value) {
        final keyStr = k.toString();
        if (_sensitiveKeys.contains(keyStr.toLowerCase())) {
          out[keyStr] = '***';
        } else {
          out[keyStr] = _redactValue(value);
        }
      });
      return out;
    }
    if (v is List) {
      return v.map(_redactValue).toList();
    }
    return v;
  }

  static String _safeBody(dynamic body) {
    try {
      return jsonEncode(_redactValue(body));
    } catch (_) {
      return '<unserializable body>';
    }
  }

  static String _safeResponseBody(String raw) {
    try {
      return jsonEncode(_redactValue(jsonDecode(raw)));
    } catch (_) {
      return raw;
    }
  }

  static Future<Map<String, String>> _headers() async {
    final token = await PrefData.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(queryParameters: queryParams);
    debugPrint('[API] GET $uri');
    try {
      final response = await http.get(uri, headers: await _headers());
      debugPrint('[API] Response ${response.statusCode}: ${_safeResponseBody(response.body)}');
      return _handleResponse(response);
    } catch (e, stack) {
      debugPrint('[API] ERROR GET $uri: $e');
      debugPrint('[API] Stack: $stack');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body, bool skipAuthRefresh = false}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    debugPrint('[API] POST $uri');
    debugPrint('[API] Body: ${_safeBody(body)}');
    try {
      final response = await http.post(uri, headers: await _headers(), body: jsonEncode(body));
      debugPrint('[API] Response ${response.statusCode}: ${_safeResponseBody(response.body)}');
      return _handleResponse(response, skipAuthRefresh: skipAuthRefresh);
    } catch (e, stack) {
      debugPrint('[API] ERROR POST $uri: $e');
      debugPrint('[API] Stack: $stack');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    debugPrint('[API] PUT $uri');
    debugPrint('[API] Body: ${_safeBody(body)}');
    try {
      final response = await http.put(uri, headers: await _headers(), body: jsonEncode(body));
      debugPrint('[API] Response ${response.statusCode}: ${_safeResponseBody(response.body)}');
      return _handleResponse(response);
    } catch (e, stack) {
      debugPrint('[API] ERROR PUT $uri: $e');
      debugPrint('[API] Stack: $stack');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    debugPrint('[API] DELETE $uri');
    try {
      final response = await http.delete(uri, headers: await _headers());
      debugPrint('[API] Response ${response.statusCode}: ${_safeResponseBody(response.body)}');
      if (response.statusCode == 204) return {'success': true};
      return _handleResponse(response);
    } catch (e, stack) {
      debugPrint('[API] ERROR DELETE $uri: $e');
      debugPrint('[API] Stack: $stack');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response, {bool skipAuthRefresh = false}) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Auto refresh token on 401 (skip for login/register endpoints)
    if (response.statusCode == 401 && !skipAuthRefresh) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry original request — caller should retry
        throw TokenRefreshedException();
      } else {
        // Refresh failed — clear tokens, redirect to login
        await PrefData.clearAll();
        throw ApiException(
          statusCode: 401,
          message: 'Session expired. Please login again.',
        );
      }
    }

    if (response.statusCode == 403) {
      final msg = (body['message'] ?? '').toString().toLowerCase();
      if (msg.contains('paid subscription')) {
        throw PaidSubscriptionRequiredException();
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] ?? 'Unknown error',
      errors: (body['errors'] as List?)?.cast<String>(),
    );
  }

  static Future<bool> _tryRefreshToken() async {
    final refreshToken = await PrefData.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refresh}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data != null) {
          final tokens = data['tokens'];
          if (tokens != null) {
            await PrefData.setTokens(
              tokens['access_token'],
              tokens['refresh_token'],
            );
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  /// Helper to make an API call with automatic retry on token refresh
  static Future<Map<String, dynamic>> getWithRetry(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      return await get(endpoint, queryParams: queryParams);
    } on TokenRefreshedException {
      return await get(endpoint, queryParams: queryParams);
    }
  }

  static Future<Map<String, dynamic>> postWithRetry(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      return await post(endpoint, body: body);
    } on TokenRefreshedException {
      return await post(endpoint, body: body);
    }
  }

  static Future<Map<String, dynamic>> putWithRetry(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      return await put(endpoint, body: body);
    } on TokenRefreshedException {
      return await put(endpoint, body: body);
    }
  }

  static Future<Map<String, dynamic>> deleteWithRetry(String endpoint) async {
    try {
      return await delete(endpoint);
    } on TokenRefreshedException {
      return await delete(endpoint);
    }
  }

  /// Upload an image file via multipart/form-data
  static Future<Map<String, dynamic>> uploadImage(
    String filePath, {
    String? entityType,
    String? entityId,
  }) async {
    final token = await PrefData.getAccessToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploads}');

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    if (entityType != null) request.fields['entity_type'] = entityType;
    if (entityId != null) request.fields['entity_id'] = entityId;

    debugPrint('[API] UPLOAD $uri');
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    debugPrint('[API] Response ${streamedResponse.statusCode}: $responseBody');
    final body = jsonDecode(responseBody) as Map<String, dynamic>;

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      return body;
    }

    if (streamedResponse.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        throw TokenRefreshedException();
      } else {
        await PrefData.clearAll();
        throw ApiException(
          statusCode: 401,
          message: 'Session expired. Please login again.',
        );
      }
    }

    throw ApiException(
      statusCode: streamedResponse.statusCode,
      message: body['message'] ?? 'Upload failed',
    );
  }

  static Future<Map<String, dynamic>> uploadImageWithRetry(
    String filePath, {
    String? entityType,
    String? entityId,
  }) async {
    try {
      return await uploadImage(filePath,
          entityType: entityType, entityId: entityId);
    } on TokenRefreshedException {
      return await uploadImage(filePath,
          entityType: entityType, entityId: entityId);
    }
  }

  /// Generic multipart/form-data POST helper.
  ///
  /// Used by features (like payment-proof upload) that need to hit a
  /// specific endpoint other than `/uploads`. The backend handler is
  /// responsible for parsing the form-data, persisting the file, and
  /// linking it to the parent entity.
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? extraFields,
  }) async {
    final token = await PrefData.getAccessToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files
        .add(await http.MultipartFile.fromPath(fieldName, file.path));
    if (extraFields != null) request.fields.addAll(extraFields);

    debugPrint('[API] UPLOAD $uri');
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    debugPrint('[API] Response ${streamedResponse.statusCode}: $responseBody');

    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      // empty / non-json body — fall through
    }

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      return body;
    }

    if (streamedResponse.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry once with refreshed token
        return await uploadFile(endpoint, file,
            fieldName: fieldName, extraFields: extraFields);
      }
      await PrefData.clearAll();
      throw ApiException(
        statusCode: 401,
        message: 'Session expired. Please login again.',
      );
    }

    throw ApiException(
      statusCode: streamedResponse.statusCode,
      message: body['message']?.toString() ?? 'Upload failed',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final List<String>? errors;
  ApiException({required this.statusCode, required this.message, this.errors});

  @override
  String toString() => message;
}

class TokenRefreshedException implements Exception {}

/// Thrown when the backend rejects a request because the user does not
/// have an active paid subscription. UI should redirect to the upgrade screen.
class PaidSubscriptionRequiredException implements Exception {
  @override
  String toString() => 'paid subscription required';
}
