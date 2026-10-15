import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routing/routes.dart';
import '../state/reports_state.dart';
import '../widgets/centered_content.dart';
import '../widgets/report_card.dart';
import '../widgets/status_message.dart';

/// S05 - My Reports: the resident's reports with their current status.
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Load after the first frame: notifying listeners while the screen is still building is not allowed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReportsState>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My reports'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportsState>().load(),
          ),
        ],
      ),
      body: CenteredContent(
        maxWidth: 720,
        child: Consumer<ReportsState>(
          builder: (context, state, _) {
            final noDataYet = state.items.isEmpty;

            if (noDataYet && state.error == null && (state.loading || !state.loadedOnce)) {
              return const Center(child: CircularProgressIndicator());
            }
            if (noDataYet && state.error != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("You haven't submitted any reports yet."),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pushNamed(Routes.submitReport),
                        child: const Text('Submit a report'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: state.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.error != null) ...[
                    StatusMessage(text: state.error!, kind: MessageKind.error),
                    const SizedBox(height: 12),
                  ],
                  for (final report in state.items)
                    ReportCard(
                      report: report,
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.reportDetail(report.reportId)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
