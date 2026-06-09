// 레벨 하나의 설계 정보를 담는 모델 클래스입니다.

/// level_design.csv 한 행을 표현하는 데이터 모델.
///
/// - [level]      : 레벨 번호 (1~101, 102 이상은 101과 동일 난이도 적용)
/// - [wordCount]  : 해당 레벨에 배치할 단어 수
/// - [hintCount]  : 미리 오픈되는 힌트 타일 총 개수
class LevelDesignModel {
  /// 레벨 번호
  final int level;

  /// 배치할 단어 수
  final int wordCount;

  /// 미리 오픈되는 힌트 타일 수
  final int hintCount;

  const LevelDesignModel({
    required this.level,
    required this.wordCount,
    required this.hintCount,
  });

  /// CSV 한 행(헤더 제외)에서 LevelDesignModel 생성.
  ///
  /// 형식: `level,word_count,hint_count`
  factory LevelDesignModel.fromCsvRow(String row) {
    final parts = row.trim().split(',');
    return LevelDesignModel(
      level: int.parse(parts[0].trim()),
      wordCount: int.parse(parts[1].trim()),
      hintCount: int.parse(parts[2].trim()),
    );
  }

  @override
  String toString() =>
      'LevelDesignModel(level: $level, wordCount: $wordCount, hintCount: $hintCount)';
}
