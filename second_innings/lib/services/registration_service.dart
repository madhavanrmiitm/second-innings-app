import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';
import 'user_service.dart';

class RegistrationService {
  // Register user with backend
  static Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String idToken,
    required String fullName,
    required String role,
    required String dateOfBirth,
    String? youtubeUrl,
    String? description,
    String? tags,
  }) async {
    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'id_token': idToken,
      'full_name': fullName,
      'role': role,
      'date_of_birth': dateOfBirth,
    };

    // Add optional fields for caregivers
    if (role == 'caregiver') {
      if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
        requestBody['youtube_url'] = youtubeUrl;
      }
      if (description != null && description.isNotEmpty) {
        requestBody['description'] = description;
      }
      if (tags != null && tags.isNotEmpty) {
        requestBody['tags'] = tags;
      }
    }

    return await ApiService.post(ApiConfig.registerEndpoint, body: requestBody);
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
  }) async {
    try {
      // Convert date to API format (YYYY-MM-DD)
      final formattedDate =
          "${dateOfBirth.year.toString().padLeft(4, '0')}-"
          "${dateOfBirth.month.toString().padLeft(2, '0')}-"
          "${dateOfBirth.day.toString().padLeft(2, '0')}";

      // Convert user role to API role
      final apiRole = _mapUserRoleToApiRole(userRole);

      // Make registration API call
      final response = await registerUser(
        idToken: idToken,
        fullName: fullName,
        role: apiRole,
        dateOfBirth: formattedDate,
        youtubeUrl: youtubeUrl,
        description: description,
        tags: tags,
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
