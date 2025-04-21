import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';
import 'package:workout_prediction_system_mobile/features/profile/bloc/profile_bloc.dart';
import 'package:workout_prediction_system_mobile/features/profile/bloc/profile_event.dart';

class ProfileProvider extends StatelessWidget {
  final Widget child;

  const ProfileProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final currentUser = authBloc.state.user;

    return BlocProvider(
      create: (context) {
        final profileBloc = ProfileBloc(authRepository: authRepository);

        // Load profile data if user is authenticated
        if (currentUser != null) {
          profileBloc.add(ProfileLoadRequested(userId: currentUser.id));
        }

        return profileBloc;
      },
      child: child,
    );
  }
}
