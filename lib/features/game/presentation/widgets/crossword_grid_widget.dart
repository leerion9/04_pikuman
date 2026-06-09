// 크로스워드 퍼즐 그리드(10×12) UI 위젯입니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/engine/puzzle_model.dart';
import '../../controllers/game_controller.dart';
import '../../models/game_enums.dart';

/// 10열 × 12행 크로스워드 그리드 위젯.
///
/// - 화면 너비에 맞춰 셀 크기를 자동 계산합니다.
/// - 모든 셀(활성/비활성)을 동일한 크기(SizedBox)로 감싸 정렬 불일치를 방지합니다.
/// - Obx 로 감싸서 입력·선택 상태 변화 시 자동 리렌더합니다.
class CrosswordGridWidget extends StatelessWidget {
  final GameController controller;

  /// 애니메이션에서 그리드 컨테이너 위치를 구하기 위한 전역 키
  final GlobalKey? containerKey;

  /// 셀 크기(px). null이면 화면 너비 기준으로 자동 계산합니다.
  ///
  /// 작은 화면·하단 배너 등으로 세로 공간이 부족할 때 [GamePage]에서
  /// 높이에 맞게 줄인 값을 넘깁니다.
  final double? cellSize;

  const CrosswordGridWidget({
    super.key,
    required this.controller,
    this.containerKey,
    this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    // 그리드 컨테이너 내부 패딩(양쪽 2px)을 제외한 너비를 10칸으로 나눠 셀 크기 계산
    const double gridPadding = 2.0;
    final double resolvedCellSize = cellSize ??
        (MediaQuery.of(context).size.width - gridPadding * 2) /
            PuzzleBoard.boardCols;

    return Container(
      key: containerKey,
      color: const Color(0xFF37474F), // 그리드 배경 (진한 청회색)
      padding: const EdgeInsets.all(gridPadding),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            PuzzleBoard.boardRows,
            (row) => Row(
              children: List.generate(
                PuzzleBoard.boardCols,
                (col) => _buildCell(row, col, resolvedCellSize),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 셀 하나를 그립니다.
  ///
  /// 모든 셀(활성/비활성)을 동일한 SizedBox로 감싸 Row 정렬이 틀어지지 않게 합니다.
  /// 활성 셀 내부에는 Padding을 사용해 셀 간 시각적 간격을 만듭니다(margin 대신).
  Widget _buildCell(int row, int col, double size) {
    final state = controller.cellState(row, col);
    final letter = controller.displayLetter(row, col);
    final isSelected = controller.isSelected(row, col);

    // 검은 칸(비활성): 배경색 없이 동일 크기의 빈 공간
    if (state == CellDisplayState.inactive) {
      return SizedBox(width: size, height: size);
    }

    // 활성 칸: 선택 시 배경은 유지하고 테두리만 강조합니다.
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: GestureDetector(
          onTap: () => controller.onCellTap(row, col),
          child: Container(
            decoration: BoxDecoration(
              color: _bgColor(state),
              borderRadius: BorderRadius.circular(2),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFFF9800),
                      width: 2.5,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                letter ?? '',
                style: TextStyle(
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.bold,
                  color: _textColor(state),
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 셀 배경색: 상태별로 다른 색상을 반환합니다.
  Color _bgColor(CellDisplayState state) => switch (state) {
        CellDisplayState.inactive => Colors.transparent,
        CellDisplayState.empty => Colors.white,
        CellDisplayState.activeWord => Colors.white,
        CellDisplayState.selected => Colors.white,
        CellDisplayState.hint => const Color(0xFFA5D6A7), // green-200
        CellDisplayState.filled => const Color(0xFFFFE0B2), // orange-100 (입력됐지만 판별 전)
        CellDisplayState.correct => const Color(0xFF90CAF9), // blue-200 (정답 확정)
        CellDisplayState.incorrect => const Color(0xFFEF9A9A), // red-200 (오답)
      };

  /// 셀 텍스트 색상: 오답은 진한 빨간색, 그 외는 진한 회색
  Color _textColor(CellDisplayState state) =>
      state == CellDisplayState.incorrect
          ? const Color(0xFFB71C1C)
          : const Color(0xFF212121);
}
