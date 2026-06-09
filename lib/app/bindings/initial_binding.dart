// 앱 최초 실행 시 공통으로 주입되는 바인딩 파일입니다.

import 'package:get/get.dart';

import '../../core/services/route_sync_service.dart';

/// 앱 시작 시 한 번만 등록하는 전역 바인딩.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RouteSyncService(), permanent: true);
  }
}
