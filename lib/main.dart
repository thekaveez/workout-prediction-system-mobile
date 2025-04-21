import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_event.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_state.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:workout_prediction_system_mobile/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create:
            (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(const AuthCheckRequested()),
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'AI Workout Prediction System',
              theme: ThemeData(
                colorScheme: ColorScheme.dark(
                  surface: const Color(0xFF001612),
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  secondary: const Color(0xFF63F2C5),
                  onSecondary: const Color(0xFF21D07A),
                  error: const Color(0xFFE63946),
                ),
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Color.fromARGB(255, 99, 173, 242),
                  selectionColor: Color.fromARGB(255, 99, 173, 242),
                  selectionHandleColor: Color.fromARGB(255, 99, 173, 242),
                ),
              ),
              initialRoute: '/',
              routes: {
                '/': (context) => _buildHomeWidget(context),
                '/login': (context) => const LoginPage(),
                '/home': (context) => const HomeScreen(),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeWidget(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // If checking auth state
        if (state.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If authenticated, show home screen
        if (state.isAuthenticated) {
          return const HomeScreen();
        }

        // Otherwise show onboarding or login
        // For development, you can directly show the login page
        return const LoginPage();
        // return const OnboardingScreen(); // Enable this for production
      },
    );
  }
}
