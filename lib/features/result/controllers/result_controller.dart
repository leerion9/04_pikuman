// 게임 결과 화면 컨트롤러 - 클리어 결과 정보를 관리하고 다음 화면으로 이동하는 파일
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../core/data/puzzle_repository.dart';
import '../../../core/services/settings_service.dart';

/// 게임 결과 화면의 데이터와 버튼 이벤트를 관리합니다
///
/// Get.arguments로 전달받는 데이터:
/// - 'puzzleId'       : int  - 클리어한 레벨 ID
/// - 'elapsedSeconds' : int  - 클리어 소요 시간 (초)
/// - 'title'          : String - 퍼즐 제목
/// - 'thumbnail'      : String? - 완성 이미지 (Base64 또는 URL, 없으면 null)
class ResultController extends GetxController {
  /// 클리어한 레벨 ID
  late final int puzzleId;

  /// 클리어 소요 시간 (초)
  late final int elapsedSeconds;

  /// 퍼즐 제목
  late final String title;

  /// 완성 이미지 썸네일 (없을 수 있음)
  late final String? thumbnail;

  /// 다음 레벨이 존재하는지 여부
  final hasNextLevel = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    puzzleId = args['puzzleId'] as int? ?? 1;
    elapsedSeconds = args['elapsedSeconds'] as int? ?? 0;
    title = args['title'] as String? ?? '';
    thumbnail = args['thumbnail'] as String?;
    _checkNextLevel();
  }

  /// 다음 레벨 존재 여부를 확인합니다
  Future<void> _checkNextLevel() async {
    final nextId =
        await Get.find<PuzzleRepository>().getNextId(puzzleId);
    hasNextLevel.value = nextId != null;
  }

  /// 경과 시간을 "분:초" 포맷으로 반환합니다 (예: 3:07)
  String get timerText {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Home 버튼: 메인 화면으로 돌아갑니다
  void onHomePressed() {
    Get.offAllNamed(Routes.main);
  }

  /// Next Level 버튼: 다음 레벨 게임 화면으로 이동합니다
  Future<void> onNextLevelPressed() async {
    final nextId =
        await Get.find<PuzzleRepository>().getNextId(puzzleId);
    if (nextId == null) {
      onHomePressed();
      return;
    }
    await Get.find<SettingsService>().setCurrentLevel(nextId);
    Get.offAllNamed(Routes.game, arguments: {'puzzleId': nextId});
  }
}
