import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/myards_app_card.dart';
import 'package:sixam_mart_delivery/common/widgets/myards_primary_button.dart';
import 'package:sixam_mart_delivery/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_details_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_location_screen.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/myards_theme_tokens.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

Future<void> showMyardsOrderRequestPopup(
  BuildContext context,
  OrderModel order, {
  required VoidCallback onClosed,
  required VoidCallback onIgnoreSuccess,
  VoidCallback? onNavigateAfterAccept,
}) async {
  final orderController = Get.find<OrderController>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.60),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(MyardsRadius.lg),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            MyardsSpacing.lg,
            MyardsSpacing.lg,
            MyardsSpacing.lg,
            MyardsSpacing.lg,
          ),
          child: _MyardsOrderRequestPopupBody(
            order: order,
            orderController: orderController,
            onIgnoreSuccess: onIgnoreSuccess,
            onNavigateAfterAccept: onNavigateAfterAccept,
          ),
        ),
      );
    },
  ).whenComplete(onClosed);
}

class _MyardsOrderRequestPopupBody extends StatelessWidget {
  final OrderModel order;
  final OrderController orderController;
  final VoidCallback onIgnoreSuccess;
  final VoidCallback? onNavigateAfterAccept;

  const _MyardsOrderRequestPopupBody({
    required this.order,
    required this.orderController,
    required this.onIgnoreSuccess,
    required this.onNavigateAfterAccept,
  });

