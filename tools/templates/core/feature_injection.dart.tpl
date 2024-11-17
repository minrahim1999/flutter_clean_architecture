  // Features - Feature
  // Bloc
  sl.registerFactory(
    () => FeatureBloc(
      getFeatures: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFeaturesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FeatureRepository>(
    () => FeatureRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<FeatureRemoteDataSource>(
    () => FeatureRemoteDataSourceImpl(
      apiService: sl(),
    ),
  );

  sl.registerLazySingleton<FeatureLocalDataSource>(
    () => FeatureLocalDataSourceImpl(
      databaseService: sl(),
    ),
  );
