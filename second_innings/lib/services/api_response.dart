class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? message;
  final String? error;
  final bool isSuccess;

  ApiResponse({required this.statusCode, this.data, this.message, this.error})
    : isSuccess = statusCode >= 200 && statusCode < 300;

  factory ApiResponse.success({
    required int statusCode,
    T? data,
    String? message,
  }) {
    return ApiResponse<T>(statusCode: statusCode, data: data, message: message);
  }

  factory ApiResponse.error({
    required int statusCode,
    String? error,
    String? message,
  }) {
    return ApiResponse<T>(
      statusCode: statusCode,
      error: error ?? message,
      message: message,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, isSuccess: $isSuccess, data: $data, error: $error)';
  }
}
