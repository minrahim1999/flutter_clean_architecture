import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
import '../../features/chambers/presentation/pages/chambers_page.dart';
import '../../features/chambers/presentation/pages/create_chamber_page.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Add routes here
    ],
    redirect: (context, state) {
      // Add global redirect logic here if needed
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
