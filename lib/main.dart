import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/auth/providers/auth_provider.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:workout_prediction_system_mobile/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
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
            '/': (context) => _buildHomeWidget(context, ref),
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }

  Widget _buildHomeWidget(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // If checking auth state
    if (authState.status == AuthStatus.initial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If authenticated, show home screen
    if (authState.isAuthenticated) {
      return const HomeScreen();
    }

    // Otherwise show onboarding or login
    // For development, you can directly show the login page
    return const LoginPage();
    // return const OnboardingScreen(); // Enable this for production
  }
}
