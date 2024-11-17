part of 'connection_bloc.dart';

abstract class ConnectionState {}

class ConnectionInitial extends ConnectionState {}

class ConnectionConnected extends ConnectionState {}

class ConnectionDisconnected extends ConnectionState {}
