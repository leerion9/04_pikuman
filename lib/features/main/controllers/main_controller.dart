// 메인 화면 컨트롤러 - 현재 레벨 표시와 화면 이동을 담당하는 파일
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../core/data/puzzle_repository.dart';
import '../../../core/services/settings_service.dart';

/// 메인 화면의 상태와 버튼 이벤트를 관리합니다
///
/// 화면에 표시할 내용:
/// - 현재 플레이할 레벨 번호 (SettingsService에서 관리)
/// - 사용 가능한 첫 레벨 확인 (번들 퍼즐 로드 여부 확인)
class MainController extends GetxController {
  /// 현재 플레이할 레벨 번호 (SettingsService와 동기화됨)
  int get currentLevel => Get.find<SettingsService>().currentLevel.value;

  /// 플레이할 퍼즐이 실제로 존재하는지 여부
  final isPuzzleAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPuzzleAvailability();
  }

  /// 현재 레벨의 퍼즐이 존재하는지 확인합니다
  Future<void> _checkPuzzleAvailability() async {
    final repo = Get.find<PuzzleRepository>();
    final puzzle = await repo.getPuzzle(currentLevel);
    isPuzzleAvailable.value = puzzle != null;
  }

  /// Play 버튼: 현재 레벨의 게임 화면으로 이동합니다
  Future<void> onPlayPressed() async {
    final repo = Get.find<PuzzleRepository>();
    final puzzle = await repo.getPuzzle(currentLevel);

    if (puzzle == null) {
      // 퍼즐이 없을 경우 첫 번째 사용 가능한 레벨로 대체
      final firstId = await repo.getFirstAvailableId();
      if (firstId == null) {
        Get.snackbar('알림', '플레이 가능한 퍼즐이 없습니다.\n인터넷 연결 후 다시 시도해 주세요.');
        return;
      }
      await Get.find<SettingsService>().setCurrentLevel(firstId);
      Get.toNamed(Routes.game, arguments: {'puzzleId': firstId});
    } else {
      Get.toNamed(Routes.game, arguments: {'puzzleId': currentLevel});
    }
  }

  /// 갤러리 버튼: 클리어한 퍼즐 갤러리 화면으로 이동합니다
  void onGalleryPressed() {
    Get.toNamed(Routes.gallery);
  }

  /// 설정 버튼: 설정 화면으로 이동합니다
  void onSettingsPressed() {
    Get.toNamed(Routes.settings);
  }
}
