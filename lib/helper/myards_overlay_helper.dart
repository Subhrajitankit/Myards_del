import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/domain/models/order_model.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/screens/order_location_screen.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/widgets/myards_order_request_popup.dart';
import 'package:sixam_mart_delivery/helper/myards_local_notification_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';

class MyardsOverlayHelper {
  static const String _channelName = 'myards_delivery_overlay';
  static const Duration _shownIdTtl = Duration(minutes: 20);

  static final MethodChannel _overlayChannel = MethodChannel(_channelName);

  static final Set<String> _shownOrderIds = <String>{};
  static final Map<String, DateTime> _shownOrderTimestamps =
      <String, DateTime>{};
  static final Queue<OrderModel> _popupQueue = Queue<OrderModel>();
  static final Set<String> _queuedOrderIds = <String>{};
  static Set<String> _lastKnownPendingOrderIds = <String>{};
  static bool _hasInitialPendingSnapshot = false;
  static bool _isPopupShowing = false;
  static bool _isInAppPopupShowing = false;
  static Timer? _cleanupTimer;
  static AppLifecycleState _currentLifecycleState = AppLifecycleState.resumed;

  static bool get isAppInForeground =>
      _currentLifecycleState == AppLifecycleState.resumed;

  /// Initialize overlay helper and set up cleanup timer
  static Future<void> initialize() async {
    _startCleanupTimer();
    _overlayChannel.setMethodCallHandler(_handleOverlayCallback);
    await _checkPendingOverlayAction();
  }

  static Future<void> updateLifecycleState(AppLifecycleState state) async {
    _currentLifecycleState = state;
    debugPrint('[MyardsOverlay] lifecycle changed: $state');
    if (state == AppLifecycleState.resumed) {
      await _checkPendingOverlayAction();
      await showNextPopupIfAvailable();
    }
  }

