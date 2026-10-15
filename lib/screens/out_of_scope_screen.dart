import 'package:flutter/material.dart';

import '../models/submission_result.dart';
import '../routing/routes.dart';
import '../widgets/centered_content.dart';

/// S09 - Out-of-Scope Notice: shown instead of the confirmation when the server decides a message
/// is not something BayanSense handles.
class OutOfScopeNoticeScreen extends StatelessWidget {
  const OutOfScopeNoticeScreen({super.key, required this.result});

  final SubmissionResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Not handled by BayanSense')),
      body: CenteredContent(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.info_outline, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('This looks like something BayanSense does not handle.',
                style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text(
              'BayanSense is only for flooding, water waste, drainage, sewer, and clogged or '
              'damaged drainage problems in our barangay.',
            ),
            const SizedBox(height: 12),
            const Text(
              'For other concerns, such as health, permits or clearances, or police matters, '
              'please contact or visit the barangay office directly. In an emergency, contact '
              'your local emergency hotline.',
            ),
            const SizedBox(height: 12),
            Text(
              'Your message was saved as ${result.referenceNumber} but was not sent to any department.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.residentHome, (route) => false),
              child: const Text('Back to home'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.submitReport),
              child: const Text('Submit a different report'),
            ),
          ],
        ),
      ),
    );
  }
}
