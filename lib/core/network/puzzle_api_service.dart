// 서버 통신 서비스 - 서버에서 신규 퍼즐 목록을 확인하고 다운로드하는 파일
// ⚠️ 서버 환경 결정 전까지 stub(빈 구현)입니다

import '../engine/nonogram_model.dart';

/// 서버에서 퍼즐 데이터를 가져오는 서비스
///
/// ⚠️ 미결 사항 (README.md 미결 1 참고):
/// 서버 환경(정적 파일 vs REST API)이 확정되면 아래 메서드를 구현해야 합니다.
///
/// 정적 파일 방식 예시:
///   GET https://your-server.com/puzzles/list.json   → 레벨 ID 목록
///   GET https://your-server.com/puzzles/051.json    → 개별 퍼즐 JSON
///
/// REST API 방식 예시:
///   GET https://your-server.com/api/puzzles?from=51 → 퍼즐 목록
class PuzzleApiService {
  const PuzzleApiService._(); // 인스턴스 생성 방지

  /// 서버에서 제공하는 퍼즐 ID 목록을 가져옵니다
  ///
  /// 반환값: 서버에 존재하는 레벨 ID 목록 (현재 stub → 빈 리스트 반환)
  static Future<List<int>> fetchAvailableIds() async {
    // TODO: 서버 환경 확정 후 HTTP 통신 코드 구현
    // 예시:
    // final response = await http.get(Uri.parse('$_baseUrl/list.json'));
    // final data = jsonDecode(response.body) as List;
    // return data.cast<int>();
    return [];
  }

  /// 특정 ID의 퍼즐 데이터를 서버에서 다운로드합니다
  ///
  /// [id]: 다운로드할 퍼즐 레벨 ID
  /// 반환값: 퍼즐 데이터 (현재 stub → null 반환)
  static Future<NonogramPuzzle?> fetchPuzzle(int id) async {
    // TODO: 서버 환경 확정 후 HTTP 통신 코드 구현
    // 예시:
    // final response = await http.get(Uri.parse('$_baseUrl/$id.json'));
    // if (response.statusCode == 200) {
    //   return NonogramPuzzle.fromJsonString(response.body);
    // }
    return null;
  }
}
