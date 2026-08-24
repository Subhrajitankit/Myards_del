import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class PricingCard extends StatelessWidget {
  final String image;
  final String title;
  final double amount;
  const PricingCard({super.key, required this.image, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 5, spreadRadius: 1)],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Image.asset(image, height: 40, width: 40, fit: BoxFit.cover),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(PriceConverterHelper.convertPrice(amount), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),

      ]),
    );
  }
}