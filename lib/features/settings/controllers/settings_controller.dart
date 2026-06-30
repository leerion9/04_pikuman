// 설정 화면 컨트롤러 - 토글 상태 변경과 인앱 리뷰 요청을 담당하는 파일
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/audio_service.dart';

/// 설정 화면의 버튼 이벤트와 상태를 관리합니다
///
/// SettingsService의 값을 직접 참조하므로 별도 상태 없이 위임합니다.
class SettingsController extends GetxController {
  SettingsService get _settings => Get.find<SettingsService>();
  AudioService get _audio => Get.find<AudioService>();

  // 구글 플레이 스토어 앱 URL
  static const _storeUrl =
      'https://play.google.com/store/apps/details?id=com.interpage.pikuman4';

  /// 배경음악 ON/OFF를 토글합니다
  Future<void> toggleMusic() async {
    await _settings.toggleMusic();
    await _audio.applyMusicSetting();
  }

  /// 효과음 ON/OFF를 토글합니다
  Future<void> toggleSound() async {
    await _settings.toggleSound();
  }

  /// 진동 ON/OFF를 토글합니다
  Future<void> toggleVibration() async {
    await _settings.toggleVibration();
  }

  /// 오류 즉시 표시(Easy 모드) ON/OFF를 토글합니다
  Future<void> toggleEasyMode() async {
    await _settings.toggleEasyMode();
  }

  /// 인앱 리뷰를 요청하고, 불가능하면 스토어로 이동합니다
  Future<void> requestReview() async {
    final inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await _openStore();
      }
    } catch (_) {
      await _openStore();
    }
  }

  /// 구글 플레이 스토어 앱 페이지를 엽니다
  Future<void> _openStore() async {
    final uri = Uri.parse(_storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('알림', '스토어를 열 수 없습니다.');
    }
  }
}
