import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/auth/providers/auth_provider.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/exercise_screen.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/features/meal_prediction/screens/meal_prediction_screen.dart';
import 'package:workout_prediction_system_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:workout_prediction_system_mobile/features/progress/screens/progress_tracking_screen.dart';
import 'package:workout_prediction_system_mobile/features/progress/screens/workout_recorder_screen.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/providers/user_setup_provider.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/screens/user_setup_screen.dart';
import 'package:workout_prediction_system_mobile/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Schedule user setup data loading after the widget tree is built
    Future.microtask(() {
      ref.read(userSetupProvider.notifier).loadUserSetupData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            '/': (context) => _buildHomeWidget(ref),
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomeScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/user_setup': (context) => const UserSetupScreen(),
            '/meal_prediction': (context) => const MealPredictionScreen(),
            '/exercise': (context) => const ExerciseScreen(),
            '/progress': (context) => const ProgressTrackingScreen(),
            '/workout_recorder': (context) => const WorkoutRecorderScreen(),
          },
        );
      },
    );
  }

  Widget _buildHomeWidget(WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasCompletedSetup = ref.watch(hasCompletedSetupProvider);

    // If checking auth state
    if (authState.status == AuthStatus.initial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If authenticated, check if profile setup is needed
    if (authState.isAuthenticated) {
      // Check if user needs to complete setup
      if (!hasCompletedSetup) {
        return const UserSetupScreen();
      }

      return const HomeScreen();
    }

    // Otherwise show onboarding or login
    // For development, you can directly show the login page
    return const LoginPage();
    // return const OnboardingScreen(); // Enable this for production
  }
}
