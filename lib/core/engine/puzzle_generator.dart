// 레벨 번호(시드)를 받아 퍼즐 전체를 생성하는 최상위 진입점입니다.

import 'dart:math';

import '../data/level_design_loader.dart';
import '../data/level_design_model.dart';
import '../data/word_model.dart';
import 'hint_selector.dart';
import 'puzzle_model.dart';
import 'word_placer.dart';

/// 퍼즐 생성기 (최상위 진입점).
///
/// 레벨 번호를 시드로 사용하므로, 같은 레벨 번호를 넣으면
/// 항상 동일한 퍼즐([PuzzleBoard])이 생성됩니다.
///
/// 사용 예:
/// ```dart
/// final words   = await WordLoader.load();
/// final designs = await LevelDesignLoader.load();
///
/// final board = PuzzleGenerator.generate(
///   level: 5,
///   wordPool: words,
///   designs: designs,
/// );
/// ```
class PuzzleGenerator {
  PuzzleGenerator._(); // 인스턴스 생성 불가 — 정적 메서드만 사용

  /// 레벨에 해당하는 [PuzzleBoard] 를 생성하여 반환합니다.
  ///
  /// - [level]    : 레벨 번호 (시드로 사용)
  /// - [wordPool] : 전체 단어 목록 (`WordLoader.load()` 결과)
  /// - [designs]  : 전체 레벨 설계 목록 (`LevelDesignLoader.load()` 결과)
  static PuzzleBoard generate({
    required int level,
    required List<WordModel> wordPool,
    required List<LevelDesignModel> designs,
  }) {
    // 레벨 설계 정보 조회 (102 이상이면 101 고정 난이도 자동 적용)
    final design = LevelDesignLoader.getByLevel(designs, level);

    // 레벨 번호를 시드로 사용하는 난수 생성기
    final rng = Random(level);

    // 단어 풀을 시드로 셔플 (같은 레벨 = 항상 동일한 순서)
    final shuffledPool = [...wordPool]..shuffle(rng);

    // 단어 배치 (WordPlacer 내부도 동일 시드 사용)
    final placer = WordPlacer(level);
    final placedWords = placer.place(shuffledPool, design.wordCount);

    // 힌트 타일 선정 (rng 는 셔플 이후 상태 그대로 이어서 사용 → 결정론적)
    final hintTiles = HintSelector.select(placedWords, design.hintCount, rng);

    return PuzzleBoard(
      placedWords: placedWords,
      hintTiles: hintTiles,
      grid: placer.grid,
    );
  }
}
