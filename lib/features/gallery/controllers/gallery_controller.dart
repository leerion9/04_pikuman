// 갤러리 화면 컨트롤러 - 클리어한 퍼즐 목록과 썸네일을 관리하는 파일
import 'package:get/get.dart';
import '../../../core/database/cleared_dao.dart';
import '../../../core/data/puzzle_repository.dart';

/// 클리어한 퍼즐의 정보를 담는 데이터 클래스
class ClearedPuzzleInfo {
  /// 레벨 ID
  final int id;

  /// 퍼즐 제목
  final String title;

  /// 완성 이미지 썸네일 (Base64 또는 URL, 없으면 null)
  final String? thumbnail;

  /// 클리어 소요 시간 (초)
  final int elapsedSeconds;

  /// 클리어 날짜 문자열
  final String clearedAt;

  const ClearedPuzzleInfo({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.elapsedSeconds,
    required this.clearedAt,
  });
}

/// 갤러리 화면의 상태와 데이터 로드를 관리합니다
class GalleryController extends GetxController {
  /// 클리어한 퍼즐 목록 (갤러리에 표시할 데이터)
  final clearedList = <ClearedPuzzleInfo>[].obs;

  /// 데이터 로딩 중 여부
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadClearedPuzzles();
  }

  /// SQLite cleared 테이블에서 클리어한 퍼즐 목록을 불러옵니다
  Future<void> loadClearedPuzzles() async {
    isLoading.value = true;

    final clearedIds = await ClearedDao.getAllClearedIds();
    final repo = Get.find<PuzzleRepository>();
    final list = <ClearedPuzzleInfo>[];

    for (final id in clearedIds) {
      final puzzle = await repo.getPuzzle(id);
      final record = await ClearedDao.getClearRecord(id);

      list.add(
        ClearedPuzzleInfo(
          id: id,
          title: puzzle?.title ?? '레벨 $id',
          thumbnail: puzzle?.thumbnail,
          elapsedSeconds: record?['elapsedSeconds'] as int? ?? 0,
          clearedAt: record?['clearedAt'] as String? ?? '',
        ),
      );
    }

    clearedList.value = list;
    isLoading.value = false;
  }

  /// 경과 시간(초)을 "분:초" 포맷으로 변환합니다
  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
