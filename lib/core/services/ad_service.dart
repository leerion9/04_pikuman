// 광고 서비스 - Google AdMob 배너·전면 광고를 로드하고 표시하는 파일
// Phase 6에서 구현 예정
import 'package:get/get.dart';

/// Google AdMob 광고를 관리하는 전역 서비스
///
/// 관리하는 광고:
/// - 배너 광고: 게임 플레이·결과·갤러리 등 화면 하단에 고정 표시
/// - 전면 광고: 10개 레벨 클리어 시마다 전체 화면으로 표시
///
/// ⚠️ 출시 전 반드시 교체 필요:
/// - AdMob App ID (AndroidManifest.xml)
/// - 배너 광고 Unit ID
/// - 전면 광고 Unit ID
class AdService extends GetxService {
  // TODO: Phase 6에서 구현
  // 배너 광고 로드, 전면 광고 로드·표시 메서드 추가 예정

  /// 전면 광고 표시 (구현 예정)
  /// 10레벨 클리어마다 호출됩니다.
  void showInterstitialAd() {}
}
