import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';
import '../config/test_mode_config.dart';

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
      requireAuth: false, // No auth header needed for token verification
    );
  }

  // Handle authentication flow after Google Sign-In
  static Future<AuthFlowResult> handleAuthFlow(String idToken) async {
    try {
      // Store the ID token for future API calls
      await ApiService.storeIdToken(idToken);

      // Check if test mode is enabled and if this is a test token
      if (ApiConfig.isTestMode) {
        final testUser = TestModeConfig.getTestUserByToken(idToken);
        if (testUser != null) {
          return await handleTestAuthFlow(testUser);
        }
      }

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
      debugPrint('Error saving user data: $e');
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
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Clear user data (logout)
  static Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.setBool(_isLoggedInKey, false);
      // Also clear the stored ID token
      await ApiService.clearIdToken();
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
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
      debugPrint('Error updating user data: $e');
      return false;
    }
  }

  // Fetch user profile from backend
  static Future<ApiResponse<Map<String, dynamic>>> fetchUserProfile() async {
    try {
      // Get current user data to extract stored ID token or Firebase UID
      final userData = await getUserData();
      if (userData == null) {
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 401,
          error: 'No user session found',
        );
      }

      // For now, we'll use the stored user data. In a real implementation,
      // you might want to make an API call to get fresh data
      // Using Firebase Auth to get a fresh ID token would be ideal
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 200,
        data: {
          'data': {'user': userData},
        },
      );
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        error: 'Failed to fetch user profile: $e',
      );
    }
  }

  // Refresh user profile from backend
  static Future<ApiResponse<Map<String, dynamic>>> refreshUserProfile(
    String idToken,
  ) async {
    return await ApiService.post(
      ApiConfig.profileEndpoint,
      body: {'id_token': idToken},
      requireAuth:
          false, // No auth header needed for profile retrieval with token
    );
  }

  // Check if user status allows access
  static Future<bool> canUserAccess() async {
    final userData = await getUserData();
    if (userData == null) return false;

    final status = userData['status']?.toString().toLowerCase();
    return status == 'active';
  }

  // Check if user is blocked
  static Future<bool> isUserBlocked() async {
    final userData = await getUserData();
    if (userData == null) return false;

    final status = userData['status']?.toString().toLowerCase();
    return status == 'blocked';
  }

  // Check if user is pending approval
  static Future<bool> isUserPendingApproval() async {
    final userData = await getUserData();
    if (userData == null) return false;

    final status = userData['status']?.toString().toLowerCase();
    return status == 'pending_approval';
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final userData = await getUserData();
    return userData?['role']?.toString();
  }

  // Get user status
  static Future<String?> getUserStatus() async {
    final userData = await getUserData();
    return userData?['status']?.toString();
  }

  // Test mode authentication flow
  static Future<AuthFlowResult> handleTestAuthFlow(TestUser testUser) async {
    try {
      // Simulate API call to verify token
      await Future.delayed(const Duration(milliseconds: 500));

      if (testUser.isUnregistered) {
        // New user - return user info for registration
        return AuthFlowResult.newUser(
          gmailId: testUser.email,
          firebaseUid: testUser.firebaseUid,
          fullName: testUser.name,
        );
      } else {
        // Existing user - store data and return success
        final userData = testUser.toUserData();
        await _saveUserData(userData);

        // Store the test token as ID token for API calls
        await ApiService.storeIdToken(testUser.token);

        return AuthFlowResult.existingUser(userData);
      }
    } catch (e) {
      return AuthFlowResult.error('Test authentication error: $e');
    }
  }

  // Test mode token verification
  static Future<ApiResponse<Map<String, dynamic>>> verifyTestToken(
    String testToken,
  ) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      final testUser = TestModeConfig.getTestUserByToken(testToken);
      if (testUser == null) {
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 401,
          error: 'Invalid test token',
        );
      }

      if (testUser.isUnregistered) {
        // Return 201 for new user
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 201,
          data: {
            'data': {
              'user_info': {
                'gmail_id': testUser.email,
                'firebase_uid': testUser.firebaseUid,
                'full_name': testUser.name,
              },
            },
          },
        );
      } else {
        // Return 200 for existing user
        return ApiResponse<Map<String, dynamic>>(
          statusCode: 200,
          data: {
            'data': {'user': testUser.toUserData()},
          },
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 500,
        error: 'Test token verification error: $e',
      );
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
