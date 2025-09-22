

// lib/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import '../services/recommendation_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final _avgScoreCtrl = TextEditingController();
  final _timeSpentCtrl = TextEditingController();
  final _engagementCtrl = TextEditingController();
  String _contentType = 'Video';
  bool _loading = false;
  List<String> _recs = [];

  @override
  void dispose() {
    _avgScoreCtrl.dispose();
    _timeSpentCtrl.dispose();
    _engagementCtrl.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    final quiz = int.tryParse(_avgScoreCtrl.text) ?? 75;
    final time = int.tryParse(_timeSpentCtrl.text) ?? 30;
    final engagement = int.tryParse(_engagementCtrl.text) ?? 3;

    setState(() {
      _loading = true;
      _recs.clear();
    });

    try {
      final Map<String, dynamic> res = await RecommendationService.getRecommendation(
        quizScore: quiz,
        timeSpent: time,
        contentType: _contentType,
        engagement: engagement,
      );

      final rec = res['recommendation'];
      _recs = rec is List ? List<String>.from(rec) : [rec.toString()];
    } catch (e) {
      _recs = ['Error: $e'];
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommended Pathway')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _avgScoreCtrl,
              decoration: const InputDecoration(
                labelText: 'Average Quiz Score (0–100)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _timeSpentCtrl,
              decoration: const InputDecoration(
                labelText: 'Average Time Spent (min)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Text('Content Type Preference'),
            DropdownButton<String>(
              value: _contentType,
              isExpanded: true,
              items: const ['Video', 'Text', 'Quiz']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (String? v) {
                setState(() => _contentType = v ?? 'Video');
              },
            ),
            TextField(
              controller: _engagementCtrl,
              decoration: const InputDecoration(
                labelText: 'Topic Engagement (1–5)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _getRecommendations,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get Recommendation'),
            ),
            const SizedBox(height: 16),
            ..._recs.map(
              (r) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(title: Text(r)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learning'),
              child: const Text('Start Learning'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/feedback'),
              child: const Text('Give Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}