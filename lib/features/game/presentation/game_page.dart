// 게임 플레이 화면 UI: 헤더, 크로스워드 그리드, 음절 팔레트, 힌트 버튼을 조립합니다.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/engine/puzzle_model.dart';
import '../controllers/game_controller.dart';
import 'widgets/crossword_grid_widget.dart';
import 'widgets/syllable_palette_widget.dart';

/// 게임 플레이 화면.
///
/// StatefulWidget으로 구현해 팔레트 타일 → 크로스워드 칸으로 날아가는 애니메이션 상태를 관리합니다.
///
/// 레이아웃 (위→아래):
///  1. 헤더 — "Level N" + 경과 타이머
///  2. 크로스워드 그리드 (10×12)
///  3. 음절 팔레트 (반응형: 정답 입력 시 해당 음절 타일 사라짐)
///  4. 힌트 버튼
///  5. 하단 배너 광고
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  /// GetX 컨트롤러 (Get.find 직접 참조)
  GameController get controller => Get.find<GameController>();

  /// 크로스워드 그리드 컨테이너의 전역 키.
  /// 날아가는 애니메이션에서 목적지 셀 위치를 계산할 때 사용합니다.
  final GlobalKey _gridKey = GlobalKey();

  /// 팔레트 타일별 전역 키 목록 (인덱스 대응).
  /// 탭한 타일의 화면 위치를 구할 때 사용합니다.
  final List<GlobalKey> _paletteKeys = [];

  // ─── 빌드 ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 하단 배너·힌트·팔레트를 남기고 그리드 셀 크기를 줄여 overflow 방지
            const gridPadding = 2.0;
            const hintBlockHeight = 52.0;
            const bottomGap = 4.0;
            const minPaletteHeight = 56.0;
            const headerBlockHeight = 52.0;

            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;
            final cellByWidth =
                (maxWidth - gridPadding * 2) / PuzzleBoard.boardCols;
            final cellByHeight = (maxHeight -
                    headerBlockHeight -
                    hintBlockHeight -
                    minPaletteHeight -
                    bottomGap) /
                PuzzleBoard.boardRows;
            final cellSize = min(cellByWidth, cellByHeight.clamp(0.0, cellByWidth));

            return Column(
              children: [
                _buildHeader(),
                CrosswordGridWidget(
                  controller: controller,
                  containerKey: _gridKey,
                  cellSize: cellSize,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildPalette()),
                      _buildHintButton(),
                      const SizedBox(height: bottomGap),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── 헤더 ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFFF6B2B),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: controller.goBack,
            tooltip: '뒤로',
          ),
          Expanded(
            child: Text(
              'Level ${controller.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Obx(
            () => Text(
              controller.formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.settings),
            tooltip: '설정',
          ),
        ],
      ),
    );
  }

  // ─── 팔레트 ───────────────────────────────────────────────
  /// 팔레트 영역. Obx로 감싸 음절 목록이 바뀔 때 자동으로 리빌드됩니다.
  Widget _buildPalette() {
    return Obx(() {
      final syllables = controller.palette.toList();
      // 팔레트 타일 수만큼 GlobalKey를 확보 (부족하면 추가 생성)
      while (_paletteKeys.length < syllables.length) {
        _paletteKeys.add(GlobalKey());
      }
      return Container(
        width: double.infinity,
        color: const Color(0xFFEEEEEE),
        child: SyllablePaletteWidget(
          syllables: syllables,
          tileKeys: _paletteKeys,
          onTap: _onPaletteTileTap,
        ),
      );
    });
  }

  /// 팔레트 타일 탭 처리.
  ///
  /// 1. 탭한 타일의 화면 위치를 GlobalKey로 구합니다.
  /// 2. 목적지 셀의 화면 위치를 그리드 GlobalKey로 계산합니다.
  /// 3. Overlay에 날아가는 타일 애니메이션을 삽입합니다.
  /// 4. 즉시 게임 상태를 업데이트합니다 (팔레트 타일 사라짐 + 셀 입력).
  void _onPaletteTileTap(int index, String syllable) {
    final selectedPos = controller.selectedPos.value;
    if (selectedPos == null) return;

    // 입력 불가(이미 채워진 칸·확정 칸 등)면 애니메이션·팔레트 소모 없음
    if (!controller.canAcceptSyllableAt(selectedPos.$1, selectedPos.$2)) {
      return;
    }

    // 팔레트 타일 위치 구하기
    final paletteKey = index < _paletteKeys.length ? _paletteKeys[index] : null;
    final paletteBox =
        paletteKey?.currentContext?.findRenderObject() as RenderBox?;

    // 그리드 컨테이너 위치 구하기
    final gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (paletteBox != null && gridBox != null) {
      final startPos = paletteBox.localToGlobal(Offset.zero);
      final gridPos = gridBox.localToGlobal(Offset.zero);
      final cellSize = gridBox.size.width / PuzzleBoard.boardCols;

      final endPos = Offset(
        gridPos.dx + selectedPos.$2 * cellSize,
        gridPos.dy + selectedPos.$1 * cellSize,
      );

      // 날아가는 타일 애니메이션 (순수 시각 효과)
      _launchFlyingTile(
        syllable: syllable,
        startPos: startPos,
        endPos: endPos,
        tileSize: min(paletteBox.size.width, cellSize),
      );
    }

    // 게임 상태는 즉시 업데이트 (애니메이션과 병행)
    if (!controller.onSyllableTap(syllable)) return;
  }

  /// Overlay에 음절 타일이 팔레트 위치에서 그리드 칸으로 날아가는 애니메이션을 삽입합니다.
  void _launchFlyingTile({
    required String syllable,
    required Offset startPos,
    required Offset endPos,
    required double tileSize,
  }) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: _FlyingTileWidget(
            syllable: syllable,
            startPos: startPos,
            endPos: endPos,
            tileSize: tileSize,
            onComplete: () => entry?.remove(),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
  }

  // ─── 힌트 버튼 ────────────────────────────────────────────
  Widget _buildHintButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final remaining = controller.remainingHints;
        final active = remaining > 0 && !controller.isLevelComplete.value;
        return OutlinedButton.icon(
          onPressed: active ? controller.onHintTap : null,
          icon: Icon(
            Icons.lightbulb_outline,
            color: active ? const Color(0xFFFF6B2B) : Colors.grey,
          ),
          label: Text(
            '힌트  남은 횟수: $remaining회',
            style: TextStyle(
              color: active ? const Color(0xFFFF6B2B) : Colors.grey,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            side: BorderSide(
              color: active ? const Color(0xFFFF6B2B) : Colors.grey,
            ),
          ),
        );
      }),
    );
  }
}

