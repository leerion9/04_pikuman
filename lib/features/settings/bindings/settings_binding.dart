// 설정 화면 의존성 주입 파일 - 설정 화면에서 필요한 컨트롤러를 등록하는 파일
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

/// 설정 화면 진입 시 SettingsController를 등록합니다.
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}
