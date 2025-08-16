import axios from 'axios'
import { ApiResponse } from '@/utils/apiResponse'
import { ApiConfig } from '@/config/api'
import { FirebaseAuthService } from '@/services/firebaseAuth'

// Create axios instance with interceptors
const axiosInstance = axios.create({
  baseURL: ApiConfig.currentBaseUrl,
  timeout: ApiConfig.requestTimeout,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  }
})

// Request interceptor to add auth token
axiosInstance.interceptors.request.use(
  async (config) => {
    // Check for test token first
    const testToken = localStorage.getItem('testToken')
    if (testToken) {
      config.headers['Authorization'] = `Bearer ${testToken}`
      return config
    }
    
    // Otherwise use Firebase token
    try {
      const idToken = await FirebaseAuthService.getCurrentUserIdToken()
      if (idToken) {
        config.headers['Authorization'] = `Bearer ${idToken}`
      }
    } catch (error) {
      console.error('Failed to get auth token:', error)
    }
    
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor for 401 handling
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    // Don't automatically clear session on 401 - let the app handle it
    // This prevents premature logout during page loads
    if (error.response?.status === 401) {
      console.warn('401 Unauthorized received:', error.config?.url)
    }
    return Promise.reject(error)
  }
)

export class ApiService {
  static get baseUrl() {
    return ApiConfig.currentBaseUrl
  }

  static get timeout() {
    return ApiConfig.requestTimeout
  }

  // Default headers for all requests
  static get _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    }
  }

  // GET Request
  static async get(endpoint, { headers = {}, queryParams = {} } = {}) {
    try {
      const url = new URL(endpoint, this.baseUrl)

      // Add query parameters
      Object.keys(queryParams).forEach((key) => {
        if (queryParams[key] !== null && queryParams[key] !== undefined) {
          url.searchParams.append(key, queryParams[key])
        }
      })

      // Changed: axios.get → axiosInstance.get
      const response = await axiosInstance.get(url.toString(), {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      })

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

  // POST Request
  static async post(endpoint, { body = null, headers = {} } = {}) {
    try {
      // Changed: axios.post → axiosInstance.post
      const response = await axiosInstance.post(`${this.baseUrl}${endpoint}`, body, {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      })

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

  // PUT Request
  static async put(endpoint, { body = null, headers = {} } = {}) {
    try {
      // Changed: axios.put → axiosInstance.put
      const response = await axiosInstance.put(`${this.baseUrl}${endpoint}`, body, {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      })

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

  // DELETE Request
  static async delete(endpoint, { headers = {}, body = null } = {}) {
    try {
      const config = {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      }

      // Add data if body is provided
      if (body) {
        config.data = body
      }

      // Changed: axios.delete → axiosInstance.delete
      const response = await axiosInstance.delete(`${this.baseUrl}${endpoint}`, config)

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

  // Handle HTTP Response
  static _handleResponse(response) {
    const { status: statusCode, data } = response

    switch (statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        return ApiResponse.success({
          statusCode,
          data,
          message: data?.message,
        })

      case 400:
        return ApiResponse.error({
          statusCode,
          error: data?.error || data?.message || 'Bad Request',
        })

      case 401:
        return ApiResponse.error({
          statusCode,
          error: data?.error || data?.message || 'Unauthorized',
        })

      case 403:
        return ApiResponse.error({
          statusCode,
          error: data?.error || data?.message || 'Forbidden',
        })

      case 404:
        return ApiResponse.error({
          statusCode,
          error: data?.error || data?.message || 'Not Found',
        })

      case 422:
        // Handle validation errors with detailed messages
        let validationError = 'Validation failed'
        if (data?.data && Array.isArray(data.data)) {
          // Format Pydantic validation errors
          const errors = data.data.map(err => `${err.loc?.join('.')} ${err.msg}`).join(', ')
          validationError = `Validation errors: ${errors}`
        } else if (data?.message) {
          validationError = data.message
        }
        return ApiResponse.error({
          statusCode,
          error: validationError,
        })

      case 500:
        return ApiResponse.error({
          statusCode,
          error: data?.error || data?.message || 'Internal Server Error',
        })

      case 502:
        return ApiResponse.error({
          statusCode,
          error: 'Bad Gateway',
        })

      case 503:
        return ApiResponse.error({
          statusCode,
          error: 'Service Unavailable',
        })

      default:
        return ApiResponse.error({
          statusCode,
          error: data?.error || data?.message || 'Unknown error occurred',
        })
    }
  }

  // Handle Errors (Network, Timeout, etc.)
  static _handleError(error) {
    if (error.response) {
      // Server responded with error status
      return this._handleResponse(error.response)
    } else if (error.request) {
      // Network error
      if (error.code === 'NETWORK_ERROR' || error.message.includes('Network Error')) {
        return ApiResponse.error({
          statusCode: 0,
          error: 'No internet connection',
        })
      } else if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
        return ApiResponse.error({
          statusCode: 0,
          error: 'Request timeout',
        })
      } else {
        return ApiResponse.error({
          statusCode: 0,
          error: 'Network error occurred',
        })
      }
    } else {
      // Something else happened
      return ApiResponse.error({
        statusCode: 0,
        error: `An unexpected error occurred: ${error.message}`,
      })
    }
  }
}