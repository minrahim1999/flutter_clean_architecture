part of 'connection_bloc.dart';

abstract class ConnectionEvent {}

class ConnectionStarted extends ConnectionEvent {}

class ConnectionStatusChanged extends ConnectionEvent {
  final bool isConnected;

  ConnectionStatusChanged({required this.isConnected});
}
