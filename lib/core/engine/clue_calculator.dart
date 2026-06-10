// 클루 계산기 파일 - 이진 배열(0/1)에서 노노그램 행·열 클루(숫자 힌트)를 계산하는 파일

/// 노노그램 클루(숫자 힌트)를 계산하는 유틸리티 클래스
///
/// 클루란 각 행 또는 열에서 연속으로 채워진(1) 칸의 개수 목록입니다.
///
/// 예시:
/// - 입력: [0, 1, 1, 0, 1, 1, 1, 0]
/// - 출력: [2, 3]  (연속 2칸, 연속 3칸)
///
/// - 입력: [1, 1, 1, 1, 1]
/// - 출력: [5]  (연속 5칸)
///
/// - 입력: [0, 0, 0, 0, 0]
/// - 출력: [0]  (아무것도 없음 → 관례상 [0] 반환)
class ClueCalculator {
  // 인스턴스 생성 방지 (모든 메서드가 static)
  const ClueCalculator._();

  // ──────────────────────────────────────────
  // 한 줄 계산
  // ──────────────────────────────────────────

  /// 한 줄(행 또는 열)의 이진 배열에서 클루 목록을 계산합니다.
  ///
  /// [line]: 0(빈칸) 또는 1(채움)으로 구성된 정수 리스트
  ///
  /// 반환값: 연속 채움 칸의 개수 목록
  /// - 완전히 비어 있으면 [0] 반환 (노노그램 표기 관례)
  ///
  /// 예시:
  /// ```dart
  /// calculateLineClue([0, 1, 1, 0, 1]) // → [2, 1]
  /// calculateLineClue([0, 0, 0])       // → [0]
  /// calculateLineClue([1, 1, 1])       // → [3]
  /// ```
  static List<int> calculateLineClue(List<int> line) {
    final clues = <int>[];
    var count = 0; // 현재 연속 채움 칸 수

    for (final cell in line) {
      if (cell == 1) {
        // 채움 칸: 카운트 증가
        count++;
      } else {
        // 빈칸: 지금까지 세던 연속 구간이 끝남
        if (count > 0) {
          clues.add(count);
          count = 0;
        }
      }
    }

    // 마지막 구간 처리 (줄 끝까지 채워진 경우)
    if (count > 0) {
      clues.add(count);
    }

    // 아무것도 채워지지 않은 줄은 [0] 반환 (노노그램 표기 관례)
    return clues.isEmpty ? [0] : clues;
  }

  // ──────────────────────────────────────────
  // 전체 그리드 계산
  // ──────────────────────────────────────────

  /// 2D 그리드에서 모든 행(가로줄)의 클루를 계산합니다.
  ///
  /// [grid]: [행][열] 형태의 이진 배열 (0=빈칸, 1=채움)
  ///
  /// 반환값: 각 행의 클루 목록 (grid.length 개의 클루 리스트)
  ///
  /// 예시 (3×3 그리드):
  /// ```
  /// grid = [[1,1,0],  → rowClues[0] = [2]
  ///         [0,0,0],  → rowClues[1] = [0]
  ///         [1,0,1]]  → rowClues[2] = [1,1]
  /// ```
  static List<List<int>> calculateRowClues(List<List<int>> grid) {
    return grid.map((row) => calculateLineClue(row)).toList();
  }

  /// 2D 그리드에서 모든 열(세로줄)의 클루를 계산합니다.
  ///
  /// [grid]: [행][열] 형태의 이진 배열 (0=빈칸, 1=채움)
  ///
  /// 반환값: 각 열의 클루 목록 (grid[0].length 개의 클루 리스트)
  ///
  /// 예시 (3×3 그리드):
  /// ```
  /// grid = [[1,0,1],
  ///         [1,0,0],
  ///         [0,0,1]]
  /// colClues[0] = [2]   (1열: 1,1,0 → 연속 2칸)
  /// colClues[1] = [0]   (2열: 0,0,0 → 없음)
  /// colClues[2] = [1,1] (3열: 1,0,1 → 1칸, 1칸)
  /// ```
  static List<List<int>> calculateColClues(List<List<int>> grid) {
    if (grid.isEmpty) return [];

    final height = grid.length;
    final width = grid[0].length;

    return List.generate(width, (col) {
      // 해당 열의 모든 행 값을 한 줄로 추출
      final column = List.generate(height, (row) => grid[row][col]);
      return calculateLineClue(column);
    });
  }

  /// 그리드에서 행·열 클루를 한 번에 계산합니다.
  ///
  /// [grid]: [행][열] 형태의 이진 배열
  ///
  /// 반환값: 행 클루 리스트와 열 클루 리스트를 담은 레코드
  ///
  /// 예시:
  /// ```dart
  /// final (:rowClues, :colClues) = ClueCalculator.calculate(grid);
  /// ```
  static ({List<List<int>> rowClues, List<List<int>> colClues}) calculate(
    List<List<int>> grid,
  ) {
    return (
      rowClues: calculateRowClues(grid),
      colClues: calculateColClues(grid),
    );
  }

  // ──────────────────────────────────────────
  // 클루 비교
  // ──────────────────────────────────────────

  /// 두 클루 목록이 동일한지 비교합니다.
  ///
  /// 노노그램에서 클루가 같다 = 두 그리드의 행·열 패턴이 같다는 의미입니다.
  ///
  /// [cluesA], [cluesB]: 비교할 두 클루 목록
  static bool cluesEqual(List<List<int>> cluesA, List<List<int>> cluesB) {
    if (cluesA.length != cluesB.length) return false;

    for (var i = 0; i < cluesA.length; i++) {
      final a = cluesA[i];
      final b = cluesB[i];
      if (a.length != b.length) return false;
      for (var j = 0; j < a.length; j++) {
        if (a[j] != b[j]) return false;
      }
    }
    return true;
  }
}
