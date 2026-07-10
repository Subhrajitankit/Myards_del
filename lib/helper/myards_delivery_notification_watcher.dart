import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/delivery_module/order/controllers/order_controller.dart';
import 'package:sixam_mart_delivery/helper/myards_overlay_helper.dart';

/// App-wide watcher for delivery request notifications and overlay popups.
///
/// Call [start] from HomeScreen.initState() after data is loaded.
/// Call [stop]  from HomeScreen.dispose().
/// Call [reset] on logout.
/// Call [refresh] on demand (app resume calls are handled by the existing
/// lifecycle listener, but the timer drives continuous background detection).
///
/// This watcher delegates entirely to [OrderController.getLatestOrders],
/// which internally calls [MyardsOverlayHelper.processPendingOrdersSnapshot]
/// and [_processDeliveryRequestNotificationDiff] — all detection and
/// notification logic lives in the controller.
class MyardsDeliveryNotificationWatcher {
  static const Duration _pollInterval = Duration(seconds: 15);

  static Timer? _timer;

  /// Starts the 12-second polling timer.
  /// Calls [refresh] immediately for the initial snapshot.
  static void start() {
    stop();
    debugPrint('[MyardsNotification] delivery watcher started');
    refresh();
    _timer = Timer.periodic(_pollInterval, (_) {
      debugPrint('[MyardsNotification] delivery polling tick');
      refresh();
    });
  }

  /// Cancels the polling timer.
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clears any watcher-level state. Call this on logout.
  static void reset() {
    debugPrint('[MyardsNotification] delivery watcher state reset');
  }

  /// Fetches the latest delivery requests and triggers overlay / notification
  /// logic via the existing [OrderController] pipeline.
  static Future<void> refresh() async {
    try {
      if (!Get.isRegistered<OrderController>()) return;
      await Get.find<OrderController>().getLatestOrders();
      MyardsOverlayHelper.showNextPopupIfAvailable();
    } catch (e) {
      debugPrint('[MyardsNotification] delivery watcher error: $e');
    }
  }
}
