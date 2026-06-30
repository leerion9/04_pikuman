// 스플래시 화면 컨트롤러 - 앱 초기화 순서를 관리하고 메인 화면으로 이동하는 파일
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/data/puzzle_repository.dart';
import '../../../core/network/puzzle_api_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/ad_service.dart';

/// 스플래시 화면의 진행 단계와 앱 초기화를 관리합니다
///
/// 단계:
///   0 → 스플래시 1 (interpage 로고, 2초)
///   1 → 스플래시 2 (pikuMAN 캐릭터, 초기화 진행)
class SplashController extends GetxController {
  /// 현재 스플래시 단계 (0=splash1, 1=splash2)
  final phase = 0.obs;

  /// 스플래시 2 화면의 로딩 상태 메시지
  final loadingText = '초기화 중...'.obs;

  @override
  void onInit() {
    super.onInit();
    _runSplash();
  }

  /// 스플래시 전체 흐름을 실행합니다
  Future<void> _runSplash() async {
    // 스플래시 1: 2초 표시
    await Future.delayed(const Duration(seconds: 2));

    // 스플래시 2로 전환 후 초기화 시작
    phase.value = 1;
    await _initializeApp();

    // 초기화 완료 → 메인 화면으로 이동 (뒤로가기 불가)
    Get.offAllNamed(Routes.main);
  }

  /// 앱 서비스를 순서대로 초기화합니다
  Future<void> _initializeApp() async {
    // 1. 설정 로드 (SharedPreferences)
    loadingText.value = '설정을 불러오는 중...';
    await Get.find<SettingsService>().init();

    // 2. SQLite DB 초기화
    loadingText.value = '데이터베이스 초기화 중...';
    final dbHelper = DatabaseHelper();
    await dbHelper.init();
    Get.put(dbHelper, permanent: true);

    // 3. 퍼즐 리포지토리 등록
    Get.put(PuzzleRepository(), permanent: true);

    // 4. AdMob 초기화
    loadingText.value = '광고 로드 중...';
    await Get.find<AdService>().init();

    // 5. 오디오 초기화 및 BGM 시작
    loadingText.value = '오디오 초기화 중...';
    await Get.find<AudioService>().init();
    await Get.find<AudioService>().playBgm();

    // 6. 서버에서 신규 레벨 확인 (실패해도 앱 진행)
    loadingText.value = '새 레벨 확인 중...';
    await _checkNewLevels();

    loadingText.value = '준비 완료!';
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// 서버에서 신규 레벨을 확인하고 다운로드합니다
  ///
  /// 네트워크 오류 시 무시하고 계속 진행합니다.
  Future<void> _checkNewLevels() async {
    try {
      final serverIds = await PuzzleApiService.fetchAvailableIds();
      final repo = Get.find<PuzzleRepository>();

      for (final id in serverIds) {
        final puzzle = await PuzzleApiService.fetchPuzzle(id);
        if (puzzle != null) {
          await repo.saveServerPuzzle(puzzle);
        }
      }
    } catch (_) {
      // 네트워크 오류 무시 (오프라인에서도 앱 정상 실행)
    }
  }
}
