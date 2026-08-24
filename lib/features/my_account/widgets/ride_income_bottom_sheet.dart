import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/domain/models/trip_details_model.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class RideIncomeBottomSheet extends StatelessWidget {
  final RideDetails tripDetail;
  const RideIncomeBottomSheet({super.key, required this.tripDetail});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(width: double.infinity,
          decoration: BoxDecoration(color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft:  Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 4, width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(50)
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text('${'ride'.tr}# ${tripDetail.refId}'.tr,
              style: robotoBold,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                color: Theme.of(context).disabledColor.withValues(alpha: 0.06)
              ),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(children: [
                PaymentItemInfoWidget(
                  icon: Images.farePrice,
                  title: 'fare_price'.tr,
                  amount: _calculateFarePrice(
                   tripDetail.paidFare ?? 0,
                   tripDetail.adminCommission ?? 0,
                    tripDetail.tips ?? 0,
                  ),
                  toolTipText: 'include_idle_waiting_fee'.tr,
                ),

                if(tripDetail.couponAmount != 0 )
                  PaymentItemInfoWidget(
                    icon: Images.deliveryIncome,
                    title: 'coupon_amount'.tr,
                    amount: tripDetail.couponAmount ?? 0,
                  ),

                if(tripDetail.discountAmount != 0 )
                  PaymentItemInfoWidget(
                    icon: Images.discountAmount,
                    title: 'discount_amount'.tr,
                    amount: tripDetail.discountAmount ?? 0,
                  ),

                if(tripDetail.tips != 0 )
                  PaymentItemInfoWidget(
                    icon: Images.tipsSmallIcon,
                    title: 'tips'.tr,
                    amount: tripDetail.tips ?? 0,
                  ),

                PaymentItemInfoWidget(
                  title: 'sub_total'.tr,
                  amount: _calculateSubTotal(
                    tripDetail.paidFare ?? 0,
                    tripDetail.adminCommission ?? 0,
                    tripDetail.couponAmount ?? 0,
                    tripDetail.discountAmount ?? 0,
                  ),
                  isSubTotal: true,
                ),


              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,color: Colors.amber, size: 20,),
                const SizedBox(width: 7),

                Flexible( child: Text('income_hint_note'.tr,style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  fontSize: Dimensions.fontSizeSmall
                )))
              ]),
            )

          ]),
        ),
      ),
    );
  }

  double _calculateFarePrice(
      double paidFare, double adminCommission, double tips
      ){
    return paidFare   - adminCommission - tips;
  }

  double _calculateSubTotal(
      double paidFare, double adminCommission, double coupon, double discount,
      ){
    return paidFare + coupon + discount  - adminCommission;
  }
}


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
  const PaymentItemInfoWidget({
    super.key, required this.title,  this.icon, required this.amount,  this.isSubTotal = false,
    this.isFromTripDetails = false, this.paymentType,  this.discount = false, this.toolTipText,
    this.subTitle
  });

  @override
  State<PaymentItemInfoWidget> createState() => _PaymentItemInfoWidgetState();
}

class _PaymentItemInfoWidgetState extends State<PaymentItemInfoWidget> {
  JustTheController tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if(widget.icon != null)
          SizedBox(width: 15, child: Image.asset(widget.icon!)),

        if(widget.icon != null)
          const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
          Row(children: [
            Text(
              widget.title,
              style: !widget.isSubTotal ? robotoRegular : robotoMedium,
            ),
            widget.toolTipText != null ? JustTheTooltip(
              backgroundColor: Get.isDarkMode ?
              Theme.of(context).primaryColor :
              Theme.of(context).textTheme.bodyMedium!.color,
              controller: tooltipController,
              preferredDirection: AxisDirection.right,
              tailLength: 10,
              tailBaseWidth: 20,
              content: Container(width: 150,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Text(
                  widget.toolTipText!.tr,
                  style: robotoRegular.copyWith(
                    color: Colors.white, fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
              child: InkWell(
                onTap: () async {
                  tooltipController.showTooltip();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Icon(Icons.info,color: Theme.of(context).colorScheme.primaryContainer, size: 16),
                ),
              ),
            ) : const SizedBox()
          ]),

          widget.subTitle != null ?
          Text(
            widget.subTitle!.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ) : const SizedBox()
        ])),

        widget.isSubTotal || widget.isFromTripDetails ?
        Text(
          PriceConverterHelper.convertPrice( widget.amount),
          style: robotoMedium,
        ) : widget.paymentType != null ? Text(widget.paymentType!,style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)) :

        widget.discount ? Text(
          '-${PriceConverterHelper.convertPrice(widget.amount)}',
          style: robotoRegular,
        ) : Text(
          PriceConverterHelper.convertPrice(widget.amount),
          style: robotoRegular,
        ),

      ]),
    );
  }
}