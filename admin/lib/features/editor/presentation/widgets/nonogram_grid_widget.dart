// 노노그램 그리드 편집 위젯 - 에디터 화면에서 셀을 클릭/드래그로 편집하는 그리드 위젯
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/editor_controller.dart';

/// 노노그램 그리드를 표시하고 마우스 클릭/드래그로 셀을 편집하는 위젯
///
/// - 좌클릭: 셀 토글 (채움 ↔ 비움)
/// - 드래그: 연속으로 채우기 또는 지우기
class NonogramGridWidget extends StatelessWidget {
  const NonogramGridWidget({
    super.key,
    required this.controller,
    required this.cellSize,
  });

  final EditorController controller;

  /// 각 셀의 픽셀 크기
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final grid = controller.grid;
      if (grid.isEmpty) {
        return const Center(child: Text('그리드가 없습니다.'));
      }

      final rows = grid.length;
      final cols = grid[0].length;

      return GestureDetector(
        // 탭: 단일 셀 토글
        onTapDown: (details) {
          final (row, col) = _cellAt(details.localPosition, cols);
          if (row != null) controller.toggleCell(row, col!);
        },
        // 드래그 시작
        onPanStart: (details) {
          final (row, col) = _cellAt(details.localPosition, cols);
          if (row != null) controller.startDrag(row, col!);
        },
        // 드래그 중
        onPanUpdate: (details) {
          final (row, col) = _cellAt(details.localPosition, cols);
          if (row != null) controller.applyDrag(row, col!);
        },
        // 드래그 종료
        onPanEnd: (_) => controller.endDrag(),
        child: CustomPaint(
          size: Size(cols * cellSize, rows * cellSize),
          painter: _GridPainter(
            grid: List<List<int>>.from(grid),
            cellSize: cellSize,
          ),
        ),
      );
    });
  }

  /// 로컬 좌표에서 셀의 (행, 열) 인덱스를 계산합니다.
  (int?, int?) _cellAt(Offset localPos, int cols) {
    final col = (localPos.dx / cellSize).floor();
    final row = (localPos.dy / cellSize).floor();

    final rows = controller.grid.length;
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return (null, null);
    }
    return (row, col);
  }
}

/// 그리드를 실제로 그리는 CustomPainter
class _GridPainter extends CustomPainter {
  _GridPainter({required this.grid, required this.cellSize});

  final List<List<int>> grid;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = grid.length;
    final cols = rows > 0 ? grid[0].length : 0;

    final filledPaint = Paint()..color = Colors.black87;
    final emptyPaint = Paint()..color = Colors.white;
    final gridLinePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 0.5;
    final boldLinePaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.5;

    // 셀 배경 그리기
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * cellSize,
          r * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(rect, grid[r][c] == 1 ? filledPaint : emptyPaint);
      }
    }

    // 격자선 그리기 (5칸마다 굵게)
    for (var c = 0; c <= cols; c++) {
      final x = c * cellSize;
      final paint = (c % 5 == 0) ? boldLinePaint : gridLinePaint;
      canvas.drawLine(Offset(x, 0), Offset(x, rows * cellSize), paint);
    }
    for (var r = 0; r <= rows; r++) {
      final y = r * cellSize;
      final paint = (r % 5 == 0) ? boldLinePaint : gridLinePaint;
      canvas.drawLine(Offset(0, y), Offset(cols * cellSize, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.grid != grid || old.cellSize != cellSize;
}
