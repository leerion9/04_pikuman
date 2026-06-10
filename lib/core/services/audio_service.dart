// 오디오 서비스 - BGM과 효과음 재생·정지·볼륨을 관리하는 파일
// Phase 6에서 구현 예정
import 'package:get/get.dart';

/// 게임 내 모든 오디오를 중앙에서 관리하는 전역 서비스
/// audioplayers 패키지를 사용합니다.
///
/// 관리하는 오디오:
/// - BGM: 게임 진행 중 배경음악 (앱 백그라운드 시 일시정지)
/// - 효과음: 칸 채우기, X표시, 오류 입력, 레벨 클리어
class AudioService extends GetxService {
  // TODO: Phase 6에서 구현
  // BGM 재생/정지, 효과음 재생 메서드 추가 예정

  /// 칸 채우기 효과음 재생 (구현 예정)
  void playFillSound() {}

  /// X표시 효과음 재생 (구현 예정)
  void playMarkSound() {}

  /// 오류 입력 효과음 재생 (구현 예정)
  void playErrorSound() {}

  /// 레벨 클리어 효과음 재생 (구현 예정)
  void playClearSound() {}
}
