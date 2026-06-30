// 퍼즐 리포지토리 - 번들(assets)과 SQLite(서버 다운로드) 퍼즐을 통합 관리하는 파일
import 'package:get/get.dart';
import '../engine/nonogram_model.dart';
import '../database/puzzle_dao.dart';
import 'bundle_loader.dart';

/// 퍼즐 데이터에 접근하는 통합 창구 (GetxService)
///
/// 레벨 1~50  → assets/data/puzzles/ 에서 직접 로드 (BundleLoader)
/// 레벨 51~   → SQLite에서 로드 (서버에서 다운로드한 데이터, PuzzleDao)
///
/// 모든 화면은 이 리포지토리를 통해 퍼즐을 가져옵니다.
class PuzzleRepository extends GetxService {
  /// 특정 레벨 ID의 퍼즐을 가져옵니다 (없으면 null 반환)
  ///
  /// [id]: 레벨 ID (1 이상)
  Future<NonogramPuzzle?> getPuzzle(int id) async {
    if (id <= BundleLoader.maxBundleLevel) {
      return BundleLoader.loadPuzzle(id);
    }
    return PuzzleDao.getPuzzle(id);
  }

  /// 현재 사용 가능한 모든 레벨 ID 목록을 반환합니다 (오름차순)
  ///
  /// 번들 퍼즐 + SQLite에 저장된 서버 퍼즐을 합쳐서 반환합니다.
  Future<List<int>> getAvailableIds() async {
    final bundleIds = await BundleLoader.getAvailableIds();
    final serverIds = await PuzzleDao.getAllIds();
    // 중복 제거 후 정렬
    final all = {...bundleIds, ...serverIds}.toList()..sort();
    return all;
  }

  /// 현재 플레이 가능한 가장 낮은 레벨 ID를 반환합니다
  ///
  /// 사용 가능한 레벨이 없으면 null 반환
  Future<int?> getFirstAvailableId() async {
    final ids = await getAvailableIds();
    return ids.isEmpty ? null : ids.first;
  }

  /// 특정 레벨 다음 레벨 ID를 반환합니다 (없으면 null)
  ///
  /// [currentId]: 현재 레벨 ID
  Future<int?> getNextId(int currentId) async {
    final ids = await getAvailableIds();
    final idx = ids.indexOf(currentId);
    if (idx < 0 || idx >= ids.length - 1) return null;
    return ids[idx + 1];
  }

  /// 서버에서 다운로드한 퍼즐을 SQLite에 저장합니다
  ///
  /// [puzzle]: 저장할 퍼즐 (ID 51 이상)
  Future<void> saveServerPuzzle(NonogramPuzzle puzzle) async {
    await PuzzleDao.savePuzzle(puzzle);
  }
}
