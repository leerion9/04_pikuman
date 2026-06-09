// 게임 전역 상수: 레벨 수, 퍼즐 크기, 힌트 개수 등 게임 규칙 숫자를 한 곳에 모아 둡니다.

/// 게임에서 사용하는 변경되지 않는 숫자 상수 모음.
class GameConstants {
  GameConstants._();

  /// level_design.csv 에 정의된 최대 레벨 (101레벨까지 고유 난이도)
  static const int maxDefinedLevel = 101;

  /// 102레벨 이후 word_count 고정값
  static const int infiniteLevelWordCount = 11;

  /// 102레벨 이후 hint_count 고정값
  static const int infiniteLevelHintCount = 11;

  /// 크로스워드 판의 가로 칸 수
  static const int gridCols = 10;

  /// 크로스워드 판의 세로 칸 수
  static const int gridRows = 12;

  /// 사용 가능한 최소 음절 수
  static const int minSyllables = 3;

  /// 사용 가능한 최대 음절 수
  static const int maxSyllables = 5;

  /// 플레이어가 판당 사용할 수 있는 유저 힌트 횟수
  static const int maxUserHintsPerLevel = 2;

  /// 퍼즐 생성 시 단어 하나에서 미리 오픈될 수 있는 힌트 타일 최대 개수
  static const int maxHintTilesPerWord = 2;

  /// 백트래킹 최대 시도 횟수 (초과 시 단어 교체)
  static const int maxBacktrackCount = 500;

  /// 전면 광고 표시 주기 (N레벨 클리어마다)
  static const int interstitialAdInterval = 10;
}
