// lib/screens/quick_recommendation_screen.dart
import 'package:flutter/material.dart';

class QuickRecommendationScreen extends StatelessWidget {
  const QuickRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pretend inference/result (replace with your real call later)
    final recommendations = [
      'Intro to Data Science',
      'Flutter Basics',
      'SQL for Beginners',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Recommendation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended Pathway (no quiz):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recommendations.map(
              (r) => ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(r),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/learning'),
                child: const Text('Start Learning Module'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
