// 클루 위젯 - 노노그램 행·열 숫자 힌트를 표시하는 위젯 파일
import 'package:flutter/material.dart';
import '../../../../core/engine/nonogram_model.dart';

/// 노노그램 행 클루(왼쪽 숫자) 표시 위젯
///
/// 완성된 행의 클루는 흐리게 처리됩니다.
class RowClueWidget extends StatelessWidget {
  const RowClueWidget({
    super.key,
    required this.puzzle,
    required this.cellSize,
    required this.isRowCompleted,
  });

  /// 퍼즐 데이터 (rowClues 사용)
  final NonogramPuzzle puzzle;

  /// 그리드 셀 크기 (행 높이와 맞춰야 함)
  final double cellSize;

  /// 행별 완성 여부 콜백
  final bool Function(int row) isRowCompleted;

  @override
  Widget build(BuildContext context) {
    // 행 클루 최대 숫자 개수 (컬럼 너비 계산용)
    final maxLen = puzzle.rowClues.fold<int>(
      0,
      (max, c) => c.length > max ? c.length : max,
    );
    // 클루 1개당 최소 16px, 전체 최대 88px
    final clueWidth = (maxLen * 16.0).clamp(32.0, 88.0);

    return SizedBox(
      width: clueWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(puzzle.rowClues.length, (row) {
          final done = isRowCompleted(row);
          // 클루 숫자가 모두 0인 경우 "0" 표시
          final nums = puzzle.rowClues[row].where((v) => v > 0).toList();
          final text = nums.isEmpty ? '0' : nums.join(' ');

          return SizedBox(
            height: cellSize,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: (cellSize * 0.38).clamp(8, 14),
                    fontWeight: FontWeight.w700,
                    color: done ? Colors.grey.shade400 : const Color(0xFF333333),
                    decoration:
                        done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 노노그램 열 클루(위쪽 숫자) 표시 위젯
///
/// 완성된 열의 클루는 흐리게 처리됩니다.
class ColClueWidget extends StatelessWidget {
  const ColClueWidget({
    super.key,
    required this.puzzle,
    required this.cellSize,
    required this.isColCompleted,
  });

  /// 퍼즐 데이터 (colClues 사용)
  final NonogramPuzzle puzzle;

  /// 그리드 셀 크기 (열 너비와 맞춰야 함)
  final double cellSize;

  /// 열별 완성 여부 콜백
  final bool Function(int col) isColCompleted;

  @override
  Widget build(BuildContext context) {
    // 열 클루 최대 숫자 개수 (행 높이 계산용)
    final maxLen = puzzle.colClues.fold<int>(
      0,
      (max, c) => c.length > max ? c.length : max,
    );
    final clueHeight = (maxLen * 14.0).clamp(20.0, 80.0);

    return SizedBox(
      height: clueHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(puzzle.colClues.length, (col) {
          final done = isColCompleted(col);
          final nums = puzzle.colClues[col].where((v) => v > 0).toList();

          return SizedBox(
            width: cellSize,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: (nums.isEmpty ? [0] : nums).map((n) {
                return Text(
                  '$n',
                  style: TextStyle(
                    fontSize: (cellSize * 0.36).clamp(8, 13),
                    fontWeight: FontWeight.w700,
                    color:
                        done ? Colors.grey.shade400 : const Color(0xFF333333),
                    decoration: done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                );
              }).toList(),
            ),
          );
        }),
      ),
    );
  }
}
