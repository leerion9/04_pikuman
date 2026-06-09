// 단어장 화면 바인딩: WordbookController에 필요한 서비스를 주입합니다.

import 'package:get/get.dart';

import '../../../core/services/level_progress_service.dart';
import '../../../core/services/wordbook_service.dart';
import '../controllers/wordbook_controller.dart';

/// 단어장 화면 바인딩.
/// LevelProgressService, WordbookService 를 WordbookController에 주입합니다.
class WordbookBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      WordbookController(
        Get.find<LevelProgressService>(),
        Get.find<WordbookService>(),
      ),
    );
  }
}
