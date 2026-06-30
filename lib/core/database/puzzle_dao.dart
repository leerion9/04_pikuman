// 퍼즐 DAO - 서버에서 받은 퍼즐 데이터를 SQLite에 저장·조회하는 파일
import 'dart:convert';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../engine/nonogram_model.dart';
import 'database_helper.dart';

/// 서버 다운로드 퍼즐(ID 51~)의 SQLite CRUD를 담당합니다.
///
/// 번들 퍼즐(ID 1~50)은 assets에서 직접 로드하므로 이 DAO를 사용하지 않습니다.
class PuzzleDao {
  const PuzzleDao._(); // 인스턴스 생성 방지

  static Database get _db => Get.find<DatabaseHelper>().db;

  /// 퍼즐을 SQLite에 저장합니다 (이미 있으면 덮어씁니다)
  static Future<void> savePuzzle(NonogramPuzzle puzzle) async {
    await _db.insert(
      'puzzles',
      {'id': puzzle.id, 'data_json': jsonEncode(puzzle.toJson())},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 특정 ID의 퍼즐을 SQLite에서 불러옵니다 (없으면 null 반환)
  static Future<NonogramPuzzle?> getPuzzle(int id) async {
    final rows = await _db.query(
      'puzzles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return NonogramPuzzle.fromJson(
      jsonDecode(rows.first['data_json'] as String) as Map<String, dynamic>,
    );
  }

  /// SQLite에 저장된 모든 퍼즐 ID를 오름차순으로 반환합니다
  static Future<List<int>> getAllIds() async {
    final rows = await _db.query('puzzles', columns: ['id'], orderBy: 'id ASC');
    return rows.map((r) => r['id'] as int).toList();
  }

  /// 특정 ID 퍼즐이 SQLite에 있는지 확인합니다
  static Future<bool> exists(int id) async {
    final rows = await _db.query(
      'puzzles',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
