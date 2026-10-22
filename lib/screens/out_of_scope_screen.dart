import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/submission_result.dart';
import '../routing/routes.dart';
import '../widgets/centered_content.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_message.dart';

/// S09 - Out-of-Scope Notice: shown instead of the confirmation when the server decides a message
/// is not something BayanSense handles.
class OutOfScopeNoticeScreen extends StatelessWidget {
  const OutOfScopeNoticeScreen({super.key, required this.result});

  final SubmissionResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reportReceivedTitle)),
      body: CenteredContent(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.info_outline,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(AppStrings.thankYouReportReceived,
                style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Center(
              child: SelectableText(
                '${AppStrings.referenceNumberLabel}: ${result.referenceNumber}',
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: AppStrings.category,
              value: result.predictedCategory ?? AppStrings.unclassified,
            ),
            _DetailRow(
              label: AppStrings.department,
              value: result.assignedDepartment ?? AppStrings.unassigned,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(AppStrings.status),
                  ),
                  StatusBadge(label: result.status),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const StatusMessage(text: AppStrings.reportReceivedOutsideServices),
            if (result.needsManualReview) ...[
              const SizedBox(height: 12),
              const StatusMessage(
                text: 'A barangay staff member will double-check this report.',
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.residentHome, (route) => false),
              child: const Text('Back to home'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(Routes.submitReport),
              child: const Text('Submit a different report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
