import 'package:flutter/material.dart';

import 'app.dart';
import 'config.dart';
import 'services/api_client.dart';
import 'services/bayan_sense_service.dart';
import 'services/mock_bayan_sense_service.dart';
import 'services/token_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final BayanSenseService service = AppConfig.useMock
      ? MockBayanSenseService()
      : ApiClient(baseUrl: AppConfig.apiBaseUrl);
  runApp(BayanSenseApp(
    service: service,
    tokenStore: PrefsTokenStore(),
  ));
}
