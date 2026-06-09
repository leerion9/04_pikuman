// word_pool 에서 단어를 골라 크로스워드 보드에 배치하는 알고리즘입니다.

import 'dart:math';

import '../constants/game_constants.dart';
import '../data/word_model.dart';
import 'puzzle_model.dart';

/// 크로스워드 단어 배치기 (Incremental Growth + Backtracking 방식).
///
/// 동작 순서:
///  1. 첫 단어를 보드 중앙에 가로로 배치
///  2. 이미 배치된 단어와 교차 가능한 모든 후보 위치를 탐색
///  3. 후보를 랜덤 셔플 후 유효한 위치에 배치
///  4. word_count 에 도달할 때까지 재귀적으로 다음 단어 배치
///  5. 막다른 길이면 마지막 단어를 롤백하고 다른 위치·조합 재시도 (Backtracking)
///  6. 단어 하나에 대해 백트래킹 500회 초과 시 해당 단어를 포기하고
///     시드 순서상 다음 단어로 교체 (Freezing 방지)
class WordPlacer {
  /// 보드 행 수 (세로)
  static const int _rows = PuzzleBoard.boardRows;

  /// 보드 열 수 (가로)
  static const int _cols = PuzzleBoard.boardCols;

  /// 무한 루프 방지용 전체 백트래킹 상한
  static const int _maxTotalBacktracks = 50000;

  /// 시드 기반 난수 생성기
  final Random _rng;

  /// 배치 중인 2D 격자: _grid[row][col] = 음절 문자 (빈칸이면 '')
  late List<List<String>> _grid;

  /// 배치 완료된 단어 목록
  final List<PlacedWord> _placed = [];

  /// 현재 탐색에서 누적된 백트래킹(롤백) 횟수
  int _backtrackCount = 0;

  /// 500회 초과로 배치를 포기한 word_pool 인덱스
  final Set<int> _abandonedPoolIndices = {};

  /// [seed] 를 시드로 사용해 WordPlacer 를 생성합니다.
  WordPlacer(int seed) : _rng = Random(seed) {
    _resetGrid();
  }

  // ─── 공개 API ────────────────────────────────────────────

  /// [pool] 에서 최대 [wordCount] 개의 단어를 보드에 배치하고 결과를 반환합니다.
  ///
  /// [pool] 은 호출 전에 시드로 미리 셔플된 상태여야 합니다.
  List<PlacedWord> place(List<WordModel> pool, int wordCount) {
    if (pool.isEmpty) return const [];

    _resetGrid();
    _placeFirstWord(pool[0]);

    if (wordCount <= 1) {
      return List.unmodifiable(_placed);
    }

    _solve(pool, wordCount, 1);
    return List.unmodifiable(_placed);
  }

  /// 배치 완료된 격자의 복사본을 반환합니다.
  List<List<String>> get grid =>
      _grid.map((row) => List<String>.from(row)).toList();

  // ─── 백트래킹 탐색 ───────────────────────────────────────

  /// [poolIdx] 번째 단어부터 시도하며 [targetCount] 개 배치를 목표로 탐색합니다.
  ///
  /// 단어 스킵은 while 루프로 처리해 pool 크기만큼 재귀 깊이가 늘지 않게 합니다.
  /// 성공하면 true, 더 이상 진행할 수 없으면 false 를 반환합니다.
  bool _solve(List<WordModel> pool, int targetCount, int poolIdx) {
    while (poolIdx < pool.length) {
      if (_placed.length >= targetCount) return true;
      if (_backtrackCount >= _maxTotalBacktracks) return false;

      if (!_abandonedPoolIndices.contains(poolIdx) &&
          _tryPlaceWord(pool, targetCount, poolIdx)) {
        return true;
      }

      // 배치 실패 또는 포기한 단어 → 다음 pool 순번으로 스킵 (재귀 없음)
      poolIdx++;
    }

    return _placed.length >= targetCount;
  }

  /// [poolIdx] 단어를 하나 배치해 보고, 성공 시 재귀적으로 다음 단어를 이어갑니다.
  bool _tryPlaceWord(List<WordModel> pool, int targetCount, int poolIdx) {
    final word = pool[poolIdx];
    final candidates = _findCandidates(word)..shuffle(_rng);

    for (final (r, c, dir) in candidates) {
      if (!_isValid(word, r, c, dir)) continue;

      _apply(word, r, c, dir);
      if (_solve(pool, targetCount, poolIdx + 1)) return true;

      _undoLast();
      _backtrackCount++;

      if (_backtrackCount >= GameConstants.maxBacktrackCount) {
        _abandonedPoolIndices.add(poolIdx);
        _backtrackCount = 0;
        return false;
      }
    }

    return false;
  }

  // ─── 내부 메서드 ─────────────────────────────────────────

