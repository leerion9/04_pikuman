// 게임 플레이 화면 파일 - 노노그램 그리드, 클루, 타이머를 표시하는 화면
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'widgets/nonogram_grid_widget.dart';
import 'widgets/clue_widget.dart';
import '../../../core/widgets/banner_ad_widget.dart';

/// 게임 플레이 화면
///
/// 구성:
/// - 상단: Level N | 타이머 | 설정/모드 버튼
/// - 중앙: 열 클루(위) + 행 클루(왼쪽) + 그리드(오른쪽)
/// - 하단: 배너 광고
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GameController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _GameAppBar(controller: controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final puzzle = controller.puzzle.value;
        final progress = controller.progress.value;
        if (puzzle == null || progress == null) {
          return const Center(child: Text('퍼즐을 불러올 수 없습니다.'));
        }
        return _GameBody(controller: controller);
      }),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}

/// 게임 상단 AppBar
class _GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GameAppBar({required this.controller});
  final GameController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFE53935),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Text(
          'Level ${controller.puzzle.value?.id ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      actions: [
        // 경과 타이머
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                controller.timerText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        // 채우기/X표시 모드 전환 버튼
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: controller.toggleMode,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.isFillMode.value
                      ? Colors.white
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.isFillMode.value ? '■ 채우기' : '✕ X표시',
                  style: TextStyle(
                    color: controller.isFillMode.value
                        ? const Color(0xFFE53935)
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 게임 본문 (클루 + 그리드)
class _GameBody extends StatelessWidget {
  const _GameBody({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Obx(() {
          final puzzle = controller.puzzle.value!;
          final progress = controller.progress.value!;

          // 행 클루 최대 개수 기반으로 행 클루 영역 너비 계산
          final maxRowClueLen = puzzle.rowClues.fold<int>(
            0,
            (m, c) => c.length > m ? c.length : m,
          );
          final rowClueWidth = (maxRowClueLen * 16.0).clamp(32.0, 88.0);

          // 열 클루 최대 개수 기반으로 열 클루 영역 높이 계산
          final maxColClueLen = puzzle.colClues.fold<int>(
            0,
            (m, c) => c.length > m ? c.length : m,
          );
          final colClueHeight = (maxColClueLen * 14.0).clamp(20.0, 80.0);

          // 그리드에 사용할 가용 영역
          final screenW = MediaQuery.of(context).size.width - 16;
          final gridAreaW = screenW - rowClueWidth;
          final cellSize =
              (gridAreaW / puzzle.width).clamp(8.0, 48.0);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 빈 코너 (행 클루 너비 × 열 클루 높이)
                    SizedBox(width: rowClueWidth, height: colClueHeight),
                    // 열 클루
                    ColClueWidget(
                      puzzle: puzzle,
                      cellSize: cellSize,
                      isColCompleted: controller.isColComplete,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 행 클루
                    RowClueWidget(
                      puzzle: puzzle,
                      cellSize: cellSize,
                      isRowCompleted: controller.isRowComplete,
                    ),
                    // 그리드
                    NonogramGridWidget(
                      puzzle: puzzle,
                      progress: progress,
                      isFillMode: controller.isFillMode.value,
                      errorCells: controller.errorCells,
                      onCellTap: controller.tapCell,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
