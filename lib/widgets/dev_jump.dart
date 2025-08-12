// lib/widgets/dev_jump.dart (or paste at bottom of home_screen.dart)
import 'package:flutter/material.dart';

class DevJumpMenu extends StatelessWidget {
  const DevJumpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Dev jump',
      icon: const Icon(Icons.bug_report_outlined),
      onSelected: (route) {
        if (route == '__restart') {
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: '/',              child: Text('Splash')),
        PopupMenuItem(value: '/home',          child: Text('Home')),
        PopupMenuItem(value: '/quiz',          child: Text('Diagnostic Quiz')),
        PopupMenuItem(value: '/recommendations', child: Text('Recommendations')),
        PopupMenuItem(value: '/learning',      child: Text('Learning Module')),
        PopupMenuItem(value: '/feedback',      child: Text('Feedback Form')),
        PopupMenuItem(value: '/loop',          child: Text('Loop View')),
        PopupMenuDivider(),
        PopupMenuItem(value: '__restart',      child: Text('Restart to Splash')),
      ],
    );
  }
}
