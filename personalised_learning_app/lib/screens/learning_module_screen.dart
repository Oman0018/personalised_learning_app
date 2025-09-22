import 'package:flutter/material.dart';
import '../services/module_service.dart';

class LearningModuleScreen extends StatefulWidget {
  const LearningModuleScreen({super.key});
  @override
  State<LearningModuleScreen> createState() => _LearningModuleScreenState();
}

class _LearningModuleScreenState extends State<LearningModuleScreen> {
  int _i = 0;

  void _prev() => setState(() => _i = (_i > 0) ? _i - 1 : 0);
  void _next() =>
      setState(() => _i = (_i < ModuleService.length - 1) ? _i + 1 : _i);

  void _markComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked "${ModuleService.byIndex(_i).title}" complete')),
    );
    Navigator.pushNamed(context, '/feedback');
  }

  @override
  Widget build(BuildContext context) {
    final m = ModuleService.byIndex(_i);
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Module')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(m.summary),
          const SizedBox(height: 12),
          Expanded(child: SingleChildScrollView(child: Text(m.content))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _prev, child: const Text('Previous'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton(onPressed: _markComplete, child: const Text('Mark Complete'))),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _next,
                child: Text(_i == ModuleService.length - 1 ? 'Finish' : 'Next'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
