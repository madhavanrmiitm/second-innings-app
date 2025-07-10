class ApiConfig {
  // API endpoints
  static const String verifyTokenEndpoint = '/api/auth/verify-token';
  static const String registerEndpoint = '/api/auth/register';
  static const String profileEndpoint = '/api/user/profile';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  // API version (if needed)
  static const String apiVersion = 'v1';

  // Environment-specific configurations
  static const bool isDevelopment = false; // Set to false for production

  // Development vs Production URLs
  static String get developmentUrl =>
      'http://localhost:8000'; // Your local development server
  static String get productionUrl =>
      'https://second-innings-iitm-249726620429.asia-south1.run.app'; // Your production server

  // Get the appropriate base URL based on environment
  static String get currentBaseUrl {
    return isDevelopment ? developmentUrl : productionUrl;
  }
}
