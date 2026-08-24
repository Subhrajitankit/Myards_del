import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/dotted_divider.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatelessWidget {
  final bool isUpdate;
  const UpdateScreen({super.key, required this.isUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SplashController>(builder: (splashController) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          
                Image.asset(
                  isUpdate ? Images.update : Images.maintenance,
                  width: MediaQuery.of(context).size.height*0.3,
                  height: MediaQuery.of(context).size.height*0.3,
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
          
                Text(
                  isUpdate ? 'update'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.maintenanceMessage ?? 'we_re_cooking_up_something_special'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
          
                Text(
                  isUpdate ? 'your_app_is_deprecated'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.messageBody ?? 'maintenance_message'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isUpdate ? MediaQuery.of(context).size.height*0.04 : MediaQuery.of(context).size.height*0.05),
          
                if(!isUpdate)
                  Column(children: [
            
                    splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessEmail == 1
                    || splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? Column(
                      children: [
            
                        SizedBox(
                          width:  context.width,
                          child: DottedDivider(dashWidth: 10, color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                        ),
                        SizedBox(height: Dimensions.paddingSizeLarge),
            
                        Text(
                          'any_query_feel_free_to_contact'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
            
                        InkWell(
                          onTap: () async {
                            if(await canLaunchUrlString('tel:${splashController.configModel?.phone}')) {
                              launchUrlString('tel:${splashController.configModel?.phone}', mode: LaunchMode.externalApplication);
                            }else {
                              showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.phone}');
                            }
                          },
                          child: Text(
                            splashController.configModel?.phone ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                          ),
                        ) ,
                        SizedBox(height: splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? Dimensions.paddingSizeExtraSmall : 0),
            
                        InkWell(
                          onTap: () async {
                            if(await canLaunchUrlString('mailto:${splashController.configModel?.email}')) {
                              launchUrlString('mailto:${splashController.configModel?.email}', mode: LaunchMode.externalApplication);
                            }else {
                              showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.email}');
                            }
                          },
                          child: Text(
                            splashController.configModel?.email ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                          ),
                        ) ,
                      ],
                    ) : const SizedBox(),
            
                  ]),
                SizedBox(height: isUpdate ? 0 : MediaQuery.of(context).size.height*0.04),
          
                isUpdate ? CustomButtonWidget(buttonText: 'update_now'.tr, onPressed: () async {
                  String? appUrl = 'https://google.com';
          
                  if(GetPlatform.isAndroid) {
                    appUrl = Get.find<SplashController>().configModel!.appUrlAndroid;
                  }else if(GetPlatform.isIOS) {
                    appUrl = Get.find<SplashController>().configModel!.appUrlIos;
                  }
                  if(await canLaunchUrlString(appUrl!)) {
                    launchUrlString(appUrl, mode: LaunchMode.externalApplication);
                  }else {
                    showCustomSnackBar('${'can_not_launch'.tr} $appUrl');
                  }
                }) : const SizedBox(),
          
              ]),
            ),
          );
        }
      ),
    );
  }
}