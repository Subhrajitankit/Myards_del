import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';


class OrderRow {
  final String label;
  final double value;
  const OrderRow({required this.label, required this.value});
}

// ─── Card widget ──────────────────────────────────────────────────────────────

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderId,
    required this.dateTime,
    required this.rows,
    required this.netProfitLabel,
    required this.netProfitValue,
  });

  final String orderId;
  final String dateTime;
  final List<OrderRow> rows;
  final String netProfitLabel;
  final double netProfitValue;



  @override
  Widget build(BuildContext context) {
    // Merge regular rows + net-profit into ONE list → ONE Table.
    // This guarantees every colon sits in the exact same column.
    final allRows = [
      ...rows,
      OrderRow(label: netProfitLabel, value: netProfitValue),
    ];
    final lastIndex = allRows.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withAlpha(50),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: robotoBlack.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                    children: [
                      TextSpan(
                        text: (AppConstants.appMode == AppMode.delivery ? 'order' : 'ride').tr,
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200)),
                      ),
                      TextSpan(
                        text: ' $orderId',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Dimensions.paddingSizeDefault,),
                Text(dateTime.tr),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Theme.of(context).disabledColor.withAlpha(100)),

          // ── ONE Table covers ALL rows including Net Profit ─────────────
          //
          //   Column 0 – IntrinsicColumnWidth  widest label sets the width
          //   Column 1 – IntrinsicColumnWidth  just enough for " : "
          //   Column 2 – FlexColumnWidth       fills remaining space
          //
          //   The net-profit TableRow receives a BoxDecoration with the
          //   pink background so it looks like a separate section while
          //   still sharing the exact same column layout.
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: List.generate(allRows.length, (i) {
              final row = allRows[i];
              final isNetProfit = i == lastIndex;

              final labelStyle = robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200));
              final valueStyle = isNetProfit ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor) : robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200));

              final double topPad = isNetProfit
                  ? Dimensions.paddingSizeDefault
                  : (i == 0 ? Dimensions.paddingSizeDefault : Dimensions.fontSizeExtraSmall);

              final double bottomPad = isNetProfit
                  ? Dimensions.paddingSizeDefault
                  : Dimensions.paddingSizeExtraSmall;

              return TableRow(
                decoration: isNetProfit ? BoxDecoration(color: Theme.of(context).hintColor.withAlpha(10)) : null,
                children: [
                  // Label
                  isNetProfit ? Padding(
                    padding: EdgeInsets.only(left : Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(row.label.tr, style: labelStyle),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: '${'net_income'.tr} = ${'total_earning'.tr} - ${'total_expense'.tr}',
                          triggerMode: TooltipTriggerMode.tap,
                          waitDuration: Duration.zero,
                          showDuration: const Duration(seconds: 3),
                          child: CustomAssetImageWidget(image: Images.noteIcon, color: Theme.of(context).hintColor, height: Dimensions.fontSizeSmall, width: Dimensions.fontSizeSmall,),
                        ),
                      ],
                    ),
                  ) : Padding(
                    padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Text(row.label.tr, style: labelStyle),
                  ),

                  // Colon
                  Padding(
                    padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Text(' : ', style: labelStyle),
                  ),

                  // Value
                  Padding(
                    padding: EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(PriceConverterHelper.convertPrice(row.value), style: valueStyle),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
