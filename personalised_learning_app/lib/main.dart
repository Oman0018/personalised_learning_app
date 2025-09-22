// 📁 personalised_learning_app/lib/main.dart
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/diagnostic_quiz_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/learning_module_screen.dart';
import 'screens/feedback_form_screen.dart';
import 'screens/loop_view_screen.dart';

// Read the API_BASE_URL passed with --dart-define
import 'config/app_config.dart'; // defines: const String kBaseUrl

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Prints once at startup so we can confirm the define actually arrived.
  debugPrint('API_BASE_URL define: $kBaseUrl');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personalised Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/quiz': (context) => const DiagnosticQuizScreen(),
        '/recommendations': (context) => const RecommendationsScreen(),
        '/learning': (context) => const LearningModuleScreen(),
        '/feedback': (context) => const FeedbackFormScreen(),
        '/loop': (context) => const LoopViewScreen(),
      },
    );
  }
}
