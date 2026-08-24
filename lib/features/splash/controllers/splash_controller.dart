import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/models/config_model.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/splash/domain/services/splash_service_interface.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/enums.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  int? _storeCategoryID;
  int? get storeCategoryID => _storeCategoryID;

  String? _storeType;
  String? get storeType => _storeType;

  Map<String, dynamic>? _data = {};

  DateTime get currentTime => DateTime.now();

  Module getModuleConfig(String? moduleType) {
    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    moduleType == 'food' ? module.newVariation = true : module.newVariation = false;
    return module;
  }

  Future<bool> getConfigData() async {
    Response response = await splashServiceInterface.getConfigData();
    splashServiceInterface.handleInitialTopicSubscription();
    bool isSuccess = false;
    if(response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);

      bool isMaintenanceMode = _configModel!.maintenanceMode!;
      print("DEBUG: isInMaintenanceMode $isMaintenanceMode");
      String platform = AppConstants.appMode == AppMode.delivery ? 'deliveryman_app' : "rider_app";
      bool isInMaintenance = isMaintenanceMode && (_configModel?.maintenanceModeData?.maintenanceSystemSetup?.contains(platform) ?? false);
      print("DEBUG: isInMaintenance = $isInMaintenance");

      if(isInMaintenance) {
        print("DEBUG: ENTERING FIRST IF (isInMaintenance = true)");
        Get.offNamed(RouteHelper.getUpdateRoute(false));
      }else if((Get.currentRoute.contains(RouteHelper.update) && !isMaintenanceMode) || (!isInMaintenance)) {
        print("DEBUG: ENTERING ELSE IF");
        print("DEBUG: isLoggedIn = ${Get.find<AuthController>().isLoggedIn()}");
        if(Get.find<AuthController>().isLoggedIn()) {
          print("DEBUG: NAVIGATING TO InitialRoute");
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          print("DEBUG: NAVIGATING TO SignInRoute");
          Get.offNamed(RouteHelper.getSignInRoute());
        }
      }
      isSuccess = true;
    }else {
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Module getModule(String? moduleType) => Module.fromJson(_data!['module_config'][moduleType]);

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashServiceInterface.removeSharedData();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }



  /// Rider module pusher config

  String? _pusherConnectionStatus;
  String? get pusherConnectionStatus => _pusherConnectionStatus;

  void setPusherStatus(String? connection){
    _pusherConnectionStatus = connection;
  }

}