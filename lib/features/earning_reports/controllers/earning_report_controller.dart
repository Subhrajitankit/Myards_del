import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/emun/filter_type.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/services/report_service_interface.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/enums.dart';

class EarningReportController extends GetxController implements GetxService {
  final EarningReportServiceInterface earningReportServiceInterface;

  EarningReportController({required this.earningReportServiceInterface});

  int? _pageSize;
  int? get pageSize => _pageSize;

  final List<String> _offsetList = [];

  int _offset = 1;
  int get offset => _offset;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _from;
  String? get from => _from;

  String? _to;
  String? get to => _to;

  FilterType _selectedFilter = FilterType.all;
  FilterType get selectedFilter => _selectedFilter;

  bool get isFiltered => _selectedFilter != FilterType.all;

  EarningReportModel? _earningReportModel;
  EarningReportModel? get getEarningReportModel => _earningReportModel;

  List<TransactionData>? _transactions;
  List<TransactionData>? get transactions => _transactions;

  void initSetDate() {
    _selectedFilter = FilterType.all;
    _from = DateConverterHelper.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 10000)));
    _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
  }

  Future<void> getEarningReport({required String offset, required String? from, required String? to}) async {
    final formattedFrom = _convertDateFormat(from ?? '');
    final formattedTo = _convertDateFormat(to ?? '');

    if (offset == '1') {
      _offsetList.clear();
      _offset = 1;
      _transactions = null;
      _earningReportModel = null;
      _pageSize = null;
      _isLoading = true;
      update();
    }

    if (_offsetList.contains(offset)) {
      if (_isLoading) {
        _isLoading = false;
        update();
      }
      return;
    }

    _offsetList.add(offset);
    _isLoading = true;
    update();

    final EarningReportModel? model = await earningReportServiceInterface.getEarningReport(
      offset: int.parse(offset),
      from: formattedFrom,
      to: formattedTo,
      isDelivery : AppConstants.appMode == AppMode.delivery,
    );

    if (model != null) {
      _earningReportModel = model;
      _transactions ??= [];

      if (offset == '1') {
        _transactions!.clear();
      }

      if (model.transactions?.data != null) {
        _transactions!.addAll(model.transactions!.data!);
      }

      _pageSize = model.transactions?.totalSize;
      _offset = int.parse(offset);
    }

    _isLoading = false;
    update();
  }

  List<Map<String, dynamic>> getEarningData() {
    return [
      {
        'label': AppConstants.appMode == AppMode.delivery ? 'delivery_charge' : 'ride_charge',
        'value': getEarningReportModel?.summary?.breakdown?.deliveryCharge ?? 0.0,
      },
      {
        'label': 'total_tips',
        'value': getEarningReportModel?.summary?.breakdown?.dmTips ?? 0.0,
      },
    ];
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void showDatePicker(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'done'.tr,
      confirmText: 'done'.tr,
      cancelText: 'cancel'.tr,
      fieldStartLabelText: 'start_date'.tr,
      fieldEndLabelText: 'end_date'.tr,
      errorInvalidRangeText: 'select_range'.tr,
    );

    if (result == null) {
      return;
    }

    _selectedFilter = FilterType.custom;
    _from = result.start.toString().split(' ')[0];
    _to = result.end.toString().split(' ')[0];
    update();

    getEarningReport(offset: '1', from: _from, to: _to);
  }

  void setFilter(String filterText) {
    _selectedFilter = FilterType.values.firstWhere((filter) => filter.name == filterText, orElse: () => FilterType.all);

    if (filterText == FilterType.all.name) {
      _from = DateConverterHelper.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 10000)));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
    } else if (filterText == FilterType.thisYear.name) {
      _from = DateConverterHelper.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 365)));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
    } else if (filterText == FilterType.previousYear.name) {
      final DateTime now = DateTime.now();
      _from = DateConverterHelper.dateTimeForCoupon(DateTime(now.year - 1, 1, 1));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime(now.year - 1, 12, 31));
    } else if (filterText == FilterType.thisMonth.name) {
      final DateTime now = DateTime.now();
      _from = DateConverterHelper.dateTimeForCoupon(DateTime(now.year, now.month, 1));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
    } else if (filterText == FilterType.thisWeek.name) {
      final DateTime now = DateTime.now();
      final int currentWeekday = now.weekday;
      _from = DateConverterHelper.dateTimeForCoupon(now.subtract(Duration(days: currentWeekday - 1)));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
    }

    getEarningReport(offset: '1', from: _from, to: _to);
  }
}

/// MM/dd/yyyy -> yyyy-MM-dd
String _convertDateFormat(String inputDate) {
  try {
    if (inputDate.contains('-')) {
      return inputDate;
    }
    final parts = inputDate.split('/');

    if (parts.length != 3) {
      return '';
    }

    final month = parts[0].padLeft(2, '0');
    final day = parts[1].padLeft(2, '0');
    final year = parts[2];

    return '$year-$month-$day';
  } catch (_) {
    return '';
  }
}
