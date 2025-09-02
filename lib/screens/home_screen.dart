// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/recommendation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- existing controllers (kept for Advanced form) ---
  final TextEditingController _quizCtrl = TextEditingController(text: '75');
  final TextEditingController _timeCtrl = TextEditingController(text: '45');
  final TextEditingController _engageCtrl = TextEditingController(text: '4');

  final List<String> _contentTypes = const ['Video', 'Text', 'Interactive'];
  String _selectedContentType = 'Video';

  bool _loading = false;
  List<String> _recs = [];

  Future<void> _submit() async {
    final quiz = int.tryParse(_quizCtrl.text.trim());
    final time = int.tryParse(_timeCtrl.text.trim());
    final engagement = int.tryParse(_engageCtrl.text.trim());

    if (quiz == null || quiz < 0 || quiz > 100) {
      _toast('Average quiz score must be 0–100.');
      return;
    }
    if (time == null || time < 0) {
      _toast('Average time spent must be a positive number.');
      return;
    }
    if (engagement == null || engagement < 1 || engagement > 5) {
      _toast('Engagement must be 1–5.');
      return;
    }

    setState(() {
      _loading = true;
      _recs = [];
    });

    try {
      final res = await RecommendationService.getRecommendation(
        quizScore: quiz,
        timeSpent: time,
        contentType: _selectedContentType,
        engagement: engagement,
      );

      final rec = res['recommendation'];
      setState(() {
        _recs = rec is List ? List<String>.from(rec) : [rec.toString()];
      });
    } catch (e) {
      setState(() {
        _recs = ['Error: ${e.toString()}'];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openDevJump() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Developer Jump'),
                  subtitle: Text('Quickly navigate to key screens'),
                ),
                ListTile(
                  leading: const Icon(Icons.recommend_outlined),
                  title: const Text('Recommendations'),
                  onTap:
                      () => Navigator.popAndPushNamed(
                        context,
                        '/recommendations',
                      ),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Learning Module'),
                  onTap: () => Navigator.popAndPushNamed(context, '/learning'),
                ),
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: const Text('Feedback'),
                  onTap: () => Navigator.popAndPushNamed(context, '/feedback'),
                ),
                ListTile(
                  leading: const Icon(Icons.loop_outlined),
                  title: const Text('Loop View'),
                  onTap: () => Navigator.popAndPushNamed(context, '/loop'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle =
        kUseMock
            ? 'Mock mode: backend calls are faked'
            : 'Live mode: calling $kBaseUrl';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalised Learning'),
        actions: [
          if (kShowDevJump)
            IconButton(
              tooltip: 'Dev Jump',
              icon: const Icon(Icons.tune_outlined),
              onPressed: _openDevJump,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // status line
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: kUseMock ? Colors.orange : Colors.teal,
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Welcome 👋',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Let’s personalise your learning path.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // PRIMARY CTA — aligns with supervisor’s flow
            ElevatedButton.icon(
              icon: const Icon(Icons.assignment_turned_in_outlined),
              label: const Text('Start Diagnostic'),
              onPressed: () => Navigator.pushNamed(context, '/quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // SECONDARY CTA — quick recs (uses your existing form below)
            OutlinedButton.icon(
              icon: const Icon(Icons.recommend_outlined),
              label: const Text('Quick Recommendation (skip quiz)'),
              onPressed: () async {
                // Scroll to the advanced section or simply expand it—here we do nothing special.
                // Optionally: navigate straight to Recommendations if you prefer:
                // Navigator.pushNamed(context, '/recommendations');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 24),

            // Advanced inputs (your existing UI), collapsible to keep the hub clean
            ExpansionTile(
              initiallyExpanded: false,
              title: const Text('Advanced (skip quiz) — enter parameters'),
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: _quizCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Average Quiz Score (0–100)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _timeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Average Time Spent (min)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                const Text('Content Type Preference'),
                DropdownButton<String>(
                  value: _selectedContentType,
                  isExpanded: true,
                  items:
                      _contentTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedContentType = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _engageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Topic Engagement (1–5)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child:
                      _loading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Get Recommendation'),
                ),
                const SizedBox(height: 10),
              ],
            ),

            const SizedBox(height: 10),

            if (_recs.isNotEmpty)
              ..._recs.map(
                (r) => Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(r),
                    trailing: TextButton(
                      onPressed:
                          () => Navigator.pushNamed(context, '/learning'),
                      child: const Text('Start'),
                    ),
                  ),
                ),
              ),
            if (_recs.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/feedback'),
                child: const Text('Give Feedback'),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton:
          kShowDevJump
              ? FloatingActionButton(
                onPressed: _openDevJump,
                child: const Icon(Icons.developer_mode),
              )
              : null,
    );
  }
}
