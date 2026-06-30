// 앱 초기 의존성 주입 파일 - 앱 시작 시 전역 서비스를 등록하는 파일
import 'package:get/get.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/ad_service.dart';

/// 앱 시작 시 가장 먼저 실행되는 전역 서비스 등록
///
/// permanent: true 로 등록된 서비스는 앱 종료 시까지 메모리에 유지됩니다.
/// 각 서비스의 실제 초기화(init())는 SplashController에서 순서대로 진행합니다.
///
/// DatabaseHelper, PuzzleRepository는 async 초기화가 필요하므로
/// SplashController._initializeApp()에서 별도로 등록합니다.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 설정 서비스 (SharedPreferences 기반)
    Get.put(SettingsService(), permanent: true);

    // 오디오 서비스 (BGM, 효과음)
    Get.put(AudioService(), permanent: true);

    // 광고 서비스 (배너, 전면 광고)
    Get.put(AdService(), permanent: true);
  }
}
