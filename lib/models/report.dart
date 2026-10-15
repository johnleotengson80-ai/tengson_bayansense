/// The category name the server uses for concerns BayanSense does not handle.
const String outOfScopeCategory = 'Out of Scope';

/// "BS-0101": the reference number shown to residents (the report id, zero-padded).
String referenceFor(int reportId) => 'BS-${reportId.toString().padLeft(4, '0')}';

/// A full report as returned by GET /reports and GET /reports/{id} (CON-04).
class Report {
  const Report({
    required this.reportId,
    required this.residentId,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.predictedCategory,
    required this.confidenceScore,
    required this.assignedDepartment,
    required this.needsManualReview,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.residentName,
    this.contactNumber,
  });

  final int reportId;
  final int residentId;
  final String description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? predictedCategory;
  final double? confidenceScore;
  final String? assignedDepartment;
  final bool needsManualReview;

  /// 'Received' | 'In Progress' | 'Resolved'
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? residentName;
  final String? contactNumber;

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        reportId: json['report_id'] as int,
        residentId: json['resident_id'] as int,
        description: json['description'] as String,
        imageUrl: json['image_url'] as String?,
        // JSON numbers may arrive as int or double (always int-like on web), so go through num.
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        predictedCategory: json['predicted_category'] as String?,
        confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
        assignedDepartment: json['assigned_department'] as String?,
        needsManualReview: json['needs_manual_review'] as bool,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        residentName: json['resident_name'] as String?,
        contactNumber: json['contact_number'] as String?,
      );

  String get referenceNumber => referenceFor(reportId);
  bool get isOutOfScope => predictedCategory == outOfScopeCategory;
}
