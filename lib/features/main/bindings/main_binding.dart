// 메인 화면 바인딩: MainController를 주입합니다.

import 'package:get/get.dart';

import '../../../core/services/level_progress_service.dart';
import '../controllers/main_controller.dart';

/// 메인 화면 바인딩
class MainBinding extends Bindings {
  @override
  void dependencies() {
    final levelProgress = Get.find<LevelProgressService>();
    Get.put(MainController(levelProgress));
  }
}
