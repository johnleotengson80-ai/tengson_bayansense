import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_strings.dart';
import '../../format.dart';
import '../../models/report.dart';
import '../../routing/routes.dart';
import '../../services/api_exception.dart';
import '../../services/bayan_sense_service.dart';
import '../../services/mock_bayan_sense_service.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_message.dart';
import 'staff_home_screen.dart';

class StaffReportDetailScreen extends StatefulWidget {
  const StaffReportDetailScreen({super.key, required this.reportId});

  final int reportId;

  @override
  State<StaffReportDetailScreen> createState() =>
      _StaffReportDetailScreenState();
}

class _StaffReportDetailScreenState extends State<StaffReportDetailScreen> {
  static const _statuses = <String>[
    AppStrings.received,
    AppStrings.inProgress,
    AppStrings.resolved,
  ];

  final _noteController = TextEditingController();
  Report? _report;
  String? _selectedStatus;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final report =
          await context.read<BayanSenseService>().getReport(widget.reportId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _selectedStatus = report.status;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            error.statusCode == 403 ? AppStrings.accessDenied : error.message;
        _loading = false;
      });
    } on MockServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    final status = _selectedStatus;
    final report = _report;
    if (_saving || status == null || report == null) return;
    final note = _noteController.text.trim();
    if (status == AppStrings.resolved && note.isEmpty) {
      setState(() => _error = AppStrings.resolutionNoteRequired);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.updateStatus),
        content: const Text(AppStrings.statusUpdateConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await context.read<BayanSenseService>().updateStatus(
            reportId: report.reportId,
            status: status,
            resolutionNote: note.isEmpty ? null : note,
          );
      if (!mounted) return;
      setState(() {
        _report = updated;
        _selectedStatus = updated.status;
        _noteController.clear();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            error.statusCode == 403 ? AppStrings.accessDenied : error.message;
      });
    } on MockServiceException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(
        title: referenceFor(widget.reportId),
        role: 'staff',
        selectedRoute: Routes.staffQueue,
        items: StaffHomeScreen.navigationItems,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _report == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: StatusMessage(
                        text: _error ?? AppStrings.loadReportsError,
                        kind: MessageKind.error,
                        onRetry: _load,
                      ),
                    ),
                  )
                : _reportContent(_report!),
      );

  Widget _reportContent(Report report) => ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          if (_error != null) ...[
            StatusMessage(
              text: _error!,
              kind: MessageKind.error,
              onRetry: _load,
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(label: report.status),
          ),
          const SizedBox(height: AppSpacing.medium),
          _DetailRow(
            label: AppStrings.category,
            value: report.predictedCategory ?? AppStrings.categoryPending,
          ),
          _DetailRow(
            label: AppStrings.department,
            value: report.assignedDepartment ?? AppStrings.unassigned,
          ),
          _DetailRow(
            label: AppStrings.submittedDate,
            value: formatDate(report.createdAt),
          ),
          _DetailRow(
            label: AppStrings.lastUpdatedDate,
            value: formatDate(report.updatedAt),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(AppStrings.description,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.small),
          SelectableText(report.description),
          if (report.needsManualReview) ...[
            const SizedBox(height: AppSpacing.medium),
            const StatusMessage(text: AppStrings.needsReview),
          ],
          const SizedBox(height: AppSpacing.large),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppStrings.updateStatus,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.medium),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: AppStrings.status,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final status in _statuses)
                        DropdownMenuItem(value: status, child: Text(status)),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _selectedStatus = value),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: _noteController,
                    enabled: !_saving,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: AppStrings.resolutionNote,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  FilledButton(
                    onPressed: _saving ? null : _updateStatus,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text(AppStrings.updateStatus),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
