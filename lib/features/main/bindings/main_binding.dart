// 메인 화면 의존성 주입 파일 - 메인 화면에서 필요한 컨트롤러를 등록하는 파일
import 'package:get/get.dart';
import '../controllers/main_controller.dart';

/// 메인 화면 진입 시 MainController를 등록합니다.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
  }
}
