// 노노그램 퍼즐 데이터 모델 파일 - 서버 JSON과 Dart 객체 사이의 변환을 담당하는 파일
import 'dart:convert';

/// 그리드(격자)의 가로·세로 크기를 나타내는 모델
class GridSize {
  /// 그리드 가로 칸 수
  final int width;

  /// 그리드 세로 칸 수
  final int height;

  const GridSize({required this.width, required this.height});

  /// JSON 맵에서 GridSize 객체 생성
  factory GridSize.fromJson(Map<String, dynamic> json) {
    return GridSize(
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  /// GridSize 객체를 JSON 맵으로 변환
  Map<String, dynamic> toJson() => {'width': width, 'height': height};
}

/// 노노그램 퍼즐 한 개를 나타내는 데이터 모델
///
/// 서버 JSON, 번들 JSON, SQLite 저장 모두 이 모델을 기반으로 합니다.
///
/// 예시 JSON:
/// ```json
/// {
///   "id": 1,
///   "title": "고양이",
///   "gridSize": { "width": 10, "height": 10 },
///   "rowClues": [[2], [1,1], [3]],
///   "colClues": [[1], [2,1], [4]],
///   "solution": [[0,1,1,0,...], ...],
///   "thumbnail": "data:image/jpeg;base64,...",
///   "createdAt": "2026-06-01"
/// }
/// ```
class NonogramPuzzle {
  /// 레벨 고유 번호 (1, 2, 3, ...)
  final int id;

  /// 퍼즐 제목 (완성 시 표시되는 그림 이름)
  final String title;

  /// 그리드 크기 (가로 × 세로)
  final GridSize gridSize;

  /// 각 행(가로줄)의 클루 목록
  /// 예: 2번 행 클루가 [3, 1] 이면 → 연속 3칸, 연속 1칸
  final List<List<int>> rowClues;

  /// 각 열(세로줄)의 클루 목록
  final List<List<int>> colClues;

  /// 정답 이진 배열 (0=빈칸, 1=채움)
  /// [행][열] 순서로 접근: solution[row][col]
  final List<List<int>> solution;

  /// 완성 이미지 썸네일 (Base64 문자열 또는 URL, 없으면 null)
  final String? thumbnail;

  /// 퍼즐 생성 날짜 (예: "2026-06-01")
  final String createdAt;

  const NonogramPuzzle({
    required this.id,
    required this.title,
    required this.gridSize,
    required this.rowClues,
    required this.colClues,
    required this.solution,
    this.thumbnail,
    required this.createdAt,
  });

  // ──────────────────────────────────────────
  // JSON 변환
  // ──────────────────────────────────────────

  /// JSON 맵에서 NonogramPuzzle 객체 생성
  factory NonogramPuzzle.fromJson(Map<String, dynamic> json) {
    return NonogramPuzzle(
      id: json['id'] as int,
      title: json['title'] as String,
      gridSize: GridSize.fromJson(json['gridSize'] as Map<String, dynamic>),
      rowClues: _parseClues(json['rowClues']),
      colClues: _parseClues(json['colClues']),
      solution: _parseSolution(json['solution']),
      thumbnail: json['thumbnail'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  /// JSON 문자열에서 NonogramPuzzle 객체 생성
  factory NonogramPuzzle.fromJsonString(String jsonString) {
    return NonogramPuzzle.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// NonogramPuzzle 객체를 JSON 맵으로 변환
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'gridSize': gridSize.toJson(),
    'rowClues': rowClues,
    'colClues': colClues,
    'solution': solution,
    'thumbnail': thumbnail,
    'createdAt': createdAt,
  };

  /// NonogramPuzzle 객체를 JSON 문자열로 변환
  String toJsonString() => jsonEncode(toJson());

  // ──────────────────────────────────────────
  // 편의 속성
  // ──────────────────────────────────────────

  /// 그리드 가로 칸 수 (열 개수)
  int get width => gridSize.width;

  /// 그리드 세로 칸 수 (행 개수)
  int get height => gridSize.height;

  // ──────────────────────────────────────────
  // 내부 파싱 헬퍼
  // ──────────────────────────────────────────

  /// 클루 배열 파싱 (`List<dynamic>` → `List<List<int>>`)
  static List<List<int>> _parseClues(dynamic raw) {
    final outer = raw as List<dynamic>;
    return outer.map<List<int>>((row) {
      final inner = row as List<dynamic>;
      return inner.map<int>((v) => v as int).toList();
    }).toList();
  }

  /// 정답 배열 파싱 (`List<dynamic>` → `List<List<int>>`)
  static List<List<int>> _parseSolution(dynamic raw) {
    final outer = raw as List<dynamic>;
    return outer.map<List<int>>((row) {
      final inner = row as List<dynamic>;
      return inner.map<int>((v) => v as int).toList();
    }).toList();
  }
}

/// 플레이어의 각 셀 입력 상태를 나타내는 열거형
enum CellState {
  /// 아직 아무것도 입력하지 않은 빈 상태
  empty,

  /// 플레이어가 채운 상태 (검정 칸)
  filled,

  /// 플레이어가 X 표시한 상태 (빈칸 확정)
  marked,
}

/// 플레이어의 게임 진행 상태를 나타내는 모델
///
/// 게임 중 SQLite에 저장되며, 앱 재실행 시 이어서 풀기에 사용됩니다.
class GameProgress {
  /// 플레이 중인 퍼즐의 레벨 ID
  final int puzzleId;

  /// 플레이어 입력 그리드 [행][열] → CellState
  final List<List<CellState>> grid;

  /// 경과 시간 (초 단위)
  final int elapsedSeconds;

  GameProgress({
    required this.puzzleId,
    required this.grid,
    required this.elapsedSeconds,
  });

  /// 빈 진행 상태 생성 (새 게임 시작 시)
  factory GameProgress.empty({
    required int puzzleId,
    required int width,
    required int height,
  }) {
    return GameProgress(
      puzzleId: puzzleId,
      grid: List.generate(
        height,
        (_) => List.filled(width, CellState.empty),
      ),
      elapsedSeconds: 0,
    );
  }

  /// 특정 셀 상태 변경 후 새 GameProgress 반환 (불변 업데이트)
  GameProgress updateCell(int row, int col, CellState state) {
    // 기존 그리드를 복사하여 해당 셀만 변경
    final newGrid = grid
        .map((r) => List<CellState>.from(r))
        .toList();
    newGrid[row][col] = state;

    return GameProgress(
      puzzleId: puzzleId,
      grid: newGrid,
      elapsedSeconds: elapsedSeconds,
    );
  }

  /// 타이머 갱신 후 새 GameProgress 반환
  GameProgress updateTimer(int seconds) {
    return GameProgress(
      puzzleId: puzzleId,
      grid: grid,
      elapsedSeconds: seconds,
    );
  }
}
