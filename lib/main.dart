import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_delivery/common/controllers/theme_controller.dart';
import 'package:sixam_mart_delivery/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_delivery/helper/notification_helper.dart';
import 'package:sixam_mart_delivery/helper/myards_local_notification_helper.dart';
import 'package:sixam_mart_delivery/helper/myards_overlay_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/theme/dark_theme.dart';
import 'package:sixam_mart_delivery/theme/light_theme.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyACE9WGG7Jj8zfh2c8L9mqNtktAIBCEckM",
        appId: "1:328521548399:android:103e2ac634f2be4e31039a",
        messagingSenderId: "328521548399",
        projectId: "myards-9876",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  // Initialize overlay helper for out-of-app delivery request notifications
  await MyardsOverlayHelper.initialize();
  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      await MyardsLocalNotificationHelper.initialize(
        flutterLocalNotificationsPlugin,
        onTapPayload: (Map<String, dynamic> payload) async {
          final String routeType = payload['route_type']?.toString() ?? '';
          final int? orderId = int.tryParse(
            payload['order_id']?.toString() ?? '',
          );
          final int? conversationId = int.tryParse(
            payload['conversation_id']?.toString() ?? '',
          );

          if (routeType == 'order_details' && orderId != null) {
            Get.toNamed(
              RouteHelper.getOrderDetailsRoute(orderId, fromNotification: true),
            );
          } else if (routeType == 'order_request') {
            Get.toNamed(RouteHelper.getMainRoute('order-request'));
          } else if (routeType == 'chat' && conversationId != null) {
            final NotificationBodyModel body = NotificationBodyModel(
              notificationType: NotificationType.message,
              conversationId: conversationId,
            );
            Get.toNamed(
              RouteHelper.getChatRoute(
                notificationBody: body,
                conversationId: conversationId,
                fromNotification: true,
              ),
            );
          } else if (routeType == 'wallet') {
            Get.toNamed(RouteHelper.getMyAccountRoute());
          } else {
            Get.toNamed(
              RouteHelper.getNotificationRoute(fromNotification: true),
            );
          }
        },
      );
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, this.body});

  void _route() {
    Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
      if (isSuccess) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().updateToken();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      _route();
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                return (GetPlatform.isWeb &&
                        splashController.configModel == null)
                    ? const SizedBox()
                    : GetMaterialApp(
                        title: AppConstants.appName,
                        debugShowCheckedModeBanner: false,
                        navigatorKey: Get.key,
                        theme: themeController.darkTheme ? dark : light,
                        locale: localizeController.locale,
                        translations: Messages(languages: languages),
                        fallbackLocale: Locale(
                          AppConstants.languages[0].languageCode!,
                          AppConstants.languages[0].countryCode,
                        ),
                        initialRoute: RouteHelper.getSplashRoute(body),
                        getPages: RouteHelper.routes,
                        defaultTransition: Transition.topLevel,
                        transitionDuration: const Duration(milliseconds: 500),
                        builder: (BuildContext context, widget) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: const TextScaler.linear(1.0),
                            ),
                            child: Material(
                              child: SafeArea(
                                top: false,
                                bottom: GetPlatform.isAndroid,
                                child: Stack(children: [widget!]),
                              ),
                            ),
                          );
                        },
                      );
              },
            );
          },
        );
      },
    );
  }
}
