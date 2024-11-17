import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/connection/connection_bloc.dart' as conn;
import '../utils/snackbar_utils.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final bool showDonateButton;
  final VoidCallback? onDonatePressed;

  const BaseScreen({
    super.key,
    required this.child,
    this.showDonateButton = true,
    this.onDonatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<conn.ConnectionBloc, conn.ConnectionState>(
          listener: (context, state) {
            if (state is conn.ConnectionDisconnected) {
              showSnackBar(
                context: context,
                message: 'No internet connection',
                isError: true,
              );
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthOtherDeviceLogin) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Session Expired'),
                  content: const Text(
                    'Your account has been logged in from another device.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
      child: Stack(
        children: [
          child,
          if (showDonateButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: onDonatePressed ?? () => _showDonateDialog(context),
                icon: const Icon(Icons.favorite),
                label: const Text('Donate'),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  void _showDonateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donate'),
        content: const Text('Thank you for your support!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
