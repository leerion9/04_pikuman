// 설정 화면 컨트롤러: 효과음·BGM·진동 토글 상태를 관리하고 서비스와 동기화합니다.

import 'package:get/get.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/services/settings_service.dart';

/// 설정 화면 컨트롤러
class SettingsController extends GetxController {
  SettingsController(this._settings);

  final SettingsService _settings;

  final sfxEnabled = true.obs;
  final musicEnabled = true.obs;
  final vibrationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    sfxEnabled.value = _settings.sfxEnabled;
    musicEnabled.value = _settings.musicEnabled;
    vibrationEnabled.value = _settings.vibrationEnabled;
  }

  void setSfx(bool value) {
    sfxEnabled.value = value;
    _settings.setSfxEnabled(value);
  }

  void setMusic(bool value) {
    musicEnabled.value = value;
    _settings.setMusicEnabled(value);
    try {
      final audio = Get.find<AudioService>();
      value ? audio.resumeBgm() : audio.pauseBgm();
    } catch (_) {}
  }

  void setVibration(bool value) {
    vibrationEnabled.value = value;
    _settings.setVibrationEnabled(value);
  }

  void back() => Get.back();
}
