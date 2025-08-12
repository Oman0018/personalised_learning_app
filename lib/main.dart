// 📁 personalised_learning_app/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/diagnostic_quiz_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/learning_module_screen.dart';
import 'screens/feedback_form_screen.dart';
import 'screens/loop_view_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personalised Learning',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/quiz': (context) => const DiagnosticQuizScreen(),
        '/recommendations':
            (context) => const RecommendationsScreen(), // ✅ Added const
        '/learning': (context) => const LearningModuleScreen(),
        '/feedback': (context) => const FeedbackFormScreen(), // ✅ Added const
        '/loop': (context) => const LoopViewScreen(),
      },
    );
  }
}
