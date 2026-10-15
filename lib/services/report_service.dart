import '../models/report.dart';
import '../models/user_account.dart';

abstract interface class ReportService {
  Future<List<Report>> reportsForResident(UserAccount resident);
  Future<List<Report>> reportsForDepartment(String department);
  Future<List<Report>> allReports();
}

class EmptyReportService implements ReportService {
  @override
  Future<List<Report>> reportsForResident(UserAccount resident) async =>
      const <Report>[];

  @override
  Future<List<Report>> reportsForDepartment(String department) async =>
      const <Report>[];

  @override
  Future<List<Report>> allReports() async => const <Report>[];
}
