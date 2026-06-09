// 레벨 진행 서비스: 현재 레벨 번호를 SharedPreferences에 저장합니다.

import 'package:shared_preferences/shared_preferences.dart';

/// 다음에 플레이할 레벨 번호를 로컬에 저장하고 불러오는 서비스.
class LevelProgressService {
  LevelProgressService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyCurrentLevel = 'current_level';

  /// 저장된 레벨을 반환합니다. (없으면 1)
  int getCurrentLevel() {
    return _prefs.getInt(_keyCurrentLevel) ?? 1;
  }

  /// 레벨을 저장합니다. (최소 1)
  Future<void> setCurrentLevel(int level) async {
    await _prefs.setInt(_keyCurrentLevel, level < 1 ? 1 : level);
  }

  /// 레벨 진행을 1로 초기화합니다.
  Future<void> reset() async {
    await _prefs.setInt(_keyCurrentLevel, 1);
  }
}
