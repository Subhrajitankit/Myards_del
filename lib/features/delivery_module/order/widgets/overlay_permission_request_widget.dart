import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/helper/myards_overlay_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class OverlayPermissionRequestWidget extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const OverlayPermissionRequestWidget({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                size: 48,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Title
            Text(
              'Enable Floating Order Alerts',
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Description
            Text(
              'Allow Myards Delivery Partner to show new delivery requests over other apps so you do not miss orders.',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Enable Button
            CustomButtonWidget(
              buttonText: 'Enable Now',
              onPressed: () async {
                await MyardsOverlayHelper.requestOverlayPermission();
                Navigator.of(context).pop();
                onPermissionGranted?.call();
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Later Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPermissionDenied?.call();
                },
                child: Text(
                  'Later',
                  style: robotoMedium.copyWith(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
