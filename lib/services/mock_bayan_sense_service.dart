import '../constants/app_strings.dart';
import '../models/report.dart';
import '../models/session.dart';
import '../models/submission_result.dart';
import 'bayan_sense_service.dart';

class MockBayanSenseService implements BayanSenseService {
  final List<Report> _reports = <Report>[];
  final Map<String, ({String password, Session session})> _accounts =
      <String, ({String password, Session session})>{};
  int _nextReportId = 1;
  int _nextUserId = 1;
  String? _token;
  String? _currentRole;
  String? _currentDepartment;
  int? _currentUserId;

  @override
  String? get token => _token;

  @override
  set token(String? value) => _token = value;

  @override
  void Function()? onUnauthorized;

  @override
  Future<int> register({
    required String fullName,
    required String email,
    required String password,
    String? contactNumber,
    String? barangayZone,
  }) async {
    final id = _nextUserId++;
    final session = Session(
      id: id,
      role: 'resident',
      token: 'mock-$id',
      fullName: fullName,
      email: email,
    );
    _accounts[email.toLowerCase()] = (password: password, session: session);
    _currentUserId = id;
    _currentRole = 'resident';
    return id;
  }

  @override
  Future<Session> login(
      {required String email, required String password}) async {
    final entry = _accounts[email.toLowerCase()];
    if (entry != null && entry.password == password) {
      _currentRole = entry.session.role;
      _currentDepartment = entry.session.department;
      _currentUserId = entry.session.id;
      return entry.session;
    }
    if (entry == null && password.isNotEmpty) {
      final id = _nextUserId++;
      final session = Session(
        id: id,
        role: 'resident',
        token: 'mock-$id',
        email: email,
      );
      _accounts[email.toLowerCase()] = (password: password, session: session);
      _currentRole = 'resident';
      _currentUserId = id;
      return session;
    }
    throw const MockServiceException(
        'Login failed. Check your email and password.');
  }

  @override
  Future<SubmissionResult> createReport({
    required String description,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final text = description.toLowerCase();
    final outOfScope = <String>[
      'doctor',
      'medical',
      'sakit',
      'hospital',
      'crime'
    ].any(text.contains);
    final category = outOfScope
        ? AppStrings.outOfScope
        : text.contains('baha') || text.contains('flood')
            ? AppStrings.flooding
            : text.contains('sewer') || text.contains('kanal')
                ? AppStrings.drainageProblem
                : AppStrings.waterWaste;
    final department = outOfScope
        ? null
        : category == AppStrings.flooding
            ? AppStrings.departmentNames[1].name
            : category == AppStrings.drainageProblem
                ? AppStrings.departmentNames[4].name
                : AppStrings.departmentNames[2].name;
    final id = _nextReportId++;
    final now = DateTime.now();
    _reports.add(Report(
      reportId: id,
      residentId: _currentUserId ?? 1,
      description: description,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      predictedCategory: category,
      confidenceScore: 0.9,
      assignedDepartment: department,
      needsManualReview: false,
      status: AppStrings.received,
      createdAt: now,
      updatedAt: now,
    ));
    return SubmissionResult(
      reportId: id,
      predictedCategory: category,
      assignedDepartment: department,
      confidenceScore: 0.9,
      needsManualReview: false,
      status: AppStrings.received,
    );
  }

  @override
  Future<List<Report>> listReports({int? departmentId, String? status}) async {
    return _reports
        .where((report) => status == null || report.status == status)
        .where((report) =>
            _currentRole != 'resident' || report.residentId == _currentUserId)
        .where((report) =>
            _currentRole != 'personnel' ||
            report.assignedDepartment == _currentDepartment)
        .where((report) =>
            departmentId == null ||
            report.assignedDepartment ==
                AppStrings.departmentNameForId(departmentId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Report> getReport(int reportId) async {
    for (final report in _reports) {
      if (report.reportId == reportId) return report;
    }
    throw const MockServiceException('Report not found.');
  }

  @override
  Future<Report> updateStatus({
    required int reportId,
    required String status,
    String? resolutionNote,
  }) async {
    final index = _reports.indexWhere((report) => report.reportId == reportId);
    if (index < 0) throw const MockServiceException('Report not found.');
    final report = _reports[index];
    final updated = Report(
      reportId: report.reportId,
      residentId: report.residentId,
      description: report.description,
      imageUrl: report.imageUrl,
      latitude: report.latitude,
      longitude: report.longitude,
      predictedCategory: report.predictedCategory,
      confidenceScore: report.confidenceScore,
      assignedDepartment: report.assignedDepartment,
      needsManualReview: report.needsManualReview,
      status: status,
      createdAt: report.createdAt,
      updatedAt: DateTime.now(),
    );
    _reports[index] = updated;
    return updated;
  }

  @override
  Future<int> createPersonnel({
    required String fullName,
    required String email,
    required String password,
    required int departmentId,
  }) async {
    final id = _nextUserId++;
    final session = Session(
      id: id,
      role: 'personnel',
      token: 'mock-$id',
      fullName: fullName,
      email: email,
      department: AppStrings.departmentNameForId(departmentId),
    );
    _accounts[email.toLowerCase()] = (password: password, session: session);
    _currentRole = 'admin';
    _currentDepartment = null;
    _currentUserId = id;
    return id;
  }
}

class MockServiceException implements Exception {
  const MockServiceException(this.message);

  final String message;
}
