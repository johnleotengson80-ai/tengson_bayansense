import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../routing/routes.dart';
import '../state/reports_state.dart';
import '../widgets/report_card.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/status_message.dart';
import 'resident/resident_home_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _searchController = TextEditingController();
  String _status = AppStrings.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReportsState>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(
        title: AppStrings.myReports,
        role: 'resident',
        selectedRoute: Routes.myReports,
        items: ResidentHomeScreen.navigationItems,
        child: Consumer<ReportsState>(
          builder: (context, state, _) {
            final noDataYet = state.items.isEmpty;
            if (noDataYet &&
                state.error == null &&
                (state.loading || !state.loadedOnce)) {
              return const Center(child: CircularProgressIndicator());
            }
            if (noDataYet && state.error != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: StatusMessage(
                  text: state.error!,
                  kind: MessageKind.error,
                  onRetry: state.load,
                ),
              );
            }
            if (noDataYet) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(AppStrings.noReportsDescription),
                      const SizedBox(height: AppSpacing.medium),
                      FilledButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(Routes.submitReport),
                        child: const Text(AppStrings.submitReport),
                      ),
                    ],
                  ),
                ),
              );
            }
            final query = _searchController.text.trim().toLowerCase();
            final filtered = state.items.where((report) {
              final matchesSearch = query.isEmpty ||
                  report.description.toLowerCase().contains(query);
              final matchesStatus =
                  _status == AppStrings.all || report.status == _status;
              return matchesSearch && matchesStatus;
            }).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return RefreshIndicator(
              onRefresh: state.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.medium),
                children: [
                  if (state.error != null) ...[
                    StatusMessage(
                      text: state.error!,
                      kind: MessageKind.error,
                      onRetry: state.load,
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
                          onSelected: (_) => setState(() => _status = status),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.large),
                      child: Text(AppStrings.noReportsMatch),
                    ),
                  for (final report in filtered)
                    ReportCard(
                      report: report,
                      onTap: () => Navigator.of(context)
                          .pushNamed(Routes.reportDetail(report.reportId)),
                    ),
                ],
              ),
            );
          },
        ),
      );
}
