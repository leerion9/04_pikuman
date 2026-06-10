// 어드민 앱 전체 설정 파일 - GetX 라우팅, 테마 설정
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';

/// pikuman4 어드민 도구 앱의 루트 위젯
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'pikuman4 Admin — 노노그램 퍼즐 제작 도구',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // 데스크톱 UI에 맞게 기본 폰트 크기 조정
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
