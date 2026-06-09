// 현재 GetX 라우트를 Obx UI가 구독할 수 있게 동기화합니다.

import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';

/// [GetMaterialApp.routingCallback]으로 갱신되는 현재 라우트.
class RouteSyncService extends GetxService {
  final current = AppRoutes.splash.obs;

  void updateRoute(String? route) {
    if (route == null || route.isEmpty) return;
    current.value = route;
  }
}
