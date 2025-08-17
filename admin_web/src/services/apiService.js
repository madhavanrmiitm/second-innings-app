import axios from 'axios'
import { ApiResponse } from '@/utils/apiResponse'
import { ApiConfig } from '@/config/api'
import { FirebaseAuthService } from '@/services/firebaseAuth'

const axiosInstance = axios.create({
  baseURL: ApiConfig.currentBaseUrl,
  timeout: ApiConfig.requestTimeout,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  }
})

axiosInstance.interceptors.request.use(
  async (config) => {
    const testToken = localStorage.getItem('testToken')
    if (testToken) {
      config.headers['Authorization'] = `Bearer ${testToken}`
      return config
    }
    
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

axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
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

  static get _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    }
  }

  static async get(endpoint, { headers = {}, queryParams = {} } = {}) {
    try {
      const url = new URL(endpoint, this.baseUrl)

      Object.keys(queryParams).forEach((key) => {
        if (queryParams[key] !== null && queryParams[key] !== undefined) {
          url.searchParams.append(key, queryParams[key])
        }
      })

      const response = await axiosInstance.get(url.toString(), {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      })

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

  static async post(endpoint, { body = null, headers = {} } = {}) {
    try {
      const response = await axiosInstance.post(`${this.baseUrl}${endpoint}`, body, {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      })

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

  static async put(endpoint, { body = null, headers = {} } = {}) {
    try {
      const response = await axiosInstance.put(`${this.baseUrl}${endpoint}`, body, {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      })

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

  static async delete(endpoint, { headers = {}, body = null } = {}) {
    try {
      const config = {
        headers: { ...this._defaultHeaders, ...headers },
        timeout: this.timeout,
      }

      if (body) {
        config.data = body
      }

      const response = await axiosInstance.delete(`${this.baseUrl}${endpoint}`, config)

      return this._handleResponse(response)
    } catch (error) {
      return this._handleError(error)
    }
  }

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
        let validationError = 'Validation failed'
        if (data?.data && Array.isArray(data.data)) {
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

  static _handleError(error) {
    if (error.response) {
      return this._handleResponse(error.response)
    } else if (error.request) {
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