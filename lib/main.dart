import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:workout_prediction_system_mobile/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
              surface: Color(0xFF001612),
              primary: Colors.white,
              onPrimary: Colors.black,
              secondary: Color(0xFF63F2C5),
              onSecondary: Color(0xFF21D07A),
              error: Color(0xFFE63946),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Color.fromARGB(255, 99, 173, 242),
              selectionColor: Color.fromARGB(255, 99, 173, 242).withAlpha(100),
              selectionHandleColor: Color.fromARGB(255, 99, 173, 242),
            ),
          ),
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
