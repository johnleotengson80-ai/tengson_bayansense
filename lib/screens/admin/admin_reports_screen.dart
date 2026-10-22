import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../routing/routes.dart';
import '../report_list_screen.dart';
import 'admin_home_screen.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => const ReportListScreen(
        title: AppStrings.allReports,
        role: 'admin',
        selectedRoute: Routes.adminReports,
        items: AdminHomeScreen.navigationItems,
        admin: true,
      );
}
