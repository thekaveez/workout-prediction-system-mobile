import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_prediction_system_mobile/features/auth/models/user_model.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';

part 'auth_provider.g.dart';

// Auth state definition
enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

// Auth state class
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isConnected;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isConnected = true,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      user: null,
      errorMessage: null,
      isConnected: true,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isConnected,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isAuthenticating => status == AuthStatus.authenticating;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;
}

// Repository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

// Connectivity provider
@riverpod
Stream<ConnectivityResult> connectivity(Ref ref) {
  final connectivity = Connectivity();

  // Create a stream controller to emit initial and subsequent connectivity changes
  final controller = StreamController<ConnectivityResult>();

  // Check connectivity immediately and add to stream
  connectivity.checkConnectivity().then((result) {
    controller.add(result);
  });

  // Listen to connectivity changes
  final subscription = connectivity.onConnectivityChanged.listen((result) {
    controller.add(result);
  });

  // Clean up when the provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
}

// Auth provider
@riverpod
class Auth extends _$Auth {
  late StreamSubscription<User?> _authSubscription;

  @override
  AuthState build() {
    ref.onDispose(() {
      _authSubscription.cancel();
    });

    final repository = ref.watch(authRepositoryProvider);

    // Watch connectivity changes
    ref.listen<AsyncValue<ConnectivityResult>>(connectivityProvider, (
      previous,
      next,
    ) {
      next.whenData((result) {
        final isConnected = result != ConnectivityResult.none;
        state = state.copyWith(isConnected: isConnected);
      });
    });

    // Initialize auth state listener
    _authSubscription = repository.authStateChanges.listen(_handleAuthChange);

    // Check current auth state
    _checkAuthStatus();

    return AuthState.initial();
  }

  void _handleAuthChange(User? user) async {
    if (user != null) {
      try {
        final userData = await ref
            .read(authRepositoryProvider)
            .getUserData(user.uid);
        if (userData != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: userData,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } catch (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    }
  }

  Future<void> _checkAuthStatus() async {
    final repository = ref.read(authRepositoryProvider);
    final currentUser = repository.currentUser;

    if (currentUser != null) {
      try {
        final userData = await repository.getUserData(currentUser.uid);
        if (userData != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: userData,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } catch (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (!state.isConnected) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No internet connection',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.authenticating);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signIn(email: email, password: password);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!state.isConnected) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No internet connection',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.authenticating);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    // First update UI state immediately
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
