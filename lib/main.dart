import 'package:flutter/material.dart';

import 'app.dart';
import 'config.dart';
import 'services/api_client.dart';
import 'services/report_service.dart';
import 'services/token_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BayanSenseApp(
    api: ApiClient(baseUrl: apiBaseUrl),
    tokenStore: PrefsTokenStore(),
    reportService: EmptyReportService(),
  ));
}
