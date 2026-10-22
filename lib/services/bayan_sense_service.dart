import '../models/report.dart';
import '../models/session.dart';
import '../models/submission_result.dart';

abstract interface class BayanSenseService {
  String? get token;
  set token(String? value);
  void Function()? get onUnauthorized;
  set onUnauthorized(void Function()? callback);

  Future<int> register({
    required String fullName,
    required String email,
    required String password,
    String? contactNumber,
    String? barangayZone,
  });
  Future<Session> login({required String email, required String password});
  Future<SubmissionResult> createReport({
    required String description,
    String? imageUrl,
    double? latitude,
    double? longitude,
  });
  Future<List<Report>> listReports({int? departmentId, String? status});
  Future<Report> getReport(int reportId);
  Future<Report> updateStatus({
    required int reportId,
    required String status,
    String? resolutionNote,
  });
  Future<int> createPersonnel({
    required String fullName,
    required String email,
    required String password,
    required int departmentId,
  });
}
