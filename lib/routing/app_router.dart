import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/resident/resident_home_screen.dart';
import '../screens/staff/staff_home_screen.dart';
import '../widgets/responsive_scaffold.dart';
import 'route_guard.dart';
import 'routes.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    final name = normalizeRoute(settings.name);

    final Widget page;
    if (name == Routes.root) {
      page = const RootRedirect();
    } else if (name == Routes.login) {
      page = const RouteGuard(guestOnly: true, child: LoginScreen());
    } else if (name == Routes.register) {
      page = const RouteGuard(
        guestOnly: true,
        child: LoginScreen(initialRegisterMode: true),
      );
    } else if (name == Routes.residentHome) {
      page = const RouteGuard(requiredRole: 'resident', child: ResidentHomeScreen());
    } else if (name == Routes.submitReport || name == Routes.myReports) {
      page = RouteGuard(
        requiredRole: 'resident',
        child: ResponsiveScaffold.placeholder(
          title: name == Routes.submitReport
              ? AppStrings.submitReport
              : AppStrings.myReports,
          role: 'resident',
          selectedRoute: name,
          items: ResidentHomeScreen.navigationItems,
        ),
      );
    } else if (name == Routes.staffHome || name == Routes.personnelDashboard) {
      page = const RouteGuard(
        requiredRole: 'staff',
        child: StaffHomeScreen(),
      );
    } else if (name == Routes.staffQueue) {
      page = RouteGuard(
        requiredRole: 'staff',
        child: ResponsiveScaffold.placeholder(
          title: AppStrings.queue,
          role: 'staff',
          selectedRoute: name,
          items: StaffHomeScreen.navigationItems,
        ),
      );
    } else if (name == Routes.adminHome) {
      page = const RouteGuard(requiredRole: 'admin', child: AdminHomeScreen());
    } else if (name == Routes.adminReports || name == Routes.adminStaff ||
        name == Routes.adminPersonnel) {
      final selected = name == Routes.adminStaff || name == Routes.adminPersonnel
          ? Routes.adminStaff
          : Routes.adminReports;
      final title = selected == Routes.adminStaff
          ? AppStrings.staffAccounts
          : AppStrings.allReports;
      page = RouteGuard(
        requiredRole: 'admin',
        child: ResponsiveScaffold.placeholder(
          title: title,
          role: 'admin',
          selectedRoute: selected,
          items: AdminHomeScreen.navigationItems,
        ),
      );
    } else {
      page = const NotFoundScreen();
    }

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}
