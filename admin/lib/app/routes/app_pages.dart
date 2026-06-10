// 어드민 앱 라우트 정의 파일 - 모든 화면의 경로와 연결 정보
import 'package:get/get.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/editor/presentation/editor_page.dart';
import '../../features/play_test/presentation/play_test_page.dart';

/// 어드민 앱 화면 경로 상수
abstract class Routes {
  static const home = '/';
  static const editor = '/editor';
  static const playTest = '/play-test';
}

/// GetX 라우트 페이지 목록
abstract class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(name: Routes.home, page: () => const HomePage()),
    GetPage(name: Routes.editor, page: () => const EditorPage()),
    GetPage(name: Routes.playTest, page: () => const PlayTestPage()),
  ];
}
