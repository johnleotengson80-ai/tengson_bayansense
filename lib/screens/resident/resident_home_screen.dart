import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../models/report.dart';
import '../../routing/routes.dart';
import '../../services/report_service.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/report_card.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  static const List<ResponsiveNavItem> navigationItems = <ResponsiveNavItem>[
    ResponsiveNavItem(
      label: AppStrings.publicHome,
      icon: Icons.home_outlined,
      route: Routes.residentHome,
    ),
    ResponsiveNavItem(
      label: AppStrings.submitReport,
      icon: Icons.edit_note_outlined,
      route: Routes.submitReport,
    ),
    ResponsiveNavItem(
      label: AppStrings.myReports,
      icon: Icons.list_alt_outlined,
      route: Routes.myReports,
    ),
  ];

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  late final Future<List<Report>> _reportFuture;

  @override
  void initState() {
    super.initState();
    final account = context.read<AuthState>().account;
    _reportFuture = account == null
      ? Future<List<Report>>.value(const <Report>[])
        : context.read<ReportService>().reportsForResident(account);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AuthState>().account;
    return ResponsiveScaffold(
      title: AppStrings.publicHome,
      role: 'resident',
      selectedRoute: Routes.residentHome,
      items: ResidentHomeScreen.navigationItems,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          Text(
            '${AppStrings.welcomeBack} ${account?.fullName ?? AppStrings.residentRole}',
            style: AppTextStyles.pageTitle,
          ),
          const SizedBox(height: AppSpacing.large),
          AppButton(
            label: AppStrings.submitReport,
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.submitReport),
          ),
          const SizedBox(height: AppSpacing.xLarge),
          FutureBuilder<List<Report>>(
            future: _reportFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xLarge),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const _ReportsError();
              }
              final reports = List<Report>.of(snapshot.data ?? const <Report>[])
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final inProgress = reports
                  .where((report) => report.status == AppStrings.inProgress)
                  .length;
              final resolved = reports
                  .where((report) => report.status == AppStrings.resolved)
                  .length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth < AppSpacing.compactBreakpoint
                              ? 1
                              : 3;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.medium,
                        crossAxisSpacing: AppSpacing.medium,
                        childAspectRatio: columns == 1 ? 3.4 : 1.9,
                        children: [
                          StatCard(
                            label: AppStrings.totalReports,
                            value: '${reports.length}',
                            icon: Icons.assignment_outlined,
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
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  SectionHeader(
                    title: AppStrings.recentReports,
                    actionLabel: AppStrings.viewAll,
                    onAction: () =>
                        Navigator.of(context).pushNamed(Routes.myReports),
                  ),
                  if (reports.isEmpty)
                    const _EmptyReports()
                  else
                    for (final report in reports.take(3))
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.medium),
                        child: ReportCard(
                          report: report,
                          onTap: () =>
                              Navigator.of(context).pushNamed(Routes.myReports),
                        ),
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

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: AppSpacing.smallIconSize),
            SizedBox(height: AppSpacing.small),
            Text(AppStrings.noReportsTitle, style: AppTextStyles.cardTitle),
            SizedBox(height: AppSpacing.small),
            Text(
              AppStrings.noReportsDescription,
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsError extends StatelessWidget {
  const _ReportsError();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Text(AppStrings.loadReportsError, style: AppTextStyles.body),
      ),
    );
  }
}
