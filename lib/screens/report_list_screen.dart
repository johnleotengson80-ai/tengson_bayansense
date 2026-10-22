import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../format.dart';
import '../models/report.dart';
import '../routing/routes.dart';
import '../services/api_exception.dart';
import '../services/bayan_sense_service.dart';
import '../services/mock_bayan_sense_service.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_message.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({
    super.key,
    required this.title,
    required this.role,
    required this.selectedRoute,
    required this.items,
    required this.admin,
  });

  final String title;
  final String role;
  final String selectedRoute;
  final List<ResponsiveNavItem> items;
  final bool admin;

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _searchController = TextEditingController();
  List<Report> _reports = const <Report>[];
  String _status = AppStrings.all;
  String _department = AppStrings.all;
  bool _needsReviewOnly = false;
  bool _newestFirst = true;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reports = await context.read<BayanSenseService>().listReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
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

  List<Report> get _filteredReports {
    final query = _searchController.text.trim().toLowerCase();
    final reports = _reports.where((report) {
      final matchesText =
          query.isEmpty || report.description.toLowerCase().contains(query);
      final matchesStatus =
          _status == AppStrings.all || report.status == _status;
      final matchesReview = !_needsReviewOnly || report.needsManualReview;
      final matchesDepartment = !widget.admin ||
          _department == AppStrings.all ||
          (_department == AppStrings.unassigned
              ? report.assignedDepartment == null
              : report.assignedDepartment == _department);
      return matchesText && matchesStatus && matchesReview && matchesDepartment;
    }).toList();
    reports.sort((a, b) => _newestFirst
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return reports;
  }

  void _openReport(Report report) {
    if (widget.admin) return;
    Navigator.of(context)
        .pushNamed(Routes.staffReportDetail(report.reportId))
        .then((_) {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(
        title: widget.title,
        role: widget.role,
        selectedRoute: widget.selectedRoute,
        items: widget.items,
        child: _loading && _reports.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _reports.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: StatusMessage(
                        text: _error!,
                        kind: MessageKind.error,
                        onRetry: _load,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.searchReports,
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Wrap(
                          spacing: AppSpacing.small,
                          runSpacing: AppSpacing.small,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final status in const [
                              AppStrings.all,
                              AppStrings.received,
                              AppStrings.inProgress,
                              AppStrings.resolved,
                            ])
                              ChoiceChip(
                                label: Text(status),
                                selected: _status == status,
                                onSelected: (_) =>
                                    setState(() => _status = status),
                              ),
                            _NeedsReviewToggle(
                              value: _needsReviewOnly,
                              onChanged: (value) =>
                                  setState(() => _needsReviewOnly = value),
                            ),
                          ],
                        ),
                        if (widget.admin) ...[
                          const SizedBox(height: AppSpacing.medium),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = (constraints.maxWidth -
                                      AppSpacing.xxLarge * 3)
                                  .clamp(0.0, 600.0);
                              return SizedBox(
                                width: constraints.maxWidth,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _department,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: AppStrings.department,
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: AppStrings.all,
                                      child: Text(AppStrings.all),
                                    ),
                                    for (final department
                                        in AppStrings.departmentNames)
                                      DropdownMenuItem(
                                        value: department.name,
                                        child: SizedBox(
                                          width: itemWidth,
                                          child: Text(
                                            department.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    const DropdownMenuItem(
                                      value: AppStrings.unassigned,
                                      child: Text(AppStrings.unassigned),
                                    ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _department = value ?? AppStrings.all,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: AppSpacing.medium),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<bool>(
                            value: _newestFirst,
                            onChanged: (value) =>
                                setState(() => _newestFirst = value ?? true),
                            items: const [
                              DropdownMenuItem(
                                value: true,
                                child: Text(AppStrings.newestFirst),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text(AppStrings.oldestFirst),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        if (_filteredReports.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.large),
                            child: Text(AppStrings.noReportsMatch),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) =>
                                constraints.maxWidth <
                                        AppSpacing.compactBreakpoint
                                    ? Column(
                                        children: [
                                          for (final report in _filteredReports)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: AppSpacing.medium,
                                              ),
                                              child: _ReportCard(
                                                report: report,
                                                onTap: widget.admin
                                                    ? null
                                                    : () => _openReport(report),
                                                showDepartment: widget.admin,
                                              ),
                                            ),
                                        ],
                                      )
                                    : _ReportTable(
                                        reports: _filteredReports,
                                        admin: widget.admin,
                                        onTap: _openReport,
                                      ),
                          ),
                      ],
                    ),
                  ),
      );
}

class _ReportTable extends StatefulWidget {
  const _ReportTable({
    required this.reports,
    required this.admin,
    required this.onTap,
  });

  final List<Report> reports;
  final bool admin;
  final ValueChanged<Report> onTap;

  @override
  State<_ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<_ReportTable> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.top,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowMinHeight: AppSpacing.reportTableRowMinHeight,
              dataRowMaxHeight: AppSpacing.reportTableRowMaxHeight,
              columns: [
                const DataColumn(label: Text(AppStrings.reference)),
                const DataColumn(label: Text(AppStrings.description)),
                const DataColumn(label: Text(AppStrings.category)),
                const DataColumn(label: Text(AppStrings.confidence)),
                const DataColumn(label: Text(AppStrings.status)),
                const DataColumn(label: Text(AppStrings.date)),
                if (widget.admin)
                  const DataColumn(label: Text(AppStrings.department)),
              ],
              rows: [
                for (final report in widget.reports)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(report.referenceNumber),
                        onTap: widget.admin ? null : () => widget.onTap(report),
                      ),
                      DataCell(
                        SizedBox(
                          width: AppSpacing.queueDescriptionWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (report.needsManualReview)
                                const Text(
                                  AppStrings.needsReview,
                                  style: AppTextStyles.eyebrow,
                                ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(
                        report.predictedCategory ?? AppStrings.categoryPending,
                      )),
                      DataCell(Text(_confidenceLabel(report))),
                      DataCell(StatusBadge(label: report.status)),
                      DataCell(Text(formatDate(report.createdAt))),
                      if (widget.admin)
                        DataCell(Text(
                          report.assignedDepartment ?? AppStrings.unassigned,
                        )),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
}

class _NeedsReviewToggle extends StatelessWidget {
  const _NeedsReviewToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final trackColor = value ? AppColors.primary : AppColors.border;
    final stateLabel = value ? AppStrings.filterOn : AppStrings.filterOff;
    return Semantics(
      label: AppStrings.needsReviewOnly,
      value: stateLabel,
      toggled: value,
      button: true,
      child: Material(
        color: value ? AppColors.primaryTint : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: value ? AppColors.primary : AppColors.border,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onChanged(!value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minimumTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.xSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(AppStrings.needsReviewOnly),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    stateLabel,
                    style: TextStyle(
                      color:
                          value ? AppColors.primary : AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 38,
                    height: 22,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 160),
                      alignment:
                          value ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: value
                              ? null
                              : Border.all(color: AppColors.secondaryText),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onTap,
    required this.showDepartment,
  });

  final Report report;
  final VoidCallback? onTap;
  final bool showDepartment;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.referenceNumber,
                        style: AppTextStyles.cardTitle,
                      ),
                    ),
                    StatusBadge(label: report.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                Text(report.description,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.medium,
                  runSpacing: AppSpacing.small,
                  children: [
                    Text(
                      report.predictedCategory ?? AppStrings.categoryPending,
                      style: AppTextStyles.secondary,
                    ),
                    Text(_confidenceLabel(report),
                        style: AppTextStyles.secondary),
                    Text(formatDate(report.createdAt),
                        style: AppTextStyles.secondary),
                    if (showDepartment)
                      Text(
                        report.assignedDepartment ?? AppStrings.unassigned,
                        style: AppTextStyles.secondary,
                      ),
                  ],
                ),
                if (report.needsManualReview) ...[
                  const SizedBox(height: AppSpacing.small),
                  const Text(
                    AppStrings.needsReview,
                    style: AppTextStyles.eyebrow,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

String _confidenceLabel(Report report) {
  final value = report.confidenceScore == null
      ? '—'
      : '${(report.confidenceScore! * 100).round()}${AppStrings.percentSuffix}';
  return value;
}
