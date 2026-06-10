// 어드민 앱 진입점 - Windows 데스크톱 어드민 도구를 시작하는 파일
import 'package:flutter/material.dart';
import 'app/app.dart';

/// 어드민 앱 시작 함수
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdminApp());
}
