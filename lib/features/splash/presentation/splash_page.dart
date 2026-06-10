// 스플래시 화면 파일 - 앱 시작 시 로고를 표시하고 신규 레벨을 다운로드하는 화면
// Phase 3에서 구현 예정
import 'package:flutter/material.dart';

/// 스플래시 화면
///
/// 구현 예정 내용 (Phase 3):
/// - 스플래시 1: 하늘색 배경 + interpage 회사 로고
/// - 스플래시 2: 빨간 배경 + pikuMAN 캐릭터 + 서버 신규 레벨 체크·다운로드
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      body: Center(
        child: Text(
          'pikuman4 : nonogram\n(스플래시 화면 - 구현 예정)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
