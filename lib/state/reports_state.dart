import 'package:flutter/foundation.dart';

import '../error_messages.dart';
import '../models/report.dart';
import '../models/submission_result.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// The signed-in resident's reports (My Reports) and report submission.
class ReportsState extends ChangeNotifier {
  ReportsState(this._api);

  final ApiClient _api;

  List<Report> _items = const [];
  bool _loading = false;
  bool _loadedOnce = false;
  String? _error;

  List<Report> get items => _items;
  bool get loading => _loading;

  /// False until a load succeeds (so "no reports yet" is never shown before we actually know).
  bool get loadedOnce => _loadedOnce;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _api.listMyReports();
      _loadedOnce = true;
    } on ApiException catch (e) {
      _error = messageForLoadList(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// One report by id (the detail screen). Throws [ApiException]; the screen shows the message.
  Future<Report> fetchReport(int reportId) => _api.getReport(reportId);

  /// Throws [ApiException] on failure; the screen shows the message.
  Future<SubmissionResult> submit(String description) async {
    final result = await _api.createReport(description: description.trim());
    _loadedOnce = false; // the list is now out of date; My Reports reloads when opened
    return result;
  }

  /// Forget everything (called when the user signs out, so the next user never sees it).
  void reset() {
    _items = const [];
    _loading = false;
    _loadedOnce = false;
    _error = null;
    notifyListeners();
  }
}
