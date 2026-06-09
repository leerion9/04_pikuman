// 퍼즐 생성에 필요한 기본 데이터 모델들을 정의합니다.

import '../data/word_model.dart';

/// 단어의 배치 방향
enum Direction {
  /// 가로 방향 (왼쪽 → 오른쪽)
  across,

  /// 세로 방향 (위 → 아래)
  down,
}

/// 보드에 배치된 단어 하나의 위치·방향 정보
class PlacedWord {
  /// 배치된 단어 모델
  final WordModel word;

  /// 단어 시작 행 (0 기준, 위에서부터)
  final int row;

  /// 단어 시작 열 (0 기준, 왼쪽부터)
  final int col;

  /// 배치 방향
  final Direction direction;

  const PlacedWord({
    required this.word,
    required this.row,
    required this.col,
    required this.direction,
  });

  /// 단어 음절(글자) 수
  int get length => word.syllableCount;

  /// 이 단어가 차지하는 모든 (행, 열) 위치 목록.
  /// 예: 가로 단어 row=3, col=2, length=3 → [(3,2), (3,3), (3,4)]
  List<(int, int)> get positions => List.generate(length, (i) {
        return direction == Direction.across ? (row, col + i) : (row + i, col);
      });

  /// 인덱스 [i] 위치의 음절 문자를 반환합니다.
  String letterAt(int i) => word.word[i];

  @override
  String toString() =>
      'PlacedWord(${word.word}, row:$row, col:$col, dir:${direction.name})';
}

/// 퍼즐에서 미리 오픈되는 힌트 타일 하나의 보드 위치
class HintTile {
  /// 행 (0 기준)
  final int row;

  /// 열 (0 기준)
  final int col;

  const HintTile({required this.row, required this.col});

  /// 같은 위치인지 비교하기 위해 == 과 hashCode 를 정의합니다.
  @override
  bool operator ==(Object other) =>
      other is HintTile && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'HintTile(row:$row, col:$col)';
}

/// 퍼즐 보드 전체 (배치된 단어 + 힌트 타일 포함)
class PuzzleBoard {
  /// 보드 세로 칸 수 (행)
  static const int boardRows = 12;

  /// 보드 가로 칸 수 (열)
  static const int boardCols = 10;

  /// 배치된 모든 단어 목록
  final List<PlacedWord> placedWords;

  /// 미리 오픈된 힌트 타일 목록
  final List<HintTile> hintTiles;

  /// 2D 격자: grid[row][col] = 해당 위치의 음절 문자 (빈칸이면 '')
  final List<List<String>> grid;

  const PuzzleBoard({
    required this.placedWords,
    required this.hintTiles,
    required this.grid,
  });

  /// [row], [col] 이 보드 범위 내인지 확인합니다.
  static bool isInBounds(int row, int col) =>
      row >= 0 && row < boardRows && col >= 0 && col < boardCols;

  /// [row], [col] 위치의 글자를 반환합니다. 빈칸이면 '' 반환.
  String letterAt(int row, int col) => grid[row][col];

  /// [row], [col] 위치가 빈칸인지 확인합니다.
  bool isEmpty(int row, int col) => grid[row][col].isEmpty;
}
