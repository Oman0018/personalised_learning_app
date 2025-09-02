// lib/screens/hub_screen.dart
import 'package:flutter/material.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bigBtn(
      String label,
      VoidCallback onTap, {
      IconData icon = Icons.play_arrow,
    }) {
      return SizedBox(
        width: 280,
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 22),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          onPressed: onTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Personalised Learning – Hub')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose a path to begin',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              bigBtn(
                'Start Diagnostic → Quiz',
                () => Navigator.pushNamed(context, '/diagnostic'),
                icon: Icons.quiz,
              ),
              const SizedBox(height: 12),
              bigBtn(
                'Recommendations',
                () => Navigator.pushNamed(context, '/recommendations'),
                icon: Icons.recommend,
              ),
              const SizedBox(height: 12),
              bigBtn(
                'Learning Module',
                () => Navigator.pushNamed(context, '/learning'),
                icon: Icons.menu_book,
              ),
              const SizedBox(height: 12),
              bigBtn(
                'Feedback Form',
                () => Navigator.pushNamed(context, '/feedback'),
                icon: Icons.feedback,
              ),
              const SizedBox(height: 12),
              bigBtn(
                'Loop View (Updated Recommendations)',
                () => Navigator.pushNamed(context, '/loopview'),
                icon: Icons.loop,
              ),
              const SizedBox(height: 24),
              // Optional: quick path, if you still want it visible on Hub
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/quick_reco'),
                child: const Text('Quick Recommendation (Skip Quiz)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
