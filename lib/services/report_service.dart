import 'bayan_sense_service.dart';
import 'mock_bayan_sense_service.dart';

abstract interface class ReportService implements BayanSenseService {}

class EmptyReportService extends MockBayanSenseService
    implements ReportService {}
