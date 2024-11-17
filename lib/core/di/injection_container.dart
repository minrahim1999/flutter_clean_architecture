import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../bloc/connection/connection_bloc.dart';
import '../database/database_service.dart';
import '../network/api_service.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker()),
  );
  sl.registerLazySingleton<ApiService>(() => ApiServiceImpl());
  sl.registerLazySingleton<DatabaseService>(() => DatabaseServiceImpl());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  //! Core Blocs
  sl.registerFactory(() => ConnectionBloc(connectionChecker: sl()));

  //! Features
  // Add your feature dependencies here
}
