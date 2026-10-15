import 'report.dart';

/// What the server returns right after a report is submitted (CON-01).
class SubmissionResult {
  const SubmissionResult({
    required this.reportId,
    required this.predictedCategory,
    required this.assignedDepartment,
    required this.confidenceScore,
    required this.needsManualReview,
    required this.status,
  });

  final int reportId;
  final String? predictedCategory;
  final String? assignedDepartment;
  final double? confidenceScore;
  final bool needsManualReview;
  final String status;

  factory SubmissionResult.fromJson(Map<String, dynamic> json) => SubmissionResult(
        reportId: json['report_id'] as int,
        predictedCategory: json['predicted_category'] as String?,
        assignedDepartment: json['assigned_department'] as String?,
        confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
        needsManualReview: json['needs_manual_review'] as bool,
        status: json['status'] as String,
      );

  String get referenceNumber => referenceFor(reportId);
  bool get isOutOfScope => predictedCategory == outOfScopeCategory;
}
