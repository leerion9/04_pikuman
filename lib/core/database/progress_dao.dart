// 진행 상태 DAO - 게임 중간 저장(이어하기)을 SQLite에서 관리하는 파일
import 'dart:convert';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../engine/nonogram_model.dart';
import 'database_helper.dart';

/// 플레이어의 게임 진행 상태를 SQLite에 저장·불러오는 DAO
///
/// 앱 종료 후 재실행해도 중간에 멈춘 곳에서 이어서 풀 수 있게 합니다.
class ProgressDao {
  const ProgressDao._(); // 인스턴스 생성 방지

  static Database get _db => Get.find<DatabaseHelper>().db;

  /// 현재 진행 상태를 저장합니다 (이미 있으면 덮어씁니다)
  ///
  /// [progress]: 저장할 게임 진행 상태 (그리드 입력값 + 경과 시간)
  static Future<void> saveProgress(GameProgress progress) async {
    // 그리드 상태를 JSON 문자열로 변환
    // CellState enum → 숫자 (empty=0, filled=1, marked=2)
    final gridJson = jsonEncode(
      progress.grid
          .map(
            (row) => row.map((cell) {
              switch (cell) {
                case CellState.empty:
                  return 0;
                case CellState.filled:
                  return 1;
                case CellState.marked:
                  return 2;
              }
            }).toList(),
          )
          .toList(),
    );

    await _db.insert(
      'progress',
      {
        'puzzle_id': progress.puzzleId,
        'grid_state_json': gridJson,
        'elapsed_seconds': progress.elapsedSeconds,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 특정 퍼즐의 저장된 진행 상태를 불러옵니다 (없으면 null 반환)
  ///
  /// [puzzleId]: 불러올 퍼즐의 레벨 ID
  /// [width], [height]: 그리드 크기 (JSON 파싱 시 필요)
  static Future<GameProgress?> loadProgress(
    int puzzleId, {
    required int width,
    required int height,
  }) async {
    final rows = await _db.query(
      'progress',
      where: 'puzzle_id = ?',
      whereArgs: [puzzleId],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final rawGrid =
        jsonDecode(row['grid_state_json'] as String) as List<dynamic>;

    // 숫자 → CellState enum 복원
    final grid = rawGrid.map<List<CellState>>((rowData) {
      final cells = rowData as List<dynamic>;
      return cells.map<CellState>((v) {
        switch (v as int) {
          case 1:
            return CellState.filled;
          case 2:
            return CellState.marked;
          default:
            return CellState.empty;
        }
      }).toList();
    }).toList();

    return GameProgress(
      puzzleId: puzzleId,
      grid: grid,
      elapsedSeconds: row['elapsed_seconds'] as int,
    );
  }

  /// 특정 퍼즐의 진행 상태를 삭제합니다 (클리어 후 정리)
  static Future<void> deleteProgress(int puzzleId) async {
    await _db.delete('progress', where: 'puzzle_id = ?', whereArgs: [puzzleId]);
  }
}
