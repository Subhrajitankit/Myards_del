import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyardsLocalNotificationHelper {
  static const String channelOrderUpdates = 'myards_order_updates';
  static const String channelNewOrders = 'myards_new_orders';
  static const String channelDeliveryRequests = 'myards_delivery_requests';
  static const String channelWalletPayments = 'myards_wallet';
  static const String channelChatMessages = 'myards_chat';
  static const String channelPromotions = 'myards_promotions';

  static const String snapshotDeliveryRequestIds =
      'lastKnownDeliveryRequestIds';
  static const String snapshotOrderStatuses = 'lastKnownOrderStatuses';
  static const String snapshotWalletBalance = 'lastKnownWalletBalance';
  static const String recentNotificationKeys = 'recentNotificationKeys';

  static final Map<String, AndroidNotificationChannel> _channels = {
    channelOrderUpdates: const AndroidNotificationChannel(
      channelOrderUpdates,
      'Order Updates',
      description: 'Order status and flow updates',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('order_update'),
      enableVibration: true,
    ),
    channelNewOrders: const AndroidNotificationChannel(
      channelNewOrders,
      'New Orders',
      description: 'New order alerts',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('vendor_new_order'),
      enableVibration: true,
    ),
    channelDeliveryRequests: const AndroidNotificationChannel(
      channelDeliveryRequests,
      'Delivery Requests',
      description: 'Delivery request alerts',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('delivery_request'),
      enableVibration: true,
    ),
    channelWalletPayments: const AndroidNotificationChannel(
      channelWalletPayments,
      'Wallet & Payments',
      description: 'Wallet and payout changes',
      importance: Importance.defaultImportance,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('wallet_credit'),
      enableVibration: true,
    ),
    channelChatMessages: const AndroidNotificationChannel(
      channelChatMessages,
      'Chat Messages',
      description: 'New chat messages',
      importance: Importance.defaultImportance,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('chat_message'),
      enableVibration: true,
    ),
    channelPromotions: const AndroidNotificationChannel(
      channelPromotions,
      'Promotions & Announcements',
      description: 'Promotional messages and announcements',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
    ),
  };

  static FlutterLocalNotificationsPlugin? _plugin;
  static Future<void> Function(Map<String, dynamic> payload)? _onTapPayload;

  static Future<void> initialize(
    FlutterLocalNotificationsPlugin plugin, {
    required Future<void> Function(Map<String, dynamic> payload) onTapPayload,
  }) async {
    _plugin = plugin;
    _onTapPayload = onTapPayload;

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_myards_notification'),
      iOS: DarwinInitializationSettings(),
    );

    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _handleTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _backgroundTap,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      for (final AndroidNotificationChannel channel in _channels.values) {
        await androidPlugin.createNotificationChannel(channel);
      }
      await androidPlugin.requestNotificationsPermission();
    }

    debugPrint(
      '[MyardsNotification] channels initialized: ${_channels.keys.join(', ')}',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundTap(NotificationResponse response) async {}

  static Future<void> _handleTap(String? payloadText) async {
    if (payloadText == null || payloadText.isEmpty || _onTapPayload == null) {
      return;
    }
    try {
      final Map<String, dynamic> payload = jsonDecode(payloadText);
      await _onTapPayload!(payload);
    } catch (e) {
      debugPrint('[MyardsNotification] payload parse failed: $e');
    }
  }

  static Future<bool> requestPermission() async {
    final PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }
    final PermissionStatus result = await Permission.notification.request();
    return result.isGranted;
  }

  static Future<void> promptForPermission({
    required String title,
    required String message,
  }) async {
    final PermissionStatus status = await Permission.notification.status;
    if (status.isGranted || Get.isDialogOpen == true) {
      return;
    }

    await Get.dialog<void>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () async {
              await requestPermission();
              Get.back<void>();
            },
            child: const Text('Allow Notifications'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  static Future<bool> showNotification({
    required String channelId,
    required String title,
    required String body,
    required String dedupeKey,
    Map<String, dynamic>? payload,
    int ttlMinutes = 20,
  }) async {
    if (_plugin == null) {
      return false;
    }

    final bool suppressed = await _isDuplicate(
      dedupeKey: dedupeKey,
      ttlMinutes: ttlMinutes,
    );
    if (suppressed) {
      debugPrint('[MyardsNotification] duplicate skipped: $dedupeKey');
      return false;
    }

    final AndroidNotificationChannel? channel = _channels[channelId];
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channel?.name ?? 'Myards Notifications',
          channelDescription: channel?.description,
          importance: channel?.importance ?? Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_myards_notification',
          color: const Color(0xFF039D55),
          playSound: channel?.playSound ?? true,
          sound: channel?.sound,
          enableVibration: channel?.enableVibration ?? true,
          category: AndroidNotificationCategory.message,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    final int id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    await _plugin!.show(
      id,
      title,
      body,
      details,
      payload: payload == null ? null : jsonEncode(payload),
    );

    debugPrint('[MyardsNotification] shown channel=$channelId key=$dedupeKey');
    return true;
  }

  static Future<Map<String, String>> readSnapshot(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(raw);
      return jsonMap.map((String k, dynamic v) => MapEntry(k, v.toString()));
    } catch (_) {
      return <String, String>{};
    }
  }

  static Future<void> writeSnapshot(
    String key,
    Map<String, String> value,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<double?> readDouble(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> writeDouble(String key, double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<bool> _isDuplicate({
    required String dedupeKey,
    required int ttlMinutes,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(recentNotificationKeys);
    Map<String, dynamic> entries = <String, dynamic>{};

    if (raw != null && raw.isNotEmpty) {
      try {
        entries = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        entries = <String, dynamic>{};
      }
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int ttlMs = Duration(minutes: ttlMinutes).inMilliseconds;

    entries.removeWhere((String _, dynamic value) {
      final int? ts = int.tryParse(value.toString());
      return ts == null || (now - ts) > ttlMs;
    });

    final int? seenAt = int.tryParse(entries[dedupeKey]?.toString() ?? '');
    final bool suppressed = seenAt != null && (now - seenAt) <= ttlMs;
    if (!suppressed) {
      entries[dedupeKey] = now;
    }

    await prefs.setString(recentNotificationKeys, jsonEncode(entries));
    return suppressed;
  }
}
