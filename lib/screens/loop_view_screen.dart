// lib/screens/loop_view_screen.dart
import 'package:flutter/material.dart';

class LoopViewScreen extends StatelessWidget {
  const LoopViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> updatedRecommendations = [
      "Advanced Python Projects",
      "AI Ethics and Explainability",
      "Data Science Capstone"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updated Learning Paths'),
      ),
      body: ListView.builder(
        itemCount: updatedRecommendations.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(updatedRecommendations[index]),
              subtitle: const Text('Recommended after your feedback'),
              trailing: const Icon(Icons.replay_circle_filled_outlined),
              onTap: () {
                // Navigate to the learning module screen
                Navigator.pushNamed(context, '/learning');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        icon: const Icon(Icons.home),
        label: const Text('Back to Home'),
      ),
    );
  }
}
