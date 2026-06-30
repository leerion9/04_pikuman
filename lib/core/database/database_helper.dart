// SQLite 데이터베이스 헬퍼 - 앱의 로컬 DB를 초기화하고 테이블을 생성하는 파일
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// SQLite 데이터베이스를 초기화하고 관리하는 전역 서비스
///
/// 앱 전체에서 `Get.find<DatabaseHelper>()`로 DB 인스턴스에 접근합니다.
///
/// 관리 테이블:
/// - puzzles  : 서버에서 다운로드한 퍼즐 데이터 (ID 51 이상)
/// - progress : 현재 진행 중인 퍼즐의 입력 상태 (이어하기)
/// - cleared  : 클리어 완료한 레벨 기록 (갤러리·통계)
class DatabaseHelper extends GetxService {
  static const _dbName = 'pikuman4.db';
  static const _dbVersion = 1;

  Database? _db;

  /// SQLite DB 인스턴스 (init() 호출 후 사용 가능)
  Database get db {
    assert(_db != null, 'DatabaseHelper.init()을 먼저 호출해야 합니다.');
    return _db!;
  }

  /// DB 파일을 열고 테이블을 생성합니다 (앱 시작 시 한 번 호출)
  Future<DatabaseHelper> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
    return this;
  }

  /// DB 최초 생성 시 테이블을 만듭니다
  Future<void> _onCreate(Database db, int version) async {
    // 서버에서 다운로드한 퍼즐 JSON을 통째로 보관 (번들 퍼즐은 assets에서 직접 로드)
    await db.execute('''
      CREATE TABLE puzzles (
        id       INTEGER PRIMARY KEY,
        data_json TEXT NOT NULL
      )
    ''');

    // 현재 진행 중인 퍼즐 상태 (이어하기)
    await db.execute('''
      CREATE TABLE progress (
        puzzle_id        INTEGER PRIMARY KEY,
        grid_state_json  TEXT NOT NULL,
        elapsed_seconds  INTEGER NOT NULL DEFAULT 0,
        updated_at       TEXT NOT NULL
      )
    ''');

    // 클리어 완료 기록 (갤러리·통계)
    await db.execute('''
      CREATE TABLE cleared (
        puzzle_id       INTEGER PRIMARY KEY,
        elapsed_seconds INTEGER NOT NULL,
        cleared_at      TEXT NOT NULL
      )
    ''');
  }

  @override
  void onClose() {
    _db?.close();
    super.onClose();
  }
}
