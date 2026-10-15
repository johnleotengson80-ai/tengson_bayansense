import 'package:flutter/material.dart';

enum MessageKind { info, success, error }

/// One consistent banner for loading problems, errors, notices and success (Activity 6, Part E/H).
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.text,
    this.kind = MessageKind.info,
    this.onRetry,
  });

  final String text;
  final MessageKind kind;

  /// When set, a "Try again" button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Defaults are the "info" look; error and success override them.
    Color background = scheme.secondaryContainer;
    Color foreground = scheme.onSecondaryContainer;
    IconData icon = Icons.info_outline;
    if (kind == MessageKind.error) {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
      icon = Icons.error_outline;
    } else if (kind == MessageKind.success) {
      background = scheme.primaryContainer;
      foreground = scheme.onPrimaryContainer;
      icon = Icons.check_circle_outline;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(color: foreground)),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Try again'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
