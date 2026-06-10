// 플레이 테스트 컨트롤러 - 생성한 퍼즐을 직접 풀어보며 검증하는 화면의 로직 파일
import 'package:get/get.dart';
import '../../../core/engine/nonogram_model.dart';
import '../../../core/engine/puzzle_validator.dart';

/// 플레이 테스트 화면의 상태와 비즈니스 로직을 관리합니다.
///
/// 에디터에서 만든 퍼즐을 받아서 직접 풀어볼 수 있게 합니다.
/// 풀이가 완성되면 "클리어!" 메시지를 표시합니다.
class PlayTestController extends GetxController {
  /// 테스트할 퍼즐 데이터
  final NonogramPuzzle puzzle;

  PlayTestController({required this.puzzle});

  /// 플레이어의 현재 셀 입력 상태
  late final Rx<GameProgress> progress;

  /// 클리어 여부
  final isCleared = false.obs;

  /// 현재 입력 모드 (true=채우기, false=X표시)
  final isFillMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    // 빈 상태로 게임 시작
    progress = Rx<GameProgress>(
      GameProgress.empty(
        puzzleId: puzzle.id,
        width: puzzle.width,
        height: puzzle.height,
      ),
    );
  }

  /// 셀을 탭하여 현재 모드에 따라 채우기 또는 X표시를 적용합니다.
  void tapCell(int row, int col) {
    if (isCleared.value) return;

    final current = progress.value.grid[row][col];

    CellState next;
    if (isFillMode.value) {
      // 채우기 모드: empty→filled, filled→empty
      next = current == CellState.filled ? CellState.empty : CellState.filled;
    } else {
      // X표시 모드: empty→marked, marked→empty
      next = current == CellState.marked ? CellState.empty : CellState.marked;
    }

    progress.value = progress.value.updateCell(row, col, next);
    _checkClear();
  }

  /// 입력 모드 전환 (채우기 ↔ X표시)
  void toggleMode() => isFillMode.value = !isFillMode.value;

  /// 현재 풀이가 완성되었는지 확인합니다.
  void _checkClear() {
    if (PuzzleValidator.isSolvedByClue(progress.value.grid, puzzle)) {
      isCleared.value = true;
    }
  }

  /// 풀이를 초기화합니다.
  void reset() {
    isCleared.value = false;
    progress.value = GameProgress.empty(
      puzzleId: puzzle.id,
      width: puzzle.width,
      height: puzzle.height,
    );
  }

  /// 특정 행이 완성되었는지 확인합니다. (클루 흐림 처리용)
  bool isRowComplete(int row) {
    return PuzzleValidator.isRowComplete(row, progress.value.grid, puzzle);
  }

  /// 특정 열이 완성되었는지 확인합니다.
  bool isColComplete(int col) {
    return PuzzleValidator.isColComplete(col, progress.value.grid, puzzle);
  }
}
