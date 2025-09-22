// lib/screens/feedback_form_screen.dart
import 'package:flutter/material.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key}); // ✅ Added key

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  double rating = 3.0;
  String feedback = '';
  bool tooEasy = false;
  bool tooDifficult = false;

  void submitFeedback() {
    debugPrint('Rating: $rating');
    debugPrint('Feedback: $feedback');
    debugPrint('Too Easy: $tooEasy, Too Difficult: $tooDifficult');

    // Navigate to loop screen
    Navigator.pushNamed(context, '/loop');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Module Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text('Rate this module', style: TextStyle(fontSize: 18)),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.round().toString(),
              onChanged: (value) {
                setState(() => rating = value);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your comments...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                feedback = value;
              },
            ),
            const SizedBox(height: 20),
            const Text('Module Difficulty'),
            CheckboxListTile(
              title: const Text('Too Easy'),
              value: tooEasy,
              onChanged: (val) {
                setState(() {
                  tooEasy = val ?? false;
                  if (tooEasy) tooDifficult = false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Too Difficult'),
              value: tooDifficult,
              onChanged: (val) {
                setState(() {
                  tooDifficult = val ?? false;
                  if (tooDifficult) tooEasy = false;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
