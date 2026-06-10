// 앱 전체 설정 파일 - GetX 라우팅, 테마, 초기 바인딩을 설정하는 파일
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';

/// pikuman4 앱의 루트 위젯
/// GetMaterialApp을 사용하여 GetX 기능(라우팅, 상태관리 등)을 활성화합니다.
class PikumanApp extends StatelessWidget {
  const PikumanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 앱 제목 (멀티태스킹 화면 등에 표시)
      title: 'pikuman4 : nonogram',

      // 디버그 배너 숨기기
      debugShowCheckedModeBanner: false,

      // 처음 열리는 화면 (스플래시)
      initialRoute: AppPages.initial,

      // 전체 라우트(화면 경로) 목록
      getPages: AppPages.routes,

      // 앱 시작 시 전역 서비스 초기화
      initialBinding: InitialBinding(),

      // 앱 기본 테마 (추후 디자인 확정 후 변경)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE53935)),
        useMaterial3: true,
      ),
    );
  }
}
