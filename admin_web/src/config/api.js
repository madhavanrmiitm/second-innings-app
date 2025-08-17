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

  static get requestTimeout() {
    return 30000
  } // 30 seconds

  static get apiVersion() {
    return 'v1'
  }

  static get isDevelopment() {
    return import.meta.env.DEV || false
  }

  static get developmentUrl() {
    return import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'
  }

  static get productionUrl() {
    return 'https://second-innings-iitm-249726620429.asia-south1.run.app'
  }

  static get currentBaseUrl() {
    return this.isDevelopment ? this.developmentUrl : this.productionUrl
  }
}
