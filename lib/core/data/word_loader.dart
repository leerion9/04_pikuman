// assets/data/word_pool.csv 를 읽어 WordModel 리스트로 반환하는 로더입니다.

import 'package:flutter/services.dart' show rootBundle;

import 'word_model.dart';

/// word_pool.csv 를 파싱해서 단어 목록을 제공하는 클래스.
///
/// 사용 예:
/// ```dart
/// final words = await WordLoader.load();
/// final threeLetterWords = WordLoader.filterBySyllable(words, 3);
/// ```
class WordLoader {
  WordLoader._(); // 인스턴스 생성 불가 — 정적 메서드만 사용

  /// CSV 파일 경로
  static const _assetPath = 'assets/data/word_pool.csv';

  /// CSV 전체를 읽어 [WordModel] 리스트로 반환합니다.
  ///
  /// - 첫 번째 줄(헤더)은 자동으로 건너뜁니다.
  /// - 빈 줄과 파싱 불가 행은 무시합니다.
  /// - 음절 수가 3~5가 아닌 단어는 제외합니다.
  static Future<List<WordModel>> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final lines = raw.split('\n');
    final result = <WordModel>[];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final model = WordModel.fromCsvRow(line);
        // 게임 규칙: 3~5 음절 단어만 사용
        if (model.syllableCount >= 3 && model.syllableCount <= 5) {
          result.add(model);
        }
      } catch (_) {
        // 파싱 실패 행은 조용히 건너뜀
      }
    }
    return result;
  }

  /// [words] 중에서 [syllable] 음절 수에 해당하는 단어만 필터링합니다.
  static List<WordModel> filterBySyllable(
    List<WordModel> words,
    int syllable,
  ) {
    return words.where((w) => w.syllableCount == syllable).toList();
  }
}
