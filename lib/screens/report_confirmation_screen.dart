import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/submission_result.dart';
import '../routing/routes.dart';
import '../widgets/centered_content.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_message.dart';

/// S04 - Report Confirmation: what the server decided for the report just submitted.
class ReportConfirmationScreen extends StatelessWidget {
  const ReportConfirmationScreen({super.key, required this.result});

  final SubmissionResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reportReceivedTitle)),
      body: CenteredContent(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.check_circle, size: 64, color: colors.primary),
            const SizedBox(height: 12),
            Text(AppStrings.thankYouReportReceived,
                style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Center(
              child: SelectableText(
                '${AppStrings.referenceNumberLabel}: ${result.referenceNumber}',
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              label: AppStrings.category,
              value: result.predictedCategory ?? AppStrings.staffWillDecide,
            ),
            _DetailRow(
                label: AppStrings.sentTo,
                value: result.assignedDepartment ?? AppStrings.staffWillDecide),
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
            if (result.needsManualReview) ...[
              const SizedBox(height: 16),
              const StatusMessage(
                text:
                    'A barangay staff member will double-check this report to make sure it '
                    'goes to the right office.',
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.myReports, ModalRoute.withName(Routes.residentHome)),
              child: const Text('View my reports'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.residentHome, (route) => false),
              child: const Text('Back to home'),
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
  Widget build(BuildContext context) {
    return Padding(
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
}
