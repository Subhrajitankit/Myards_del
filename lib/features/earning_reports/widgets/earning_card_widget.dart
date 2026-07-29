
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class EarningCardWidget extends StatelessWidget {
  final Color cardColor;
  final String icon;
  final Color iconColor;
  final String title;
  final double amount;
  final List<Map<String,dynamic>>? data;
  final String? profitText;
  const EarningCardWidget({super.key, required this.cardColor, required this.icon, required this.iconColor, required this.title, this.data, this.profitText, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeExtraSmall)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(PriceConverterHelper.convertPrice(amount), style: robotoSemiBold.copyWith(color: iconColor, fontSize: Dimensions.fontSizeLarge)),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
            ),
            child: CustomAssetImageWidget(image: icon,height: 30,width: 30)
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        if(data != null) SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: data!.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                margin: EdgeInsets.only(right: index == (data?.length ?? 0) - 1 ? 0 : Dimensions.paddingSizeSmall),
                width: 240,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Theme.of(context).hintColor.withValues(alpha: 0.3) : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Expanded(
                    child: Text(
                      '${data![index]['label']}'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                  ),
                  SizedBox(width: Dimensions.paddingSizeSmall,),

                  (data![index]['value'] is double || data![index]['value'] is int) ?
                  Text(
                    PriceConverterHelper.convertPrice(data![index]['value'].toDouble()),
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ) : Text(
                    "${Get.find<SplashController>().configModel!.currencySymbol!} ${ data![index]['value']?.toString()}",
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),

                ]),
              );
            },
          ),
        ),

        if(profitText != null)  Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Theme.of(context).hintColor.withValues(alpha: 0.3) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(
            children: [
              CustomAssetImageWidget(image: Images.noteIcon, height: 12, width: 12, color: iconColor,),
              SizedBox(width: Dimensions.paddingSizeSmall,),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    profitText!,
                    maxLines: 1,
                    style: robotoMedium.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )

      ]),
    );
  }
}
