import 'package:dio/dio.dart';

class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final int? statusCode;
  final bool isSuccess;
  final DioException? error;

  ApiResponse._({
    this.data,
    this.errorMessage,
    this.statusCode,
    required this.isSuccess,
    this.error,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(
      data: data,
      isSuccess: true,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(DioException error) {
    return ApiResponse._(
      errorMessage: _getErrorMessage(error),
      statusCode: error.response?.statusCode,
      isSuccess: false,
      error: error,
    );
  }

  static String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badResponse:
        return error.response?.data['message'] ?? 'Server error occurred.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        if (error.error != null && error.error.toString().contains('SocketException')) {
          return 'No internet connection.';
        }
        return 'An unexpected error occurred.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
