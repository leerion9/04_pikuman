// 앱 전체 화면 경로(라우트) 정의 파일 - 모든 화면의 URL 경로와 연결 정보를 관리하는 파일
import 'package:get/get.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/main/bindings/main_binding.dart';
import '../../features/main/presentation/main_page.dart';
import '../../features/game/bindings/game_binding.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/result/bindings/result_binding.dart';
import '../../features/result/presentation/result_page.dart';
import '../../features/gallery/bindings/gallery_binding.dart';
import '../../features/gallery/presentation/gallery_page.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/presentation/settings_page.dart';

/// 앱 내 모든 화면의 경로(URL) 상수 모음
abstract class Routes {
  static const splash = '/splash';
  static const main = '/main';
  static const game = '/game';
  static const result = '/result';
  static const gallery = '/gallery';
  static const settings = '/settings';
}

/// GetX 라우트 페이지 목록
/// 각 경로에 어떤 화면(Page)과 바인딩(Binding)을 연결할지 정의합니다.
abstract class AppPages {
  /// 앱 시작 시 처음 열리는 화면
  static const initial = Routes.splash;

  /// 전체 라우트 목록
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.game,
      page: () => const GamePage(),
      binding: GameBinding(),
    ),
    GetPage(
      name: Routes.result,
      page: () => const ResultPage(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: Routes.gallery,
      page: () => const GalleryPage(),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
  ];
}
