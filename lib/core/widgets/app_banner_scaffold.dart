// 배너 광고를 화면별로 dispose하지 않고 앱 하단에 고정하는 래퍼입니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../services/route_sync_service.dart';
import 'banner_ad_widget.dart';

/// 배너를 표시할 라우트 (메인·게임·결과)
const _bannerRoutes = {
  AppRoutes.main,
  AppRoutes.game,
  AppRoutes.result,
};

/// GetMaterialApp [builder]: 본문 + 하단 배너(Offstage로 숨김만, dispose 안 함).
class AppBannerScaffold extends StatelessWidget {
  const AppBannerScaffold({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final routeSync = Get.find<RouteSyncService>();

    // Navigator(child)는 Obx 밖에 둡니다.
    // Obx로 전체를 감싸면 GlobalKey<NavigatorState> 중복 오류가 납니다.
    return Column(
      children: [
        Expanded(child: child ?? const SizedBox.shrink()),
        Obx(() {
          final showBanner =
              _bannerRoutes.contains(routeSync.current.value);
          return SafeArea(
            top: false,
            child: Offstage(
              offstage: !showBanner,
              child: const BannerAdWidget(),
            ),
          );
        }),
      ],
    );
  }
}
