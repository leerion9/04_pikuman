// 에디터 화면 파일 - 이미지 로드, 그리드 편집, 클루 확인, 저장을 하는 메인 편집 화면
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/editor_controller.dart';
import 'widgets/nonogram_grid_widget.dart';
import 'widgets/clue_display_widget.dart';

/// 어드민 에디터 화면
///
/// 화면 구성 (좌우 분할):
/// - 왼쪽: 이미지 미리보기 + 컨트롤 패널 (그리드 크기, 임계값 슬라이더)
/// - 오른쪽: 노노그램 그리드 + 클루 + 저장 버튼
class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  /// 각 셀의 픽셀 크기
  static const double _cellSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.title.value.isEmpty
              ? '새 퍼즐 편집'
              : '편집: ${controller.title.value}',
        )),
        actions: [
          // 플레이 테스트 버튼
          Obx(() => controller.grid.isNotEmpty
              ? TextButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('플레이 테스트'),
                  onPressed: controller.goToPlayTest,
                )
              : const SizedBox.shrink()),
          const SizedBox(width: 8),
          // 저장 버튼
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('저장'),
            onPressed: controller.savePuzzle,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 왼쪽 패널: 이미지 + 설정 ──
          SizedBox(
            width: 300,
            child: _LeftPanel(controller: controller),
          ),
          const VerticalDivider(width: 1),
          // ── 오른쪽 패널: 퍼즐 미리보기 ──
          Expanded(
            child: _RightPanel(controller: controller, cellSize: _cellSize),
          ),
        ],
      ),
    );
  }
}

/// 왼쪽 패널: 이미지 미리보기 + 컨트롤
class _LeftPanel extends StatelessWidget {
  const _LeftPanel({required this.controller});

  final EditorController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 이미지 로드 ──
          const Text('이미지', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('이미지 선택...'),
            onPressed: controller.pickImage,
          ),
          const SizedBox(height: 8),
          // 이미지 미리보기
          Obx(() {
            final path = controller.imagePath.value;
            if (path == null) {
              return Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text('이미지를 선택하세요',
                      style: TextStyle(color: Colors.grey.shade500)),
                ),
              );
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(path), height: 160, fit: BoxFit.contain),
            );
          }),

          const SizedBox(height: 20),
          const Divider(),

          // ── 그리드 크기 ──
          const Text('그리드 크기', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => _GridSizeSelector(
            width: controller.gridWidth.value,
            height: controller.gridHeight.value,
            onChanged: controller.onGridSizeChanged,
          )),

          const SizedBox(height: 20),
          const Divider(),

          // ── 임계값 ──
          const Text('이진화 임계값', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
            '낮을수록 어두운 부분만 채움, 높을수록 더 많이 채움',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Obx(() => Slider(
            value: controller.threshold.value,
            min: 20,
            max: 240,
            divisions: 44,
            label: controller.threshold.value.round().toString(),
            onChanged: controller.onThresholdChanged,
          )),
          Obx(() => Center(
            child: Text('${controller.threshold.value.round()}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )),

          const SizedBox(height: 8),
          // 반전 버튼
          OutlinedButton.icon(
            icon: const Icon(Icons.invert_colors),
            label: const Text('흑백 반전'),
            onPressed: controller.invertGrid,
          ),

          const SizedBox(height: 20),
          const Divider(),

          // ── 채움 비율 ──
          Obx(() {
            final ratio = controller.filledRatio;
            final percent = (ratio * 100).toStringAsFixed(1);
            final color = (ratio >= 0.2 && ratio <= 0.6)
                ? Colors.green
                : Colors.orange;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('채움 비율', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        ratio >= 0.2 && ratio <= 0.6
                            ? '(적정 범위 20%~60%)'
                            : '(적정 범위 20%~60%에서 벗어남)',
                        style: TextStyle(fontSize: 11, color: color),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          const SizedBox(height: 20),
          const Divider(),

          // ── 퍼즐 정보 ──
          const Text('퍼즐 정보', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => TextFormField(
            initialValue: controller.title.value,
            decoration: const InputDecoration(
              labelText: '퍼즐 제목 (예: 고양이)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => controller.title.value = v,
          )),
          const SizedBox(height: 8),
          Obx(() => TextFormField(
            initialValue: controller.levelId.value.toString(),
            decoration: const InputDecoration(
              labelText: '레벨 번호',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final id = int.tryParse(v);
              if (id != null && id > 0) controller.levelId.value = id;
            },
          )),
        ],
      ),
    );
  }
}

/// 그리드 크기 선택 위젯 (프리셋 + 커스텀)
class _GridSizeSelector extends StatelessWidget {
  const _GridSizeSelector({
    required this.width,
    required this.height,
    required this.onChanged,
  });

  final int width;
  final int height;
  final void Function(int w, int h) onChanged;

  static const presets = [
    (10, 10, '10×10'),
    (15, 15, '15×15'),
    (20, 20, '20×20'),
    (25, 25, '25×25'),
    (15, 20, '15×20'),
    (20, 15, '20×15'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: presets.map((preset) {
        final (w, h, label) = preset;
        final isSelected = width == w && height == h;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onChanged(w, h),
        );
      }).toList(),
    );
  }
}

/// 오른쪽 패널: 노노그램 퍼즐 미리보기 (클루 + 그리드)
class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.controller, required this.cellSize});

  final EditorController controller;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '퍼즐 미리보기 (클릭/드래그: 셀 편집)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.grid.isEmpty) {
              return const Text('이미지를 선택하거나 그리드를 설정하면 여기에 퍼즐이 표시됩니다.');
            }

            final rowClues = controller.rowClues;
            final colClues = controller.colClues;

            // 행 클루 영역 너비 계산 (가장 긴 클루 * 약 20px)
            final maxRowClueLen = rowClues.fold<int>(
              0,
              (max, clue) => clue.length > max ? clue.length : max,
            );
            final rowClueWidth = (maxRowClueLen * 20.0).clamp(40.0, 120.0);

            // 열 클루 영역 높이 계산
            final maxColClueLen = colClues.fold<int>(
              0,
              (max, clue) => clue.length > max ? clue.length : max,
            );
            final colClueHeight = (maxColClueLen * 16.0).clamp(20.0, 80.0);

            final gridW = controller.gridWidth.value * cellSize;
            final gridH = controller.gridHeight.value * cellSize;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 왼쪽 상단 빈 공간 (행클루↔열클루 교차점)
                    SizedBox(height: colClueHeight),
                    // 행 클루
                    SizedBox(
                      width: rowClueWidth,
                      height: gridH,
                      child: ClueDisplayWidget(
                        clues: rowClues,
                        cellSize: cellSize,
                        isRow: true,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 열 클루
                    SizedBox(
                      width: gridW,
                      height: colClueHeight,
                      child: ClueDisplayWidget(
                        clues: colClues,
                        cellSize: cellSize,
                        isRow: false,
                      ),
                    ),
                    // 메인 그리드
                    NonogramGridWidget(
                      controller: controller,
                      cellSize: cellSize,
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
