import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';
import '../config/test_mode_config.dart';
import 'user_service.dart';

class RegistrationService {
  // Register user with backend
  static Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String idToken,
    required String fullName,
    required String role,
    String? dateOfBirth,
    String? gender,
    String? phoneNumber,
    String? address,
    String? description,
    List<String>? tags,
    String? youtubeUrl,
  }) async {
    final Map<String, dynamic> body = {
      'id_token': idToken,
      'full_name': fullName,
      'role': role,
    };

    // Add optional fields based on role
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
    if (gender != null) body['gender'] = gender;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;
    if (address != null) body['address'] = address;
    if (description != null) body['description'] = description;
    if (tags != null) body['tags'] = tags;
    if (youtubeUrl != null) body['youtube_url'] = youtubeUrl;

    return await ApiService.post(
      ApiConfig.registerEndpoint,
      body: body,
      requireAuth: false, // No auth header needed for registration
    );
  }

  // Handle registration flow
  static Future<RegistrationResult> handleRegistration({
    required String idToken,
    required String fullName,
    required UserRole userRole,
    required DateTime dateOfBirth,
    String? youtubeUrl,
    String? description,
    String? tags,
    bool isTestMode = false,
  }) async {
    try {
      // Handle test mode registration
      if (isTestMode || ApiConfig.isTestMode) {
        return await _handleTestRegistration(
          idToken: idToken,
          fullName: fullName,
          userRole: userRole,
          dateOfBirth: dateOfBirth,
          youtubeUrl: youtubeUrl,
          description: description,
          tags: tags,
        );
      }

      // Convert date to API format (YYYY-MM-DD)
      final formattedDate =
          "${dateOfBirth.year.toString().padLeft(4, '0')}-"
          "${dateOfBirth.month.toString().padLeft(2, '0')}-"
          "${dateOfBirth.day.toString().padLeft(2, '0')}";

      // Convert user role to API role
      final apiRole = _mapUserRoleToApiRole(userRole);

      // Convert tags string to list if provided
      List<String>? tagsList;
      if (tags != null && tags.isNotEmpty) {
        tagsList = tags.split(',').map((tag) => tag.trim()).toList();
      }

      // Make registration API call
      final response = await registerUser(
        idToken: idToken,
        fullName: fullName,
        role: apiRole,
        dateOfBirth: formattedDate,
        youtubeUrl: youtubeUrl,
        description: description,
        tags: tagsList,
      );

      if (response.statusCode == 201) {
        // Registration successful - save user data
        final userData = response.data?['data']?['user'];
        if (userData != null) {
          await UserService.updateUserData(userData);
          return RegistrationResult.success(
            userData: userData,
            message:
                response.data?['data']?['message'] ?? 'Registration successful',
          );
        } else {
          return RegistrationResult.error('Invalid response format');
        }
      } else {
        return RegistrationResult.error(
          response.error ?? 'Registration failed',
        );
      }
    } catch (e) {
      return RegistrationResult.error('Registration error: $e');
    }
  }

  // Handle test mode registration
  static Future<RegistrationResult> _handleTestRegistration({
    required String idToken,
    required String fullName,
    required UserRole userRole,
    required DateTime dateOfBirth,
    String? youtubeUrl,
    String? description,
    String? tags,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // Find the test user by token
      final testUser = TestModeConfig.getTestUserByToken(idToken);
      if (testUser == null) {
        return RegistrationResult.error('Invalid test token');
      }

      // Convert user role to API role
      final apiRole = _mapUserRoleToApiRole(userRole);

      // Create mock user data for test mode
      final Map<String, dynamic> mockUserData = {
        'id': testUser.firebaseUid,
        'gmail_id': testUser.email,
        'firebase_uid': testUser.firebaseUid,
        'full_name': fullName,
        'email': testUser.email,
        'role': apiRole,
        'status': 'ACTIVE',
        'user_type': apiRole,
        'date_of_birth':
            "${dateOfBirth.year.toString().padLeft(4, '0')}-"
            "${dateOfBirth.month.toString().padLeft(2, '0')}-"
            "${dateOfBirth.day.toString().padLeft(2, '0')}",
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add caregiver-specific fields if applicable
      if (apiRole == 'caregiver') {
        if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
          mockUserData['youtube_url'] = youtubeUrl;
        }
        if (description != null && description.isNotEmpty) {
          mockUserData['description'] = description;
        }
        if (tags != null && tags.isNotEmpty) {
          // Convert tags string to list
          final tagsList = tags.split(',').map((tag) => tag.trim()).toList();
          mockUserData['tags'] = tagsList;
        }
      }

      // Save user data
      await UserService.updateUserData(mockUserData);

      // Store the test token as ID token for API calls
      await ApiService.storeIdToken(idToken);

      return RegistrationResult.success(
        userData: mockUserData,
        message: 'Test registration successful',
      );
    } catch (e) {
      return RegistrationResult.error('Test registration error: $e');
    }
  }

  // Map UI user roles to API roles
  static String _mapUserRoleToApiRole(UserRole userRole) {
    switch (userRole) {
      case UserRole.seniorCitizen:
        return 'senior_citizen';
      case UserRole.family:
        return 'family_member';
      case UserRole.caregiver:
        return 'caregiver';
    }
  }

  // Parse date from form format (DD / MM / YYYY) to DateTime
  static DateTime? parseDateFromForm(String dateString) {
    try {
      final parts = dateString.split(' / ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// User roles enum to match the registration form
enum UserRole { seniorCitizen, family, caregiver }

// Registration result class
class RegistrationResult {
  final RegistrationResultType type;
  final Map<String, dynamic>? userData;
  final String? error;
  final String? message;

  RegistrationResult._({
    required this.type,
    this.userData,
    this.error,
    this.message,
  });

  factory RegistrationResult.success({
    required Map<String, dynamic> userData,
    String? message,
  }) {
    return RegistrationResult._(
      type: RegistrationResultType.success,
      userData: userData,
      message: message,
    );
  }

  factory RegistrationResult.error(String error) {
    return RegistrationResult._(
      type: RegistrationResultType.error,
      error: error,
    );
  }

  bool get isSuccess => type == RegistrationResultType.success;
  bool get hasError => type == RegistrationResultType.error;
}

enum RegistrationResultType { success, error }
