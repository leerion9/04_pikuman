// 설정 화면 파일 - 사운드·진동·오류 표시 설정 토글과 평점 버튼을 표시하는 화면
// Phase 6에서 구현 예정
import 'package:flutter/material.dart';

/// 설정 화면
///
/// 구현 예정 내용 (Phase 6):
/// - 배경음악(music) 토글
/// - 효과음(sound) 토글
/// - 진동(vibration) 토글
/// - 오류 즉시 표시(Easy 모드) 토글
/// - 평점 남기기 버튼 (In-App Review → 스토어 이동 fallback)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('설정 화면 (구현 예정)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