  @override
  Widget build(BuildContext context) {
    final bool isParcel = order.orderType == 'parcel';
    final bool isPrescription = order.prescriptionOrder ?? false;
    final String requestId = order.id?.toString() ?? '';

    final double distance = Get.find<AddressController>().getRestaurantDistance(
      LatLng(
        double.tryParse(
              isParcel
                  ? order.deliveryAddress?.latitude ?? '0'
                  : order.storeLat ?? '0',
            ) ??
            0,
        double.tryParse(
              isParcel
                  ? order.deliveryAddress?.longitude ?? '0'
                  : order.storeLng ?? '0',
            ) ??
            0,
      ),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'New Delivery Request',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: MyardsColors.textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                splashRadius: 22,
              ),
            ],
          ),
          Text(
            'You have a new order to pick up',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: MyardsSpacing.sm),
          MyardsAppCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(MyardsRadius.sm),
                      child: CustomImageWidget(
                        image: isParcel
                            ? (order.parcelCategory?.imageFullUrl ?? '')
                            : (order.storeLogoFullUrl ?? ''),
                        height: 52,
                        width: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: MyardsSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isParcel
                                ? (order.parcelCategory?.name ?? '')
                                : (order.storeName ?? 'no_store_data_found'.tr),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          const SizedBox(height: MyardsSpacing.xs),
                          if (!isPrescription || isParcel)
                            Text(
                              isParcel
                                  ? 'parcel'.tr
                                  : '${order.detailsCount ?? 0} ${(order.detailsCount ?? 0) > 1 ? 'items'.tr : 'item'.tr}',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: MyardsColors.primary,
                              ),
                            ),
                          const SizedBox(height: MyardsSpacing.xs),
                          Text(
                            isParcel
                                ? (order.parcelCategory?.description ?? '')
                                : (order.storeAddress ?? ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MyardsSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(MyardsSpacing.md),
                  decoration: BoxDecoration(
                    color: MyardsColors.surface,
                    borderRadius: BorderRadius.circular(MyardsRadius.md),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          Images.dmAvatar,
                          height: 36,
                          width: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: MyardsSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'deliver_to'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(height: MyardsSpacing.xs),
                            Text(
                              isParcel
                                  ? (order.receiverDetails?.address ?? '')
                                  : (order.deliveryAddress?.address ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MyardsSpacing.md),
                Wrap(
                  spacing: MyardsSpacing.sm,
                  runSpacing: MyardsSpacing.sm,
                  children: [
                    _InfoPill(
                      text:
                          '${distance > 1000 ? '1000+' : distance.toStringAsFixed(2)} ${'km_away_from_you'.tr}',
                    ),
                    _InfoPill(
                      text:
                          '${'payment'.tr}: ${order.paymentMethod == 'cash_on_delivery'
                              ? 'cod'.tr
                              : order.paymentMethod == 'wallet'
                              ? 'wallet'.tr
                              : 'digitally_paid'.tr}',
                    ),
                    _InfoPill(
                      text:
                          '${'status'.tr}: ${(order.paymentStatus ?? 'pending').tr}',
                    ),
                    _InfoPill(
                      text: DateConverterHelper.beforeTimeFormat(
                        order.createdAt ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: MyardsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.dialog(
                      ConfirmationDialogWidget(
                        icon: Images.warning,
                        title: 'are_you_sure_to_ignore'.tr,
                        description: isParcel
                            ? 'you_want_to_ignore_this_delivery'.tr
                            : 'you_want_to_ignore_this_order'.tr,
                        onYesPressed: () {
                          Get.back();
                          final int targetIndex = _findCurrentIndex(requestId);
                          if (targetIndex >= 0) {
                            orderController.ignoreOrder(targetIndex);
                          }
                          Navigator.of(context).pop();
                          onIgnoreSuccess();
                        },
                      ),
                      barrierDismissible: false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).disabledColor),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MyardsRadius.md),
                    ),
                  ),
                  child: Text('ignore'.tr),
                ),
              ),
              const SizedBox(width: MyardsSpacing.sm),
              Expanded(
                child: MyardsPrimaryButton(
                  label: 'accept'.tr,
                  onPressed: () {
                    Get.dialog(
                      ConfirmationDialogWidget(
                        icon: Images.warning,
                        title: 'are_you_sure_to_accept'.tr,
                        description: isParcel
                            ? 'you_want_to_accept_this_delivery'.tr
                            : 'you_want_to_accept_this_order'.tr,
                        onYesPressed: () {
                          final int targetIndex = _findCurrentIndex(requestId);
                          if (targetIndex < 0) {
                            Get.back();
                            orderController.getLatestOrders();
                            return;
                          }

                          orderController
                              .acceptOrder(order.id, targetIndex, order)
                              .then((isSuccess) {
                                if (isSuccess) {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                  onNavigateAfterAccept?.call();
                                  order.orderStatus =
                                      (order.orderStatus == 'pending' ||
                                          order.orderStatus == 'confirmed')
                                      ? 'accepted'
                                      : order.orderStatus;
                                  Get.toNamed(
                                    RouteHelper.getOrderDetailsRoute(order.id),
                                    arguments: OrderDetailsScreen(
                                      orderId: order.id,
                                      isRunningOrder: true,
                                      orderIndex:
                                          (orderController
                                                  .currentOrderList
                                                  ?.length ??
                                              1) -
                                          1,
                                    ),
                                  );
                                } else {
                                  orderController.getLatestOrders();
                                }
                              });
                        },
                      ),
                      barrierDismissible: false,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: MyardsSpacing.sm),
          MyardsPrimaryButton(
            label: 'view_on_map'.tr,
            backgroundColor: MyardsColors.primaryDark,
            onPressed: () {
              final int targetIndex = _findCurrentIndex(requestId);
              Get.to(
                () => OrderLocationScreen(
                  orderModel: order,
                  orderController: orderController,
                  index: targetIndex,
                  onTap: () {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _findCurrentIndex(String requestId) {
    final list = orderController.latestOrderList ?? [];
    return list.indexWhere(
      (orderItem) => orderItem.id?.toString() == requestId,
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  const _InfoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MyardsSpacing.sm,
        vertical: MyardsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MyardsColors.mint,
        borderRadius: BorderRadius.circular(MyardsRadius.sm),
      ),
      child: Text(
        text,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: MyardsColors.primaryDark,
        ),
      ),
    );
  }
}
