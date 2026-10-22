import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../error_messages.dart';
import '../format.dart';
import '../models/report.dart';
import '../routing/routes.dart';
import '../services/api_exception.dart';
import '../services/mock_bayan_sense_service.dart';
import '../state/reports_state.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_message.dart';
import 'resident/resident_home_screen.dart';

/// Report Status Detail: one report, for the resident who submitted it.
class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final int reportId;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Report? _report;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _fetch();
  }

  Future<void> _fetch() async {
    final reports = context.read<ReportsState>();
    try {
      final report = await reports.fetchReport(widget.reportId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = messageForLoadReport(e);
        _loading = false;
      });
    } on MockServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: referenceFor(widget.reportId),
      role: 'resident',
      selectedRoute: Routes.myReports,
      items: ResidentHomeScreen.navigationItems,
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final report = _report;
    if (report == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: StatusMessage(
            text: _error ?? 'Unable to load this report. Try again.',
            kind: MessageKind.error,
            onRetry: _retry),
      );
    }
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [StatusBadge(label: report.status)]),
        const SizedBox(height: 16),
        _Row(
            label: 'Category',
            value: report.predictedCategory ?? 'Waiting for staff to decide'),
        _Row(
            label: 'Sent to',
            value: report.assignedDepartment ?? 'Not assigned to a department'),
        _Row(
          label: AppStrings.submittedDate,
          value: formatDate(report.createdAt),
        ),
        _Row(
          label: AppStrings.lastUpdatedDate,
          value: formatDate(report.updatedAt),
        ),
        const SizedBox(height: 8),
        const StatusMessage(text: AppStrings.statusHistoryUnavailable),
        const SizedBox(height: 8),
        Text('Your description', style: textTheme.titleSmall),
        const SizedBox(height: 4),
        SelectableText(report.description),
        if (report.needsManualReview) ...[
          const SizedBox(height: 16),
          const StatusMessage(
              text:
                  'A staff member will confirm the category for this report.'),
        ],
        if (report.isOutOfScope) ...[
          const SizedBox(height: 16),
          const StatusMessage(
            text:
                'This was not something BayanSense handles. Please contact the barangay office '
                'directly about it.',
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
