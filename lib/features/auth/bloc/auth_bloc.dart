import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_event.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_state.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final Connectivity _connectivity;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required AuthRepository authRepository, Connectivity? connectivity})
    : _authRepository = authRepository,
      _connectivity = connectivity ?? Connectivity(),
      super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);

    // Initialize connectivity listener
    _initConnectivity();

    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(userId: user?.uid));
    });
  }

  // Initialize connectivity listener
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionState(result);

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionState,
      );
    } catch (_) {
      // Handle connectivity check error
    }
  }

  void _updateConnectionState(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    emit(state.copyWith(isConnected: isConnected));
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _authRepository.currentUser;

    if (currentUser != null) {
      try {
        final userData = await _authRepository.getUserData(currentUser.uid);
        if (userData != null) {
          emit(
            state.copyWith(status: AuthStatus.authenticated, user: userData),
          );
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      } catch (_) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.isConnected) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'No internet connection',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.authenticating));

    try {
      final user = await _authRepository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.isConnected) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'No internet connection',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.authenticating));

    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // First emit unauthenticated state immediately to update UI
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));

    try {
      // Then perform the actual sign out
      await _authRepository.signOut();
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.userId != null) {
      final userData = await _authRepository.getUserData(event.userId!);
      if (userData != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: userData));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
