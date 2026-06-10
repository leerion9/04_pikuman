// 설정 저장 서비스 - 사운드·진동·오류표시 등 앱 설정값을 SharedPreferences에 저장하고 불러오는 파일
// Phase 6에서 구현 예정
import 'package:get/get.dart';

/// 앱 설정값을 관리하는 전역 서비스
/// SharedPreferences를 통해 앱 종료 후에도 설정이 유지됩니다.
///
/// 관리하는 설정 항목:
/// - isMusicOn: 배경음악 ON/OFF
/// - isSoundOn: 효과음 ON/OFF
/// - isVibrationOn: 진동 피드백 ON/OFF
/// - isEasyMode: 오류 즉시 표시 모드 ON/OFF (ON=Easy, OFF=Normal)
class SettingsService extends GetxService {
  // TODO: Phase 6에서 구현
  // SharedPreferences를 이용한 설정값 저장·불러오기 로직 추가 예정
}
