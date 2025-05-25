import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/core/services/notification_service.dart';
import 'package:workout_prediction_system_mobile/features/auth/providers/auth_provider.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/auth_wrapper.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/exercise_screen.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/features/meal_prediction/screens/meal_prediction_screen.dart';
import 'package:workout_prediction_system_mobile/features/notifications/screens/notification_settings_screen.dart';
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

  // Initialize notification service
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize();

  runApp(ProviderScope(parent: container, child: const MyApp()));
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
              cursorColor: Color(0xFF63F2C5),
              selectionColor: Color(0xFF63F2C5),
              selectionHandleColor: Color(0xFF63F2C5),
            ),
          ),
          home: const AuthWrapper(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginPage(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/user-setup': (context) => const UserSetupScreen(),
            '/exercise': (context) => const ExerciseScreen(),
            '/meal-prediction': (context) => const MealPredictionScreen(),
            '/progress-tracking': (context) => const ProgressTrackingScreen(),
            '/workout-recorder': (context) => const WorkoutRecorderScreen(),
            '/notification-settings':
                (context) => const NotificationSettingsScreen(),
          },
        );
      },
    );
  }
}
