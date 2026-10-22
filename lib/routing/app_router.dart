import 'package:flutter/material.dart';

import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/admin/create_staff_screen.dart';
import '../screens/login_screen.dart';
import '../screens/my_reports_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/report_form_screen.dart';
import '../screens/report_detail_screen.dart';
import '../screens/staff/report_detail_screen.dart';
import '../screens/staff/report_list_screen.dart';
import '../screens/resident/resident_home_screen.dart';
import '../screens/staff/staff_home_screen.dart';
import '../screens/submit_report_screen.dart';
import 'route_guard.dart';
import 'routes.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    final name = normalizeRoute(settings.name);
    final residentReportId = parseReportId(name);
    final staffReportId = parseStaffReportId(name);

    final Widget page;
    if (residentReportId != null) {
      page = RouteGuard(
        requiredRole: 'resident',
        child: ReportDetailScreen(reportId: residentReportId),
      );
    } else if (staffReportId != null) {
      page = RouteGuard(
        requiredRole: 'staff',
        child: StaffReportDetailScreen(reportId: staffReportId),
      );
    } else if (name == Routes.root) {
      page = const RootRedirect();
    } else if (name == Routes.login) {
      page = const RouteGuard(guestOnly: true, child: LoginScreen());
    } else if (name == Routes.register) {
      page = const RouteGuard(
        guestOnly: true,
        child: LoginScreen(initialRegisterMode: true),
      );
    } else if (name == Routes.reportForm) {
      page = const ReportFormScreen();
    } else if (name == Routes.residentHome) {
      page = const RouteGuard(
          requiredRole: 'resident', child: ResidentHomeScreen());
    } else if (name == Routes.submitReport) {
      page = const RouteGuard(
        requiredRole: 'resident',
        child: SubmitReportScreen(),
      );
    } else if (name == Routes.myReports) {
      page = const RouteGuard(
        requiredRole: 'resident',
        child: MyReportsScreen(),
      );
    } else if (name == Routes.staffHome || name == Routes.personnelDashboard) {
      page = const RouteGuard(
        requiredRole: 'staff',
        child: StaffHomeScreen(),
      );
    } else if (name == Routes.staffQueue) {
      page = const RouteGuard(
        requiredRole: 'staff',
        child: StaffReportListScreen(),
      );
    } else if (name == Routes.adminHome) {
      page = const RouteGuard(requiredRole: 'admin', child: AdminHomeScreen());
    } else if (name == Routes.adminReports) {
      page = const RouteGuard(
        requiredRole: 'admin',
        child: AdminReportsScreen(),
      );
    } else if (name == Routes.adminStaff || name == Routes.adminPersonnel) {
      page = const RouteGuard(
        requiredRole: 'admin',
        child: CreateStaffScreen(),
      );
    } else {
      page = const NotFoundScreen();
    }

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}
