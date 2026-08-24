import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/features/earning_reports/controllers/earning_report_controller.dart';
import 'package:sixam_mart_delivery/features/earning_reports/domain/emun/filter_type.dart';
import 'package:sixam_mart_delivery/features/earning_reports/widgets/earning_card_widget.dart';
import 'package:sixam_mart_delivery/features/earning_reports/widgets/transaction_card_widget.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';


class EarningReportScreen extends StatefulWidget {
  const EarningReportScreen({super.key});

  @override
  State<EarningReportScreen> createState() => _EarningReportScreenState();
}

class _EarningReportScreenState extends State<EarningReportScreen> {
  final ScrollController scrollController = ScrollController();
  final Color earningColor = Color(0xFF04BB7B);
  final Color expenseColor = Color(0xFFE6A832);
  final Color profitColor = Color(0xFF245BD1);

  @override
  void initState() {
    super.initState();

    Get.find<EarningReportController>().setOffset(1);
    Get.find<EarningReportController>().initSetDate();
    Get.find<EarningReportController>().getEarningReport(offset: '1', from: Get.find<EarningReportController>().from, to: Get.find<EarningReportController>().to,);

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<EarningReportController>().transactions != null && !Get.find<EarningReportController>().isLoading) {
        int pageSize = (Get.find<EarningReportController>().pageSize! / 10).ceil();
        if (Get.find<EarningReportController>().offset < pageSize) {
          Get.find<EarningReportController>().showBottomLoader();
          Get.find<EarningReportController>().getEarningReport(offset: (Get.find<EarningReportController>().offset + 1).toString(), from: Get.find<EarningReportController>().from, to: Get.find<EarningReportController>().to,);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EarningReportController>(builder: (reportController) {
      return Scaffold(
        appBar: CustomAppBarWidget(
          title: 'earning_report'.tr,
          actionWidget: PopupMenuButton<FilterType>(
            position: PopupMenuPosition.under,
            initialValue: reportController.selectedFilter,
            itemBuilder: (context) {
              return <PopupMenuEntry<FilterType>>[
                PopupMenuItem<FilterType>(
                  value: FilterType.all,
                  child: SizedBox(width: 100, child: Text('all_the_time'.tr, style: robotoRegular)),
                ),

                PopupMenuItem<FilterType>(
                  value: FilterType.thisYear,
                  child: Text('this_year'.tr, style: robotoRegular),
                ),

                PopupMenuItem<FilterType>(
                  value: FilterType.previousYear,
                  child: Text('previous_year'.tr, style: robotoRegular),
                ),

                PopupMenuItem<FilterType>(
                  value: FilterType.thisMonth,
                  child: Text('this_month'.tr, style: robotoRegular),
                ),

                PopupMenuItem<FilterType>(
                  value: FilterType.thisWeek,
                  child: Text('this_week'.tr, style: robotoRegular),
                ),

                PopupMenuItem<FilterType>(
                  value: FilterType.custom,
                  child: Text('custom'.tr, style: robotoRegular),
                ),

              ];
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                  ),
                  child: Icon(Icons.tune_rounded, color: Theme.of(context).colorScheme.secondary, size: 20),
                ),

                if(reportController.isFiltered)
                  Positioned(
                    top: 5, right: 5,
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Container(
                        height: 10, width: 10,
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle,),
                      ),
                    ),
                  ),
              ],
            ),
            onSelected: (FilterType value) {
              if (value == FilterType.all) {
                reportController.setFilter(FilterType.all.name);
              }else if (value == FilterType.thisYear) {
                reportController.setFilter(FilterType.thisYear.name);
              }else if (value == FilterType.previousYear) {
                reportController.setFilter(FilterType.previousYear.name);
              }else if (value == FilterType.thisMonth) {
                reportController.setFilter(FilterType.thisMonth.name);
              }else if (value == FilterType.thisWeek) {
                reportController.setFilter(FilterType.thisWeek.name);
              } else{
                reportController.showDatePicker(context);
              }
            },
          ),
        ),

        // note: remove from here static condition
        body:  SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [

            Column(children: [
              /// total earning
              EarningCardWidget(
                cardColor: earningColor.withAlpha(50),
                icon: Images.dollerIcon,
                iconColor: earningColor,
                title: 'total_earning_with_admin_commission'.tr,
                amount:reportController.getEarningReportModel?.summary?.totalEarnings?.toDouble() ?? 0.0,
                data: reportController.getEarningData(),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

              Row(children: [
                /// Commission Paid
                Expanded(child: EarningCardWidget(
                  cardColor: expenseColor.withAlpha(50),
                  icon: Images.dollerIcon,
                  iconColor: expenseColor,
                  title: 'commission_paid'.tr,
                  amount:reportController.getEarningReportModel?.summary?.totalExpenses?.toDouble() ?? 0.0,
                )),
                const SizedBox(width: Dimensions.paddingSizeDefault,),

                /// Net Profit
                Expanded(child: EarningCardWidget(
                  cardColor: profitColor.withAlpha(50),
                  icon: Images.walletIconSign,
                  iconColor: profitColor,
                  title: 'net_income'.tr,
                  amount:reportController.getEarningReportModel?.summary?.netProfit?.toDouble() ?? 0.0,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

              /// Recent Transactions
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appMode == AppMode.delivery ? "recent_transactions".tr : 'ride'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  reportController.transactions == null ?
                  const Center(child: CircularProgressIndicator())
                  : (reportController.transactions!.isEmpty) ?
                    Padding(padding: EdgeInsets.only(top: context.height * 0.2),
                      child: Center(child: Text(
                        'no_transaction_found'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6),
                        ),
                      )),
                    ) : ListView.builder(
                      itemCount: reportController.transactions!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final txn = reportController.transactions![index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                          child: OrderCard(
                            orderId: txn.orderId ?? txn.rideId ?? '',
                            dateTime: DateConverterHelper.isoStringToLocalDateTime(txn.date!),
                            rows: [
                              if ((txn.deliveryCharge ?? 0) > 0) OrderRow(label: 'delivery_charge', value: txn.deliveryCharge!),
                              if ((txn.incentive ?? 0) > 0) OrderRow(label: 'incentive', value: txn.incentive!),
                              if ((txn.rideCost ?? 0) > 0) OrderRow(label: 'ride_cost', value: txn.rideCost!),
                              if ((txn.commissionPaid ?? 0) > 0) OrderRow(label: 'commission_paid', value: txn.commissionPaid!),
                              if ((txn.vatTex ?? 0) > 0) OrderRow(label: 'vat_tax', value: txn.vatTex!),
                              if ((txn.tips ?? 0) > 0) OrderRow(label: 'tips', value: txn.tips!),
                            ],
                            netProfitLabel: 'net_income',
                            netProfitValue: txn.netProfit ?? 0,
                          ),
                        );
                      },
                    ),

                  if (reportController.isLoading && reportController.transactions != null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                    ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ]),

          ]),
        ),
      );
    });
  }
}
