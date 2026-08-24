import 'package:sixam_mart_delivery/features/earning_reports/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/interface/repository_interface.dart';

abstract class EarningReportRepositoryInterface implements RepositoryInterface {
  Future<EarningReportModel?> getEarningReport({required int offset, required String? from, required String? to, required bool isDelivery});
}
