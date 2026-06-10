// 앱 진입점 - Flutter 앱을 시작하는 파일
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';

/// 앱 시작 함수
/// - 세로 모드 고정
/// - PikumanApp 실행
void main() async {
  // Flutter 엔진 초기화 (async 작업 전 반드시 필요)
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향을 세로 모드로만 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const PikumanApp());
}
