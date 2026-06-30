// 배너 광고 위젯 - 화면 하단에 표시하는 AdMob 배너 광고 공통 위젯 파일
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 화면 하단에 고정 표시되는 AdMob 배너 광고 위젯 (StatefulWidget)
///
/// ⚠️ 출시 전 [_bannerUnitId]를 실제 배너 광고 Unit ID로 교체하세요.
/// 현재는 Google 제공 테스트 ID를 사용합니다.
///
/// 사용 방법:
/// ```dart
/// Scaffold(
///   body: ...,
///   bottomNavigationBar: const BannerAdWidget(),
/// )
/// ```
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  // ⚠️ 출시 전 실제 배너 광고 Unit ID로 교체하세요
  static const _bannerUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // 테스트 배너 ID

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  /// 배너 광고를 로드합니다
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고가 로드된 경우: 실제 배너 광고 표시
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // 광고 로드 중 또는 실패: 빈 공간으로 대체 (레이아웃 유지)
    return const SizedBox(
      height: 50,
      child: ColoredBox(
        color: Color(0xFFF5F5F5),
      ),
    );
  }
}
