import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final InternetConnectionChecker connectionChecker;
  StreamSubscription<bool>? _connectionSubscription;

  ConnectionBloc({required this.connectionChecker})
      : super(ConnectionInitial()) {
    on<ConnectionStarted>(_onConnectionStarted);
    on<ConnectionStatusChanged>(_onConnectionStatusChanged);
  }

  Future<void> _onConnectionStarted(
    ConnectionStarted event,
    Emitter<ConnectionState> emit,
  ) async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = connectionChecker.onStatusChange.listen(
      (status) => add(ConnectionStatusChanged(
        isConnected: status == InternetConnectionStatus.connected,
      )),
    ) as StreamSubscription<bool>?;

    final isConnected = await connectionChecker.hasConnection;
    emit(isConnected ? ConnectionConnected() : ConnectionDisconnected());
  }

  void _onConnectionStatusChanged(
    ConnectionStatusChanged event,
    Emitter<ConnectionState> emit,
  ) {
    event.isConnected
        ? emit(ConnectionConnected())
        : emit(ConnectionDisconnected());
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    return super.close();
  }
}
