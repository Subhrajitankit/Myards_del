import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/disbursement/helper/disbursement_helper.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/pending_ride_list_screen.dart';
import 'package:sixam_mart_delivery/features/ride_module/ride_order/screens/ride_order_screen.dart';
import 'package:sixam_mart_delivery/helper/notification_helper.dart';
import 'package:sixam_mart_delivery/helper/myards_local_notification_helper.dart';
import 'package:sixam_mart_delivery/helper/myards_overlay_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/main.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:sixam_mart_delivery/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:sixam_mart_delivery/features/dashboard/widgets/new_request_dialog_widget.dart';
import 'package:sixam_mart_delivery/features/home/screens/home_screen.dart';
import 'package:sixam_mart_delivery/features/profile/screens/profile_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_request_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/enums.dart';
import 'package:sixam_mart_delivery/util/images.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromOrderDetails;
  const DashboardScreen({
    super.key,
    required this.pageIndex,
    this.fromOrderDetails = false,
  });

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.sixamtech/app_retain');
  late StreamSubscription _stream;

  DisbursementHelper disbursementHelper = DisbursementHelper();
  bool _canExit = false;
  bool isRideActive = AppConstants.appMode == AppMode.ride;
  double? _lastKnownWalletBalance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      HomeScreen(onNavigateToOrders: () => _setPage(2)),
      isRideActive
          ? RideRequestScreen(onTap: () => _setPage(0))
          : OrderRequestScreen(onTap: () => _setPage(0)),
      isRideActive ? RideOrderScreen() : const OrderScreen(),
      const ProfileScreen(),
    ];

    showDisbursementWarningMessage();
    _initializeNotificationState();
    Get.find<OrderController>().getLatestOrders();

    _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? type = message.data['body_loc_key'] ?? message.data['type'];
      String? orderID =
          message.data['title_loc_key'] ?? message.data['order_id'];
      bool isParcel = (message.data['order_type'] == 'parcel_order');
      bool isPrescription = (message.data['order_type'] == 'prescription');
      if (type != 'assign' &&
          type != 'new_order' &&
          type != 'message' &&
          type != 'order_request' &&
          type != 'order_status') {
        NotificationHelper.showNotification(
          message,
          flutterLocalNotificationsPlugin,
        );
      }
      if (type == 'new_order' || type == 'order_request') {
        Get.find<OrderController>().getRunningOrders(
          Get.find<OrderController>().offset,
          status: 'all',
        );
        Get.find<OrderController>().getOrderCount(
          Get.find<OrderController>().orderType,
        );
        _refreshAndShowLatestRequestPopup();
      } else if (type == 'assign' && orderID != null && orderID.isNotEmpty) {
        Get.find<OrderController>().getRunningOrders(
          Get.find<OrderController>().offset,
          status: 'all',
        );
        Get.find<OrderController>().getOrderCount(
          Get.find<OrderController>().orderType,
        );
        Get.find<OrderController>().getLatestOrders();
        Get.dialog(
          NewRequestDialogWidget(
            isRequest: false,
            orderId: int.parse(message.data['order_id'].toString()),
            hideItemCount: isParcel || isPrescription,
            onTap: () {
              Get.offAllNamed(
                RouteHelper.getOrderDetailsRoute(
                  int.parse(orderID),
                  fromNotification: true,
                ),
              );
            },
          ),
        );
      } else if (type == 'block') {
        Get.find<AuthController>().clearSharedData();
        Get.find<ProfileController>().stopLocationRecord();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  Future<void> showDisbursementWarningMessage() async {
    if (!widget.fromOrderDetails) {
      disbursementHelper.enableDisbursementWarningMessage(true);
    }
  }

  void _navigateRequestPage() {
    if (isDeliveryManActive()) {
      _setPage(1);
    }
  }

  @override
  void dispose() {
    _stream.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    MyardsOverlayHelper.updateLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshAndShowLatestRequestPopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              if (Get.find<ProfileController>().profileModel!.active == 1) {
                _channel.invokeMethod('sendToBackground');
              }
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'back_press_again_to_exit'.tr,
                style: const TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ),
          );
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        bottomNavigationBar: GetPlatform.isDesktop
            ? const SizedBox()
            : Container(
                height: 70 + MediaQuery.of(context).padding.bottom,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    BottomNavItemWidget(
                      iconData: Images.home,
                      label: 'home'.tr,
                      isSelected: _pageIndex == 0,
                      onTap: () => _setPage(0),
                    ),
                    BottomNavItemWidget(
                      iconData: Images.request,
                      label: 'request'.tr,
                      isSelected: _pageIndex == 1,
                      pageIndex: 1,
                      onTap: () {
                        _navigateRequestPage();
                      },
                    ),
                    BottomNavItemWidget(
                      iconData: Images.bag,
                      label: isRideActive ? "history".tr : 'orders'.tr,
                      isSelected: _pageIndex == 2,
                      onTap: () => _setPage(2),
                    ),
                    BottomNavItemWidget(
                      iconData: Images.userP,
                      label: 'profile'.tr,
                      isSelected: _pageIndex == 3,
                      onTap: () => _setPage(3),
                    ),
                  ],
                ),
              ),
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _screens.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _screens[index];
              },
            ),
            if (kDebugMode)
              Positioned(
                right: 12,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await MyardsLocalNotificationHelper.showNotification(
                          channelId: MyardsLocalNotificationHelper
                              .channelDeliveryRequests,
                          title: 'New Delivery Request',
                          body:
                              'Pickup from Test Restaurant • 2 items • cash_on_delivery',
                          dedupeKey: 'delivery_request_debug_single',
                          payload: <String, dynamic>{
                            'route_type': 'order_request',
                          },
                          ttlMinutes: 1,
                        );
                      },
                      child: const Text('Test Delivery Request Notification'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await MyardsLocalNotificationHelper.showNotification(
                          channelId: MyardsLocalNotificationHelper
                              .channelDeliveryRequests,
                          title: 'New Delivery Request',
                          body:
                              'Pickup from Test Restaurant • 3 items • digital_payment',
                          dedupeKey: 'delivery_request_debug_overlay',
                          payload: <String, dynamic>{
                            'route_type': 'order_request',
                          },
                          ttlMinutes: 1,
                        );
                        await MyardsOverlayHelper.showTestOverlay();
                      },
                      child: const Text(
                        'Test Delivery Request Notification + Overlay',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await MyardsLocalNotificationHelper.showNotification(
                          channelId: MyardsLocalNotificationHelper
                              .channelDeliveryRequests,
                          title: 'New Delivery Request',
                          body:
                              'Pickup from Queue Test A • 1 item • cash_on_delivery',
                          dedupeKey: 'delivery_request_debug_queue_a',
                          payload: <String, dynamic>{
                            'route_type': 'order_request',
                          },
                          ttlMinutes: 1,
                        );
                        await MyardsLocalNotificationHelper.showNotification(
                          channelId: MyardsLocalNotificationHelper
                              .channelDeliveryRequests,
                          title: 'New Delivery Request',
                          body:
                              'Pickup from Queue Test B • 4 items • digital_payment',
                          dedupeKey: 'delivery_request_debug_queue_b',
                          payload: <String, dynamic>{
                            'route_type': 'order_request',
                          },
                          ttlMinutes: 1,
                        );
                      },
                      child: const Text('Test Queue Two Delivery Requests'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
    if (pageIndex == 0) {
      _refreshAndShowLatestRequestPopup();
    }
  }

  Future<void> _initializeNotificationState() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!Get.find<AuthController>().isLoggedIn()) {
      return;
    }
    await MyardsLocalNotificationHelper.promptForPermission(
      title: 'Enable Notifications',
      message:
          'Allow Myards Delivery Partner to send delivery requests, order alerts, and earning updates.',
    );
    final profileModel = Get.find<ProfileController>().profileModel;
    _lastKnownWalletBalance = profileModel?.balance;
    if (_lastKnownWalletBalance != null) {
      await MyardsLocalNotificationHelper.writeDouble(
        MyardsLocalNotificationHelper.snapshotWalletBalance,
        _lastKnownWalletBalance!,
      );
    }
  }

  Future<void> _checkWalletChange() async {
    final profile = await Get.find<ProfileController>().getProfile();
    final double? currentBalance = profile?.balance;
    if (currentBalance == null) {
      return;
    }

    _lastKnownWalletBalance ??= await MyardsLocalNotificationHelper.readDouble(
      MyardsLocalNotificationHelper.snapshotWalletBalance,
    );

    if (_lastKnownWalletBalance != null &&
        _lastKnownWalletBalance != currentBalance) {
      await MyardsLocalNotificationHelper.showNotification(
        channelId: MyardsLocalNotificationHelper.channelWalletPayments,
        title: 'Payment Update',
        body: 'Your payment or wallet status has been updated.',
        dedupeKey: 'delivery_wallet_${currentBalance.toStringAsFixed(2)}',
        payload: <String, dynamic>{'route_type': 'wallet'},
      );
    }

    _lastKnownWalletBalance = currentBalance;
    await MyardsLocalNotificationHelper.writeDouble(
      MyardsLocalNotificationHelper.snapshotWalletBalance,
      currentBalance,
    );
  }

  Future<void> _refreshAndShowLatestRequestPopup() async {
    if (isRideActive || !Get.find<AuthController>().isLoggedIn()) {
      return;
    }
    await Get.find<OrderController>().getLatestOrders();
    await _checkWalletChange();
    await MyardsOverlayHelper.showNextPopupIfAvailable();
  }
}

bool isDeliveryManActive({bool showPopUp = true}) {
  if (Get.find<ProfileController>().profileModel != null &&
      Get.find<ProfileController>().profileModel!.active == 1 &&
      Get.find<OrderController>().currentOrderList != null &&
      Get.find<OrderController>().currentOrderList!.isEmpty) {
    return true;
  } else {
    if (Get.find<ProfileController>().profileModel == null ||
        Get.find<ProfileController>().profileModel!.active == 0) {
      if (showPopUp) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.dialog(
            CustomAlertDialogWidget(
              description: 'you_are_offline_now'.tr,
              onOkPressed: () => Get.back(),
            ),
          );
        });
      }
      return false;
    } else {
      return true;
    }
  }
}
