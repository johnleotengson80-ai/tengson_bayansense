import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../format.dart';
import '../../models/report.dart';
import '../../routing/routes.dart';
import '../../services/report_service.dart';
import '../../state/auth_state.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  static const List<ResponsiveNavItem> navigationItems = <ResponsiveNavItem>[
    ResponsiveNavItem(
      label: AppStrings.publicHome,
      icon: Icons.home_outlined,
      route: Routes.staffHome,
    ),
    ResponsiveNavItem(
      label: AppStrings.queue,
      icon: Icons.inbox_outlined,
      route: Routes.staffQueue,
    ),
  ];

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  late final Future<List<Report>> _queueFuture;

  @override
  void initState() {
    super.initState();
    final department = context.read<AuthState>().account?.department;
    _queueFuture = department == null
      ? Future<List<Report>>.value(const <Report>[])
        : context.read<ReportService>().reportsForDepartment(department);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AuthState>().account;
    final department = account?.department ?? AppStrings.staffSubtitle;
    return ResponsiveScaffold(
      title: department,
      role: 'staff',
      selectedRoute: Routes.staffHome,
      items: StaffHomeScreen.navigationItems,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          Text(department, style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.large),
          FutureBuilder<List<Report>>(
            future: _queueFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xLarge),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const _QueueError();
              }
              final reports = List<Report>.of(snapshot.data ?? const <Report>[])
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final received =
                  reports.where((report) => report.status == AppStrings.received).length;
              final inProgress =
                  reports.where((report) => report.status == AppStrings.inProgress).length;
              final resolved =
                  reports.where((report) => report.status == AppStrings.resolved).length;
              final needsReview =
                  reports.where((report) => report.needsManualReview).length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth < AppSpacing.compactBreakpoint ? 1 : 4;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.medium,
                        crossAxisSpacing: AppSpacing.medium,
                        childAspectRatio: columns == 1 ? 3.4 : 1.5,
                        children: [
                          StatCard(
                            label: AppStrings.received,
                            value: '$received',
                            icon: Icons.mark_email_unread_outlined,
                          ),
                          StatCard(
                            label: AppStrings.inProgress,
                            value: '$inProgress',
                            icon: Icons.pending_actions_outlined,
                          ),
                          StatCard(
                            label: AppStrings.resolved,
                            value: '$resolved',
                            icon: Icons.task_alt_outlined,
                          ),
                          StatCard(
                            label: AppStrings.needsReview,
                            value: '$needsReview',
                            icon: Icons.fact_check_outlined,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  const SectionHeader(title: AppStrings.departmentQueue),
                  if (reports.isEmpty)
                    const _EmptyQueue()
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < AppSpacing.compactBreakpoint) {
                          return Column(
                            children: [
                              for (final report in reports.take(5))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.medium,
                                  ),
                                  child: _QueueCard(report: report),
                                ),
                            ],
                          );
                        }
                        return _QueueTable(reports: reports.take(5).toList());
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QueueTable extends StatelessWidget {
  const _QueueTable({required this.reports});

  final List<Report> reports;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text(AppStrings.reference)),
            DataColumn(label: Text(AppStrings.description)),
            DataColumn(label: Text(AppStrings.category)),
            DataColumn(label: Text(AppStrings.confidence)),
            DataColumn(label: Text(AppStrings.status)),
            DataColumn(label: Text(AppStrings.date)),
          ],
          rows: [
            for (final report in reports)
              DataRow(
                cells: [
                  DataCell(Text(report.referenceNumber)),
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
                  DataCell(Text(report.predictedCategory ?? AppStrings.categoryPending)),
                  DataCell(Text(_confidenceLabel(report))),
                  DataCell(StatusBadge(label: report.status)),
                  DataCell(Text(formatDate(report.createdAt))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(report.referenceNumber, style: AppTextStyles.cardTitle),
                ),
                StatusBadge(label: report.status),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(report.description, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.medium,
              runSpacing: AppSpacing.small,
              children: [
                Text(
                  report.predictedCategory ?? AppStrings.categoryPending,
                  style: AppTextStyles.secondary,
                ),
                Text(_confidenceLabel(report), style: AppTextStyles.secondary),
                Text(formatDate(report.createdAt), style: AppTextStyles.secondary),
              ],
            ),
            if (report.needsManualReview) ...[
              const SizedBox(height: AppSpacing.small),
              const Text(AppStrings.needsReview, style: AppTextStyles.eyebrow),
            ],
          ],
        ),
      ),
    );
  }
}

String _confidenceLabel(Report report) {
  final confidence = ((report.confidenceScore ?? 0) * 100).round();
  return '$confidence${AppStrings.percentSuffix}';
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: AppSpacing.smallIconSize,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSpacing.small),
            Text(AppStrings.emptyQueueTitle, style: AppTextStyles.cardTitle),
            SizedBox(height: AppSpacing.small),
            Text(
              AppStrings.emptyQueueDescription,
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueError extends StatelessWidget {
  const _QueueError();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.large),
      child: Text(AppStrings.loadReportsError, style: AppTextStyles.body),
    );
  }
}
