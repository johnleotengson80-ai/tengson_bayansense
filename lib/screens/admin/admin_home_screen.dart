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
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_message.dart';

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
  List<Report> _reports = const <Report>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: AppStrings.publicHome,
      role: 'admin',
      selectedRoute: Routes.adminHome,
      items: AdminHomeScreen.navigationItems,
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
              : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    final reports = List<Report>.of(_reports)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final flagged = reports.where((report) => report.needsManualReview).length;
    final unrouted =
        reports.where((report) => report.assignedDepartment == null).length;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          if (_error != null) ...[
            StatusMessage(
              text: _error!,
              kind: MessageKind.error,
              onRetry: _load,
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          const Text(AppStrings.adminRole, style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.large),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth < AppSpacing.compactBreakpoint ? 1 : 3;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.medium,
                crossAxisSpacing: AppSpacing.medium,
                childAspectRatio: columns == 1
                    ? AppSpacing.mobileStatCardAspectRatio
                    : constraints.maxWidth < AppSpacing.desktopBreakpoint
                        ? AppSpacing.tabletStatCardAspectRatio
                        : 1.8,
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
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.large),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(Routes.adminStaff),
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
      for (final department in AppStrings.departmentNames)
        department.name: reports
            .where((report) => report.assignedDepartment == department.name)
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
