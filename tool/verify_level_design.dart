// level_design.csv 의 word_count·hint_count 가 실제 퍼즐 생성 결과와 일치하는지 검증합니다.
// Flutter 없이 파일 시스템에서 CSV를 직접 읽습니다.
// 실행: dart run tool/verify_level_design.dart

import 'dart:io';
import 'dart:math';

import '../lib/core/data/level_design_model.dart';
import '../lib/core/data/word_model.dart';
import '../lib/core/engine/hint_selector.dart';
import '../lib/core/engine/puzzle_model.dart';
import '../lib/core/engine/word_placer.dart';

Future<void> main() async {
  final words = _loadWords('assets/data/word_pool.csv');
  final designs = _loadDesigns('assets/data/level_design.csv');

  final wordMismatches = <String>[];
  final hintMismatches = <String>[];

  for (final design in designs) {
    final board = _generate(
      level: design.level,
      wordPool: words,
      design: design,
    );

    final actualWords = board.placedWords.length;
    final actualHints = board.hintTiles.length;

    if (actualWords != design.wordCount) {
      wordMismatches.add(
        'L${design.level}: expected word_count=${design.wordCount}, actual=$actualWords',
      );
    }
    if (actualHints != design.hintCount) {
      hintMismatches.add(
        'L${design.level}: expected hint_count=${design.hintCount}, actual=$actualHints (words=$actualWords)',
      );
    }
  }

  stdout.writeln('=== level_design 검증 (레벨 1~101) ===');
  stdout.writeln('총 레벨: ${designs.length}');
  stdout.writeln('word_count 불일치: ${wordMismatches.length}개');
  stdout.writeln('hint_count 불일치: ${hintMismatches.length}개');
  stdout.writeln('');

  if (wordMismatches.isNotEmpty) {
    stdout.writeln('[word_count 불일치 목록]');
    for (final line in wordMismatches) {
      stdout.writeln('  $line');
    }
    stdout.writeln('');
  }

  if (hintMismatches.isNotEmpty) {
    stdout.writeln('[hint_count 불일치 목록]');
    for (final line in hintMismatches) {
      stdout.writeln('  $line');
    }
  }

  if (wordMismatches.isEmpty && hintMismatches.isEmpty) {
    stdout.writeln('모든 레벨이 CSV 조건과 일치합니다.');
  }
}

PuzzleBoard _generate({
  required int level,
  required List<WordModel> wordPool,
  required LevelDesignModel design,
}) {
  final rng = Random(level);
  final shuffledPool = [...wordPool]..shuffle(rng);
  final placer = WordPlacer(level);
  final placedWords = placer.place(shuffledPool, design.wordCount);
  final hintTiles = HintSelector.select(placedWords, design.hintCount, rng);
  return PuzzleBoard(
    placedWords: placedWords,
    hintTiles: hintTiles,
    grid: placer.grid,
  );
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
