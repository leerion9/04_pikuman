// 번들 퍼즐 로더 - assets/data/puzzles/ 폴더의 내장 JSON 파일을 불러오는 파일
import 'package:flutter/services.dart';
import '../engine/nonogram_model.dart';

/// 앱에 내장된 번들 퍼즐(레벨 1~50)을 assets에서 로드하는 유틸리티
///
/// 퍼즐 파일 경로: assets/data/puzzles/puzzle_001.json ~ puzzle_050.json
/// 파일이 없으면 null을 반환하므로 안전하게 사용할 수 있습니다.
class BundleLoader {
  const BundleLoader._(); // 인스턴스 생성 방지

  static const int maxBundleLevel = 50;

  /// 레벨 번호를 파일 경로로 변환합니다 (예: 1 → assets/data/puzzles/puzzle_001.json)
  static String _pathFor(int id) =>
      'assets/data/puzzles/puzzle_${id.toString().padLeft(3, '0')}.json';

  /// 특정 레벨의 번들 퍼즐을 불러옵니다 (없으면 null 반환)
  ///
  /// [id]: 레벨 ID (1~50)
  static Future<NonogramPuzzle?> loadPuzzle(int id) async {
    try {
      final jsonStr = await rootBundle.loadString(_pathFor(id));
      return NonogramPuzzle.fromJsonString(jsonStr);
    } catch (_) {
      // 파일이 없거나 파싱 오류 시 null 반환 (오류 무시)
      return null;
    }
  }

  /// 존재하는 번들 퍼즐 ID 목록을 반환합니다
  ///
  /// assets에 실제 파일이 있는 레벨만 포함됩니다.
  /// 한 번에 최대 maxBundleLevel(50)개까지 확인합니다.
  static Future<List<int>> getAvailableIds() async {
    final ids = <int>[];
    for (var i = 1; i <= maxBundleLevel; i++) {
      try {
        await rootBundle.load(_pathFor(i));
        ids.add(i);
      } catch (_) {
        // 파일 없음 → 이후 레벨도 없다고 가정하여 중단
        break;
      }
    }
    return ids;
  }
}
