// 노노그램 그리드 위젯 - 플레이어가 칸을 채우고 X표시하는 인터랙티브 격자 위젯 파일
import 'package:flutter/material.dart';
import '../../../../core/engine/nonogram_model.dart';

/// 노노그램 게임 격자 위젯
///
/// - 탭: 채우기/X표시 (isFillMode에 따라)
/// - 길게 누르기: 반대 모드 적용
/// - 드래그: 연속으로 같은 동작 적용
///
/// 5칸마다 굵은 테두리로 구역을 구분합니다.
class NonogramGridWidget extends StatefulWidget {
  const NonogramGridWidget({
    super.key,
    required this.puzzle,
    required this.progress,
    required this.isFillMode,
    required this.errorCells,
    required this.onCellTap,
  });

  /// 퍼즐 데이터 (그리드 크기, 정답 등)
  final NonogramPuzzle puzzle;

  /// 플레이어의 현재 입력 상태
  final GameProgress progress;

  /// 현재 입력 모드 (true=채우기, false=X표시)
  final bool isFillMode;

  /// Easy 모드 오류 셀 집합 {row * 1000 + col}
  final Set<int> errorCells;

  /// 셀 탭/드래그 콜백
  final void Function(int row, int col) onCellTap;

  @override
  State<NonogramGridWidget> createState() => _NonogramGridWidgetState();
}

class _NonogramGridWidgetState extends State<NonogramGridWidget> {
  // 드래그 중 이미 처리한 셀을 기억 (중복 처리 방지)
  final Set<int> _processedInDrag = {};
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final rows = widget.puzzle.height;
    final cols = widget.puzzle.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면에 맞는 최적 셀 크기 계산
        final cellSize = _calcCellSize(constraints, rows, cols);

        return GestureDetector(
          onPanStart: (d) => _onDragStart(d.localPosition, rows, cols),
          onPanUpdate: (d) => _onDragUpdate(d.localPosition, rows, cols, cellSize),
          onPanEnd: (_) => _onDragEnd(),
          onTapDown: (d) => _onTap(d.localPosition, rows, cols, cellSize),
          onLongPressStart: (d) =>
              _onLongPress(d.localPosition, rows, cols, cellSize),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF555555), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(rows, (row) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(cols, (col) {
                    return _CellWidget(
                      state: widget.progress.grid[row][col],
                      size: cellSize,
                      isError: widget.errorCells.contains(row * 1000 + col),
                      isBoldRight: (col + 1) % 5 == 0 && col != cols - 1,
                      isBoldBottom: (row + 1) % 5 == 0 && row != rows - 1,
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  /// 화면 크기에 맞게 셀 크기를 계산합니다 (8~48 범위)
  double _calcCellSize(BoxConstraints c, int rows, int cols) {
    final byWidth = c.maxWidth / cols;
    final byHeight = c.maxHeight.isFinite ? c.maxHeight / rows : byWidth;
    return (byWidth < byHeight ? byWidth : byHeight).clamp(8.0, 48.0);
  }

  /// 화면 좌표를 셀 (row, col) 인덱스로 변환합니다
  (int row, int col)? _cellAt(Offset pos, int rows, int cols, double cellSize) {
    final col = (pos.dx / cellSize).floor();
    final row = (pos.dy / cellSize).floor();
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return (row, col);
  }

  void _onTap(Offset pos, int rows, int cols, double cellSize) {
    final cell = _cellAt(pos, rows, cols, cellSize);
    if (cell != null) widget.onCellTap(cell.$1, cell.$2);
  }

  void _onLongPress(Offset pos, int rows, int cols, double cellSize) {
    final cell = _cellAt(pos, rows, cols, cellSize);
    if (cell == null) return;
    // 길게 누르기: 현재 모드 반전 적용
    widget.onCellTap(cell.$1, cell.$2);
  }

  void _onDragStart(Offset pos, int rows, int cols) {
    _isDragging = true;
    _processedInDrag.clear();
  }

  void _onDragUpdate(Offset pos, int rows, int cols, double cellSize) {
    if (!_isDragging) return;
    final cell = _cellAt(pos, rows, cols, cellSize);
    if (cell == null) return;
    final key = cell.$1 * 1000 + cell.$2;
    if (_processedInDrag.contains(key)) return;
    _processedInDrag.add(key);
    widget.onCellTap(cell.$1, cell.$2);
  }

  void _onDragEnd() {
    _isDragging = false;
    _processedInDrag.clear();
  }
}

/// 셀 한 개를 표시하는 위젯
class _CellWidget extends StatelessWidget {
  const _CellWidget({
    required this.state,
    required this.size,
    required this.isError,
    required this.isBoldRight,
    required this.isBoldBottom,
  });

  final CellState state;
  final double size;
  final bool isError;
  final bool isBoldRight;
  final bool isBoldBottom;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget? child;

    if (isError && state == CellState.filled) {
      // Easy 모드 오류: 붉은 채움
      bgColor = const Color(0xFFFF5252);
    } else {
      switch (state) {
        case CellState.filled:
          bgColor = const Color(0xFF333333);
        case CellState.marked:
          bgColor = Colors.white;
          child = Center(
            child: Text(
              '✕',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: size * 0.5,
                height: 1,
              ),
            ),
          );
        case CellState.empty:
          bgColor = Colors.white;
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(
            color: isBoldRight
                ? const Color(0xFF555555)
                : const Color(0xFFCCCCCC),
            width: isBoldRight ? 1.0 : 0.5,
          ),
          bottom: BorderSide(
            color: isBoldBottom
                ? const Color(0xFF555555)
                : const Color(0xFFCCCCCC),
            width: isBoldBottom ? 1.0 : 0.5,
          ),
        ),
      ),
      child: child,
    );
  }
}
