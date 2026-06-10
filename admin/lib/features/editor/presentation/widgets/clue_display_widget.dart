// 클루 표시 위젯 - 계산된 행·열 클루 숫자를 그리드 옆에 표시하는 위젯
import 'package:flutter/material.dart';

/// 행 클루(가로 힌트) 또는 열 클루(세로 힌트)를 표시하는 위젯
///
/// 사용 방법:
/// - 행 클루: isRow = true, 그리드 왼쪽에 배치
/// - 열 클루: isRow = false, 그리드 위쪽에 배치
class ClueDisplayWidget extends StatelessWidget {
  const ClueDisplayWidget({
    super.key,
    required this.clues,
    required this.cellSize,
    required this.isRow,
  });

  /// 각 행(또는 열)의 클루 목록
  final List<List<int>> clues;

  /// 그리드 셀 하나의 픽셀 크기 (그리드와 크기 일치)
  final double cellSize;

  /// true: 행 클루 (세로 방향 나열), false: 열 클루 (가로 방향 나열)
  final bool isRow;

  @override
  Widget build(BuildContext context) {
    if (isRow) {
      // 행 클루: 각 행에 해당하는 클루를 세로로 나열
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: clues.map((clue) => _RowClueCell(clue: clue, height: cellSize)).toList(),
      );
    } else {
      // 열 클루: 각 열에 해당하는 클루를 가로로 나열
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: clues.map((clue) => _ColClueCell(clue: clue, width: cellSize)).toList(),
      );
    }
  }
}

/// 행 클루 한 칸 (가로줄 왼쪽에 표시)
class _RowClueCell extends StatelessWidget {
  const _RowClueCell({required this.clue, required this.height});

  final List<int> clue;
  final double height;

  @override
  Widget build(BuildContext context) {
    // 클루 숫자들을 오른쪽 정렬로 한 줄에 표시
    final text = clue.where((v) => v > 0).join(' ');

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            text.isEmpty ? '0' : text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

/// 열 클루 한 칸 (세로줄 위에 표시)
class _ColClueCell extends StatelessWidget {
  const _ColClueCell({required this.clue, required this.width});

  final List<int> clue;
  final double width;

  @override
  Widget build(BuildContext context) {
    // 클루 숫자들을 세로로 쌓아서 표시
    final numbers = clue.where((v) => v > 0).toList();

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (numbers.isEmpty)
            Text('0',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)
          else
            ...numbers.map(
              (n) => Text(
                '$n',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
