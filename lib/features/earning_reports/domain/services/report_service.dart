import 'package:sixam_mart_delivery/features/earning_reports/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/repositories/report_repository_interface.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/services/report_service_interface.dart';

class EarningReportService implements EarningReportServiceInterface {
  final EarningReportRepositoryInterface earningReportRepositoryInterface;
  EarningReportService({required this.earningReportRepositoryInterface});

  @override
  Future<EarningReportModel?> getEarningReport({required int offset, required String? from, required String? to, required bool isDelivery}) async {
    return earningReportRepositoryInterface.getEarningReport(
      offset: offset,
      from: from,
      to: to,
      isDelivery: isDelivery
    );
  }
}
