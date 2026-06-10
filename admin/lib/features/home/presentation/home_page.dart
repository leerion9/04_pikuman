// 홈 화면 파일 - 저장된 퍼즐 목록을 보여주고 새 퍼즐 만들기를 시작하는 화면
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/engine/nonogram_model.dart';

/// 어드민 도구 홈 화면
///
/// - 출력 폴더 경로 표시 및 변경
/// - 저장된 퍼즐 카드 목록 (그리드 형태)
/// - 새 퍼즐 만들기 버튼
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 홈 컨트롤러 등록
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('pikuman4 어드민 — 노노그램 퍼즐 제작 도구'),
        actions: [
          // 출력 폴더 변경 버튼
          Obx(() => TextButton.icon(
            icon: const Icon(Icons.folder_open),
            label: Text(
              controller.outputFolder.value.length > 50
                  ? '...${controller.outputFolder.value.substring(controller.outputFolder.value.length - 47)}'
                  : controller.outputFolder.value,
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: controller.changeOutputFolder,
          )),
          const SizedBox(width: 8),
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '목록 새로고침',
            onPressed: controller.loadPuzzles,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 상단 통계 바
            _buildStatsBar(controller),
            // 퍼즐 목록
            Expanded(child: _buildPuzzleGrid(controller)),
          ],
        );
      }),
      // 새 퍼즐 만들기 FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createNewPuzzle,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('새 퍼즐 만들기'),
      ),
    );
  }

  /// 상단 통계 표시 바 (총 퍼즐 수 등)
  Widget _buildStatsBar(HomeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Obx(() => Text(
            '총 ${controller.puzzles.length}개 퍼즐',
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
          const Spacer(),
          const Text(
            '퍼즐을 클릭하면 편집, 우클릭하면 삭제',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 퍼즐 카드 그리드 목록
  Widget _buildPuzzleGrid(HomeController controller) {
    if (controller.puzzles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '저장된 퍼즐이 없습니다.\n"새 퍼즐 만들기" 버튼으로 첫 퍼즐을 만들어 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.puzzles.length,
      itemBuilder: (context, index) {
        return _PuzzleCard(
          puzzle: controller.puzzles[index],
          onTap: () => controller.openPuzzle(controller.puzzles[index]),
          onDelete: () => _confirmDelete(context, controller, controller.puzzles[index]),
        );
      },
    );
  }

  /// 퍼즐 삭제 확인 다이얼로그
  void _confirmDelete(
    BuildContext context,
    HomeController controller,
    NonogramPuzzle puzzle,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('퍼즐 삭제'),
        content: Text('"${puzzle.title}" (레벨 ${puzzle.id})를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deletePuzzle(puzzle);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

/// 퍼즐 한 개를 나타내는 카드 위젯
class _PuzzleCard extends StatelessWidget {
  const _PuzzleCard({
    required this.puzzle,
    required this.onTap,
    required this.onDelete,
  });

  final NonogramPuzzle puzzle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onSecondaryTap: onDelete, // 우클릭 = 삭제
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 퍼즐 미리보기 (그리드 축소 표시)
            Expanded(
              child: _MiniGridPreview(solution: puzzle.solution),
            ),
            // 퍼즐 정보
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '레벨 ${puzzle.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    puzzle.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${puzzle.gridSize.width}×${puzzle.gridSize.height}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 퍼즐 solution을 축소해서 표시하는 미니 그리드 위젯
class _MiniGridPreview extends StatelessWidget {
  const _MiniGridPreview({required this.solution});

  final List<List<int>> solution;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (solution.isEmpty) return const SizedBox.shrink();

        final rows = solution.length;
        final cols = solution[0].length;

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _MiniGridPainter(solution: solution, rows: rows, cols: cols),
        );
      },
    );
  }
}

/// 미니 그리드를 그리는 CustomPainter
class _MiniGridPainter extends CustomPainter {
  _MiniGridPainter({
    required this.solution,
    required this.rows,
    required this.cols,
  });

  final List<List<int>> solution;
  final int rows;
  final int cols;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    final filledPaint = Paint()..color = Colors.black87;
    final emptyPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);
        canvas.drawRect(rect, solution[r][c] == 1 ? filledPaint : emptyPaint);
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
