// 게임 진행 상태(유저 입력·타이머·힌트 사용 횟수)를 SharedPreferences에 저장하고 불러옵니다.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 앱 종료 또는 백그라운드 진입 후 재진입 시 게임을 이어서 풀 수 있도록
/// 다음 항목을 로컬 저장소에 보존합니다.
///
///   - 저장 중인 레벨 번호
///   - 경과 시간(초)
///   - 유저가 사용한 힌트 횟수
///   - 유저가 입력한 음절 맵 (키: "row,col", 값: 입력 음절)
class SaveService {
  SaveService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLevel   = 'save_level';
  static const _keyElapsed = 'save_elapsed';
  static const _keyHints   = 'save_hints_used';
  static const _keyInputs  = 'save_inputs'; // JSON 문자열로 직렬화된 Map<String,String>

  /// 현재 게임 상태를 로컬에 저장합니다.
  ///
  /// [level]        : 현재 플레이 중인 레벨 번호
  /// [elapsedSeconds]: 경과 시간(초)
  /// [hintsUsed]    : 유저가 사용한 힌트 횟수
  /// [inputs]       : 유저 입력 맵 ("row,col" → 입력 음절)
  Future<void> save({
    required int level,
    required int elapsedSeconds,
    required int hintsUsed,
    required Map<String, String> inputs,
  }) async {
    await _prefs.setInt(_keyLevel, level);
    await _prefs.setInt(_keyElapsed, elapsedSeconds);
    await _prefs.setInt(_keyHints, hintsUsed);
    await _prefs.setString(_keyInputs, jsonEncode(inputs));
  }

  /// 저장된 게임 상태를 불러옵니다.
  ///
  /// [level] 이 저장된 레벨과 다르면 null 을 반환합니다 (다른 레벨 데이터 무시).
  /// 반환 맵의 키: 'elapsed'(int), 'hintsUsed'(int), 'inputs'(Map of String to String)
  Map<String, dynamic>? load(int level) {
    final savedLevel = _prefs.getInt(_keyLevel);
    if (savedLevel != level) return null;

    final inputsJson = _prefs.getString(_keyInputs);
    return {
      'elapsed':    _prefs.getInt(_keyElapsed) ?? 0,
      'hintsUsed':  _prefs.getInt(_keyHints)   ?? 0,
      'inputs': inputsJson != null
          ? Map<String, String>.from(
              (jsonDecode(inputsJson) as Map).map(
                (k, v) => MapEntry(k as String, v as String),
              ),
            )
          : <String, String>{},
    };
  }

  /// 저장된 게임 상태를 삭제합니다.
  /// 레벨 클리어 후 또는 초기화 시 호출합니다.
  Future<void> clear() async {
    await _prefs.remove(_keyLevel);
    await _prefs.remove(_keyElapsed);
    await _prefs.remove(_keyHints);
    await _prefs.remove(_keyInputs);
  }
}
