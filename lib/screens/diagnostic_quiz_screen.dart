// 📁 lib/screens/diagnostic_quiz_screen.dart
import 'package:flutter/material.dart';
import '../state/quiz_data.dart';

class DiagnosticQuizScreen extends StatefulWidget {
  const DiagnosticQuizScreen({super.key});

  @override
  State<DiagnosticQuizScreen> createState() => _DiagnosticQuizScreenState();
}

class _DiagnosticQuizScreenState extends State<DiagnosticQuizScreen> {
  String? selectedStyle;
  double skillLevel = 5;
  List<String> interests = [];

  final List<String> learningStyles = ['Visual', 'Auditory', 'Kinesthetic'];
  final List<String> topics = [
    'AI',
    'Web Development',
    'Data Science',
    'Cybersecurity',
  ];

  void toggleInterest(String topic) {
    setState(() {
      interests.contains(topic)
          ? interests.remove(topic)
          : interests.add(topic);
    });
  }

  void submitQuiz() {
    final quizData = QuizResults();
    quizData.learningStyle = selectedStyle;
    quizData.skillLevel = skillLevel;
    quizData.interests = interests;

    //print(quizData); // Optional debug print
    debugPrint(quizData.toString()); // Optional debug print

    Navigator.pushNamed(context, '/recommendations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Preferred Learning Style',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedStyle,
              hint: const Text('Select learning style'),
              onChanged: (value) {
                setState(() => selectedStyle = value);
              },
              items:
                  learningStyles
                      .map(
                        (style) => DropdownMenuItem<String>(
                          value: style,
                          child: Text(style),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Skill Level: ${skillLevel.toInt()}',
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: skillLevel,
              min: 1,
              max: 10,
              divisions: 9,
              label: skillLevel.round().toString(),
              onChanged: (value) {
                setState(() => skillLevel = value);
              },
            ),
            const SizedBox(height: 20),
            const Text('Areas of Interest', style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8.0,
              children:
                  topics.map((topic) {
                    return FilterChip(
                      label: Text(topic),
                      selected: interests.contains(topic),
                      onSelected: (_) => toggleInterest(topic),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: submitQuiz,
              child: const Text('Generate My Pathway'),
            ),
          ],
        ),
      ),
    );
  }
}
