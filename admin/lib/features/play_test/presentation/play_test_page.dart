// 플레이 테스트 화면 파일 - 생성한 퍼즐을 직접 풀어보며 유효성을 검증하는 화면
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/play_test_controller.dart';
import '../../../core/engine/nonogram_model.dart';

/// 플레이 테스트 화면
///
/// 에디터에서 만든 퍼즐을 실제 게임처럼 풀어볼 수 있습니다.
/// - 셀 클릭: 채우기 / X표시 (모드 버튼으로 전환)
/// - 클리어 시: "클리어!" 메시지 + 돌아가기 버튼
class PlayTestPage extends StatelessWidget {
  const PlayTestPage({super.key});

  static const double _cellSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayTestController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('플레이 테스트: ${controller.puzzle.title}'),
        actions: [
          // 초기화 버튼
          TextButton.icon(
            icon: const Icon(Icons.restart_alt),
            label: const Text('초기화'),
            onPressed: controller.reset,
          ),
          // 입력 모드 토글
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ChoiceChip(
              label: Text(controller.isFillMode.value ? '■ 채우기' : '✕ X표시'),
              selected: true,
              onSelected: (_) => controller.toggleMode(),
            ),
          )),
        ],
      ),
      body: Obx(() {
        // 클리어 시 오버레이 표시
        return Stack(
          children: [
            _PuzzleView(controller: controller, cellSize: _cellSize),
            if (controller.isCleared.value) _ClearOverlay(controller: controller),
          ],
        );
      }),
    );
  }
}

/// 퍼즐 뷰 (클루 + 그리드)
class _PuzzleView extends StatelessWidget {
  const _PuzzleView({required this.controller, required this.cellSize});

  final PlayTestController controller;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final puzzle = controller.puzzle;

    // 행 클루 최대 길이 (왼쪽 여백 계산)
    final maxRowClueLen = puzzle.rowClues.fold<int>(
      0,
      (max, c) => c.length > max ? c.length : max,
    );
    final rowClueWidth = (maxRowClueLen * 22.0).clamp(40.0, 120.0);

    // 열 클루 최대 길이 (위쪽 여백 계산)
    final maxColClueLen = puzzle.colClues.fold<int>(
      0,
      (max, c) => c.length > max ? c.length : max,
    );
    final colClueHeight = (maxColClueLen * 18.0).clamp(20.0, 100.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: colClueHeight),
              // 행 클루 영역
              SizedBox(
                width: rowClueWidth,
                child: _RowClues(
                  puzzle: puzzle,
                  controller: controller,
                  cellSize: cellSize,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 열 클루 영역
              SizedBox(
                height: colClueHeight,
                child: _ColClues(
                  puzzle: puzzle,
                  controller: controller,
                  cellSize: cellSize,
                ),
              ),
              // 메인 그리드
              _PlayGrid(controller: controller, cellSize: cellSize),
            ],
          ),
        ],
      ),
    );
  }
}

/// 행 클루 표시 (완성된 행은 흐리게)
class _RowClues extends StatelessWidget {
  const _RowClues({
    required this.puzzle,
    required this.controller,
    required this.cellSize,
  });

  final NonogramPuzzle puzzle;
  final PlayTestController controller;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // progress 변경 시 재빌드
      controller.progress.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(puzzle.rowClues.length, (row) {
          final done = controller.isRowComplete(row);
          final text = puzzle.rowClues[row].where((v) => v > 0).join(' ');
          return SizedBox(
            height: cellSize,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  text.isEmpty ? '0' : text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: done ? Colors.grey.shade400 : Colors.black,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}

/// 열 클루 표시 (완성된 열은 흐리게)
class _ColClues extends StatelessWidget {
  const _ColClues({
    required this.puzzle,
    required this.controller,
    required this.cellSize,
  });

  final NonogramPuzzle puzzle;
  final PlayTestController controller;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.progress.value;

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(puzzle.colClues.length, (col) {
          final done = controller.isColComplete(col);
          final numbers = puzzle.colClues[col].where((v) => v > 0).toList();
          return SizedBox(
            width: cellSize,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: (numbers.isEmpty ? [0] : numbers).map((n) => Text(
                '$n',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: done ? Colors.grey.shade400 : Colors.black,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
                textAlign: TextAlign.center,
              )).toList(),
            ),
          );
        }),
      );
    });
  }
}

/// 실제 플레이 가능한 인터랙티브 그리드
class _PlayGrid extends StatelessWidget {
  const _PlayGrid({required this.controller, required this.cellSize});

  final PlayTestController controller;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final puzzle = controller.puzzle;
    final rows = puzzle.height;
    final cols = puzzle.width;

    return Obx(() {
      final grid = controller.progress.value.grid;

      return GestureDetector(
        onTapDown: (d) {
          final (row, col) = _cellAt(d.localPosition, rows, cols);
          if (row != null) controller.tapCell(row, col!);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rows, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(cols, (col) {
                  return _Cell(
                    state: grid[row][col],
                    size: cellSize,
                    isRowBold: (row + 1) % 5 == 0,
                    isColBold: (col + 1) % 5 == 0,
                  );
                }),
              );
            }),
          ),
        ),
      );
    });
  }

  (int?, int?) _cellAt(Offset pos, int rows, int cols) {
    final col = (pos.dx / cellSize).floor();
    final row = (pos.dy / cellSize).floor();
    if (row < 0 || row >= rows || col < 0 || col >= cols) return (null, null);
    return (row, col);
  }
}

/// 셀 한 개 위젯
class _Cell extends StatelessWidget {
  const _Cell({
    required this.state,
    required this.size,
    required this.isRowBold,
    required this.isColBold,
  });

  final CellState state;
  final double size;
  final bool isRowBold;
  final bool isColBold;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget? child;

    switch (state) {
      case CellState.filled:
        bgColor = Colors.black87;
      case CellState.marked:
        bgColor = Colors.white;
        child = const Center(
          child: Text('✕', style: TextStyle(color: Colors.grey, fontSize: 14)),
        );
      case CellState.empty:
        bgColor = Colors.white;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(
            color: isColBold ? Colors.grey.shade700 : Colors.grey.shade300,
            width: isColBold ? 1.0 : 0.5,
          ),
          bottom: BorderSide(
            color: isRowBold ? Colors.grey.shade700 : Colors.grey.shade300,
            width: isRowBold ? 1.0 : 0.5,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// 클리어 오버레이 (풀이 완성 시 표시)
class _ClearOverlay extends StatelessWidget {
  const _ClearOverlay({required this.controller});

  final PlayTestController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  '클리어!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${controller.puzzle.title}" 퍼즐이 올바르게 풀렸습니다.\n이 퍼즐은 유효합니다!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('다시 풀기'),
                      onPressed: controller.reset,
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('에디터로 돌아가기'),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
