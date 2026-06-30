// 설정 서비스 - 사운드·진동·오류표시 등 앱 설정값을 SharedPreferences에 저장하는 파일
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 설정값을 관리하는 전역 서비스
///
/// SharedPreferences를 통해 앱 종료 후에도 설정이 유지됩니다.
/// init()을 호출한 뒤부터 사용 가능합니다.
///
/// 설정 항목:
/// - isMusicOn    : 배경음악 ON/OFF (기본값: true)
/// - isSoundOn    : 효과음 ON/OFF (기본값: true)
/// - isVibrationOn: 진동 ON/OFF (기본값: true)
/// - isEasyMode   : 오류 즉시 표시 ON/OFF (기본값: false = Normal 모드)
/// - currentLevel : 현재 플레이할 레벨 번호 (기본값: 1)
class SettingsService extends GetxService {
  // SharedPreferences 키 상수
  static const _keyMusic = 'music_on';
  static const _keySound = 'sound_on';
  static const _keyVibration = 'vibration_on';
  static const _keyEasyMode = 'easy_mode';
  static const _keyCurrentLevel = 'current_level';

  late SharedPreferences _prefs;

  // 반응형 상태값 (GetX Rx) - 화면에서 Obx로 바로 구독 가능
  final isMusicOn = true.obs;
  final isSoundOn = true.obs;
  final isVibrationOn = true.obs;
  final isEasyMode = false.obs;
  final currentLevel = 1.obs;

  /// SharedPreferences를 열고 저장된 설정값을 불러옵니다
  Future<SettingsService> init() async {
    _prefs = await SharedPreferences.getInstance();
    isMusicOn.value = _prefs.getBool(_keyMusic) ?? true;
    isSoundOn.value = _prefs.getBool(_keySound) ?? true;
    isVibrationOn.value = _prefs.getBool(_keyVibration) ?? true;
    isEasyMode.value = _prefs.getBool(_keyEasyMode) ?? false;
    currentLevel.value = _prefs.getInt(_keyCurrentLevel) ?? 1;
    return this;
  }

  /// 배경음악 ON/OFF를 변경하고 저장합니다
  Future<void> toggleMusic() async {
    isMusicOn.value = !isMusicOn.value;
    await _prefs.setBool(_keyMusic, isMusicOn.value);
  }

  /// 효과음 ON/OFF를 변경하고 저장합니다
  Future<void> toggleSound() async {
    isSoundOn.value = !isSoundOn.value;
    await _prefs.setBool(_keySound, isSoundOn.value);
  }

  /// 진동 ON/OFF를 변경하고 저장합니다
  Future<void> toggleVibration() async {
    isVibrationOn.value = !isVibrationOn.value;
    await _prefs.setBool(_keyVibration, isVibrationOn.value);
  }

  /// 오류 즉시 표시(Easy 모드) ON/OFF를 변경하고 저장합니다
  Future<void> toggleEasyMode() async {
    isEasyMode.value = !isEasyMode.value;
    await _prefs.setBool(_keyEasyMode, isEasyMode.value);
  }

  /// 현재 레벨 번호를 업데이트하고 저장합니다
  ///
  /// [level]: 새로 설정할 레벨 번호 (1 이상)
  Future<void> setCurrentLevel(int level) async {
    currentLevel.value = level;
    await _prefs.setInt(_keyCurrentLevel, level);
  }
}
