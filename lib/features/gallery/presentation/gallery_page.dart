// 갤러리 화면 파일 - 클리어한 퍼즐의 완성 그림 썸네일 모음 화면
// Phase 5에서 구현 예정
import 'package:flutter/material.dart';

/// 갤러리 화면
///
/// 구현 예정 내용 (Phase 5):
/// - 클리어한 퍼즐의 완성 그림 썸네일을 그리드로 표시
/// - 썸네일 탭 시 퍼즐 제목·소요 시간 팝업/상세 화면
/// - 하단 배너 광고
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('갤러리 화면 (구현 예정)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
