// 설정 화면 바인딩: SettingsController를 주입합니다.

import 'package:get/get.dart';

import '../../../core/services/settings_service.dart';
import '../controllers/settings_controller.dart';

/// 설정 화면 바인딩
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController(Get.find<SettingsService>()));
  }
}
