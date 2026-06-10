// 게임 플레이 화면 의존성 주입 파일 - 게임 화면에서 필요한 컨트롤러를 등록하는 파일
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

/// 게임 플레이 화면 진입 시 GameController를 등록합니다.
class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GameController());
  }
}
