// 앱 내 모든 한국어 문자열을 한 곳에 모아 둔 번역 파일입니다.

import 'package:get/get.dart';

/// GetX 번역 클래스 - 한국어 전용
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ko': _ko,
      };

  static const Map<String, String> _ko = {
    'appTitle': 'pikuman3 : word puzzle',
    'home': '홈',
    'play': '플레이',
    'playAgain': '다시 하기',
    'back': '뒤로',
    'currentLevel': '현재 레벨 : @level',
    'wordbook': '단어장',
    'level': 'Level @level',
    'hint': '힌트',
    'hintRemaining': '힌트 @count',
    'hintNoneSelected': '빈 칸을 먼저 선택하세요.',
    'hintEmpty': '힌트를 사용할 수 없습니다.',
    'levelClear': 'Level @level 클리어!',
    'clearTime': '완료 시간 : @time',
    'wordsUsed': '이번 레벨 단어',
    'nextLevel': '다음 레벨',
    'wordbookTitle': '단어장',
    'wordbookEmpty': '아직 클리어한 레벨이 없습니다.',
    'wordbookLevelLabel': 'Level @level',
    'settingsTitle': '설정',
    'sectionSound': '사운드',
    'sfxTitle': '효과음',
    'bgmTitle': '배경 음악',
    'sectionVibration': '진동',
    'vibrationTitle': '진동 (햅틱)',
    'sectionRating': '평점',
    'ratingTitle': '앱 평가하기',
    'bannerAdPlaceholder': '광고 영역',
    'completionTitle': '🎉 모든 레벨 클리어!',
    'completionMessage': '101개 레벨을 모두 완료했습니다!\n앞으로도 계속 도전해 보세요.',
  };
}
