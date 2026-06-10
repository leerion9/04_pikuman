// 메인 화면 파일 - 캐릭터, 현재 레벨, Play/갤러리 버튼을 표시하는 화면
// Phase 3에서 구현 예정
import 'package:flutter/material.dart';

/// 메인 화면
///
/// 구현 예정 내용 (Phase 3):
/// - pikuMAN 캐릭터 이미지
/// - "현재 레벨 : N" 버튼
/// - Play 버튼 (게임 화면으로 이동)
/// - 갤러리 버튼 (클리어한 퍼즐 모음)
/// - 설정 버튼
/// - 하단 배너 광고
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('메인 화면 (구현 예정)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