  static Future<void> processPendingOrdersSnapshot(
    List<OrderModel> pendingOrders, {
    bool allowInitialSinglePopup = true,
  }) async {
    clearExpiredShownIds();

    final Set<String> currentIds = pendingOrders
        .map((order) => order.id?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    if (!_hasInitialPendingSnapshot) {
      _hasInitialPendingSnapshot = true;
      _lastKnownPendingOrderIds = currentIds;
      debugPrint(
        '[MyardsOverlay] initial pending snapshot stored: ${currentIds.length} ids',
      );

      if (allowInitialSinglePopup && pendingOrders.length == 1) {
        await handleIncomingOrderRequest(pendingOrders.first);
      }
      return;
    }

    final Set<String> newIds = currentIds.difference(_lastKnownPendingOrderIds);
    if (newIds.isEmpty) {
      _lastKnownPendingOrderIds = currentIds;
      return;
    }

    for (final String id in newIds) {
      final OrderModel? order = pendingOrders.cast<OrderModel?>().firstWhere(
        (o) => o?.id?.toString() == id,
        orElse: () => null,
      );
      if (order != null) {
        await handleIncomingOrderRequest(order);
      }
    }

    _lastKnownPendingOrderIds = currentIds;
  }

  /// Check if app has overlay permission
  static Future<bool> hasOverlayPermission() async {
    debugPrint('[MyardsOverlay] checkOverlayPermission called');
    try {
      final bool hasPermission =
          await _overlayChannel.invokeMethod<bool>('checkOverlayPermission') ??
          false;
      debugPrint('[MyardsOverlay] overlay permission result: $hasPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      debugPrint('[MyardsOverlay] method channel error: ${e.message}');
      return false;
    }
  }

  /// Open overlay permission settings
  static Future<void> requestOverlayPermission() async {
    try {
      debugPrint('[MyardsOverlay] openOverlayPermissionSettings called');
      await _overlayChannel.invokeMethod('openOverlayPermissionSettings');
      debugPrint('[MyardsOverlay] method channel success');
    } on PlatformException catch (e) {
      debugPrint('[MyardsOverlay] method channel error: ${e.message}');
    }
  }

  static Future<void> showTestOverlay() async {
    debugPrint('[MyardsOverlay] Test overlay button tapped');
    final Map<String, dynamic> testData = <String, dynamic>{
      'orderId': 'TEST-1001',
      'restaurantName': 'Swayam Kitchen',
      'restaurantLogo': '',
      'itemCount': 2,
      'pickupAddress': 'Fortune Tower, Maitri Vihar',
      'dropAddress': 'Zone-A, Bhubaneswar',
      'customerName': 'Test Customer',
      'distance': 0.01,
      'paymentMethod': 'COD',
      'paymentStatus': 'Unpaid',
      'orderTime': 'Just now',
      'latitude': '20.2961',
      'longitude': '85.8245',
    };
    final String orderJson = jsonEncode(testData);
    await _showOverlayByJson(orderJson);
  }

  static Future<void> showTestOverlayAfterDelay(Duration delay) async {
    debugPrint('[MyardsOverlay] showTestOverlayAfterDelay called: $delay');
    await Future.delayed(delay);
    await showTestOverlay();
  }

  static Future<void> showTestDeliveryRequestNotification() async {
    await MyardsLocalNotificationHelper.showNotification(
      channelId: MyardsLocalNotificationHelper.channelDeliveryRequests,
      title: 'New Delivery Request',
      body: 'Pickup from Swayam Kitchen • 2 items • COD',
      dedupeKey: 'debug_delivery_request_notification',
      payload: <String, dynamic>{
        'route_type': 'order_request',
        'order_id': '900001',
      },
      ttlMinutes: 1,
    );
  }

  static Future<void> showTestDeliveryRequestNotificationWithOverlay() async {
    await showTestDeliveryRequestNotification();
    await showTestOverlay();
  }

  static Future<void> showTestQueueTwoDeliveryRequests() async {
    final DateTime now = DateTime.now();
    final OrderModel first = OrderModel(
      id: 900001,
      storeName: 'Swayam Kitchen',
      storeAddress: 'Fortune Tower, Maitri Vihar',
      detailsCount: 2,
      paymentMethod: 'COD',
      paymentStatus: 'Unpaid',
      createdAt: now.toIso8601String(),
    );
    final OrderModel second = OrderModel(
      id: 900002,
      storeName: 'Green Bowl Cafe',
      storeAddress: 'Patia Main Road',
      detailsCount: 1,
      paymentMethod: 'Digital',
      paymentStatus: 'Paid',
      createdAt: now.toIso8601String(),
    );

    await handleIncomingOrderRequest(first);
    await handleIncomingOrderRequest(second);
  }

  static Future<void> handleIncomingOrderRequest(OrderModel order) async {
    clearExpiredShownIds();

    final String orderId = order.id?.toString() ?? '';
    if (orderId.isEmpty) {
      return;
    }

    if (_shownOrderIds.contains(orderId) || _queuedOrderIds.contains(orderId)) {
      debugPrint(
        '[MyardsOverlay] Order $orderId already shown/queued, skipping duplicate',
      );
      return;
    }

    _shownOrderIds.add(orderId);
    _shownOrderTimestamps[orderId] = DateTime.now();
    enqueueOrderPopup(order);

    debugPrint('[MyardsOverlay] New order queued: $orderId');

    if (!_isPopupShowing) {
      await showNextPopupIfAvailable();
    }
  }

  static void enqueueOrderPopup(OrderModel order) {
    final String orderId = order.id?.toString() ?? '';
    if (orderId.isEmpty || _queuedOrderIds.contains(orderId)) {
      return;
    }
    _popupQueue.add(order);
    _queuedOrderIds.add(orderId);
  }

  static Future<void> showNextPopupIfAvailable() async {
    if (_isPopupShowing || _popupQueue.isEmpty) {
      return;
    }

    final OrderModel order = _popupQueue.removeFirst();
    final String orderId = order.id?.toString() ?? '';
    _queuedOrderIds.remove(orderId);
    _isPopupShowing = true;

    if (isAppInForeground) {
      await _showInAppPopup(order);
      return;
    }

    final bool hasPermission = await hasOverlayPermission();
    if (!hasPermission) {
      debugPrint(
        '[MyardsOverlay] overlay permission missing, skipping overlay for orderId=$orderId',
      );
      markPopupClosed();
      return;
    }

    final String orderJson = _convertOrderToJson(order);
    final bool success = await _showOverlayByJson(orderJson);
    if (!success) {
      markPopupClosed();
    }
  }

  static Future<void> _showInAppPopup(OrderModel order) async {
    if (_isInAppPopupShowing) {
      return;
    }

    final context = Get.context;
    if (context == null || !context.mounted) {
      debugPrint(
        '[MyardsOverlay] foreground context unavailable, opening request screen fallback',
      );
      _navigateToRequestScreen();
      markPopupClosed();
      return;
    }

    _isInAppPopupShowing = true;
    await showMyardsOrderRequestPopup(
      context,
      order,
      onClosed: () {
        _isInAppPopupShowing = false;
        markPopupClosed();
      },
      onIgnoreSuccess: () {},
      onNavigateAfterAccept: () {
        _navigateToRequestScreen();
      },
    );
  }

  static Future<bool> _showOverlayByJson(String orderJson) async {
    debugPrint('[MyardsOverlay] Calling showDeliveryRequestOverlay');
    debugPrint('[MyardsOverlay] order json: $orderJson');
    try {
      final dynamic response = await _overlayChannel.invokeMethod(
        'showDeliveryRequestOverlay',
        <String, dynamic>{'orderJson': orderJson},
      );
      debugPrint('[MyardsOverlay] Overlay method channel result: $response');
      return response == null || response == true;
    } on PlatformException catch (e) {
      debugPrint('[MyardsOverlay] method channel error: ${e.message}');
      return false;
    }
  }

  /// Show overlay for a delivery order
  static Future<void> showOrderOverlay(OrderModel order) async {
    await handleIncomingOrderRequest(order);
  }

  /// Hide the current overlay
  static Future<void> hideOrderOverlay() async {
    try {
      debugPrint('[MyardsOverlay] hideDeliveryRequestOverlay called');
      await _overlayChannel.invokeMethod('hideDeliveryRequestOverlay');
      debugPrint('[MyardsOverlay] method channel success');
    } on PlatformException catch (e) {
      debugPrint('[MyardsOverlay] method channel error: ${e.message}');
    }
  }

  static void markPopupClosed({String? orderId}) {
    if (orderId != null && orderId.isNotEmpty) {
      _queuedOrderIds.remove(orderId);
    }
    _isPopupShowing = false;
    showNextPopupIfAvailable();
  }

  /// Convert order model to JSON string for native side
  static String _convertOrderToJson(OrderModel order) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'orderId': order.id?.toString() ?? '',
      'restaurantName': order.storeName ?? 'Restaurant',
      'restaurantLogo': order.storeLogoFullUrl ?? '',
      'itemCount': order.detailsCount ?? 0,
      'pickupAddress': order.storeAddress ?? '',
      'dropAddress': order.deliveryAddress?.address ?? '',
      'customerName':
          '${order.customer?.fName ?? ''} ${order.customer?.lName ?? ''}'
              .trim(),
      'distance': _calculateDistance(order),
      'paymentMethod': order.paymentMethod ?? 'COD',
      'paymentStatus': order.paymentStatus ?? 'pending',
      'orderTime': _formatOrderTime(order.createdAt),
      'latitude': order.deliveryAddress?.latitude ?? '0',
      'longitude': order.deliveryAddress?.longitude ?? '0',
    };
    return jsonEncode(payload);
  }

