import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../routing/routes.dart';
import '../report_list_screen.dart';
import 'staff_home_screen.dart';

class StaffReportListScreen extends StatelessWidget {
  const StaffReportListScreen({super.key});

  @override
  Widget build(BuildContext context) => const ReportListScreen(
        title: AppStrings.queue,
        role: 'staff',
        selectedRoute: Routes.staffQueue,
        items: StaffHomeScreen.navigationItems,
        admin: false,
      );
}
