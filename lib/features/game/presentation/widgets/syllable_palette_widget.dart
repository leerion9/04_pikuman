// 게임 화면 하단의 음절 팔레트 위젯입니다.

import 'package:flutter/material.dart';

/// 음절 팔레트 위젯.
///
/// 아직 정답이 채워지지 않은 빈 칸의 음절 타일을 표시합니다.
/// 각 타일에 GlobalKey를 부여해 날아가는 애니메이션의 시작 위치 계산에 사용합니다.
/// 타일을 탭하면 [onTap] 콜백으로 해당 타일의 인덱스와 음절을 전달합니다.
class SyllablePaletteWidget extends StatelessWidget {
  /// 표시할 음절 목록
  final List<String> syllables;

  /// 타일별 GlobalKey 목록 (인덱스 대응). 애니메이션 위치 계산에 사용됩니다.
  final List<GlobalKey> tileKeys;

  /// 타일 탭 시 호출되는 콜백 (인덱스, 음절)
  final void Function(int index, String syllable) onTap;

  const SyllablePaletteWidget({
    super.key,
    required this.syllables,
    required this.tileKeys,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 부모(SizedBox/Expanded)가 높이를 정해 주면 그 안에서 스크롤합니다.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (int i = 0; i < syllables.length; i++)
            _buildTile(i, syllables[i]),
        ],
      ),
    );
  }

  Widget _buildTile(int index, String syllable) {
    return GestureDetector(
      onTap: () => onTap(index, syllable),
      child: Container(
        // 애니메이션 시작 위치 계산을 위해 GlobalKey 부여
        key: index < tileKeys.length ? tileKeys[index] : null,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B2B),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            syllable,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
