// 광고 서비스 - Google AdMob 배너·전면 광고를 관리하는 파일
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google AdMob 광고를 관리하는 전역 서비스
///
/// ⚠️ 출시 전 반드시 교체:
/// - [_interstitialUnitId]: 실제 전면 광고 Unit ID로 교체 (android/app/src/main/AndroidManifest.xml도 함께)
/// - 현재 설정된 ID는 Google 제공 테스트 ID입니다.
///
/// 광고 종류:
/// - 배너 광고  : BannerAdWidget에서 직접 생성·표시 (화면 하단 고정)
/// - 전면 광고  : 10레벨 클리어마다 showInterstitialAd() 호출
class AdService extends GetxService {
  // ⚠️ 출시 전 실제 광고 Unit ID로 교체하세요
  static const _interstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // 테스트 전면 광고 ID

  InterstitialAd? _interstitialAd;

  /// AdMob SDK를 초기화하고 첫 전면 광고를 미리 로드합니다
  Future<AdService> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    return this;
  }

  /// 전면 광고를 미리 로드합니다 (표시 준비)
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                // 광고 닫힌 후 다음 광고 미리 로드
                onAdDismissedFullScreenContent: (_) {
                  _interstitialAd = null;
                  _loadInterstitialAd();
                },
                onAdFailedToShowFullScreenContent: (_, __) {
                  _interstitialAd = null;
                  _loadInterstitialAd();
                },
              );
        },
        onAdFailedToLoad: (_) {
          // 광고 로드 실패 시 무시 (앱 크래시 방지)
          _interstitialAd = null;
        },
      ),
    );
  }

  /// 전면 광고를 표시합니다
  ///
  /// 10레벨 클리어마다 호출됩니다. 광고가 준비되지 않았으면 그냥 넘어갑니다.
  void showInterstitialAd() {
    if (_interstitialAd == null) return;
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }
}
