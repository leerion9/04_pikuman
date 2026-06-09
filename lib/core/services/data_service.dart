// 앱 전체에서 공유하는 단어 풀·레벨 설계 데이터를 한 번만 로드해 캐시합니다.

import 'package:get/get.dart';

import '../data/level_design_loader.dart';
import '../data/level_design_model.dart';
import '../data/word_loader.dart';
import '../data/word_model.dart';

/// CSV 데이터를 앱 시작 시 한 번만 읽어 메모리에 보관하는 서비스.
///
/// SplashPage 의 Stage 2(로딩 화면)에서 [load] 를 호출합니다.
/// 이후 GameController 등에서 [wordPool] / [levelDesigns] 를 바로 사용합니다.
class DataService extends GetxService {
  List<WordModel> _wordPool = const [];
  List<LevelDesignModel> _levelDesigns = const [];
  bool _loaded = false;

  /// 3~5 음절 단어 목록 (word_pool.csv 파싱 결과)
  List<WordModel> get wordPool => _wordPool;

  /// 레벨별 설계 목록 (level_design.csv 파싱 결과)
  List<LevelDesignModel> get levelDesigns => _levelDesigns;

  /// 데이터 로딩이 완료되었으면 true
  bool get isLoaded => _loaded;

  /// CSV 파일 두 개를 비동기로 읽어 캐시합니다.
  ///
  /// 이미 로드된 상태라면 즉시 반환합니다 (중복 로드 방지).
  Future<void> load() async {
    if (_loaded) return;
    final results = await Future.wait([
      WordLoader.load(),
      LevelDesignLoader.load(),
    ]);
    _wordPool = results[0] as List<WordModel>;
    _levelDesigns = results[1] as List<LevelDesignModel>;
    _loaded = true;
  }
}
