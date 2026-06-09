// 단어장 화면 컨트롤러: 클리어한 레벨의 단어 목록을 불러와 화면에 제공합니다.

import 'package:get/get.dart';

import '../../../core/services/level_progress_service.dart';
import '../../../core/services/wordbook_service.dart';

/// 단어장의 레벨 하나에 해당하는 데이터 묶음.
/// 화면에서 레벨 번호와 단어 목록을 함께 표시하는 데 사용합니다.
class WordbookEntry {
  /// 레벨 번호
  final int level;

  /// 해당 레벨에서 등장한 단어 목록
  final List<WordEntry> words;

  const WordbookEntry({required this.level, required this.words});
}

/// 단어장 화면 컨트롤러.
///
/// 클리어한 레벨을 최신순(내림차순)으로 나열하고,
/// 각 레벨에서 사용된 단어·뜻을 WordbookService 에서 불러옵니다.
class WordbookController extends GetxController {
  WordbookController(this._progress, this._wordbook);

  final LevelProgressService _progress;
  final WordbookService _wordbook;

  /// 단어장 항목 목록 (최신 레벨이 0번 인덱스)
  final entries = <WordbookEntry>[].obs;

  /// 클리어한 레벨이 하나도 없을 때 true
  bool get isEmpty => entries.isEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadEntries();
  }

  /// 클리어한 레벨의 단어 데이터를 최신순으로 불러옵니다.
  void _loadEntries() {
    final currentLevel = _progress.getCurrentLevel();

    // currentLevel - 1 이 마지막 클리어 레벨. 그 이하는 모두 클리어.
    for (int level = currentLevel - 1; level >= 1; level--) {
      final words = _wordbook.getWordsForLevel(level);
      if (words != null && words.isNotEmpty) {
        entries.add(WordbookEntry(level: level, words: words));
      }
    }
  }

  void goBack() => Get.back();
}
