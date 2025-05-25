import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_prediction_system_mobile/features/auth/providers/auth_provider.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading indicator while initial auth check is happening
    if (authState.status == AuthStatus.initial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate based on auth state
    if (authState.isAuthenticated) {
      return const HomeScreen();
    }

    // Default to login page
    return const LoginPage();
  }
}
