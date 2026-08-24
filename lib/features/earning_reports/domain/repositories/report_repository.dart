import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/repositories/report_repository_interface.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';

class EarningReportRepository implements EarningReportRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  EarningReportRepository({required this.apiClient, required this.sharedPreferences});

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<EarningReportModel?> getEarningReport({required int offset, required String? from, required String? to, required bool isDelivery}) async {
    EarningReportModel? earningReportModel;
    final filterParam = (from != null && to != null && from.isNotEmpty && to.isNotEmpty) ? '&filter=custom&from=$from&to=$to' : '';
    Response response = await apiClient.getData('${isDelivery ? AppConstants.newEarningReportUri : AppConstants.riderEarningReportUri}?limit=10&offset=$offset$filterParam&token=${_getUserToken()}');
    if(response.statusCode == 200) {
      earningReportModel = EarningReportModel.fromJson(response.body);
      log("earning report response: ${response.body}");
    }
    return earningReportModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> get(int? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
}