// ─── 날아가는 타일 애니메이션 위젯 ──────────────────────────────────

/// 팔레트 타일이 크로스워드 목적지 칸으로 날아가는 애니메이션 위젯.
///
/// Overlay의 Positioned.fill 안에서 렌더링되므로 화면 전체를 덮지만
/// IgnorePointer로 감싸져 터치를 차단하지 않습니다.
class _FlyingTileWidget extends StatefulWidget {
  final String syllable;
  final Offset startPos; // 화면 좌표계 기준 시작 위치
  final Offset endPos; // 화면 좌표계 기준 도착 위치
  final double tileSize; // 타일 크기
  final VoidCallback onComplete; // 애니메이션 완료 시 콜백

  const _FlyingTileWidget({
    required this.syllable,
    required this.startPos,
    required this.endPos,
    required this.tileSize,
    required this.onComplete,
  });

  @override
  State<_FlyingTileWidget> createState() => _FlyingTileWidgetState();
}

class _FlyingTileWidgetState extends State<_FlyingTileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _posAnim; // 위치 이동 애니메이션
  late final Animation<double> _scaleAnim; // 크기 축소 애니메이션

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _posAnim = Tween<Offset>(
      begin: widget.startPos,
      end: widget.endPos,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // 팔레트 타일 크기(48px) → 목적지 셀 크기로 자연스럽게 변환
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: widget.tileSize / 48.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Stack(
          children: [
            Positioned(
              left: _posAnim.value.dx,
              top: _posAnim.value.dy,
              width: 48,
              height: 48,
              child: Transform.scale(
                scale: _scaleAnim.value,
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B2B),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.syllable,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
