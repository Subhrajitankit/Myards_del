import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/splash/domain/repositories/splash_repository_interface.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/enums.dart';

class SplashRepository implements SplashRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> getConfigData() async {
    Response response = await apiClient.getData(AppConstants.configUri);
    return response;
  }

  @override
  Future<bool> initSharedData() {
    if(!sharedPreferences.containsKey(AppConstants.theme)) {
      return sharedPreferences.setBool(AppConstants.theme, false);
    }
    if(!sharedPreferences.containsKey(AppConstants.countryCode)) {
      return sharedPreferences.setString(AppConstants.countryCode, AppConstants.languages[0].countryCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.languageCode)) {
      return sharedPreferences.setString(AppConstants.languageCode, AppConstants.languages[0].languageCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.notification)) {
      return sharedPreferences.setBool(AppConstants.notification, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if(!sharedPreferences.containsKey(AppConstants.ignoreList)) {
      sharedPreferences.setStringList(AppConstants.ignoreList, []);
    }
    return Future.value(true);
  }

  @override
  Future<bool> removeSharedData() {
    return sharedPreferences.clear();
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }


  @override
  bool handleInitialTopicSubscription() {
    try{
      if(!GetPlatform.isWeb) {
        if(AppConstants.appMode == AppMode.delivery){
          print("Starting subscription...");
          FirebaseMessaging.instance.subscribeToTopic(AppConstants.topicDeliveryman);
          FirebaseMessaging.instance.subscribeToTopic(AppConstants.maintenanceModeDeliveryMan);
          print("Successfully subscribed to Delivery Man: ${AppConstants.maintenanceModeDeliveryMan}");
        }else{
          FirebaseMessaging.instance.subscribeToTopic(AppConstants.topicRider);
          FirebaseMessaging.instance.subscribeToTopic(AppConstants.maintenanceModeRider);
          print("Successfully subscribed to Rider: ${AppConstants.maintenanceModeRider}");
        }
      }
      return true;
    }catch(e) {
      debugPrint('Topic Subscription Failed, $e');
      return false;
    }
  }

}