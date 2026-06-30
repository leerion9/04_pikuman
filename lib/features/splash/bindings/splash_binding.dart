// 스플래시 화면 의존성 주입 파일 - SplashController를 등록하는 파일
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// 스플래시 화면 진입 시 SplashController를 등록합니다
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}
