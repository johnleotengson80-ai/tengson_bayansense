import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../format.dart';
import '../../models/report.dart';
import '../../routing/routes.dart';
import '../../services/api_exception.dart';
import '../../services/bayan_sense_service.dart';
import '../../services/mock_bayan_sense_service.dart';
import '../../state/auth_state.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_message.dart';

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
  late Future<List<Report>> _queueFuture;

  @override
  void initState() {
    super.initState();
    _queueFuture = context.read<BayanSenseService>().listReports();
  }

  void _openReport(Report report) {
    final auth = context.read<AuthState>();
    final service = context.read<BayanSenseService>();
    Navigator.of(context)
        .pushNamed(Routes.staffReportDetail(report.reportId))
        .then((_) {
      if (mounted && auth.isAuthenticated && auth.role == 'staff') {
        setState(() {
          _queueFuture = service.listReports();
        });
      }
    });
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
                final error = snapshot.error;
                final message = error is ApiException
                    ? error.statusCode == 403
                        ? AppStrings.accessDenied
                        : error.message
                    : error is MockServiceException
                        ? error.message
                        : AppStrings.loadReportsError;
                return _QueueError(
                  message: message,
                  onRetry: () => setState(() {
                    _queueFuture =
                        context.read<BayanSenseService>().listReports();
                  }),
                );
              }
              final reports = List<Report>.of(snapshot.data ?? const <Report>[])
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final received = reports
                  .where((report) => report.status == AppStrings.received)
                  .length;
              final inProgress = reports
                  .where((report) => report.status == AppStrings.inProgress)
                  .length;
              final resolved = reports
                  .where((report) => report.status == AppStrings.resolved)
                  .length;
              final needsReview =
                  reports.where((report) => report.needsManualReview).length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth < AppSpacing.compactBreakpoint
                              ? 1
                              : 4;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.medium,
                        crossAxisSpacing: AppSpacing.medium,
                        childAspectRatio: columns == 1
                            ? AppSpacing.mobileStatCardAspectRatio
                            : constraints.maxWidth <
                                    AppSpacing.desktopBreakpoint
                                ? AppSpacing.tabletStaffStatCardAspectRatio
                                : 1.5,
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
                        if (constraints.maxWidth <
                            AppSpacing.compactBreakpoint) {
                          return Column(
                            children: [
                              for (final report in reports.take(5))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.medium,
                                  ),
                                  child: _QueueCard(
                                    report: report,
                                    onTap: () => _openReport(report),
                                  ),
                                ),
                            ],
                          );
                        }
                        return _QueueTable(
                          reports: reports.take(5).toList(),
                          onTap: _openReport,
                        );
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
  const _QueueTable({required this.reports, required this.onTap});

  final List<Report> reports;
  final ValueChanged<Report> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowMinHeight: AppSpacing.reportTableRowMinHeight,
          dataRowMaxHeight: AppSpacing.reportTableRowMaxHeight,
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
                  DataCell(
                    Text(report.referenceNumber),
                    onTap: () => onTap(report),
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
                      report.predictedCategory ?? AppStrings.categoryPending)),
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
  const _QueueCard({required this.report, required this.onTap});

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    child: Text(report.referenceNumber,
                        style: AppTextStyles.cardTitle),
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
                  Text(_confidenceLabel(report),
                      style: AppTextStyles.secondary),
                  Text(formatDate(report.createdAt),
                      style: AppTextStyles.secondary),
                ],
              ),
              if (report.needsManualReview) ...[
                const SizedBox(height: AppSpacing.small),
                const Text(AppStrings.needsReview,
                    style: AppTextStyles.eyebrow),
              ],
            ],
          ),
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
  const _QueueError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: StatusMessage(
        text: message,
        kind: MessageKind.error,
        onRetry: onRetry,
      ),
    );
  }
}
