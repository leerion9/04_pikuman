// 배너 광고 위젯 - 화면 하단에 표시하는 AdMob 배너 광고 공통 위젯 파일
// Phase 6에서 구현 예정
import 'package:flutter/material.dart';

/// 화면 하단에 고정 표시되는 AdMob 배너 광고 위젯
/// 게임 플레이, 결과, 갤러리 등 광고가 필요한 화면에서 사용합니다.
///
/// 사용 방법:
/// ```dart
/// Scaffold(
///   body: ...,
///   bottomNavigationBar: BannerAdWidget(),
/// )
/// ```
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Phase 6에서 실제 AdMob 배너 광고로 교체
    // 현재는 광고 영역 크기만 예약해 놓은 빈 컨테이너입니다.
    return const SizedBox(
      height: 50,
      child: ColoredBox(
        color: Color(0xFFEEEEEE),
        child: Center(
          child: Text(
            '광고 영역 (구현 예정)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