  /// 격자·배치 상태·백트래킹 카운터를 초기화합니다.
  void _resetGrid() {
    _grid = List.generate(_rows, (_) => List.filled(_cols, ''));
    _placed.clear();
    _backtrackCount = 0;
    _abandonedPoolIndices.clear();
  }

  /// 첫 단어를 보드 중앙에 가로로 배치합니다.
  void _placeFirstWord(WordModel word) {
    final row = _rows ~/ 2 - 1;
    final col = (_cols - word.syllableCount) ~/ 2;
    if (col >= 0) _apply(word, row, col, Direction.across);
  }

  /// 마지막으로 배치한 단어를 롤백합니다. 교차점은 다른 단어가 쓰는 칸은 유지합니다.
  void _undoLast() {
    if (_placed.isEmpty) return;

    final removed = _placed.removeLast();
    for (final (r, c) in removed.positions) {
      final stillUsed =
          _placed.any((pw) => pw.positions.contains((r, c)));
      if (!stillUsed) _grid[r][c] = '';
    }
  }

  /// 보드에서 [word] 를 배치할 수 있는 후보 위치 목록을 반환합니다.
  List<(int, int, Direction)> _findCandidates(WordModel word) {
    final result = <(int, int, Direction)>{};

    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_grid[r][c].isEmpty) continue;
        final ch = _grid[r][c];

        for (int i = 0; i < word.syllableCount; i++) {
          if (word.word[i] != ch) continue;
          result.add((r, c - i, Direction.across));
          result.add((r - i, c, Direction.down));
        }
      }
    }

    return result.toList();
  }

  /// 주어진 위치·방향으로 [word] 를 배치할 수 있는지 검사합니다.
  bool _isValid(WordModel word, int startRow, int startCol, Direction dir) {
    final len = word.syllableCount;

    if (dir == Direction.across) {
      if (startRow < 0 || startRow >= _rows) return false;
      if (startCol < 0 || startCol + len > _cols) return false;
    } else {
      if (startCol < 0 || startCol >= _cols) return false;
      if (startRow < 0 || startRow + len > _rows) return false;
    }

    if (dir == Direction.across) {
      if (startCol > 0 && _grid[startRow][startCol - 1].isNotEmpty) {
        return false;
      }
      if (startCol + len < _cols &&
          _grid[startRow][startCol + len].isNotEmpty) {
        return false;
      }
    } else {
      if (startRow > 0 && _grid[startRow - 1][startCol].isNotEmpty) {
        return false;
      }
      if (startRow + len < _rows &&
          _grid[startRow + len][startCol].isNotEmpty) {
        return false;
      }
    }

    bool hasIntersection = false;

    for (int i = 0; i < len; i++) {
      final r = dir == Direction.across ? startRow : startRow + i;
      final c = dir == Direction.across ? startCol + i : startCol;
      final expected = word.word[i];

      if (_grid[r][c].isNotEmpty) {
        if (_grid[r][c] != expected) return false;
        if (_hasWordThrough(r, c, dir)) return false;

        final perpDir =
            dir == Direction.across ? Direction.down : Direction.across;
        if (!_hasWordThrough(r, c, perpDir)) return false;

        hasIntersection = true;
      } else {
        if (dir == Direction.across) {
          if (r > 0 && _grid[r - 1][c].isNotEmpty) return false;
          if (r + 1 < _rows && _grid[r + 1][c].isNotEmpty) return false;
        } else {
          if (c > 0 && _grid[r][c - 1].isNotEmpty) return false;
          if (c + 1 < _cols && _grid[r][c + 1].isNotEmpty) return false;
        }
      }
    }

    return hasIntersection;
  }

  /// [row], [col] 을 지나는 [dir] 방향의 단어가 있으면 true 를 반환합니다.
  bool _hasWordThrough(int row, int col, Direction dir) {
    for (final pw in _placed) {
      if (pw.direction != dir) continue;
      if (dir == Direction.across &&
          pw.row == row &&
          col >= pw.col &&
          col < pw.col + pw.length) {
        return true;
      }
      if (dir == Direction.down &&
          pw.col == col &&
          row >= pw.row &&
          row < pw.row + pw.length) {
        return true;
      }
    }
    return false;
  }

  /// 검증을 통과한 단어를 보드에 실제로 기록합니다.
  void _apply(WordModel word, int startRow, int startCol, Direction dir) {
    _placed.add(
      PlacedWord(word: word, row: startRow, col: startCol, direction: dir),
    );
    for (int i = 0; i < word.syllableCount; i++) {
      final r = dir == Direction.across ? startRow : startRow + i;
      final c = dir == Direction.across ? startCol + i : startCol;
      _grid[r][c] = word.word[i];
    }
  }
}
