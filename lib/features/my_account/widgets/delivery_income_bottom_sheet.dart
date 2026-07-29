import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/delivery_income_statement_model.dart';
import 'package:sixam_mart_delivery/features/my_account/widgets/payment_item_info_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class DeliveryIncomeBottomSheet extends StatelessWidget {
  final DeliveryIncomeStatement? statement;
  const DeliveryIncomeBottomSheet({super.key, required this.statement});

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

            Text('${'order_id'.tr}# ${statement!.orderId}'.tr,
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
                  title: 'delivery_charge'.tr,
                  amount: statement?.originalDeliveryCharge ?? 0,
                ),


                PaymentItemInfoWidget(
                  icon: Images.discountAmount,
                  title: 'admin_commission'.tr,
                  amount: statement?.deliveryFeeComission ?? 0,
                  discount: true,
                ),


                PaymentItemInfoWidget(
                  icon: Images.tipsSmallIcon,
                  title: 'deliveryman_tips'.tr,
                  amount: statement?.dmTips ?? 0,
                ),


                PaymentItemInfoWidget(
                  title: 'sub_total'.tr,
                  amount: _calculateDriverIncome(
                      statement?.originalDeliveryCharge  ?? 0, statement?.deliveryFeeComission ?? 0 , statement?.dmTips ?? 0
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

  double _calculateDriverIncome(double originalDeliveryCharge, double deliveryFeeCommission, double dmTips){
    return originalDeliveryCharge + dmTips - deliveryFeeCommission;
  }

}
