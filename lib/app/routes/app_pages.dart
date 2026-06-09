// 앱의 모든 화면 경로(라우트)와 GetPage 목록을 정의하는 파일입니다.

import 'package:get/get.dart';

import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/main/bindings/main_binding.dart';
import '../../features/main/presentation/main_page.dart';
import '../../features/game/bindings/game_binding.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/result/bindings/result_binding.dart';
import '../../features/result/presentation/result_page.dart';
import '../../features/wordbook/bindings/wordbook_binding.dart';
import '../../features/wordbook/presentation/wordbook_page.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/presentation/settings_page.dart';

/// 화면 이름 상수 (화면 이동 시 사용)
abstract class AppRoutes {
  static const splash = '/splash';
  static const main = '/main';
  static const game = '/game';
  static const result = '/result';
  static const wordbook = '/wordbook';
  static const settings = '/settings';
}

/// GetX 라우트 목록 (경로 -> 화면·바인딩 매핑)
class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GamePage(),
      binding: GameBinding(),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultPage(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: AppRoutes.wordbook,
      page: () => const WordbookPage(),
      binding: WordbookBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
  ];
}
