export class ApiResponse {
  constructor({ statusCode, data = null, message = null, error = null }) {
    this.statusCode = statusCode
    this.data = data
    this.message = message
    this.error = error
    this.isSuccess = statusCode >= 200 && statusCode < 300
  }

  static success({ statusCode, data = null, message = null }) {
    return new ApiResponse({ statusCode, data, message })
  }

  static error({ statusCode, error = null, message = null }) {
    return new ApiResponse({
      statusCode,
      error: error || message,
      message,
    })
  }

  toString() {
    return `ApiResponse(statusCode: ${this.statusCode}, isSuccess: ${this.isSuccess}, data: ${this.data}, error: ${this.error})`
  }
}
