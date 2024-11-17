import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  final int? code;

  const Failure({this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({String? message, int? code})
      : super(message: message ?? 'Server Error', code: code);
}

class CacheFailure extends Failure {
  const CacheFailure({String? message, int? code})
      : super(message: message ?? 'Cache Error', code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String? message, int? code})
      : super(message: message ?? 'Network Error', code: code);
}
