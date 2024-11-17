class ServerException implements Exception {
  final String? message;
  final int? code;

  ServerException({this.message, this.code});
}

class CacheException implements Exception {
  final String? message;
  final int? code;

  CacheException({this.message, this.code});
}

class NetworkException implements Exception {
  final String? message;
  final int? code;

  NetworkException({this.message, this.code});
}
