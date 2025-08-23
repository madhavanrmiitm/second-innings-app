import 'test_mode_config.dart';

class ApiConfig {
  // Authentication endpoints
  static const String verifyTokenEndpoint = '/api/auth/verify-token';
  static const String registerEndpoint = '/api/auth/register';
  static const String profileEndpoint = '/api/user/profile';

  // Task endpoints
  static const String tasksEndpoint = '/api/tasks';
  static const String remindersEndpoint = '/api/reminders';

  // Care endpoints
  static const String caregiversEndpoint = '/api/caregivers';
  static const String careRequestsEndpoint = '/api/care-requests';

  // Family endpoints
  static const String familyMembersEndpoint =
      '/api/senior-citizens/me/family-members';
  static const String linkedSeniorCitizensEndpoint =
      '/api/family-members/me/linked-senior-citizens';
  static const String linkSeniorCitizenEndpoint =
      '/api/family-members/me/link-senior-citizen';

  // Interest Group endpoints
  static const String interestGroupsEndpoint = '/api/interest-groups';

  // Ticket endpoints
  static const String ticketsEndpoint = '/api/tickets';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  // API version (if needed)
  static const String apiVersion = 'v1';

  // Environment-specific configurations
  static const bool isDevelopment = false; // Set to false for production

  // Development vs Production URLs
  static String get developmentUrl =>
      'http://127.0.0.1:8000'; // Your local development server
  static String get productionUrl =>
      'https://second-innings-iitm-249726620429.asia-south1.run.app'; // Your production server

  // Get the appropriate base URL based on environment
  static String get currentBaseUrl {
    return isDevelopment ? developmentUrl : productionUrl;
  }

  // Check if test mode is enabled
  static bool get isTestMode => TestModeConfig.isTestMode;
}
