// 퍼즐 검증 로직 파일 - 플레이어 입력이 정답과 일치하는지 확인하는 파일
import 'nonogram_model.dart';
import 'clue_calculator.dart';

/// 노노그램 풀이 정답 여부를 검증하는 유틸리티 클래스
///
/// 검증 방식:
/// - **클루 기반 검증**: 플레이어 그리드의 행·열 클루를 계산하여 원래 클루와 비교
///   → 같으면 정답 (solution 배열이 없어도 검증 가능)
/// - **직접 비교 검증**: 플레이어 그리드를 solution 배열과 직접 비교
///
/// Easy 모드(오류 즉시 표시)에서는 셀 단위 검증도 지원합니다.
class PuzzleValidator {
  // 인스턴스 생성 방지 (모든 메서드가 static)
  const PuzzleValidator._();

  // ──────────────────────────────────────────
  // 전체 풀이 검증
  // ──────────────────────────────────────────

  /// 플레이어의 전체 그리드가 퍼즐을 완성했는지 확인합니다.
  ///
  /// 플레이어 그리드의 행·열 클루를 계산하여 퍼즐의 원래 클루와 비교합니다.
  /// solution 배열 없이도 동작합니다.
  ///
  /// [playerGrid]: 플레이어 입력 그리드 (CellState 배열)
  /// [puzzle]: 검증 기준이 되는 퍼즐 데이터
  ///
  /// 반환값: 모든 행·열 클루가 일치하면 true
  static bool isSolvedByClue(
    List<List<CellState>> playerGrid,
    NonogramPuzzle puzzle,
  ) {
    // 플레이어 그리드를 이진 배열로 변환 (filled=1, 나머지=0)
    final binaryGrid = _toBinaryGrid(playerGrid);

    // 플레이어 그리드의 클루를 계산
    final (:rowClues, :colClues) = ClueCalculator.calculate(binaryGrid);

    // 행 클루 비교
    if (!ClueCalculator.cluesEqual(rowClues, puzzle.rowClues)) return false;

    // 열 클루 비교
    if (!ClueCalculator.cluesEqual(colClues, puzzle.colClues)) return false;

    return true;
  }

  /// 플레이어의 전체 그리드를 solution 배열과 직접 비교합니다.
  ///
  /// [playerGrid]: 플레이어 입력 그리드 (CellState 배열)
  /// [solution]: 퍼즐의 정답 이진 배열 (0=빈칸, 1=채움)
  ///
  /// 반환값: 모든 셀이 정답과 일치하면 true
  static bool isSolvedByAnswer(
    List<List<CellState>> playerGrid,
    List<List<int>> solution,
  ) {
    final height = playerGrid.length;
    if (height == 0) return false;
    final width = playerGrid[0].length;

    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        final playerFilled = playerGrid[row][col] == CellState.filled ? 1 : 0;
        if (playerFilled != solution[row][col]) return false;
      }
    }
    return true;
  }

  // ──────────────────────────────────────────
  // 셀 단위 검증 (Easy 모드용)
  // ──────────────────────────────────────────

  /// 특정 셀의 입력이 정답과 일치하는지 확인합니다.
  ///
  /// Easy 모드(오류 즉시 표시)에서 플레이어가 셀을 채울 때마다 호출됩니다.
  ///
  /// [row]: 행 인덱스 (0부터 시작)
  /// [col]: 열 인덱스 (0부터 시작)
  /// [state]: 플레이어가 입력한 셀 상태
  /// [solution]: 퍼즐의 정답 이진 배열
  ///
  /// 반환값: 입력이 정답과 일치하면 true
  static bool isCellCorrect(
    int row,
    int col,
    CellState state,
    List<List<int>> solution,
  ) {
    final correctValue = solution[row][col]; // 0 또는 1

    if (state == CellState.filled) {
      // 채움 → 정답이 1이어야 올바름
      return correctValue == 1;
    } else if (state == CellState.marked) {
      // X표시 → 정답이 0이어야 올바름
      return correctValue == 0;
    }
    // empty 상태는 아직 입력 전이므로 오류로 보지 않음
    return true;
  }

  // ──────────────────────────────────────────
  // 행·열 진행 상태 확인
  // ──────────────────────────────────────────

  /// 특정 행이 정답 클루를 만족하는지 확인합니다.
  ///
  /// 게임 UI에서 완성된 행의 클루 숫자를 흐리게(dim) 표시할 때 사용합니다.
  ///
  /// [rowIndex]: 확인할 행 인덱스
  /// [playerGrid]: 플레이어 입력 그리드
  /// [puzzle]: 퍼즐 데이터 (rowClues 참조)
  ///
  /// 반환값: 해당 행의 클루가 정답 클루와 일치하면 true
  static bool isRowComplete(
    int rowIndex,
    List<List<CellState>> playerGrid,
    NonogramPuzzle puzzle,
  ) {
    final binaryRow = playerGrid[rowIndex]
        .map((cell) => cell == CellState.filled ? 1 : 0)
        .toList();

    final playerClue = ClueCalculator.calculateLineClue(binaryRow);
    final targetClue = puzzle.rowClues[rowIndex];

    return ClueCalculator.cluesEqual([playerClue], [targetClue]);
  }

  /// 특정 열이 정답 클루를 만족하는지 확인합니다.
  ///
  /// 게임 UI에서 완성된 열의 클루 숫자를 흐리게(dim) 표시할 때 사용합니다.
  ///
  /// [colIndex]: 확인할 열 인덱스
  /// [playerGrid]: 플레이어 입력 그리드
  /// [puzzle]: 퍼즐 데이터 (colClues 참조)
  ///
  /// 반환값: 해당 열의 클루가 정답 클루와 일치하면 true
  static bool isColComplete(
    int colIndex,
    List<List<CellState>> playerGrid,
    NonogramPuzzle puzzle,
  ) {
    final height = playerGrid.length;
    final binaryCol = List.generate(
      height,
      (row) => playerGrid[row][colIndex] == CellState.filled ? 1 : 0,
    );

    final playerClue = ClueCalculator.calculateLineClue(binaryCol);
    final targetClue = puzzle.colClues[colIndex];

    return ClueCalculator.cluesEqual([playerClue], [targetClue]);
  }

  // ──────────────────────────────────────────
  // 내부 헬퍼
  // ──────────────────────────────────────────

  /// CellState 그리드를 이진(0/1) 그리드로 변환합니다.
  /// - filled → 1
  /// - empty, marked → 0
  static List<List<int>> _toBinaryGrid(List<List<CellState>> playerGrid) {
    return playerGrid
        .map(
          (row) => row
              .map((cell) => cell == CellState.filled ? 1 : 0)
              .toList(),
        )
        .toList();
  }
}
