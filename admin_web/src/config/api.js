export class ApiConfig {
  // API endpoints
  static get verifyTokenEndpoint() {
    return '/api/auth/verify-token'
  }
  static get registerEndpoint() {
    return '/api/auth/register'
  }
  static get profileEndpoint() {
    return '/api/user/profile'
  }

  // Request timeout
  static get requestTimeout() {
    return 30000
  } // 30 seconds

  // API version (if needed)
  static get apiVersion() {
    return 'v1'
  }

  // Environment-specific configurations
  static get isDevelopment() {
    return import.meta.env.DEV || false
  }

  // Development vs Production URLs
  static get developmentUrl() {
    return import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'
  }

  static get productionUrl() {
    return 'https://second-innings-iitm-249726620429.asia-south1.run.app'
  }

  // Get the appropriate base URL based on environment
  static get currentBaseUrl() {
    return this.isDevelopment ? this.developmentUrl : this.productionUrl
  }
}
