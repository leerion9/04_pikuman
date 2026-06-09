// 하단 고정 배너 광고 위젯: AdService 캐시를 표시합니다 (화면마다 새로 로드하지 않음).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

/// 화면 하단 배너 광고 위젯.
///
/// - [AdService]에서 preload된 배너를 즉시 표시합니다.
/// - 슬롯 높이를 고정해 광고 로드 전후 레이아웃이 변하지 않습니다.
/// - [AppBannerScaffold]에서 1개만 유지해 화면 전환 시 재로드하지 않습니다.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  AdService? _adService;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    _adService = Get.find<AdService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePreload());
  }

  /// 실제 화면 너비로 preload를 보장합니다 (아직 없을 때만 요청).
  void _ensurePreload() {
    if (!mounted || _adService == null) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    _adService!.preloadBanner(width);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox(height: 50);
    }

    final adService = _adService ?? Get.find<AdService>();

    return Obx(() {
      final height = adService.bannerSlotHeight.value;
      final ad = adService.bannerAd;

      return SizedBox(
        width: double.infinity,
        height: height,
        child: ad != null
            ? Center(
                child: SizedBox(
                  width: ad.size.width.toDouble(),
                  height: ad.size.height.toDouble(),
                  child: AdWidget(ad: ad),
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}
