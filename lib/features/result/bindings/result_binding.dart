// 게임 결과 화면 의존성 주입 파일 - ResultController를 등록하는 파일
import 'package:get/get.dart';
import '../controllers/result_controller.dart';

/// 게임 결과 화면 진입 시 ResultController를 등록합니다
class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResultController());
  }
}
