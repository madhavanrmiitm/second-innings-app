import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';

class UserService {
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Verify token with backend
  static Future<ApiResponse<Map<String, dynamic>>> verifyToken(
    String idToken,
  ) async {
    return await ApiService.post(
      ApiConfig.verifyTokenEndpoint,
      body: {'id_token': idToken},
    );
  }

  // Handle authentication flow after Google Sign-In
  static Future<AuthFlowResult> handleAuthFlow(String idToken) async {
    try {
      final response = await verifyToken(idToken);

      if (response.statusCode == 201) {
        // New user - extract user info from response
        final userInfo = response.data?['data']?['user_info'];
        if (userInfo != null) {
          return AuthFlowResult.newUser(
            gmailId: userInfo['gmail_id'] ?? '',
            firebaseUid: userInfo['firebase_uid'] ?? '',
            fullName: userInfo['full_name'] ?? '',
          );
        } else {
          return AuthFlowResult.error('Invalid response format for new user');
        }
      } else if (response.statusCode == 200) {
        // Existing user - store data and return success
        final userData = response.data?['data']?['user'];
        if (userData != null) {
          await _saveUserData(userData);
          return AuthFlowResult.existingUser(userData);
        } else {
          return AuthFlowResult.error(
            'Invalid response format for existing user',
          );
        }
      } else {
        return AuthFlowResult.error(response.error ?? 'Authentication failed');
      }
    } catch (e) {
      return AuthFlowResult.error('Authentication error: $e');
    }
  }

  // Save user data to SharedPreferences
  static Future<bool> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(userData));
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  // Get user data from SharedPreferences
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Clear user data (logout)
  static Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }

  // Get specific user field
  static Future<String?> getUserField(String field) async {
    final userData = await getUserData();
    return userData?[field]?.toString();
  }

  // Update user data
  static Future<bool> updateUserData(Map<String, dynamic> newData) async {
    try {
      final currentData = await getUserData() ?? {};
      currentData.addAll(newData);
      return await _saveUserData(currentData);
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }
}

// Result class for authentication flow
class AuthFlowResult {
  final AuthFlowType type;
  final Map<String, dynamic>? userData;
  final String? error;
  final String? gmailId;
  final String? firebaseUid;
  final String? fullName;

  AuthFlowResult._({
    required this.type,
    this.userData,
    this.error,
    this.gmailId,
    this.firebaseUid,
    this.fullName,
  });

  factory AuthFlowResult.newUser({
    required String gmailId,
    required String firebaseUid,
    required String fullName,
  }) {
    return AuthFlowResult._(
      type: AuthFlowType.newUser,
      gmailId: gmailId,
      firebaseUid: firebaseUid,
      fullName: fullName,
    );
  }

  factory AuthFlowResult.existingUser(Map<String, dynamic> userData) {
    return AuthFlowResult._(
      type: AuthFlowType.existingUser,
      userData: userData,
    );
  }

  factory AuthFlowResult.error(String error) {
    return AuthFlowResult._(type: AuthFlowType.error, error: error);
  }

  bool get isNewUser => type == AuthFlowType.newUser;
  bool get isExistingUser => type == AuthFlowType.existingUser;
  bool get hasError => type == AuthFlowType.error;
}

enum AuthFlowType { newUser, existingUser, error }
