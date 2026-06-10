// 게임 결과 화면 파일 - 레벨 클리어 확인, 완성된 그림, 소요 시간을 표시하는 화면
// Phase 5에서 구현 예정
import 'package:flutter/material.dart';

/// 게임 결과 화면
///
/// 구현 예정 내용 (Phase 5):
/// - 레벨 클리어 메시지 + 애니메이션
/// - 완성된 퍼즐 그림
/// - 소요 시간 표시
/// - Home 버튼 (메인 화면으로)
/// - Next Level 버튼 (다음 레벨 바로 시작)
/// - 하단 배너 광고
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('게임 결과 화면 (구현 예정)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
