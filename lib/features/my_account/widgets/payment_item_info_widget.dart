import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';


class PaymentItemInfoWidget extends StatefulWidget {
  final String? icon;
  final String title;
  final double amount;
  final bool isSubTotal;
  final bool isFromTripDetails;
  final String? paymentType;
  final bool discount;
  final String? toolTipText;
  final String? subTitle;

  const PaymentItemInfoWidget({super.key, this.icon, required this.title, required this.amount,  this.isSubTotal = false,
    this.isFromTripDetails = false, this.paymentType, this.discount = false,this.subTitle,this.toolTipText});

  @override
  State<PaymentItemInfoWidget> createState() => _PaymentItemInfoWidgetState();
}

class _PaymentItemInfoWidgetState extends State<PaymentItemInfoWidget> {
  JustTheController tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    return (widget.amount > 0) ? Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if(widget.icon != null)
          SizedBox(width: 15, child: Image.asset(widget.icon!)),

        if(widget.icon != null)
          const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
          Row(children: [
            Text(widget.title, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)),

            widget.toolTipText != null ?
            JustTheTooltip(
              backgroundColor:Get.isDarkMode ?
              Theme.of(context).primaryColor :
              Theme.of(context).textTheme.bodyMedium!.color,
              controller: tooltipController,
              preferredDirection: AxisDirection.right,
              tailLength: Dimensions.paddingSizeSmall,
              tailBaseWidth: Dimensions.paddingSizeLarge,
              content: Container(width: Get.width * 0.45,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Text(widget.toolTipText!.tr,
                      style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault))),
              child: InkWell(
                  onTap: () async {
                    tooltipController.showTooltip();
                  },

                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Icon(Icons.info,color: Theme.of(context).primaryColor,size: 16))),
            ) : const SizedBox()]),

          widget.subTitle != null ?
          Text(
            widget.subTitle!.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ) : const SizedBox()
        ])),

        widget.isSubTotal || widget.isFromTripDetails ?
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha:.15),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
          ),
          child: Text(
            PriceConverterHelper.convertPrice(widget.amount),
            style: robotoMedium.copyWith(
              color: Get.isDarkMode ? Colors.white : Theme.of(context).primaryColorDark,
            ),
          ),
        ) :
        widget.paymentType != null ?
        Text(widget.paymentType!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)) :
        widget.discount ?
        Text(
          '-${PriceConverterHelper.convertPrice(widget.amount)}',
          style: robotoRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ) :
        Text(
          PriceConverterHelper.convertPrice(widget.amount),
          style: robotoRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),

      ]),
    ) : const SizedBox();
  }
}