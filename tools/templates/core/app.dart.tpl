import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/bloc/connection/connection_bloc.dart';
import 'core/di/injection_container.dart' as di;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Core BLoCs
        BlocProvider<ConnectionBloc>(
          create: (context) => di.sl<ConnectionBloc>(),
        ),
        // Feature BLoCs
      ],
      child: MaterialApp.router(
        title: AppConfig.instance.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: AppConfig.instance.themeMode,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: !AppConfig.isProduction,
      ),
    );
  }
}
