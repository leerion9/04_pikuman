// 단어장 서비스: 클리어한 레벨의 단어·뜻 목록을 SharedPreferences에 저장하고 불러옵니다.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 단어장 항목 하나 (단어 + 뜻)
class WordEntry {
  /// 단어 문자열 (예: '오스트레일리아')
  final String word;

  /// 단어 뜻 풀이
  final String meaning;

  const WordEntry({required this.word, required this.meaning});

  /// JSON 맵으로 변환합니다.
  Map<String, String> toJson() => {'word': word, 'meaning': meaning};

  /// JSON 맵에서 WordEntry 를 생성합니다.
  factory WordEntry.fromJson(Map<String, dynamic> json) => WordEntry(
        word:    json['word']    as String,
        meaning: json['meaning'] as String,
      );
}

/// 레벨 클리어 시 해당 레벨의 단어 목록을 로컬에 저장하고,
/// 단어장 화면에서 과거 레벨별 단어를 불러오는 서비스.
class WordbookService {
  WordbookService(this._prefs);

  final SharedPreferences _prefs;

  /// SharedPreferences 키 접두사 (예: 'wordbook_level_3')
  static const _prefix = 'wordbook_level_';

  /// [level] 레벨에서 사용된 단어 목록을 로컬에 저장합니다.
  /// 중복 단어는 자동으로 제거됩니다.
  Future<void> saveLevel(int level, List<WordEntry> words) async {
    // 같은 단어를 한 번만 저장 (교차점으로 중복 등장할 수 있음)
    final seen   = <String>{};
    final unique = words.where((w) => seen.add(w.word)).toList();
    final data   = unique.map((w) => w.toJson()).toList();
    await _prefs.setString('$_prefix$level', jsonEncode(data));
  }

  /// [level] 레벨의 단어 목록을 불러옵니다.
  /// 저장된 데이터가 없으면 null 을 반환합니다.
  List<WordEntry>? getWordsForLevel(int level) {
    final raw = _prefs.getString('$_prefix$level');
    if (raw == null) return null;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(WordEntry.fromJson).toList();
  }
}
