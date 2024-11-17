import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../bloc/auth/auth_bloc.dart';

enum NavigationItem {
  home,
  members,
  chambers,
  events,
  profileOrLogin,
}

extension NavigationItemExtension on NavigationItem {
  String get route {
    switch (this) {
      case NavigationItem.home:
        return '/home';
      case NavigationItem.members:
        return '/members';
      case NavigationItem.chambers:
        return '/chambers';
      case NavigationItem.events:
        return '/events';
      case NavigationItem.profileOrLogin:
        return '/profile';
      default:
        return '/home';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationItem.home:
        return Icons.home_rounded;
      case NavigationItem.members:
        return Icons.people_rounded;
      case NavigationItem.chambers:
        return Icons.business_rounded;
      case NavigationItem.events:
        return Icons.event_rounded;
      case NavigationItem.profileOrLogin:
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  String get label {
    switch (this) {
      case NavigationItem.home:
        return 'Home';
      case NavigationItem.members:
        return 'Members';
      case NavigationItem.chambers:
        return 'Chambers';
      case NavigationItem.events:
        return 'Events';
      case NavigationItem.profileOrLogin:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}

class MainNavigation extends StatelessWidget {
  final Widget child;
  final NavigationItem currentItem;

  const MainNavigation({
    Key? key,
    required this.child,
    required this.currentItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: child,
        floatingActionButton: currentItem == NavigationItem.chambers
            ? FloatingActionButton(
                onPressed: () {
                  context.push('/chambers/create');
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add),
              )
            : null,
        floatingActionButtonLocation: currentItem == NavigationItem.chambers
            ? FloatingActionButtonLocation.centerDocked
            : null,
        bottomNavigationBar: CustomNavBar(
          currentItem: currentItem,
          onTabChange: (item) {
            final route = item == NavigationItem.profileOrLogin &&
                    context.read<AuthBloc>().state is! AuthAuthenticated
                ? '/login'
                : item.route;
            context.go(route);
          },
        ),
      );
  }
}

class CustomNavBar extends StatelessWidget {
  final NavigationItem currentItem;
  final Function(NavigationItem) onTabChange;

  const CustomNavBar({
    Key? key,
    required this.currentItem,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the user is authenticated
    final isAuthenticated = context.read<AuthBloc>().state is AuthAuthenticated;

    // Get navigation items
    final items = NavigationItem.values.map((item) {
      if (item == NavigationItem.profileOrLogin) {
        return isAuthenticated ? Icons.person_rounded : Icons.login_rounded;
      }
      return item.icon;
    }).toList();

    // Get current index
    final currentIndex = NavigationItem.values.indexOf(currentItem);

    return AnimatedBottomNavigationBar(
      icons: items,
      activeIndex: currentIndex,
      gapLocation: currentItem == NavigationItem.chambers
          ? GapLocation.center
          : GapLocation.none,
      notchSmoothness: NotchSmoothness.smoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: (index) => onTabChange(NavigationItem.values[index]),
      activeColor: Theme.of(context).primaryColor,
      inactiveColor: Theme.of(context).unselectedWidgetColor,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8.0,
      splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
      splashRadius: 24,
      iconSize: 24,
    );
  }
}
