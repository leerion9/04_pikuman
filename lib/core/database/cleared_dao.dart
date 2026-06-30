// 클리어 기록 DAO - 클리어 완료한 레벨 기록을 SQLite에서 관리하는 파일
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// 클리어 완료한 레벨의 기록을 SQLite에 저장·조회하는 DAO
///
/// 갤러리 화면에서 클리어한 퍼즐 목록을 보여줄 때 사용합니다.
class ClearedDao {
  const ClearedDao._(); // 인스턴스 생성 방지

  static Database get _db => Get.find<DatabaseHelper>().db;

  /// 클리어 기록을 저장합니다 (이미 있으면 덮어씁니다)
  ///
  /// [puzzleId]: 클리어한 레벨 ID
  /// [elapsedSeconds]: 클리어에 걸린 시간 (초)
  static Future<void> saveClear(int puzzleId, int elapsedSeconds) async {
    await _db.insert(
      'cleared',
      {
        'puzzle_id': puzzleId,
        'elapsed_seconds': elapsedSeconds,
        'cleared_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 특정 레벨이 클리어되었는지 확인합니다
  static Future<bool> isCleared(int puzzleId) async {
    final rows = await _db.query(
      'cleared',
      columns: ['puzzle_id'],
      where: 'puzzle_id = ?',
      whereArgs: [puzzleId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// 클리어한 모든 레벨 ID 목록을 반환합니다 (오름차순)
  static Future<List<int>> getAllClearedIds() async {
    final rows = await _db.query(
      'cleared',
      columns: ['puzzle_id'],
      orderBy: 'puzzle_id ASC',
    );
    return rows.map((r) => r['puzzle_id'] as int).toList();
  }

  /// 특정 레벨의 클리어 기록을 반환합니다
  ///
  /// 반환값: {'elapsedSeconds': int, 'clearedAt': String} 또는 null
  static Future<Map<String, dynamic>?> getClearRecord(int puzzleId) async {
    final rows = await _db.query(
      'cleared',
      where: 'puzzle_id = ?',
      whereArgs: [puzzleId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return {
      'elapsedSeconds': rows.first['elapsed_seconds'] as int,
      'clearedAt': rows.first['cleared_at'] as String,
    };
  }

  /// 클리어한 레벨 수를 반환합니다
  static Future<int> getClearedCount() async {
    final result = await _db.rawQuery('SELECT COUNT(*) FROM cleared');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
