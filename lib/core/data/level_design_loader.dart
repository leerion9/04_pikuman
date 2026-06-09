// assets/data/level_design.csv 를 읽어 LevelDesignModel 리스트로 반환하는 로더입니다.

import 'package:flutter/services.dart' show rootBundle;

import 'level_design_model.dart';

/// level_design.csv 를 파싱해서 레벨 설계 목록을 제공하는 클래스.
///
/// 102 레벨 이상은 CSV에 없으므로 [getByLevel] 이 자동으로 101 레벨과
/// 동일한 설계값(word_count=11, hint_count=11)을 반환합니다.
///
/// 사용 예:
/// ```dart
/// final designs = await LevelDesignLoader.load();
/// final design = LevelDesignLoader.getByLevel(designs, 5);
/// ```
class LevelDesignLoader {
  LevelDesignLoader._(); // 인스턴스 생성 불가 — 정적 메서드만 사용

  /// CSV 파일 경로
  static const _assetPath = 'assets/data/level_design.csv';

  /// 102 레벨 이상에 적용되는 고정 난이도 (101 레벨과 동일)
  static const _maxLevelDesign = LevelDesignModel(
    level: 101,
    wordCount: 11,
    hintCount: 11,
  );

  /// CSV 전체를 읽어 [LevelDesignModel] 리스트로 반환합니다.
  ///
  /// - 첫 번째 줄(헤더)은 자동으로 건너뜁니다.
  /// - 빈 줄과 파싱 불가 행은 무시합니다.
  static Future<List<LevelDesignModel>> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final lines = raw.split('\n');
    final result = <LevelDesignModel>[];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        result.add(LevelDesignModel.fromCsvRow(line));
      } catch (_) {
        // 파싱 실패 행은 조용히 건너뜀
      }
    }
    return result;
  }

  /// [designs] 목록에서 [level] 번호에 맞는 설계 정보를 반환합니다.
  ///
  /// - 102 레벨 이상이면 101 레벨과 동일한 고정 난이도를 반환합니다.
  /// - 해당 레벨이 목록에 없으면 [_maxLevelDesign] 을 반환합니다.
  static LevelDesignModel getByLevel(
    List<LevelDesignModel> designs,
    int level,
  ) {
    // 102 이상은 101 레벨 고정 난이도
    final targetLevel = level > 101 ? 101 : level;

    return designs.firstWhere(
      (d) => d.level == targetLevel,
      orElse: () => _maxLevelDesign,
    );
  }
}
