// word_count는 충족하지만 hint_count만 부족한 레벨을 별도 분석합니다.
// 실행: dart run tool/analyze_hint_limits.dart

import 'dart:io';
import 'dart:math';

import '../lib/core/data/level_design_model.dart';
import '../lib/core/data/word_model.dart';
import '../lib/core/engine/hint_selector.dart';
import '../lib/core/engine/puzzle_model.dart';
import '../lib/core/engine/word_placer.dart';

void main() {
  final words = _loadWords('assets/data/word_pool.csv');
  final designs = _loadDesigns('assets/data/level_design.csv');

  stdout.writeln('=== hint_count 불일치 상세 분석 ===\n');

  for (final design in designs) {
    final rng = Random(design.level);
    final shuffledPool = [...words]..shuffle(rng);
    final placer = WordPlacer(design.level);
    final placedWords = placer.place(shuffledPool, design.wordCount);
    final hintTiles = HintSelector.select(placedWords, design.hintCount, rng);

    final actualWords = placedWords.length;
    final actualHints = hintTiles.length;
    final maxPossibleHints = _maxPossibleHints(placedWords);

    if (actualHints != design.hintCount) {
      stdout.writeln('L${design.level}:');
      stdout.writeln('  CSV → word_count=${design.wordCount}, hint_count=${design.hintCount}');
      stdout.writeln('  실제 → words=$actualWords, hints=$actualHints');
      stdout.writeln('  이론상 최대 힌트(단어당 2개 제한): $maxPossibleHints');
      if (actualWords != design.wordCount) {
        stdout.writeln('  원인: word_count 미달 → 배치 실패로 단어 수 부족');
      } else if (design.hintCount > maxPossibleHints) {
        stdout.writeln('  원인: CSV hint_count가 단어당 최대 2개 규칙으로 가능한 상한($maxPossibleHints)을 초과');
      } else {
        stdout.writeln('  원인: word_count는 충족, 그러나 힌트 선정 제약(교차점·단어당 2개)으로 목표치 미달');
      }
      stdout.writeln('');
    }
  }
}

int _maxPossibleHints(List<PlacedWord> placedWords) {
  final allCells = <HintTile>{};
  for (final w in placedWords) {
    for (final (r, c) in w.positions) {
      allCells.add(HintTile(row: r, col: c));
    }
  }

  final wordHintCount = <PlacedWord, int>{};
  var count = 0;

  for (final tile in allCells) {
    final wordsAt = placedWords
        .where((w) => w.positions.contains((tile.row, tile.col)))
        .toList();
    if (wordsAt.every((w) => (wordHintCount[w] ?? 0) < 2)) {
      count++;
      for (final w in wordsAt) {
        wordHintCount[w] = (wordHintCount[w] ?? 0) + 1;
      }
    }
  }
  return count;
}

List<WordModel> _loadWords(String path) {
  final lines = File(path).readAsLinesSync();
  final result = <WordModel>[];
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    try {
      final model = WordModel.fromCsvRow(line);
      if (model.syllableCount >= 3 && model.syllableCount <= 5) {
        result.add(model);
      }
    } catch (_) {}
  }
  return result;
}

List<LevelDesignModel> _loadDesigns(String path) {
  final lines = File(path).readAsLinesSync();
  final result = <LevelDesignModel>[];
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    try {
      result.add(LevelDesignModel.fromCsvRow(line));
    } catch (_) {}
  }
  return result;
}
