/// Route paths (Activity 6, Part C). Plain Dart, no Flutter imports, so it is easy to unit test.
class Routes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String residentHome = '/resident/home';
  static const String submitReport = '/resident/submit-report';
  static const String myReports = '/resident/reports';
  static const String staffHome = '/staff/home';
  static const String staffQueue = '/staff/queue';
  static const String adminHome = '/admin/personnel';
  static const String adminReports = '/admin/reports';
  static const String adminStaff = '/admin/staff';

  // Legacy paths remain aliases so existing links continue to resolve.
  static const String personnelDashboard = '/personnel/dashboard';
  static const String adminPersonnel = '/admin/personnel';

  static String reportDetail(int reportId) => '/resident/reports/$reportId';

  /// Where each role lands after logging in.
  static String homeFor(String role) {
    switch (role) {
      case 'staff':
        return staffHome;
      case 'personnel':
        return personnelDashboard;
      case 'admin':
        return adminPersonnel;
      default:
        return residentHome;
    }
  }
}

/// Cleans a route name coming from the browser: drops "?query" / "#fragment" and a trailing slash.
String normalizeRoute(String? name) {
  final path = Uri.tryParse(name ?? '/')?.path ?? '/';
  if (path.isEmpty) return '/';
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

/// "/resident/reports/12" -> 12. Null for any other route.
int? parseReportId(String routeName) {
  final segments = Uri.tryParse(routeName)?.pathSegments ?? const <String>[];
  if (segments.length == 3 &&
      segments[0] == 'resident' &&
      segments[1] == 'reports') {
    return int.tryParse(segments[2]);
  }
  return null;
}
