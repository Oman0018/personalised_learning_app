// lib/screens/get_recommendation_screen.dart
import 'package:flutter/material.dart';

class GetRecommendationScreen extends StatefulWidget {
  const GetRecommendationScreen({super.key});

  @override
  State<GetRecommendationScreen> createState() =>
      _GetRecommendationScreenState();
}

class _GetRecommendationScreenState extends State<GetRecommendationScreen> {
  // NOTE: wire to your real form fields / controllers

  final _formKey = GlobalKey<FormState>();

  void _onStartPressed() {
    // Validate/save form, then navigate. Adjust the route to your flow.
    if (_formKey.currentState?.validate() ?? true) {
      Navigator.pushNamed(context, '/recommendations'); // or '/learning'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get Recommendation')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ------- Example placeholder fields (remove/replace as needed) ------
                    const Text(
                      'Provide a few details (optional):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Interest Area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Level',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'beginner',
                          child: Text('Beginner'),
                        ),
                        DropdownMenuItem(
                          value: 'intermediate',
                          child: Text('Intermediate'),
                        ),
                        DropdownMenuItem(
                          value: 'advanced',
                          child: Text('Advanced'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 24),
                    // -------------------------------------------------------------------
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onStartPressed,
                  child: const Text('Start'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
