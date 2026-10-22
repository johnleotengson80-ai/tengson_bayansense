import 'package:bayansense_app/constants/app_strings.dart';
import 'package:bayansense_app/routing/app_router.dart';
import 'package:bayansense_app/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('public report route validates and retries simulated submissions',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: _ReportRouteLauncher(),
        onGenerateRoute: AppRouter.generate,
      ),
    );
    await tester.tap(find.text(AppStrings.reportProblem));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.reportsSentThisSession), findsOneWidget);
    expect(find.text(AppStrings.noSessionReports), findsOneWidget);
    expect(find.text(AppStrings.reportSimulationNote), findsOneWidget);

    await tester.tap(find.text(AppStrings.startReportAction));
    await tester.pump();
    await tester.tap(find.text(AppStrings.submitReportAction));
    await tester.pump();
    expect(find.text(AppStrings.reportDescriptionRequired), findsOneWidget);
    expect(find.text(AppStrings.reportCategoryRequired), findsOneWidget);
    expect(find.text(AppStrings.reportLocationRequired), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Water is pooling beside the community hall.',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.flooding));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).last,
      'Purok 2, beside the community hall',
    );
    await tester.tap(find.text(AppStrings.simulateFailure));
    await tester.pump();

    await tester.tap(find.text(AppStrings.submitReportAction));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(AppStrings.simulatedReportError), findsOneWidget);
    expect(find.text(AppStrings.submitReportRetry), findsOneWidget);

    await tester.tap(find.text(AppStrings.simulateFailure));
    await tester.pump();
    await tester.tap(find.text(AppStrings.submitReportRetry));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    expect(find.text(AppStrings.simulatedReportSuccessTitle), findsOneWidget);
    expect(find.text(AppStrings.submitAnotherReport), findsOneWidget);
  });
}

class _ReportRouteLauncher extends StatelessWidget {
  const _ReportRouteLauncher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.reportForm),
        child: const Text(AppStrings.reportProblem),
      ),
    );
  }
}