  /// Calculate distance from current rider location to pickup point.
  static double _calculateDistance(OrderModel order) {
    try {
      final double lat =
          double.tryParse(
            order.storeLat ?? order.deliveryAddress?.latitude ?? '0',
          ) ??
          0;
      final double lng =
          double.tryParse(
            order.storeLng ?? order.deliveryAddress?.longitude ?? '0',
          ) ??
          0;
      return Get.find<AddressController>().getRestaurantDistance(
        LatLng(lat, lng),
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// Format order time for display
  static String _formatOrderTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return 'Just now';
    }
    try {
      final DateTime orderTime = DateTime.parse(createdAt);
      final Duration difference = DateTime.now().difference(orderTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        final int hours = difference.inHours;
        return hours == 1 ? '1 hour ago' : '$hours hours ago';
      } else {
        return 'Today';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  /// Handle callbacks from native overlay
  static Future<dynamic> _handleOverlayCallback(MethodCall call) async {
    debugPrint(
      '[MyardsOverlay] callback received: ${call.method} ${call.arguments}',
    );
    switch (call.method) {
      case 'onOverlayAccept':
        _onOverlayAccept(call.arguments);
        break;
      case 'onOverlayIgnore':
        _onOverlayIgnore(call.arguments);
        break;
      case 'onOverlayViewMap':
        _onOverlayViewMap(call.arguments);
        break;
      case 'onOverlayClose':
        _onOverlayClose(call.arguments);
        break;
    }
  }

  static Future<void> _checkPendingOverlayAction() async {
    try {
      final dynamic result = await _overlayChannel.invokeMethod<dynamic>(
        'getPendingOverlayAction',
      );
      if (result is Map) {
        final String? action = result['action']?.toString();
        final String? orderId = result['orderId']?.toString();
        if (action != null && action.isNotEmpty) {
          debugPrint(
            '[MyardsOverlay] pending action fetched: action=$action orderId=$orderId',
          );
          if (action == 'MYARDS_OVERLAY_ACCEPT') {
            _onOverlayAccept(result);
            return;
          }
          if (action == 'MYARDS_OVERLAY_IGNORE') {
            _onOverlayIgnore(result);
            return;
          }
          if (action == 'MYARDS_OVERLAY_VIEW_MAP') {
            _onOverlayViewMap(result);
            return;
          }
          if (action == 'MYARDS_OVERLAY_CLOSE') {
            _onOverlayClose(result);
            return;
          }
          markPopupClosed(orderId: orderId);
        }
      }
    } on PlatformException catch (e) {
      debugPrint('[MyardsOverlay] method channel error: ${e.message}');
    }
  }

  /// Handle accept action from overlay
  static void _onOverlayAccept(dynamic arguments) {
    final String? orderId = (arguments is Map)
        ? arguments['orderId']?.toString()
        : null;
    debugPrint('[MyardsOverlay] overlay accept action received: $orderId');
    debugPrint(
      '[MyardsOverlay] Direct accept not executed from overlay; opening request/details screen fallback.',
    );
    _navigateToOrderRequestOrDetails(orderId: orderId);
    markPopupClosed(orderId: orderId);
  }

  /// Handle ignore action from overlay
  static void _onOverlayIgnore(dynamic arguments) {
    final String? orderId = (arguments is Map)
        ? arguments['orderId']?.toString()
        : null;
    debugPrint('[MyardsOverlay] overlay ignore action received: $orderId');
    debugPrint(
      '[MyardsOverlay] Direct ignore API not executed from overlay; applying local ignore when safe and opening fallback route.',
    );
    _tryIgnoreOrderLocally(orderId);
    _navigateToOrderRequestOrDetails(orderId: orderId);
    markPopupClosed(orderId: orderId);
  }

  /// Handle view map action from overlay
  static void _onOverlayViewMap(dynamic arguments) {
    final String? orderId = (arguments is Map)
        ? arguments['orderId']?.toString()
        : null;
    debugPrint('[MyardsOverlay] overlay view map action received: $orderId');
    _navigateToMapOrFallback(orderId: orderId);
    markPopupClosed(orderId: orderId);
  }

  static void _onOverlayClose(dynamic arguments) {
    final String? orderId = (arguments is Map)
        ? arguments['orderId']?.toString()
        : null;
    debugPrint('[MyardsOverlay] overlay close action received: $orderId');
    markPopupClosed(orderId: orderId);
  }

  static void _navigateToRequestScreen() {
    if (Get.currentRoute != RouteHelper.getMainRoute('order-request')) {
      Get.toNamed(RouteHelper.getMainRoute('order-request'));
    }
  }

  static void _navigateToOrderRequestOrDetails({String? orderId}) {
    final int? parsedOrderId = int.tryParse(orderId ?? '');
    if (parsedOrderId != null) {
      Get.toNamed(
        RouteHelper.getOrderDetailsRoute(parsedOrderId, fromNotification: true),
      );
      return;
    }
    _navigateToRequestScreen();
  }

  static void _navigateToMapOrFallback({String? orderId}) {
    final OrderController? orderController = _findOrderController();
    final OrderModel? order = _findLatestOrderById(orderId, orderController);

    if (orderController != null && order != null) {
      final int index = (orderController.latestOrderList ?? <OrderModel>[])
          .indexWhere(
            (OrderModel o) => o.id?.toString() == order.id?.toString(),
          );
      if (index >= 0) {
        debugPrint(
          '[MyardsOverlay] Opening order location screen from overlay action.',
        );
        Get.to(
          () => OrderLocationScreen(
            orderModel: order,
            orderController: orderController,
            index: index,
            onTap: () {},
          ),
        );
        return;
      }
    }

    debugPrint(
      '[MyardsOverlay] View map route data unavailable; opening request/details screen fallback.',
    );
    _navigateToOrderRequestOrDetails(orderId: orderId);
  }

  static void _tryIgnoreOrderLocally(String? orderId) {
    final OrderController? orderController = _findOrderController();
    if (orderController == null) {
      return;
    }

    final List<OrderModel> latest =
        orderController.latestOrderList ?? <OrderModel>[];
    final int index = latest.indexWhere(
      (OrderModel o) => o.id?.toString() == orderId,
    );
    if (index >= 0) {
      orderController.ignoreOrder(index);
    }
  }

  static OrderController? _findOrderController() {
    if (!Get.isRegistered<OrderController>()) {
      return null;
    }
    return Get.find<OrderController>();
  }

  static OrderModel? _findLatestOrderById(
    String? orderId,
    OrderController? controller,
  ) {
    if (orderId == null || orderId.isEmpty || controller == null) {
      return null;
    }
    final List<OrderModel> latest =
        controller.latestOrderList ?? <OrderModel>[];
    for (final OrderModel order in latest) {
      if (order.id?.toString() == orderId) {
        return order;
      }
    }
    return null;
  }

  static void clearExpiredShownIds() {
    final DateTime now = DateTime.now();
    final List<String> expiredIds = _shownOrderTimestamps.entries
        .where((entry) => now.difference(entry.value) > _shownIdTtl)
        .map((entry) => entry.key)
        .toList();
    for (final String id in expiredIds) {
      _shownOrderTimestamps.remove(id);
      _shownOrderIds.remove(id);
    }
  }

  /// Start cleanup timer to clear old order IDs every 10 minutes
  static void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      clearExpiredShownIds();
      debugPrint('[MyardsOverlay] cleaned expired shown IDs');
    });
  }

  /// Dispose the helper
  static void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}
