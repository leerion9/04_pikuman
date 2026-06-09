// 게임 화면 바인딩: GameController에 필요한 서비스를 주입합니다.

import 'package:get/get.dart';

import '../../../core/services/data_service.dart';
import '../../../core/services/level_progress_service.dart';
import '../../../core/services/save_service.dart';
import '../../../core/services/wordbook_service.dart';
import '../controllers/game_controller.dart';

/// 게임 화면 바인딩.
/// DataService, SaveService, LevelProgressService, WordbookService 를 GameController에 주입합니다.
class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      GameController(
        Get.find<DataService>(),
        Get.find<SaveService>(),
        Get.find<LevelProgressService>(),
        Get.find<WordbookService>(),
      ),
    );
  }
}
