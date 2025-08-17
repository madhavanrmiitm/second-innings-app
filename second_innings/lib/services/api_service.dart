import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_response.dart';
import '../config/api_config.dart';
import '../config/test_mode_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.currentBaseUrl;
  static Duration get timeout => ApiConfig.requestTimeout;

  // Headers for all requests
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get authentication headers - Updated to handle test mode properly
  static Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('firebase_id_token');

      if (idToken != null && idToken.isNotEmpty) {
        return {..._defaultHeaders, 'Authorization': 'Bearer $idToken'};
      }

      return _defaultHeaders;
    } catch (e) {
      return _defaultHeaders;
    }
  }

  // Store Firebase ID token for future API calls
  static Future<bool> storeIdToken(String idToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_id_token', idToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get stored Firebase ID token
  static Future<String?> getIdToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('firebase_id_token');
    } catch (e) {
      return null;
    }
  }

  // Clear stored Firebase ID token (for logout)
  static Future<bool> clearIdToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('firebase_id_token');
      return true;
    } catch (e) {
      return false;
    }
  }

  // GET Request with auth
  static Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    bool requireAuth = true,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final requestHeaders = requireAuth
          ? await _getAuthHeaders()
          : _defaultHeaders;

      final response = await http
          .get(uri, headers: {...requestHeaders, ...?headers})
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST Request with auth
  static Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final requestHeaders = requireAuth
          ? await _getAuthHeaders()
          : _defaultHeaders;

      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...requestHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT Request with auth
  static Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final requestHeaders = requireAuth
          ? await _getAuthHeaders()
          : _defaultHeaders;

      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...requestHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE Request with auth
  static Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final requestHeaders = requireAuth
          ? await _getAuthHeaders()
          : _defaultHeaders;

      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: {...requestHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle HTTP Response
  static ApiResponse<Map<String, dynamic>> _handleResponse(
    http.Response response,
  ) {
    final int statusCode = response.statusCode;
    Map<String, dynamic>? data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      return ApiResponse.error(
        statusCode: statusCode,
        error: 'Failed to parse response: $e',
      );
    }

    switch (statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        return ApiResponse.success(
          statusCode: statusCode,
          data: data,
          message: data?['message'],
        );

      case 400:
        return ApiResponse.error(
          statusCode: statusCode,
          error: data?['error'] ?? data?['message'] ?? 'Bad Request',
        );

      case 401:
        return ApiResponse.error(
          statusCode: statusCode,
          error: data?['error'] ?? data?['message'] ?? 'Unauthorized',
        );

      case 403:
        return ApiResponse.error(
          statusCode: statusCode,
          error: data?['error'] ?? data?['message'] ?? 'Forbidden',
        );

      case 404:
        return ApiResponse.error(
          statusCode: statusCode,
          error: data?['error'] ?? data?['message'] ?? 'Not Found',
        );

      case 422:
        return ApiResponse.error(
          statusCode: statusCode,
          error: data?['error'] ?? data?['message'] ?? 'Unprocessable Entity',
        );

      case 500:
        return ApiResponse.error(
          statusCode: statusCode,
          error: data?['error'] ?? data?['message'] ?? 'Internal Server Error',
        );

      case 502:
        return ApiResponse.error(statusCode: statusCode, error: 'Bad Gateway');

      case 503:
        return ApiResponse.error(
          statusCode: statusCode,
          error: 'Service Unavailable',
        );

      default:
        return ApiResponse.error(
          statusCode: statusCode,
          error: data?['error'] ?? data?['message'] ?? 'Unknown error occurred',
        );
    }
  }

  // Handle Errors (Network, Timeout, etc.)
  static ApiResponse<Map<String, dynamic>> _handleError(dynamic error) {
    if (error is SocketException) {
      return ApiResponse.error(statusCode: 0, error: 'No internet connection');
    } else if (error is HttpException) {
      return ApiResponse.error(statusCode: 0, error: 'HTTP error occurred');
    } else if (error.toString().contains('TimeoutException')) {
      return ApiResponse.error(statusCode: 0, error: 'Request timeout');
    } else {
      return ApiResponse.error(
        statusCode: 0,
        error: 'An unexpected error occurred: $error',
      );
    }
  }
}
