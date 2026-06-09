// 메인 화면 컨트롤러: 현재 레벨 표시와 게임·단어장 진입을 담당합니다.

import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/services/level_progress_service.dart';

/// 메인 화면 컨트롤러
class MainController extends GetxController {
  MainController(this._levelProgress);

  final LevelProgressService _levelProgress;

  /// 현재 플레이할 레벨 번호 (1부터 시작)
  final currentLevel = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLevel();
  }

  @override
  void onReady() {
    super.onReady();
    _loadLevel();
  }

  void _loadLevel() {
    currentLevel.value = _levelProgress.getCurrentLevel();
  }

  /// 플레이 버튼: 현재 레벨로 게임 화면에 진입합니다.
  void goToGame() {
    _loadLevel();
    Get.toNamed(AppRoutes.game, arguments: currentLevel.value);
  }

  /// 단어장 버튼: 단어장 화면으로 이동합니다.
  void goToWordbook() {
    Get.toNamed(AppRoutes.wordbook);
  }
}
