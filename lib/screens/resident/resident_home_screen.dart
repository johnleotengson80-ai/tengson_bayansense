import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../models/report.dart';
import '../../routing/routes.dart';
import '../../services/api_exception.dart';
import '../../services/bayan_sense_service.dart';
import '../../services/mock_bayan_sense_service.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/report_card.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_message.dart';

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
  late Future<List<Report>> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = context.read<BayanSenseService>().listReports();
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
                final error = snapshot.error;
                final message = error is ApiException
                    ? error.statusCode == 403
                        ? AppStrings.accessDenied
                        : error.message
                    : error is MockServiceException
                        ? error.message
                        : AppStrings.loadReportsError;
                return _ReportsError(
                  message: message,
                  onRetry: () => setState(() {
                    _reportFuture =
                        context.read<BayanSenseService>().listReports();
                  }),
                );
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
                        childAspectRatio: columns == 1
                            ? AppSpacing.mobileStatCardAspectRatio
                            : constraints.maxWidth <
                                    AppSpacing.desktopBreakpoint
                                ? AppSpacing.tabletStatCardAspectRatio
                                : 1.9,
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
                          onTap: () => Navigator.of(context).pushNamed(
                            Routes.reportDetail(report.reportId),
                          ),
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
  const _ReportsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: StatusMessage(
          text: message,
          kind: MessageKind.error,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
