// 단어 하나의 데이터를 담는 모델 클래스입니다.

/// word_pool.csv 한 행을 표현하는 데이터 모델.
///
/// - [word]          : 단어 (예: "바나나")
/// - [meaning]       : 단어 뜻 (예: "열대 과일의 일종")
/// - [syllableCount] : 음절(글자) 수 — CSV에 없으므로 word 길이로 자동 계산
class WordModel {
  /// 단어
  final String word;

  /// 단어 뜻
  final String meaning;

  /// 음절(글자) 수 — 퍼즐 배치 필터링에 사용
  final int syllableCount;

  const WordModel({
    required this.word,
    required this.meaning,
    required this.syllableCount,
  });

  /// CSV 한 행(헤더 제외)에서 WordModel 생성.
  ///
  /// 형식: `word,meaning`
  /// meaning 안에 쉼표가 포함될 수 있으므로 첫 번째 쉼표만 분리 지점으로 사용합니다.
  factory WordModel.fromCsvRow(String row) {
    final commaIndex = row.indexOf(',');
    if (commaIndex == -1) {
      // 쉼표가 없는 비정상 행은 빈 뜻으로 처리
      final w = row.trim();
      return WordModel(word: w, meaning: '', syllableCount: w.length);
    }
    final w = row.substring(0, commaIndex).trim();
    // meaning 앞뒤의 따옴표(" ")를 제거
    final m = row.substring(commaIndex + 1).trim().replaceAll('"', '');
    return WordModel(word: w, meaning: m, syllableCount: w.length);
  }

  @override
  String toString() => 'WordModel(word: $word, syllableCount: $syllableCount)';
}
