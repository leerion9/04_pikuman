// 앱 시작 시 전역 서비스 초기화 파일 - 앱 전체에서 사용하는 서비스를 앱 시작 시 등록하는 파일
import 'package:get/get.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/ad_service.dart';

/// 앱 시작 시 가장 먼저 실행되는 의존성 주입 설정
/// permanent: true 로 등록된 서비스는 앱이 종료될 때까지 메모리에 유지됩니다.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 설정 서비스 (사운드 ON/OFF, 진동 등)
    Get.put(SettingsService(), permanent: true);

    // 오디오 서비스 (BGM, 효과음)
    Get.put(AudioService(), permanent: true);

    // 광고 서비스 (배너, 전면 광고)
    Get.put(AdService(), permanent: true);
  }
}
