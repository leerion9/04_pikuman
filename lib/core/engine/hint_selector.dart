// 퍼즐에서 미리 오픈되는 힌트 타일을 선정하는 로직입니다.

import 'dart:math';

import 'puzzle_model.dart';

/// 힌트 타일 선정기.
///
/// 선정 규칙:
///  - 교차점 타일(두 단어가 겹치는 위치)을 우선 선택
///  - 한 단어에서 힌트 타일은 최대 2개까지만 허용
///  - 총 힌트 타일 수는 [hintCount] 를 따름
class HintSelector {
  HintSelector._(); // 인스턴스 생성 불가 — 정적 메서드만 사용

  /// [placedWords] 에서 [hintCount] 개의 힌트 타일을 선정하여 반환합니다.
  ///
  /// [rng] 는 같은 시드로 항상 동일한 결과를 보장하는 난수 생성기입니다.
  static List<HintTile> select(
    List<PlacedWord> placedWords,
    int hintCount,
    Random rng,
  ) {
    if (hintCount <= 0 || placedWords.isEmpty) return const [];

    /// 단어별 힌트 사용 횟수 추적 (단어당 최대 2개 제한)
    final wordHintCount = <PlacedWord, int>{};
    final selected = <HintTile>{};

    // ── 1단계: 교차점 타일 우선 선택 ─────────────────────
    final intersections = _intersectionCells(placedWords).toList()
      ..shuffle(rng);
    _fillHints(
      cells: intersections,
      placedWords: placedWords,
      selected: selected,
      wordHintCount: wordHintCount,
      hintCount: hintCount,
    );

    // ── 2단계: 부족분을 일반 타일로 보충 ─────────────────
    if (selected.length < hintCount) {
      final remaining = _allCells(placedWords)
          .where((t) => !selected.contains(t))
          .toList()
        ..shuffle(rng);
      _fillHints(
        cells: remaining,
        placedWords: placedWords,
        selected: selected,
        wordHintCount: wordHintCount,
        hintCount: hintCount,
      );
    }

    return selected.toList();
  }

  // ─── 내부 헬퍼 ────────────────────────────────────────

  /// 후보 타일 [cells] 에서 규칙을 만족하는 것만 [selected] 에 추가합니다.
  ///
  /// 규칙: 해당 타일에 걸린 모든 단어의 힌트 사용 횟수가 2 미만이어야 함.
  static void _fillHints({
    required List<HintTile> cells,
    required List<PlacedWord> placedWords,
    required Set<HintTile> selected,
    required Map<PlacedWord, int> wordHintCount,
    required int hintCount,
  }) {
    for (final tile in cells) {
      if (selected.length >= hintCount) break;

      final words = _wordsAt(placedWords, tile.row, tile.col);
      // 이 타일에 걸린 모든 단어가 아직 2개 미만의 힌트를 사용 중인지 확인
      if (words.every((w) => (wordHintCount[w] ?? 0) < 2)) {
        selected.add(tile);
        for (final w in words) {
          wordHintCount[w] = (wordHintCount[w] ?? 0) + 1;
        }
      }
    }
  }

  /// 두 개 이상의 단어가 겹치는 교차점 타일 집합을 반환합니다.
  static Set<HintTile> _intersectionCells(List<PlacedWord> words) {
    final count = <HintTile, int>{};
    for (final w in words) {
      for (final (r, c) in w.positions) {
        final tile = HintTile(row: r, col: c);
        count[tile] = (count[tile] ?? 0) + 1;
      }
    }
    return count.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toSet();
  }

  /// 배치된 모든 단어의 타일 집합을 반환합니다 (중복 제거).
  static Set<HintTile> _allCells(List<PlacedWord> words) {
    return {
      for (final w in words)
        for (final (r, c) in w.positions) HintTile(row: r, col: c),
    };
  }

  /// [row], [col] 위치를 포함하는 단어 목록을 반환합니다.
  static List<PlacedWord> _wordsAt(
    List<PlacedWord> words,
    int row,
    int col,
  ) {
    return words.where((w) => w.positions.contains((row, col))).toList();
  }
}
