// 게임 플레이 화면 파일 - 노노그램 그리드, 클루, 타이머를 표시하는 게임 화면
// Phase 4에서 구현 예정
import 'package:flutter/material.dart';

/// 게임 플레이 화면
///
/// 구현 예정 내용 (Phase 4):
/// - "Level N" 헤더
/// - 경과 타이머 (기록용, 제한 없음)
/// - 행 클루 (왼쪽 숫자 힌트)
/// - 열 클루 (위쪽 숫자 힌트)
/// - 노노그램 그리드 (탭: 채우기, 길게 누르기: X표시)
/// - 하단 배너 광고
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('게임 플레이 화면 (구현 예정)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
