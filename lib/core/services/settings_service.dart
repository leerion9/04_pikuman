// 설정 서비스: 효과음·BGM·진동 설정값을 SharedPreferences에 저장하고 불러옵니다.

import 'package:shared_preferences/shared_preferences.dart';

/// 효과음·BGM·진동 설정을 로컬에 저장하고 불러오는 서비스.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keySfx = 'settings_sfx';
  static const String _keyMusic = 'settings_music';
  static const String _keyVibration = 'settings_vibration';

  /// 효과음 재생 여부 (기본값: true)
  bool get sfxEnabled => _prefs.getBool(_keySfx) ?? true;

  /// BGM 재생 여부 (기본값: true)
  bool get musicEnabled => _prefs.getBool(_keyMusic) ?? true;

  /// 진동 사용 여부 (기본값: true)
  bool get vibrationEnabled => _prefs.getBool(_keyVibration) ?? true;

  /// 효과음 설정 저장
  Future<void> setSfxEnabled(bool value) async {
    await _prefs.setBool(_keySfx, value);
  }

  /// BGM 설정 저장
  Future<void> setMusicEnabled(bool value) async {
    await _prefs.setBool(_keyMusic, value);
  }

  /// 진동 설정 저장
  Future<void> setVibrationEnabled(bool value) async {
    await _prefs.setBool(_keyVibration, value);
  }
}
