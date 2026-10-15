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
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  static const List<ResponsiveNavItem> navigationItems = <ResponsiveNavItem>[
    ResponsiveNavItem(
      label: AppStrings.publicHome,
      icon: Icons.home_outlined,
      route: Routes.adminHome,
    ),
    ResponsiveNavItem(
      label: AppStrings.allReports,
      icon: Icons.list_alt_outlined,
      route: Routes.adminReports,
    ),
    ResponsiveNavItem(
      label: AppStrings.staffAccounts,
      icon: Icons.people_outline,
      route: Routes.adminStaff,
    ),
  ];

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late final Future<List<Report>> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = context.read<ReportService>().allReports();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: AppStrings.publicHome,
      role: 'admin',
      selectedRoute: Routes.adminHome,
      items: AdminHomeScreen.navigationItems,
      child: FutureBuilder<List<Report>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.large),
                child: Text(AppStrings.loadReportsError,
                    style: AppTextStyles.body),
              ),
            );
          }
          final reports = List<Report>.of(snapshot.data ?? const <Report>[])
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final flagged =
              reports.where((report) => report.needsManualReview).length;
          final unrouted =
              reports.where((report) => report.isOutOfScope).length;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              const Text(AppStrings.adminRole, style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.large),
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
                    childAspectRatio: columns == 1 ? 3.4 : 1.55,
                    children: [
                      StatCard(
                        label: AppStrings.totalReports,
                        value: '${reports.length}',
                        icon: Icons.assignment_outlined,
                      ),
                      StatCard(
                        label: AppStrings.flaggedForReview,
                        value: '$flagged',
                        icon: Icons.fact_check_outlined,
                      ),
                      StatCard(
                        label: AppStrings.unrouted,
                        value: '$unrouted',
                        icon: Icons.route_outlined,
                      ),
                      const StatCard(
                        label: AppStrings.activeStaff,
                        value: AppStrings.activeStaffValue,
                        icon: Icons.people_outline,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.large),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.adminStaff),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text(AppStrings.createStaffAccount),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              _DepartmentBreakdown(reports: reports),
              const SizedBox(height: AppSpacing.xLarge),
              SectionHeader(
                title: AppStrings.recentActivity,
                actionLabel: AppStrings.viewAll,
                onAction: () =>
                    Navigator.of(context).pushNamed(Routes.adminReports),
              ),
              if (reports.isEmpty)
                const _NoActivity()
              else
                for (final report in reports.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                    child: _ActivityCard(report: report),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _DepartmentBreakdown extends StatelessWidget {
  const _DepartmentBreakdown({required this.reports});

  final List<Report> reports;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{
      for (final department in AppStrings.departments)
        department: reports
            .where((report) => report.assignedDepartment == department)
            .length,
    };
    final maximum =
        counts.values.fold<int>(0, (max, count) => count > max ? count : max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppStrings.reportsByDepartment),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              children: [
                for (final entry in counts.entries)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.small),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child:
                              Text(entry.key, style: AppTextStyles.secondary),
                        ),
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.cornerRadius),
                            child: LayoutBuilder(
                              builder: (context, constraints) => Container(
                                height: AppSpacing.departmentBarHeight,
                                color: AppColors.primaryTint,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: maximum == 0
                                      ? 0
                                      : constraints.maxWidth *
                                          entry.value /
                                          maximum,
                                  height: AppSpacing.departmentBarHeight,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        SizedBox(
                          width: AppSpacing.departmentCountWidth,
                          child:
                              Text('${entry.value}', textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.notRoutedDescription,
                    style: AppTextStyles.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.report});

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
                  child: Text(report.referenceNumber,
                      style: AppTextStyles.cardTitle),
                ),
                StatusBadge(label: report.status),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.medium,
              runSpacing: AppSpacing.small,
              children: [
                Text(
                  report.predictedCategory ?? AppStrings.categoryPending,
                  style: AppTextStyles.secondary,
                ),
                Text(
                  report.assignedDepartment ?? AppStrings.unassigned,
                  style: AppTextStyles.secondary,
                ),
                Text(formatDate(report.createdAt),
                    style: AppTextStyles.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActivity extends StatelessWidget {
  const _NoActivity();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.large),
      child:
          Text(AppStrings.noReportsDescription, style: AppTextStyles.secondary),
    );
  }
}
