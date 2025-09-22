import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

/// Tiny banner that shows the active API base URL (debug/profile only).
class ApiBanner extends StatelessWidget {
  const ApiBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink(); // hide in release

    final base = ApiService.base;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Capture messenger *before* the await to avoid using context across an async gap.
          final messenger = ScaffoldMessenger.of(context);

          await Clipboard.setData(ClipboardData(text: base));

          messenger.showSnackBar(
            SnackBar(content: Text('Copied API_BASE_URL: $base')),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // withOpacity is deprecated in your SDK; use withValues(alpha: ...)
            color: Colors.black.withValues(alpha: 0.75),
            border: const Border(top: BorderSide(color: Colors.white24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.link, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'API: $base',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'tap to copy',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
